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
end; 

--[[local SolveCubic = function(a, b, c, d)
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
end;]] local function SolveCubic(c0, c1, c2, c3)
    -- Initialize variables
    local s0, s1, s2
    local num, sub
    local A, B, C
    local sq_A, p, q
    local cb_p, D

    -- Normalize coefficients
    A = c1 / c0
    B = c2 / c0
    C = c3 / c0

    -- Substitute x = y - A/3 to eliminate quadratic term: y^3 + py + q = 0
    sq_A = A * A
    p = (1 / 3) * (-1/3 * sq_A + B)
    q = 0.5 * (2/27 * A * sq_A - 1/3 * A * B + C)

    -- Calculate discriminant
    cb_p = p * p * p
    D = q * q + cb_p

    if IsZero(D) then
        if IsZero(q) then -- One triple solution
            s0 = 0
            num = 1
        else -- One single and one double solution
            local u = CubeRoot(-q)
            s0 = 2 * u
            s1 = -u
            num = 2
        end
    elseif D < 0 then -- Three real solutions
        local phi = (1 / 3) * math.acos(-q / math.sqrt(-cb_p))
        local t = 2 * math.sqrt(-p)

        s0 = t * math.cos(phi)
        s1 = -t * math.cos(phi + math.pi / 3)
        s2 = -t * math.cos(phi - math.pi / 3)
        num = 3
    else -- One real solution
        local sqrt_D = math.sqrt(D)
        local u = CubeRoot(sqrt_D - q)
        local v = -CubeRoot(sqrt_D + q)

        s0 = u + v
        num = 1
    end

    -- Resubstitute
    sub = 1 / 3 * A

    if num > 0 then s0 = s0 - sub end
    if num > 1 then s1 = s1 - sub end
    if num > 2 then s2 = s2 - sub end

    return s0, s1, s2
end local SolveQuartic = function(c0, c1, c2, c3, c4)
    -- Normalization
    local A = c1 / c0
    local B = c2 / c0
    local C = c3 / c0
    local D = c4 / c0

    -- Calculate coefficients for the resolvent cubic
    local sq_A = A * A
    local p = -0.375 * sq_A + B
    local q = 0.125 * sq_A * A - 0.5 * A * B + C
    local r = -(3 / 256) * sq_A * sq_A + 0.0625 * sq_A * B - 0.25 * A * C + D

    local num, s0, s1, s2, s3

    if IsZero(r) then
        -- Case when there is no absolute term (r == 0)
        local coeffs = {q, p, 0, 1}
        local results = {SolveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])}
        num = #results
        s0, s1, s2 = results[1], results[2], results[3]
    else
        -- Solve the resolvent cubic
        local coeffs = {0.5 * r * p - 0.125 * q * q, -r, -0.5 * p, 1}
        local cubic_results = {SolveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])}
        s0 = cubic_results[1]

        -- Calculate discriminants for the quadric equations
        local u = s0 * s0 - r
        local v = 2 * s0 - p

        if IsZero(u) then
            u = 0
        elseif u > 0 then
            u = math.sqrt(u)
        else
            return
        end

        if IsZero(v) then
            v = 0
        elseif v > 0 then
            v = math.sqrt(v)
        else
            return
        end

        -- Solve the two quadric equations
        local quadric_coeffs = {{z = s0 - u, q = q < 0 and -v or v}, {z = s0 + u, q = q < 0 and v or -v}}

        for i = 1, 2 do
            local quadric_results = {SolveQuadric(1, quadric_coeffs[i].q, quadric_coeffs[i].z)}
            num = num + #quadric_results
            if num == 1 then
                s1, s2 = quadric_results[1], quadric_results[2]
            elseif num == 2 then
                s2, s3 = quadric_results[1], quadric_results[2]
            end
        end
    end

    -- Resubstitute
    local sub = 0.25 * A
    if num > 0 then s0 = s0 - sub end
    if num > 1 then s1 = s1 - sub end
    if num > 2 then s2 = s2 - sub end
    if num > 3 then s3 = s3 - sub end

    return s3, s2, s1, s0
end

function Module.SolveTrajectory(Origin, TPos, TVelocity, ProjectileSpeed, ProjectileGravity, GravityCorrection, Option)
    Gravity, GravityCorrection, Option = ProjectileGravity or workspace.Gravity, GravityCorrection or 2, Option or 1;

    local Disp = (TPos - Origin);
    GCorrection = -(Gravity / GravityCorrection);

    if Option == 1 then
        local Tof = SolveQuartic(
            GCorrection * GCorrection,
            -GravityCorrection * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - GravityCorrection * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            GravityCorrection * Disp.Y * TVelocity.Y + GravityCorrection * Disp.X * TVelocity.X + GravityCorrection * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        );

        if Tof and Tof > 0 then
            return Origin + Vector3.new(
                (Disp.X + TVelocity.X * Tof) / Tof,
                (Disp.Y + TVelocity.Y * Tof - GravityCorrection * Tof * Tof) / Tof,
                (Disp.Z + TVelocity.Z * Tof) / Tof
            );
        end;
    elseif Option == 2 then
    end;

    return TPos;
end;

return Module;

--[[local T = workspace.;
print(T.Position)
print(Module.SolveTrajectory(workspace:FindFirstChildOfClass("Camera").CFrame.Position - Vector3.new(0, 1, 0), T.Position, T.AssemblyLinearVelocity, 100, 5, 2, 1));]]
