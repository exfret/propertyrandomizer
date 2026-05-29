-- Written by chatGPT, since this is a standard algorithm and I didn't feel like recoding it

-- inplace_simplex.lua
-- Solves:
--   maximize c^T x
--   subject to A x <= b
--              x >= 0
--
-- This mutates A in-place by turning it into the simplex tableau.
-- Assumes b[i] >= 0.

local Simplex = {}

local EPS = 1e-9

local function pivot(T, pivot_row, pivot_col)
    local rows = #T
    local cols = #T[1]

    local pivot_value = T[pivot_row][pivot_col]

    -- Normalize pivot row.
    for j = 1, cols do
        T[pivot_row][j] = T[pivot_row][j] / pivot_value
    end

    -- Eliminate pivot column from every other row.
    for i = 1, rows do
        if i ~= pivot_row then
            local factor = T[i][pivot_col]

            if math.abs(factor) > EPS then
                for j = 1, cols do
                    T[i][j] = T[i][j] - factor * T[pivot_row][j]
                end
            end
        end
    end
end

local function choose_entering_variable(T)
    local objective_row = #T
    local rhs_col = #T[1]

    -- Bland's rule: first negative reduced cost.
    for j = 1, rhs_col - 1 do
        if T[objective_row][j] < -EPS then
            return j
        end
    end

    return nil
end

local function choose_leaving_variable(T, entering_col)
    local rows = #T
    local rhs_col = #T[1]

    local best_row = nil
    local best_ratio = math.huge

    for i = 1, rows - 1 do
        local coeff = T[i][entering_col]

        if coeff > EPS then
            local ratio = T[i][rhs_col] / coeff

            if ratio < best_ratio - EPS then
                best_ratio = ratio
                best_row = i
            end
        end
    end

    return best_row
end

local function make_tableau_in_place(A, b, c)
    local m = #A
    local n = #c

    if #b ~= m then
        error("A and b have incompatible sizes")
    end

    for i = 1, m do
        if #A[i] ~= n then
            error("Each row of A must have the same length as c")
        end

        if b[i] < -EPS then
            return nil, "infeasible"
        end
    end

    local rhs_col = n + m + 1

    -- Mutate existing constraint rows:
    -- [A | I | b]
    for i = 1, m do
        for j = 1, m do
            A[i][n + j] = (i == j) and 1 or 0
        end

        A[i][rhs_col] = b[i]
    end

    -- Append objective row:
    -- [-c | 0 | 0]
    A[m + 1] = {}

    for j = 1, n do
        A[m + 1][j] = -c[j]
    end

    for j = 1, m do
        A[m + 1][n + j] = 0
    end

    A[m + 1][rhs_col] = 0

    return {
        m = m,
        n = n,
        rhs_col = rhs_col,
    }
end

function Simplex.solve_in_place(A, b, c)
    local info, status = make_tableau_in_place(A, b, c)

    if info == nil then
        return {
            status = status,
            objective = nil,
            solution = nil,
        }
    end

    local m = info.m
    local n = info.n
    local rhs_col = info.rhs_col

    -- Initial basis is the slack variables.
    local basis = {}
    for i = 1, m do
        basis[i] = n + i
    end

    while true do
        local entering_col = choose_entering_variable(A)

        if entering_col == nil then
            break
        end
    
        local leaving_row = choose_leaving_variable(A, entering_col)

        if leaving_row == nil then
            return {
                status = "unbounded",
                objective = nil,
                solution = nil,
            }
        end

        pivot(A, leaving_row, entering_col)
        basis[leaving_row] = entering_col
    end

    local solution = {}
    for j = 1, n do
        solution[j] = 0
    end

    for i = 1, m do
        local basic_var = basis[i]

        if basic_var <= n then
            solution[basic_var] = A[i][rhs_col]
        end
    end

    return {
        status = "optimal",
        objective = A[m + 1][rhs_col],
        solution = solution,
        basis = basis,
        tableau = A,
    }
end

return Simplex