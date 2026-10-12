#!/usr/bin/env python3
"""Solve and certify a frozen PropertyRandomizer moment LP package.

This module intentionally knows nothing about Factorio graph construction.  It
consumes the numerical package written by solve_staged_growth_lower_bound_v33.py
with --save-lp-dir --build-only:

    A-ub.npz, b-ub.npy, bounds-original.npy, column-scale.npy,
    lp-metadata.json, solver-package.json

The numerical workflow is:
  1. exact positive diagonal column scaling + row equilibration;
  2. direct HiGHS-IPM feasibility solve (highspy preferred, SciPy fallback);
  3. independent original-LP validation of any feasible candidate;
  4. lazy separation of the continuous recipe-tail capacity family;
  5. on an IPM infeasible status, solve a separate box-aware Farkas-search LP;
  6. accept infeasibility only after an exact Fraction-based check against the
     original unscaled float64 LP.

An IPM status by itself is never a proof of infeasibility.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import time
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Iterable, Sequence

import numpy as np
from scipy.optimize import linprog
from scipy.sparse import (
    coo_matrix,
    csr_matrix,
    diags,
    load_npz,
    save_npz,
    vstack,
)


SCHEMA = "propertyrandomizer-standalone-moment-lp-solver-v1"
PACKAGE_SCHEMA = "propertyrandomizer-saved-moment-lp-v1"


def _json_safe(value: Any) -> Any:
    if isinstance(value, dict):
        return {str(k): _json_safe(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [_json_safe(v) for v in value]
    if isinstance(value, Path):
        return str(value)
    if isinstance(value, np.ndarray):
        return value.tolist()
    if isinstance(value, (np.integer,)):
        return int(value)
    if isinstance(value, (np.floating,)):
        f = float(value)
        return f if math.isfinite(f) else str(f)
    return value


def _bounds_from_array(arr: np.ndarray) -> list[tuple[float | None, float | None]]:
    arr = np.asarray(arr, dtype=float)
    if arr.ndim != 2 or arr.shape[1] != 2:
        raise ValueError(f"bounds array must have shape (n,2), got {arr.shape}")
    out: list[tuple[float | None, float | None]] = []
    for lo, hi in arr:
        out.append((
            None if np.isnan(lo) else float(lo),
            None if np.isnan(hi) else float(hi),
        ))
    return out


def _bounds_array(bounds: Sequence[tuple[float | None, float | None]]) -> np.ndarray:
    arr = np.full((len(bounds), 2), np.nan, dtype=float)
    for j, (lo, hi) in enumerate(bounds):
        if lo is not None:
            arr[j, 0] = float(lo)
        if hi is not None:
            arr[j, 1] = float(hi)
    return arr


def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            chunk = f.read(1 << 20)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def _max_abs_by_axis(A: csr_matrix, axis: int) -> np.ndarray:
    if A.shape[axis] == 0:
        return np.zeros(A.shape[1 - axis], dtype=float)
    B = abs(A)
    got = B.max(axis=axis)
    if hasattr(got, "toarray"):
        got = got.toarray()
    return np.asarray(got, dtype=float).reshape(-1)


def _scale_lp(
    A: csr_matrix,
    b: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    column_scale: np.ndarray,
) -> tuple[
    csr_matrix,
    np.ndarray,
    list[tuple[float | None, float | None]],
    np.ndarray,
]:
    """Use the builder's exact variable units, then independently row-equilibrate."""
    A = A.tocsr()
    b = np.asarray(b, dtype=float).reshape(-1)
    D = np.asarray(column_scale, dtype=float).reshape(-1)
    if A.shape[0] != b.size or A.shape[1] != D.size or A.shape[1] != len(bounds):
        raise ValueError("LP/scaling dimension mismatch")
    if np.any(~np.isfinite(D)) or np.any(D <= 0.0):
        raise ValueError("column-scale.npy must contain finite positive entries")

    As = (A @ diags(D, format="csr")).tocsr()
    row_max = _max_abs_by_axis(As, axis=1)
    denom = np.maximum(row_max, np.abs(b))
    row_scale = np.ones_like(denom)
    mask = np.isfinite(denom) & (denom > 0.0)
    row_scale[mask] = 1.0 / denom[mask]
    row_scale = np.clip(row_scale, 1e-12, 1e12)
    As = (diags(row_scale, format="csr") @ As).tocsr()
    bs = b * row_scale

    scaled_bounds: list[tuple[float | None, float | None]] = []
    for j, (lo, hi) in enumerate(bounds):
        d = float(D[j])
        scaled_bounds.append((
            None if lo is None else float(lo) / d,
            None if hi is None else float(hi) / d,
        ))
    return As, bs, scaled_bounds, row_scale


def _scaled_matrix_diagnostics(A: csr_matrix) -> dict[str, Any]:
    vals = np.abs(A.data)
    vals = vals[vals > 0.0]
    if vals.size:
        lo, hi = float(np.min(vals)), float(np.max(vals))
    else:
        lo = hi = None

    def dr(axis: int) -> dict[str, Any]:
        M = A.tocsr() if axis == 1 else A.tocsc()
        ratios: list[float] = []
        count = M.shape[0] if axis == 1 else M.shape[1]
        for i in range(count):
            p0, p1 = int(M.indptr[i]), int(M.indptr[i + 1])
            av = np.abs(M.data[p0:p1])
            av = av[av > 0.0]
            if av.size:
                ratios.append(float(np.max(av) / np.min(av)))
        if not ratios:
            return {"count": 0}
        q = np.asarray(ratios, dtype=float)
        return {
            "count": int(q.size),
            "p50": float(np.quantile(q, 0.50)),
            "p90": float(np.quantile(q, 0.90)),
            "p99": float(np.quantile(q, 0.99)),
            "max": float(np.max(q)),
        }

    return {
        "abs_coefficient_range": [lo, hi],
        "row_dynamic_range": dr(1),
        "column_dynamic_range": dr(0),
        "coefficients_le_1e12": int(np.count_nonzero(vals <= 1e-12)) if vals.size else 0,
    }


def _highspy_status_ok(status: Any) -> bool:
    text = str(status).strip().lower().replace("_", "")
    return text.endswith("kok") or text == "ok" or "highsstatus.kok" in text


def _reset_highspy_scheduler(highspy_module: Any) -> dict[str, Any]:
    meta: dict[str, Any] = {"attempted": False, "ok": False}
    try:
        reset = getattr(getattr(highspy_module, "Highs", None), "resetGlobalScheduler", None)
        if reset is None:
            meta["reason"] = "Highs.resetGlobalScheduler unavailable"
            return meta
        meta["attempted"] = True
        reset(True)
        meta["ok"] = True
    except Exception as exc:
        meta["reason"] = f"{type(exc).__name__}: {exc}"
    return meta


def _configure_highspy(
    h: Any,
    *,
    seed: int,
    time_limit: float | None,
    solver_log: bool,
    feasibility_tolerance: float,
) -> tuple[dict[str, str], list[str]]:
    statuses: dict[str, str] = {}
    required_failures: list[str] = []
    opts: list[tuple[str, Any, bool]] = [
        ("output_flag", bool(solver_log), False),
        ("presolve", "on", True),
        ("solver", "ipm", True),
        ("run_crossover", "off", False),
        ("parallel", "off", False),
        ("threads", 1, False),
        ("random_seed", int(seed % 2147483647), False),
        ("small_matrix_value", 1e-12, True),
        ("primal_feasibility_tolerance", float(feasibility_tolerance), False),
        ("dual_feasibility_tolerance", float(feasibility_tolerance), False),
        ("ipm_optimality_tolerance", float(feasibility_tolerance), False),
    ]
    if time_limit is not None and time_limit > 0.0:
        opts.append(("time_limit", float(time_limit), False))
    for name, value, required in opts:
        try:
            st = h.setOptionValue(name, value)
            statuses[name] = str(st)
            if required and not _highspy_status_ok(st):
                required_failures.append(f"{name}={st}")
        except Exception as exc:
            statuses[name] = f"EXCEPTION {type(exc).__name__}: {exc}"
            if required:
                required_failures.append(f"{name}=exception")
    return statuses, required_failures


def _highspy_solve_rows(
    *,
    A: csr_matrix,
    row_lower: np.ndarray,
    row_upper: np.ndarray,
    c: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    seed: int,
    time_limit: float | None,
    solver_log: bool,
    feasibility_tolerance: float,
) -> tuple[dict[str, Any], np.ndarray | None]:
    import highspy  # type: ignore

    A = A.tocsr()
    m, n = A.shape
    inf = float(getattr(highspy, "kHighsInf", 1e30))
    lp = highspy.HighsLp()
    lp.num_col_ = int(n)
    lp.num_row_ = int(m)
    lp.col_cost_ = np.asarray(c, dtype=np.double)
    lo = np.empty(n, dtype=np.double)
    hi = np.empty(n, dtype=np.double)
    for j, (lb, ub) in enumerate(bounds):
        lo[j] = -inf if lb is None or not math.isfinite(float(lb)) else float(lb)
        hi[j] = inf if ub is None or not math.isfinite(float(ub)) else float(ub)
    lp.col_lower_ = lo
    lp.col_upper_ = hi
    lp.row_lower_ = np.asarray(row_lower, dtype=np.double)
    lp.row_upper_ = np.asarray(row_upper, dtype=np.double)
    Ac = A.tocsc()
    try:
        lp.a_matrix_.format_ = highspy.MatrixFormat.kColwise
    except Exception:
        pass
    lp.a_matrix_.start_ = np.asarray(Ac.indptr, dtype=np.int32)
    lp.a_matrix_.index_ = np.asarray(Ac.indices, dtype=np.int32)
    lp.a_matrix_.value_ = np.asarray(Ac.data, dtype=np.double)

    meta: dict[str, Any] = {
        "backend": "highspy",
        "solver": "ipm",
        "rows": int(m),
        "columns": int(n),
        "nnz": int(A.nnz),
        "global_scheduler_reset_before": _reset_highspy_scheduler(highspy),
    }
    try:
        h = highspy.Highs()
        try:
            meta["highspy_version"] = str(h.version())
        except Exception:
            meta["highspy_version"] = str(getattr(highspy, "__version__", "unknown"))
        statuses, failures = _configure_highspy(
            h,
            seed=seed,
            time_limit=time_limit,
            solver_log=solver_log,
            feasibility_tolerance=feasibility_tolerance,
        )
        meta["option_statuses"] = statuses
        if failures:
            meta.update(status="api_error", reason="required option failure: " + ", ".join(failures))
            return meta, None
        ps = h.passModel(lp)
        meta["pass_model_status"] = str(ps)
        if not _highspy_status_ok(ps):
            meta.update(status="api_error", reason=f"passModel failed ({ps})")
            return meta, None
        start = time.perf_counter()
        rs = h.run()
        meta["elapsed_seconds"] = float(time.perf_counter() - start)
        meta["run_status"] = str(rs)
        try:
            model_status = str(h.modelStatusToString(h.getModelStatus()))
        except Exception as exc:
            model_status = f"ERROR {type(exc).__name__}: {exc}"
        meta["model_status"] = model_status
        try:
            info = h.getInfo()
            for name in (
                "ipm_iteration_count", "simplex_iteration_count", "crossover_iteration_count",
                "num_primal_infeasibilities", "max_primal_infeasibility",
                "num_dual_infeasibilities", "max_dual_infeasibility",
            ):
                if hasattr(info, name):
                    v = getattr(info, name)
                    meta[name] = int(v) if isinstance(v, (int, np.integer)) else float(v)
        except Exception:
            pass
        if not _highspy_status_ok(rs):
            meta.update(status="nondecisive", reason=f"run returned {rs}; model status={model_status}")
            return meta, None
        low = model_status.strip().lower()
        if low == "optimal":
            sol = h.getSolution()
            x = np.asarray(sol.col_value, dtype=float).reshape(-1)
            if x.size != n or not np.all(np.isfinite(x)):
                meta.update(status="api_error", reason="invalid solution vector")
                return meta, None
            meta["status"] = "optimal"
            return meta, x
        if low == "infeasible":
            meta["status"] = "infeasible"
            return meta, None
        meta.update(status="nondecisive", reason=f"model status={model_status}")
        return meta, None
    except Exception as exc:
        meta.update(status="api_error", reason=f"{type(exc).__name__}: {exc}")
        return meta, None
    finally:
        try:
            meta["global_scheduler_reset_after"] = _reset_highspy_scheduler(highspy)
        except Exception:
            pass


def _scipy_direct_solve(
    *,
    A: csr_matrix,
    b: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    time_limit: float | None,
    solver_log: bool,
    feasibility_tolerance: float,
) -> tuple[dict[str, Any], np.ndarray | None]:
    options: dict[str, Any] = {
        "disp": bool(solver_log),
        "presolve": True,
        "primal_feasibility_tolerance": float(feasibility_tolerance),
        "dual_feasibility_tolerance": float(feasibility_tolerance),
        "ipm_optimality_tolerance": float(feasibility_tolerance),
    }
    if time_limit is not None and time_limit > 0.0:
        options["time_limit"] = float(time_limit)
    start = time.perf_counter()
    res = linprog(
        np.zeros(A.shape[1], dtype=float),
        A_ub=A,
        b_ub=b,
        bounds=bounds,
        method="highs-ipm",
        options=options,
    )
    elapsed = float(time.perf_counter() - start)
    status = {0: "optimal", 1: "nondecisive", 2: "infeasible", 3: "unbounded", 4: "numerical_difficulty"}.get(
        int(res.status), f"status_{res.status}"
    )
    meta = {
        "backend": "scipy",
        "solver": "highs-ipm",
        "status": status,
        "scipy_status_code": int(res.status),
        "message": str(res.message),
        "elapsed_seconds": elapsed,
        "iterations": int(getattr(res, "nit", 0) or 0),
    }
    x = None if res.x is None else np.asarray(res.x, dtype=float)
    return meta, x


def _solve_direct(
    *,
    backend: str,
    A: csr_matrix,
    b: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    seed: int,
    time_limit: float | None,
    solver_log: bool,
    feasibility_tolerance: float,
) -> tuple[dict[str, Any], np.ndarray | None]:
    if backend == "highspy":
        inf = float(1e30)
        row_lo = np.full(A.shape[0], -inf, dtype=float)
        return _highspy_solve_rows(
            A=A,
            row_lower=row_lo,
            row_upper=np.asarray(b, dtype=float),
            c=np.zeros(A.shape[1], dtype=float),
            bounds=bounds,
            seed=seed,
            time_limit=time_limit,
            solver_log=solver_log,
            feasibility_tolerance=feasibility_tolerance,
        )
    return _scipy_direct_solve(
        A=A,
        b=b,
        bounds=bounds,
        time_limit=time_limit,
        solver_log=solver_log,
        feasibility_tolerance=feasibility_tolerance,
    )


def _validate_original_candidate(
    A: csr_matrix,
    b: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    y: np.ndarray,
    row_scale: np.ndarray,
    tolerance: float,
) -> dict[str, Any]:
    residual = np.asarray(A @ y - b, dtype=float).reshape(-1)
    normalized = np.maximum(row_scale * residual, 0.0)
    max_row = float(np.max(normalized)) if normalized.size else 0.0
    max_bound = 0.0
    bound_bad = 0
    for j, (lo, hi) in enumerate(bounds):
        v = float(y[j])
        if lo is not None and math.isfinite(float(lo)) and v < float(lo):
            z = (float(lo) - v) / max(1.0, abs(float(lo)))
            max_bound = max(max_bound, z)
            if z > tolerance:
                bound_bad += 1
        if hi is not None and math.isfinite(float(hi)) and v > float(hi):
            z = (v - float(hi)) / max(1.0, abs(float(hi)))
            max_bound = max(max_bound, z)
            if z > tolerance:
                bound_bad += 1
    return {
        "passed": bool(max_row <= tolerance and max_bound <= tolerance),
        "normalized_tolerance": float(tolerance),
        "max_normalized_row_violation": max_row,
        "rows_over_tolerance": int(np.count_nonzero(normalized > tolerance)),
        "max_normalized_bound_violation": float(max_bound),
        "bounds_over_tolerance": int(bound_bad),
        "safety_interpretation": (
            "Accepting a slightly infeasible numerical point as feasible can only make a lower-bound "
            "test more conservative; it cannot create a false infeasibility proof."
        ),
    }


@dataclass
class LazyTailFamily:
    enabled: bool
    time_seconds: float
    n_actions: int
    minimum_window_seconds: float
    separation_tolerance: float
    max_rounds: int
    specs: list[dict[str, Any]]


def _load_lazy_tail(package: dict[str, Any], override_max_rounds: int | None) -> LazyTailFamily:
    rec = package.get("lazy_tail") or {}
    specs: list[dict[str, Any]] = []
    for raw in rec.get("specs", []) or []:
        spec = dict(raw)
        spec["recipe_action_index"] = int(spec["recipe_action_index"])
        spec["category_seconds_per_run"] = float(spec["category_seconds_per_run"])
        spec["constant_rate"] = float(spec.get("constant_rate", 0.0))
        spec["rate_coeff"] = {int(k): float(v) for k, v in (spec.get("rate_coeff") or {}).items()}
        specs.append(spec)
    default_rounds = int(rec.get("max_rounds_default", 50))
    return LazyTailFamily(
        enabled=bool(rec.get("enabled", False) and specs),
        time_seconds=float(package.get("time_seconds", 0.0)),
        n_actions=int(package.get("n_actions", 0)),
        minimum_window_seconds=float(rec.get("minimum_window_seconds", 1.0 / 60.0)),
        separation_tolerance=float(rec.get("separation_tolerance", 1e-6)),
        max_rounds=default_rounds if override_max_rounds is None else int(override_max_rounds),
        specs=specs,
    )


def _tail_row(family: LazyTailFamily, spec: dict[str, Any], D: float, total_vars: int) -> tuple[csr_matrix, float]:
    ri = int(spec["recipe_action_index"])
    csec = float(spec["category_seconds_per_run"])
    cols: list[int] = [ri, family.n_actions + ri]
    vals: list[float] = [2.0 * D, -2.0 * family.time_seconds]
    rate_factor = D * D / csec
    merged: dict[int, float] = {ri: vals[0], family.n_actions + ri: vals[1]}
    for aj, coeff in spec["rate_coeff"].items():
        merged[int(aj)] = merged.get(int(aj), 0.0) - rate_factor * float(coeff)
    cols = list(merged.keys())
    vals = [merged[j] for j in cols]
    row = csr_matrix((vals, ([0] * len(cols), cols)), shape=(1, total_vars), dtype=float)
    rhs = rate_factor * float(spec["constant_rate"])
    return row, rhs


def _tail_most_violated(
    family: LazyTailFamily,
    y: np.ndarray,
    spec: dict[str, Any],
) -> tuple[float, float, float]:
    ri = int(spec["recipe_action_index"])
    csec = float(spec["category_seconds_per_run"])
    q0 = max(0.0, float(y[ri]))
    q1 = max(0.0, float(y[family.n_actions + ri]))
    R = float(spec["constant_rate"])
    for aj, coeff in spec["rate_coeff"].items():
        R += float(coeff) * max(0.0, float(y[int(aj)]))
    R = max(0.0, R)
    candidates = [family.minimum_window_seconds, family.time_seconds]
    if R > 0.0 and q0 > 0.0:
        candidates.append(min(family.time_seconds, max(family.minimum_window_seconds, csec * q0 / R)))
    best_D = candidates[0]
    best_v = -math.inf
    best_scale = 1.0
    for D in candidates:
        lhs1 = 2.0 * D * q0
        lhs2 = 2.0 * family.time_seconds * q1
        machine_term = (D * D / csec) * R
        v = lhs1 - lhs2 - machine_term
        scale = 1.0 + abs(lhs1) + abs(lhs2) + abs(machine_term)
        if v > best_v:
            best_D, best_v, best_scale = float(D), float(v), float(scale)
    return best_D, best_v, best_v / best_scale


def _separate_lazy_tail(
    family: LazyTailFamily,
    y: np.ndarray,
    total_vars: int,
    seen: set[tuple[int, int]],
) -> tuple[csr_matrix | None, np.ndarray | None, list[dict[str, Any]], float]:
    if not family.enabled:
        return None, None, [], 0.0
    rows: list[csr_matrix] = []
    rhs: list[float] = []
    meta: list[dict[str, Any]] = []
    max_norm = 0.0
    for si, spec in enumerate(family.specs):
        D, violation, normalized = _tail_most_violated(family, y, spec)
        max_norm = max(max_norm, float(normalized))
        if normalized <= family.separation_tolerance:
            continue
        key = (int(si), int(round(D * 1e12)))
        if key in seen:
            continue
        row, brhs = _tail_row(family, spec, D, total_vars)
        rows.append(row)
        rhs.append(brhs)
        seen.add(key)
        meta.append({
            "spec_index": int(si),
            "recipe_action_key": str(spec.get("recipe_action_key", "")),
            "recipe_category_key": str(spec.get("recipe_category_key", "")),
            "window_seconds": float(D),
            "candidate_original_violation": float(violation),
            "candidate_normalized_violation": float(normalized),
        })
    if not rows:
        return None, None, [], max_norm
    return vstack(rows, format="csr"), np.asarray(rhs, dtype=float), meta, max_norm


def _exact_verify_row_multiplier(
    *,
    A: csr_matrix,
    b: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    lambda_original: np.ndarray,
) -> tuple[dict[str, Any], np.ndarray | None]:
    """Exactly verify a Farkas aggregate for the binary64 LP using dyadic Fractions."""
    lam = np.asarray(lambda_original, dtype=float).reshape(-1).copy()
    if lam.size != A.shape[0] or not np.all(np.isfinite(lam)):
        return {"verified": False, "reason": "invalid row multiplier vector"}, None
    if np.any(lam < 0.0):
        return {"verified": False, "reason": "row multipliers are negative after polishing", "min": float(np.min(lam))}, None
    mx = float(np.max(lam)) if lam.size else 0.0
    if not math.isfinite(mx) or mx <= 0.0:
        return {"verified": False, "reason": "all-zero row multiplier"}, None
    # Positive rescaling changes nothing mathematically.  The rounded normalized
    # float vector is itself reverified exactly below.
    lam /= mx
    nz = np.flatnonzero(lam > 0.0)
    A = A.tocsr()
    n = A.shape[1]
    agg = [Fraction(0, 1) for _ in range(n)]
    rhs = Fraction(0, 1)
    start = time.perf_counter()
    for ii0 in nz:
        ii = int(ii0)
        li = Fraction.from_float(float(lam[ii]))
        rhs += li * Fraction.from_float(float(b[ii]))
        p0, p1 = int(A.indptr[ii]), int(A.indptr[ii + 1])
        for pidx in range(p0, p1):
            j = int(A.indices[pidx])
            agg[j] += li * Fraction.from_float(float(A.data[pidx]))

    min_lhs = Fraction(0, 1)
    for j, coeff in enumerate(agg):
        if coeff == 0:
            continue
        lo, hi = bounds[j]
        chosen = lo if coeff > 0 else hi
        if chosen is None or not math.isfinite(float(chosen)):
            return ({
                "verified": False,
                "reason": "aggregate direction is unbounded over a variable box",
                "unbounded_column": int(j),
                "aggregate_coefficient_float": float(coeff),
                "coefficient_sign": 1 if coeff > 0 else -1,
                "lower_bound": lo,
                "upper_bound": hi,
                "nonzero_row_multipliers": int(nz.size),
                "exact_verification_seconds": float(time.perf_counter() - start),
            }, lam)
        min_lhs += coeff * Fraction.from_float(float(chosen))

    gap = min_lhs - rhs
    verified = gap > 0
    meta = {
        "verified": bool(verified),
        "arithmetic": "fractions.Fraction exact arithmetic on the binary64 coefficients, bounds, and returned multiplier",
        "nonzero_row_multipliers": int(nz.size),
        "minimum_aggregate_lhs_over_bounds_float": float(min_lhs),
        "aggregate_rhs_float": float(rhs),
        "certificate_gap_float": float(gap),
        "exact_gap_positive": bool(gap > 0),
        "exact_gap_numerator_bits": int(abs(gap.numerator).bit_length()),
        "exact_gap_denominator_bits": int(gap.denominator.bit_length()),
        "exact_verification_seconds": float(time.perf_counter() - start),
    }
    if not verified:
        meta["reason"] = "exact aggregate gap is not positive"
    return meta, lam


def _certificate_problem(
    *,
    A: csr_matrix,
    b: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    sign_buffer_relative: float,
) -> tuple[
    csr_matrix,
    np.ndarray,
    csr_matrix,
    np.ndarray,
    np.ndarray,
    list[tuple[float | None, float | None]],
    dict[str, Any],
]:
    """Build a box-aware Farkas search LP without B^T y = 0 stationarity.

    lambda >= 0, sum(lambda)=1, g=A^T lambda.  For one-sided variables, force
    g to point toward the finite bound.  For doubly bounded variables, an
    auxiliary z_j represents min(l_j*g_j, u_j*g_j).  The objective minimizes

        b^T lambda - sum_j z_j,

    i.e. the negative of the aggregate contradiction gap.
    """
    A = A.tocsr()
    Ac = A.tocsc()
    m, n = A.shape
    lower_only: list[int] = []
    upper_only: list[int] = []
    free: list[int] = []
    bounded: list[int] = []
    for j, (lo, hi) in enumerate(bounds):
        lof = lo is not None and math.isfinite(float(lo))
        hif = hi is not None and math.isfinite(float(hi))
        if lof and hif:
            bounded.append(j)
        elif lof:
            lower_only.append(j)
        elif hif:
            upper_only.append(j)
        else:
            free.append(j)

    p = m + len(bounded)
    rr: list[int] = []
    cc: list[int] = []
    vv: list[float] = []
    rhs: list[float] = []
    row = 0
    col_max = _max_abs_by_axis(A, axis=0)

    # lower-only: g_j >= margin  <=> -g_j <= -margin
    for j in lower_only:
        margin = float(sign_buffer_relative) * max(1e-30, float(col_max[j]))
        p0, p1 = int(Ac.indptr[j]), int(Ac.indptr[j + 1])
        for q in range(p0, p1):
            rr.append(row); cc.append(int(Ac.indices[q])); vv.append(-float(Ac.data[q]))
        rhs.append(-margin)
        row += 1

    # upper-only: g_j <= -margin
    for j in upper_only:
        margin = float(sign_buffer_relative) * max(1e-30, float(col_max[j]))
        p0, p1 = int(Ac.indptr[j]), int(Ac.indptr[j + 1])
        for q in range(p0, p1):
            rr.append(row); cc.append(int(Ac.indices[q])); vv.append(float(Ac.data[q]))
        rhs.append(-margin)
        row += 1

    # Doubly bounded: z <= lo*g and z <= hi*g.
    for zi, j in enumerate(bounded):
        lo, hi = bounds[j]
        assert lo is not None and hi is not None
        aux = m + zi
        p0, p1 = int(Ac.indptr[j]), int(Ac.indptr[j + 1])
        for bound_value in (float(lo), float(hi)):
            for q in range(p0, p1):
                rr.append(row); cc.append(int(Ac.indices[q])); vv.append(-bound_value * float(Ac.data[q]))
            rr.append(row); cc.append(aux); vv.append(1.0)
            rhs.append(0.0)
            row += 1

    A_ub = coo_matrix((vv, (rr, cc)), shape=(row, p), dtype=float).tocsr()
    b_ub = np.asarray(rhs, dtype=float)

    # Free primal variables still require exact g_j=0.  They are unusual in this
    # moment LP; keep them as equalities and let exact verification decide.
    eq_rr: list[int] = []
    eq_cc: list[int] = []
    eq_vv: list[float] = []
    eq_rhs: list[float] = []
    erow = 0
    for j in free:
        p0, p1 = int(Ac.indptr[j]), int(Ac.indptr[j + 1])
        for q in range(p0, p1):
            eq_rr.append(erow); eq_cc.append(int(Ac.indices[q])); eq_vv.append(float(Ac.data[q]))
        eq_rhs.append(0.0)
        erow += 1
    # normalization sum(lambda)=1
    for i in range(m):
        eq_rr.append(erow); eq_cc.append(i); eq_vv.append(1.0)
    eq_rhs.append(1.0)
    erow += 1
    A_eq = coo_matrix((eq_vv, (eq_rr, eq_cc)), shape=(erow, p), dtype=float).tocsr()
    b_eq = np.asarray(eq_rhs, dtype=float)

    c = np.concatenate([np.asarray(b, dtype=float), -np.ones(len(bounded), dtype=float)])
    cert_bounds: list[tuple[float | None, float | None]] = [(0.0, None)] * m + [(None, None)] * len(bounded)
    meta = {
        "ordinary_row_multiplier_variables": int(m),
        "bounded_aux_variables": int(len(bounded)),
        "lower_only_primal_columns": int(len(lower_only)),
        "upper_only_primal_columns": int(len(upper_only)),
        "free_primal_columns": int(len(free)),
        "doubly_bounded_primal_columns": int(len(bounded)),
        "inequalities": int(A_ub.shape[0]),
        "equalities": int(A_eq.shape[0]),
        "sign_buffer_relative": float(sign_buffer_relative),
    }
    return A_ub, b_ub, A_eq, b_eq, c, cert_bounds, meta


def _solve_certificate_lp(
    *,
    backend: str,
    A_ub: csr_matrix,
    b_ub: np.ndarray,
    A_eq: csr_matrix,
    b_eq: np.ndarray,
    c: np.ndarray,
    bounds: Sequence[tuple[float | None, float | None]],
    seed: int,
    time_limit: float | None,
    solver_log: bool,
    feasibility_tolerance: float,
) -> tuple[dict[str, Any], np.ndarray | None]:
    if backend == "scipy":
        options: dict[str, Any] = {
            "disp": bool(solver_log),
            "presolve": True,
            "primal_feasibility_tolerance": float(feasibility_tolerance),
            "dual_feasibility_tolerance": float(feasibility_tolerance),
            "ipm_optimality_tolerance": float(feasibility_tolerance),
        }
        if time_limit is not None and time_limit > 0.0:
            options["time_limit"] = float(time_limit)
        start = time.perf_counter()
        res = linprog(
            c,
            A_ub=A_ub,
            b_ub=b_ub,
            A_eq=A_eq,
            b_eq=b_eq,
            bounds=bounds,
            method="highs-ipm",
            options=options,
        )
        elapsed = float(time.perf_counter() - start)
        status = {0: "optimal", 1: "nondecisive", 2: "infeasible", 3: "unbounded", 4: "numerical_difficulty"}.get(
            int(res.status), f"status_{res.status}"
        )
        return ({
            "backend": "scipy",
            "status": status,
            "message": str(res.message),
            "elapsed_seconds": elapsed,
            "iterations": int(getattr(res, "nit", 0) or 0),
            "objective": None if res.fun is None else float(res.fun),
        }, None if res.x is None else np.asarray(res.x, dtype=float))

    # Combine inequality/equality row bounds for highspy.
    Aall = vstack([A_ub, A_eq], format="csr")
    inf = 1e30
    row_lo = np.concatenate([
        np.full(A_ub.shape[0], -inf, dtype=float),
        np.asarray(b_eq, dtype=float),
    ])
    row_hi = np.concatenate([
        np.asarray(b_ub, dtype=float),
        np.asarray(b_eq, dtype=float),
    ])
    meta, x = _highspy_solve_rows(
        A=Aall,
        row_lower=row_lo,
        row_upper=row_hi,
        c=c,
        bounds=bounds,
        seed=seed,
        time_limit=time_limit,
        solver_log=solver_log,
        feasibility_tolerance=feasibility_tolerance,
    )
    if x is not None:
        meta["objective"] = float(np.dot(c, x))
    return meta, x


def _find_verified_certificate(
    *,
    backend: str,
    A_scaled: csr_matrix,
    b_scaled: np.ndarray,
    scaled_bounds: Sequence[tuple[float | None, float | None]],
    row_scale: np.ndarray,
    A_original: csr_matrix,
    b_original: np.ndarray,
    bounds_original: Sequence[tuple[float | None, float | None]],
    seed: int,
    time_limit: float | None,
    solver_log: bool,
    feasibility_tolerance: float,
    sign_buffers: Sequence[float],
) -> tuple[dict[str, Any], np.ndarray | None]:
    rounds: list[dict[str, Any]] = []
    m = A_scaled.shape[0]
    for ridx, sign_buffer in enumerate(sign_buffers, start=1):
        Auc, buc, Aeq, beq, ccert, cbounds, structure = _certificate_problem(
            A=A_scaled,
            b=b_scaled,
            bounds=scaled_bounds,
            sign_buffer_relative=float(sign_buffer),
        )
        solve_meta, x = _solve_certificate_lp(
            backend=backend,
            A_ub=Auc,
            b_ub=buc,
            A_eq=Aeq,
            b_eq=beq,
            c=ccert,
            bounds=cbounds,
            seed=seed + ridx,
            time_limit=time_limit,
            solver_log=solver_log,
            feasibility_tolerance=feasibility_tolerance,
        )
        rec: dict[str, Any] = {"round": ridx, "structure": structure, "solve": solve_meta}
        rounds.append(rec)
        if x is None or solve_meta.get("status") != "optimal":
            continue
        obj = float(np.dot(ccert, x))
        rec["candidate_objective_negative_gap"] = obj
        if not math.isfinite(obj) or obj >= 0.0:
            rec["verification"] = {"verified": False, "reason": "certificate-search objective is not negative"}
            continue

        # Solver bound tolerances can return lambda_i slightly below zero.  Clip
        # only values within a conservative multiple of the configured tolerance,
        # then reverify the changed vector exactly from scratch.
        lam_scaled = np.asarray(x[:m], dtype=float).copy()
        min_lam = float(np.min(lam_scaled)) if lam_scaled.size else 0.0
        clip_limit = 10.0 * float(feasibility_tolerance)
        rec["candidate_min_lambda_scaled"] = min_lam
        rec["lambda_negative_clip_limit"] = clip_limit
        if min_lam < -clip_limit:
            rec["verification"] = {
                "verified": False,
                "reason": "certificate solver violated lambda>=0 by more than clip limit",
                "min_lambda_scaled": min_lam,
            }
            continue
        lam_scaled[lam_scaled < 0.0] = 0.0
        lam_original = lam_scaled * np.asarray(row_scale, dtype=float)
        verification, normalized = _exact_verify_row_multiplier(
            A=A_original,
            b=b_original,
            bounds=bounds_original,
            lambda_original=lam_original,
        )
        rec["verification"] = verification
        if verification.get("verified"):
            return ({
                "available": True,
                "verified": True,
                "method": "box_aware_farkas_search_ipm_plus_exact_fraction_verification",
                "rounds": rounds,
                "successful_round": ridx,
                "verification": verification,
            }, normalized)

    reason = "no certificate-search round produced an exactly verified row multiplier"
    return ({
        "available": True,
        "verified": False,
        "method": "box_aware_farkas_search_ipm_plus_exact_fraction_verification",
        "reason": reason,
        "rounds": rounds,
    }, None)


def _row_description(row: int, groups: Sequence[dict[str, Any]]) -> dict[str, Any]:
    for group in groups:
        start = int(group.get("row_start", -1))
        stop = int(group.get("row_stop_exclusive", -1))
        if start <= row < stop:
            out = {"group": str(group.get("name", "")), "group_row": int(row - start)}
            rows = group.get("rows")
            if isinstance(rows, list) and 0 <= row - start < len(rows):
                out["detail"] = rows[row - start]
            return out
    return {"group": "unknown", "group_row": None}


def _save_final_lp(
    package_dir: Path,
    A: csr_matrix,
    b: np.ndarray,
    As: csr_matrix,
    bs: np.ndarray,
    row_scale: np.ndarray,
    column_scale: np.ndarray,
    scaled_bounds: Sequence[tuple[float | None, float | None]],
    lazy_groups: Sequence[dict[str, Any]],
) -> dict[str, str]:
    paths = {
        "A_original": package_dir / "A-ub-final.npz",
        "b_original": package_dir / "b-ub-final.npy",
        "A_scaled": package_dir / "A-ub-scaled-final.npz",
        "b_scaled": package_dir / "b-ub-scaled-final.npy",
        "row_scale": package_dir / "row-scale-final.npy",
        "column_scale": package_dir / "column-scale-final.npy",
        "bounds_scaled": package_dir / "bounds-scaled-final.npy",
        "lazy_cuts": package_dir / "lazy-cuts.json",
    }
    save_npz(paths["A_original"], A)
    np.save(paths["b_original"], b)
    save_npz(paths["A_scaled"], As)
    np.save(paths["b_scaled"], bs)
    np.save(paths["row_scale"], row_scale)
    np.save(paths["column_scale"], column_scale)
    np.save(paths["bounds_scaled"], _bounds_array(scaled_bounds))
    paths["lazy_cuts"].write_text(json.dumps(_json_safe(list(lazy_groups)), indent=2, sort_keys=True) + "\n")
    return {k: _sha256(v) for k, v in paths.items()}


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Solve/certify a frozen PropertyRandomizer moment-LP package without rebuilding the Factorio graph."
    )
    parser.add_argument("lp_dir", type=Path, help="Directory containing solver-package.json and the saved LP arrays")
    parser.add_argument("--backend", choices=["auto", "highspy", "scipy"], default="auto")
    parser.add_argument("--solver-time-limit", type=float, default=60.0, help="Seconds for each direct IPM solve; 0 means no limit")
    parser.add_argument("--certificate-time-limit", type=float, default=600.0, help="Seconds for each certificate-search IPM solve; 0 means no limit")
    parser.add_argument("--solver-log", action="store_true")
    parser.add_argument("--seed", type=int, default=23, help="HiGHS random seed (default 23); no row/column permutation is performed")
    parser.add_argument("--feasibility-tolerance", type=float, default=1e-8, help="HiGHS primal/dual/IPM tolerance used for numerical search (default 1e-8)")
    parser.add_argument("--candidate-validation-tolerance", type=float, default=1e-6, help="Original-LP tolerance for accepting a feasible candidate (default 1e-6; conservative for lower bounds)")
    parser.add_argument("--lazy-tail-max-rounds", type=int, default=None, help="Override package lazy-tail separation round limit")
    parser.add_argument("--no-certificate", action="store_true", help="Do not search for a Farkas certificate after IPM says infeasible")
    parser.add_argument(
        "--certificate-sign-buffers",
        default="0,1e-8",
        help="Comma-separated relative sign buffers tried by the box-aware certificate LP (default 0,1e-8)",
    )
    parser.add_argument("--output", type=Path, default=None, help="Result JSON; default <lp_dir>/standalone-solve-result.json")
    args = parser.parse_args()

    if args.solver_time_limit < 0 or args.certificate_time_limit < 0:
        raise ValueError("time limits must be >=0; zero means unlimited")
    if args.feasibility_tolerance <= 0 or not math.isfinite(args.feasibility_tolerance):
        raise ValueError("--feasibility-tolerance must be finite and >0")
    if args.candidate_validation_tolerance <= 0 or not math.isfinite(args.candidate_validation_tolerance):
        raise ValueError("--candidate-validation-tolerance must be finite and >0")
    sign_buffers = [float(x.strip()) for x in args.certificate_sign_buffers.split(",") if x.strip()]
    if not sign_buffers or any(x < 0 or not math.isfinite(x) for x in sign_buffers):
        raise ValueError("--certificate-sign-buffers must contain finite nonnegative numbers")

    lp_dir = args.lp_dir.resolve()
    manifest_path = lp_dir / "solver-package.json"
    if not manifest_path.exists():
        raise FileNotFoundError(
            f"{manifest_path} not found. Build with solve_staged_growth_lower_bound_v33.py --save-lp-dir ... --build-only"
        )
    package = json.loads(manifest_path.read_text())
    if package.get("schema") != PACKAGE_SCHEMA:
        raise ValueError(f"unsupported package schema {package.get('schema')!r}")
    metadata = json.loads((lp_dir / str(package.get("metadata", "lp-metadata.json"))).read_text())

    A = load_npz(lp_dir / str(package.get("base_matrix", "A-ub.npz"))).tocsr()
    b = np.load(lp_dir / str(package.get("base_rhs", "b-ub.npy")))
    bounds = _bounds_from_array(np.load(lp_dir / str(package.get("bounds", "bounds-original.npy"))))
    column_scale = np.load(lp_dir / str(package.get("column_scale", "column-scale.npy")))
    if A.shape[0] != b.size or A.shape[1] != len(bounds) or A.shape[1] != column_scale.size:
        raise ValueError("saved package arrays have inconsistent dimensions")

    highspy_available = importlib.util.find_spec("highspy") is not None
    if args.backend == "highspy" and not highspy_available:
        raise RuntimeError("--backend highspy requested but highspy is not installed")
    backend = ("highspy" if highspy_available else "scipy") if args.backend == "auto" else args.backend
    print(f"Loaded frozen LP: rows={A.shape[0]:,}, cols={A.shape[1]:,}, nnz={A.nnz:,}; backend={backend}", flush=True)

    family = _load_lazy_tail(package, args.lazy_tail_max_rounds)
    if family.enabled:
        print(f"Lazy recipe-tail family: {len(family.specs):,} recipe/category specs; max rounds={family.max_rounds}", flush=True)

    groups: list[dict[str, Any]] = list(metadata.get("constraint_groups", []))
    lazy_groups: list[dict[str, Any]] = []
    seen_tail: set[tuple[int, int]] = set()
    solve_rounds: list[dict[str, Any]] = []
    start_total = time.perf_counter()
    final_validation: dict[str, Any] | None = None
    certificate: dict[str, Any] | None = None
    certified_lambda: np.ndarray | None = None
    status = "inconclusive"
    reason = ""
    solution_original: np.ndarray | None = None

    direct_limit = None if args.solver_time_limit == 0 else float(args.solver_time_limit)
    cert_limit = None if args.certificate_time_limit == 0 else float(args.certificate_time_limit)

    for round_index in range(family.max_rounds + 1 if family.enabled else 1):
        As, bs, scaled_bounds, row_scale = _scale_lp(A, b, bounds, column_scale)
        diag = _scaled_matrix_diagnostics(As)
        tiny = int(np.count_nonzero((np.abs(As.data) > 0.0) & (np.abs(As.data) <= 1e-12)))
        if tiny:
            raise RuntimeError(
                f"scaled LP contains {tiny} nonzero coefficient(s) <=1e-12; refusing to let HiGHS silently alter the LP"
            )
        print(
            f"IPM round {round_index + 1}: rows={A.shape[0]:,}, scaled coeff range={diag['abs_coefficient_range']}",
            flush=True,
        )
        solve_meta, z = _solve_direct(
            backend=backend,
            A=As,
            b=bs,
            bounds=scaled_bounds,
            seed=int(args.seed + round_index),
            time_limit=direct_limit,
            solver_log=args.solver_log,
            feasibility_tolerance=float(args.feasibility_tolerance),
        )
        rec: dict[str, Any] = {"round": round_index + 1, "scaling": diag, "solve": solve_meta}
        solve_rounds.append(rec)
        print(f"  -> {solve_meta.get('status')} in {solve_meta.get('elapsed_seconds', 0):.3f}s", flush=True)

        if solve_meta.get("status") == "optimal" and z is not None:
            y = np.asarray(column_scale, dtype=float) * np.asarray(z, dtype=float)
            validation = _validate_original_candidate(
                A, b, bounds, y, row_scale, float(args.candidate_validation_tolerance)
            )
            rec["original_validation"] = validation
            if not validation.get("passed"):
                status = "inconclusive"
                reason = "IPM returned Optimal but the candidate failed original-LP validation"
                final_validation = validation
                break

            cut_A, cut_b, cuts, max_norm = _separate_lazy_tail(family, y, A.shape[1], seen_tail)
            rec["lazy_tail_max_normalized_violation"] = float(max_norm)
            if cuts:
                if round_index >= family.max_rounds:
                    status = "inconclusive"
                    reason = "lazy-tail separation round limit reached before obtaining a tail-feasible candidate"
                    break
                start_row = int(A.shape[0])
                assert cut_A is not None and cut_b is not None
                A = vstack([A, cut_A], format="csr")
                b = np.concatenate([b, cut_b])
                group = {
                    "name": f"recipe_tail_capacity_lazy_round_{round_index + 1}",
                    "row_start": start_row,
                    "row_stop_exclusive": int(A.shape[0]),
                    "lazy": True,
                    "rows": cuts,
                }
                groups.append(group)
                lazy_groups.append(group)
                rec["lazy_tail_cuts_added"] = cuts
                print(f"  added {len(cuts)} exact lazy tail cut(s); resolving", flush=True)
                continue

            status = "feasible"
            reason = "validated IPM feasible candidate; no violated lazy tail cut remains"
            solution_original = y
            final_validation = validation
            break

        if solve_meta.get("status") == "infeasible":
            if args.no_certificate:
                status = "inconclusive"
                reason = "IPM reported infeasible, but certificate search was disabled"
                break
            print("  IPM says infeasible; searching for an independently verifiable Farkas aggregate...", flush=True)
            certificate, certified_lambda = _find_verified_certificate(
                backend=backend,
                A_scaled=As,
                b_scaled=bs,
                scaled_bounds=scaled_bounds,
                row_scale=row_scale,
                A_original=A,
                b_original=b,
                bounds_original=bounds,
                seed=int(args.seed + 1000 + round_index),
                time_limit=cert_limit,
                solver_log=args.solver_log,
                feasibility_tolerance=float(args.feasibility_tolerance),
                sign_buffers=sign_buffers,
            )
            rec["certificate"] = certificate
            if certificate.get("verified") and certified_lambda is not None:
                status = "infeasible"
                reason = "exact Fraction verification proved a Farkas contradiction for the frozen float64 LP"
                print(
                    f"  VERIFIED: exact certificate gap={certificate['verification'].get('certificate_gap_float'):.6g}",
                    flush=True,
                )
            else:
                status = "inconclusive"
                reason = "IPM reported infeasible, but no certificate candidate passed exact verification"
                print("  certificate not verified; treating IPM infeasibility as inconclusive", flush=True)
            break

        status = "inconclusive"
        reason = f"direct IPM solve was nondecisive: {solve_meta.get('reason') or solve_meta.get('message') or solve_meta.get('model_status')}"
        break

    # Recompute and freeze the exact final LP, including all lazy rows that were added.
    As, bs, scaled_bounds, row_scale = _scale_lp(A, b, bounds, column_scale)
    hashes = _save_final_lp(lp_dir, A, b, As, bs, row_scale, column_scale, scaled_bounds, lazy_groups)

    if solution_original is not None:
        np.save(lp_dir / "solution-original.npy", solution_original)
    if certified_lambda is not None:
        np.save(lp_dir / "farkas-row-multipliers-original.npy", certified_lambda)
        top_idx = np.argsort(-certified_lambda)[:25]
        top = []
        for i0 in top_idx:
            i = int(i0)
            mult = float(certified_lambda[i])
            if mult <= 0.0:
                continue
            item = {"row": i, "normalized_multiplier": mult}
            item.update(_row_description(i, groups))
            top.append(item)
        certificate = dict(certificate or {})
        certificate["top_row_multipliers"] = top
        (lp_dir / "farkas-certificate.json").write_text(
            json.dumps(_json_safe(certificate), indent=2, sort_keys=True) + "\n"
        )

    result = {
        "schema": SCHEMA,
        "package_schema": package.get("schema"),
        "builder_format": package.get("builder_format"),
        "lp_dir": str(lp_dir),
        "backend": backend,
        "status": status,
        "reason": reason,
        "proved_infeasible": bool(status == "infeasible"),
        "goal_key": package.get("goal_key"),
        "goal_coordinate_kind": package.get("goal_coordinate_kind"),
        "time_seconds": package.get("time_seconds"),
        "moment_order": package.get("moment_order"),
        "base_dimensions": {"rows": int(load_npz(lp_dir / str(package.get('base_matrix', 'A-ub.npz'))).shape[0]), "cols": int(A.shape[1])},
        "final_dimensions": {"rows": int(A.shape[0]), "cols": int(A.shape[1]), "nnz": int(A.nnz)},
        "lazy_tail": {
            "enabled": family.enabled,
            "rounds_with_cuts": int(len(lazy_groups)),
            "rows_added": int(sum(int(g['row_stop_exclusive']) - int(g['row_start']) for g in lazy_groups)),
        },
        "solve_rounds": solve_rounds,
        "final_candidate_validation": final_validation,
        "certificate": certificate,
        "final_lp_file_sha256": hashes,
        "elapsed_seconds": float(time.perf_counter() - start_total),
        "proof_semantics": (
            "status=infeasible is emitted only after exact Fraction arithmetic verifies a strict "
            "Farkas aggregate contradiction against the final original unscaled float64 LP. "
            "An IPM infeasible status alone is never promoted to a proof."
        ),
    }
    output = args.output or (lp_dir / "standalone-solve-result.json")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(_json_safe(result), indent=2, sort_keys=True) + "\n")
    print(f"Final status: {status}. {reason}", flush=True)
    print(f"Wrote {output}", flush=True)


if __name__ == "__main__":
    main()
