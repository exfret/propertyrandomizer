-- Written by chatGPT, since this is a standard algorithm and I didn't feel like recoding it

-- simplex.lua
-- Solves:
--   maximize c^T x
--   subject to A x <= b
--              x >= 0
--
-- Assumes b[i] >= 0 for all i.
--
-- Returns:
--   {
--     status = "optimal" | "unbounded" | "infeasible",
--     objective = number,
--     solution = {x1, x2, ...}
--   }

local Simplex = {}

local EPS = 1e-9

local function copy_matrix(A)
    local B = {}
    for i = 1, #A do
        B[i] = {}
        for j = 1, #A[i] do
            B[i][j] = A[i][j]
        end
    end
    return B
end

local function pivot(tableau, pivot_row, pivot_col)
    local rows = #tableau
    local cols = #tableau[1]

    local pivot_value = tableau[pivot_row][pivot_col]

    -- Normalize pivot row
    for j = 1, cols do
        tableau[pivot_row][j] = tableau[pivot_row][j] / pivot_value
    end

    -- Eliminate pivot column from all other rows
    for i = 1, rows do
        if i ~= pivot_row then
            local factor = tableau[i][pivot_col]
            if math.abs(factor) > EPS then
                for j = 1, cols do
                    tableau[i][j] = tableau[i][j] - factor * tableau[pivot_row][j]
                end
            end
        end
    end
end

local function choose_entering_variable(tableau)
    -- Last row is the objective row.
    -- For maximization, negative reduced cost means improvement.
    -- Bland's rule: choose lowest-index improving variable.
    local objective_row = #tableau
    local rhs_col = #tableau[1]

    for j = 1, rhs_col - 1 do
        if tableau[objective_row][j] < -EPS then
            return j
        end
    end

    return nil
end

local function choose_leaving_variable(tableau, entering_col)
    local rows = #tableau
    local rhs_col = #tableau[1]

    local best_row = nil
    local best_ratio = math.huge

    for i = 1, rows - 1 do
        local coefficient = tableau[i][entering_col]

        if coefficient > EPS then
            local ratio = tableau[i][rhs_col] / coefficient

            -- Bland-ish tie break: smaller row index
            if ratio < best_ratio - EPS then
                best_ratio = ratio
                best_row = i
            end
        end
    end

    return best_row
end

function Simplex.solve(A, b, c)
    local m = #A       -- number of constraints
    local n = #c       -- number of original variables

    if m ~= #b then
        error("A and b have incompatible sizes")
    end

    for i = 1, m do
        if #A[i] ~= n then
            error("Each row of A must have the same length as c")
        end

        if b[i] < -EPS then
            return {
                status = "infeasible",
                objective = nil,
                solution = nil,
            }
        end
    end

    -- Tableau dimensions:
    -- m constraint rows + 1 objective row
    -- n original variables + m slack variables + 1 RHS column
    local rows = m + 1
    local cols = n + m + 1
    local rhs_col = cols

    local tableau = {}

    -- Constraint rows
    for i = 1, m do
        tableau[i] = {}

        -- Original variables
        for j = 1, n do
            tableau[i][j] = A[i][j]
        end

        -- Slack variables
        for j = 1, m do
            tableau[i][n + j] = (i == j) and 1 or 0
        end

        -- RHS
        tableau[i][rhs_col] = b[i]
    end

    -- Objective row
    tableau[rows] = {}

    -- Since we maximize c^T x, the tableau stores -c.
    for j = 1, n do
        tableau[rows][j] = -c[j]
    end

    -- Slack variables have zero objective coefficient
    for j = 1, m do
        tableau[rows][n + j] = 0
    end

    -- Objective RHS
    tableau[rows][rhs_col] = 0

    -- Basis initially consists of slack variables
    local basis = {}
    for i = 1, m do
        basis[i] = n + i
    end

    while true do
        local entering_col = choose_entering_variable(tableau)

        if entering_col == nil then
            -- Optimal
            break
        end

        local leaving_row = choose_leaving_variable(tableau, entering_col)

        if leaving_row == nil then
            return {
                status = "unbounded",
                objective = nil,
                solution = nil,
            }
        end

        pivot(tableau, leaving_row, entering_col)
        basis[leaving_row] = entering_col
    end

    -- Extract solution for original variables
    local solution = {}
    for j = 1, n do
        solution[j] = 0
    end

    for i = 1, m do
        local basic_var = basis[i]
        if basic_var <= n then
            solution[basic_var] = tableau[i][rhs_col]
        end
    end

    local objective = tableau[rows][rhs_col]

    return {
        status = "optimal",
        objective = objective,
        solution = solution,
    }
end

return Simplex