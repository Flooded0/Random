local Module = {};

local IsZero = function(Number, Epsilon)
    Epsilon = Epsilon or 1e-9; return math.abs(Number) < Epsilon;
end; local CubeRoot = function(Number)
    if Number == 0 then
        return 0;
    elseif Number > 0 then
        return math.pow(Number, 1 / 3);
    else
        local AbsX = math.abs(Number);
        local CubeRootMagnitude = math.pow(AbsX, 1 / 3);
        local Angle = math.atan(math.sqrt(3), 1);
        local RealPart = CubeRootMagnitude * math.cos(Angle);
        local ImaginaryPart1, ImaginaryPart2 = CubeRootMagnitude * math.sin(Angle), CubeRootMagnitude * math.sin(-Angle);
        return RealPart, ImaginaryPart1, ImaginaryPart2;
    end;
end; local SolveQuadric = function(A, B, C)
    if IsZero(A) then
        if IsZero(B) then
            return nil;
        else
            return -C / B;
        end;
    end;

    local InvA = 1 / A;
    local P = B * InvA / 2;
    local Q = C * InvA;
    local D = P * P - Q;

    if IsZero(D) then
        return -P;
    elseif D < 0 then
        local SqrtD = math.sqrt(-D);
        return {Real = -P, Imag1 =  SqrtD * InvA / 2, Imag2 = -SqrtD * InvA / 2};
    else -- if D > 0
        local SqrtD = math.sqrt(D);
        return SqrtD - P, -SqrtD - P;
    end;
end; local SolveCubic = function(a, b, c, d)
    local NumSolutions;
    local Solutions = {};

    local A = b / a;
    local B = c / a;
    local C = d / a;

    local SqA = A * A;
    local p = (1/3) * (-SqA + B);
    local Q = (1/27) * (2 * SqA * A - 3 * A * B + C);
    local CbP = p * p * p;
    local D = Q * Q + CbP;

    if IsZero(D) then
        if IsZero(Q) then -- One Triple Solution
            NumSolutions = 1;
            Solutions[1] = -A / 3;
        else -- One Single And One Double Solution
            local U = CubeRoot(-Q);
            NumSolutions = 2;
            Solutions[1] = 2 * U - A / 3;
            Solutions[2] = -U - A / 3;
        end;
    elseif D < 0 then -- Three Real Solutions
        local Phi = (1/3) * math.acos(-Q / math.sqrt(-CbP));
        local SqrtP = math.sqrt(-p);
        NumSolutions = 3;
        Solutions[1] = 2 * SqrtP * math.cos(Phi) - A / 3;
        Solutions[2] = 2 * SqrtP * math.cos(Phi + (2 * math.pi) / 3) - A / 3;
        Solutions[3] = 2 * SqrtP * math.cos(Phi - (2 * math.pi) / 3) - A / 3;
    else -- One Real Solution
        local SqrtD = math.sqrt(D);
        local u = CubeRoot(SqrtD - Q);
        local v = -CubeRoot(SqrtD + Q);
        NumSolutions = 1;
        Solutions[1] = u + v - A / 3;
    end;

    return unpack(Solutions, 1, NumSolutions);
end;

local SolveQuartic = function(c0, c1, c2, c3, c4)
    local s0, s1, s2, s3

    local coeffs = {}
    local z, u, v, sub
    local A, B, C, D
    local sq_A, p, q, r
    local num

    -- normal form: x^4 + Ax^3 + Bx^2 + Cx + D = 0
    A = c1 / c0
    B = c2 / c0
    C = c3 / c0
    D = c4 / c0

    -- substitute x = y - A/4 to eliminate cubic term: x^4 + px^2 + qx + r = 0
    sq_A = A * A
    p = -0.375 * sq_A + B
    q = 0.125 * sq_A * A - 0.5 * A * B + C
    r = -(3 / 256) * sq_A * sq_A + 0.0625 * sq_A * B - 0.25 * A * C + D

    if IsZero(r) then
        -- no absolute term: y(y^3 + py + q) = 0
        coeffs[3] = q
        coeffs[2] = p
        coeffs[1] = 0
        coeffs[0] = 1

        local results = {SolveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])}
        num = #results
        s0, s1, s2 = results[1], results[2], results[3]
    else
        -- solve the resolvent cubic …
        coeffs[3] = 0.5 * r * p - 0.125 * q * q
        coeffs[2] = -r
        coeffs[1] = -0.5 * p
        coeffs[0] = 1

        s0, s1, s2 = SolveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])

        -- … and take the one real solution …
        z = s0

        -- … to build two quadric equations
        u = z * z - r
        v = 2 * z - p

        if IsZero(u) then
            u = 0
        elseif (u > 0) then
            u = math.sqrt(u)
        else
            return
        end

        if IsZero(v) then
            v = 0
        elseif (v > 0) then
            v = math.sqrt(v)
        else
            return
        end

        coeffs[2] = z - u
        coeffs[1] = q < 0 and -v or v
        coeffs[0] = 1

        do
            local results = {SolveQuadric(coeffs[0], coeffs[1], coeffs[2])}
            num = #results
            s0, s1 = results[1], results[2]
        end

        coeffs[2] = z + u
        coeffs[1] = q < 0 and v or -v
        coeffs[0] = 1

        if (num == 0) then
            local results = {SolveQuadric(coeffs[0], coeffs[1], coeffs[2])}
            num = num + #results
            s0, s1 = results[1], results[2]
        end

        if (num == 1) then
            local results = {SolveQuadric(coeffs[0], coeffs[1], coeffs[2])}
            num = num + #results
            s1, s2 = results[1], results[2]
        end

        if (num == 2) then
            local results = {SolveQuadric(coeffs[0], coeffs[1], coeffs[2])}
            num = num + #results
            s2, s3 = results[1], results[2]
        end
    end

    -- resubstitute
    sub = 0.25 * A

    if (num > 0) then s0 = s0 - sub end
    if (num > 1) then s1 = s1 - sub end
    if (num > 2) then s2 = s2 - sub end
    if (num > 3) then s3 = s3 - sub end

    return s3, s2, s1, s0
    --return s0, s1, s2, s3
    --return {s3, s2, s1, s0}
end;

function Module.SolveTrajectory(Origin, TPos, TVelocity, ProjectileSpeed, ProjectileGravity, GravityCorrection, Option)
    Gravity, GravityCorrection, Option = ProjectileGravity or workspace.Gravity, GravityCorrection or 2, Option or 1;

    local Disp = (TPos - Origin);
    GCorrection = -(Gravity / GravityCorrection);

    if Option == 1 then
        local Tof = SolveQuartic(
            GCorrection * GCorrection,
            -2 * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - 2 * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            2 * Disp.Y * TVelocity.Y + 2 * Disp.X * TVelocity.X + 2 * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        );

        if Tof and Tof > 0 then
            return Origin + Vector3.new(
                (Disp.X + TVelocity.X * Tof) / Tof,
                (Disp.Y + TVelocity.Y * Tof - GCorrection * Tof * Tof) / Tof,
                (Disp.Z + TVelocity.Z * Tof) / Tof
            );
        end;
    elseif Option == 2 then
        local Solutions = SolveQuartic(
            GCorrection * GCorrection,
            -2 * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - 2 * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            2 * Disp.Y * TVelocity.Y + 2 * Disp.X * TVelocity.X + 2 * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        );

        if Solutions then
            local PosRoots = {};
            for Index = 1, #Solutions do
                local Solution = Solutions[Index];
                if Solution > 0 then
                    table.insert(PosRoots, Solution);
                end;
            end;

            if PosRoots[1] then
                local PR = PosRoots[1];
                return Origin + Vector3.new(
                    (Disp.X + TVelocity.X * PR) / PR,
                    (Disp.Y + TVelocity.Y * PR - GCorrection * PR * PR) / PR,
                    (Disp.Z + TVelocity.Z * PR) / PR
                );
            end;
        end;
    end;

    return TPos;
end;

return Module;

--[[local T = workspace.;
print(T.Position)
print(Module.SolveTrajectory(workspace:FindFirstChildOfClass("Camera").CFrame.Position - Vector3.new(0, 1, 0), T.Position, T.AssemblyLinearVelocity, 100, 5, 2, 1));]]
