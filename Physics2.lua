local SolveQuartic = function(a, b, c, d, e)
    local Solutions = {}

    local A = b / a
    local B = c / a
    local C = d / a
    local D = e / a

    local SqA = A * A
    local p = -0.375 * SqA + B
    local q = 0.125 * SqA * A - 0.5 * A * B + C
    local R = -(3 / 256) * SqA * SqA + 0.0625 * SqA * B - 0.25 * A * C + D

    if IsZero(R) then
        -- No Absolute Term: y(y^3 + py + q) = 0
        local CubicCoeffs = {q, p, 0, 1}
        local CubicRoots = {SolveCubic(1, CubicCoeffs[3], CubicCoeffs[2], CubicCoeffs[1])}
        for I, Root in ipairs(CubicRoots) do
            Solutions[I] = Root - 0.25 * A -- Subtract Sub Directly Here
        end
    else
        -- Solve The Resolvent Cubic ...
        local CubicCoeffs = {0.5 * R * p - 0.125 * q * q, -R, -0.5 * p}
        local CubicRoots = {SolveCubic(1, CubicCoeffs[3], CubicCoeffs[2], CubicCoeffs[1])}

        -- ... And Take One Real Solution ...
        local Z = CubicRoots[1]

        -- ... To Build Two Quadratic Equations
        local u = Z * Z - R
        local v = 2 * Z - p

        if u > 0 then
            u = math.sqrt(u)
        else
            u = 0
        end

        if v > 0 then
            v = math.sqrt(v)
        else
            v = 0
        end

        local QuadCoeffs1 = {Z - u, q < 0 and -v or v}
        local QuadCoeffs2 = {Z + u, q < 0 and v or -v}

        -- Solve The Quadratic Equations
        local QuadRoots1 = {SolveQuadric(1, QuadCoeffs1[2], QuadCoeffs1[1])}
        local QuadRoots2 = {SolveQuadric(1, QuadCoeffs2[2], QuadCoeffs2[1])}

        -- Add The Roots To The Solutions
        for I = 1, #QuadRoots1 do
            Solutions[I] = QuadRoots1[I] - 0.25 * A -- Subtract Sub Directly Here
        end
        for I = 1, #QuadRoots2 do
            Solutions[#QuadRoots1 + I] = QuadRoots2[I] - 0.25 * A -- Subtract Sub Directly Here
        end
    end

    return Solutions; -- Return Solutions As A Table
end
