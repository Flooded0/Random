local Module = {};

local IsZero = function(Number)
    local Epsilon = 1e-9; return (Number > -Epsilon and Number < Epsilon);
end;
local CubeRoot = function(Number)
    return (Number >= 0) and Number ^ (1 / 3) or -((-Number) ^ (1 / 3));
end;

local SolveQuadric = function(A, B, C)
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
        local RealPart = -P;
        local ImagPart = SqrtD * InvA / 2;
        return {Real = RealPart, Imag = ImagPart}, {Real = RealPart, Imag = -ImagPart};
    else -- if D > 0
        local SqrtD = math.sqrt(D);
        return SqrtD - P, -SqrtD - P;
    end;
end;

local SolveCubic = function(A, B, C, D)
    if A == 0 then
        if B == 0 then
            if C == 0 then
                return nil;
            else
                return -D / C;
            end
        else
            local Discriminant = C * C - 4 * B * D;
            if IsZero(Discriminant) then
                return -C / (2 * B);
            elseif Discriminant < 0 then
                return nil;
            else
                local SqrtD = math.sqrt(Discriminant);
                return (-C + SqrtD) / (2 * B), (-C - SqrtD) / (2 * B);
            end
        end
    else
        B, C, D = B / A, C / A, D / A;

        local P = C - B * B/ 3;
        local Q = (B * (2 * B * B - 9 * C) / 27 + D) / 2;

        local Discriminant = Q * Q + P * P * P / 27;
        if IsZero(Discriminant) then
            local U = CubeRoot(-Q);
            return 2 * U - B / 3 * A, -U - B / 3 * A, -U - B / 3 * A;
        elseif Discriminant < 0 then
            local SqrtD = math.sqrt(-Discriminant);
            local U = CubeRoot(math.sqrt((-Q * Q) / 27));
            local V = math.atan(SqrtD, -Q) / 3;
            return 2 * U * math.cos(V) - B / 3 * A, -U * (math.cos(V) + math.sqrt(3) * math.sin(V)) - B / 3 * A, -U * (math.cos(V) -math.sqrt(3) * math.sin(V)) - B / 3 * A;
        else
            local SqrtD = math.sqrt(Discriminant);
            local U = CubeRoot(SqrtD - Q);
            local V = CubeRoot(SqrtD + Q);
            return U + V - B / 3 * A;
        end;
    end;
end;
--[[local SolveCubic = function(c0, c1, c2, c3)
    local s0, s1, s2

    local num, sub
    local A, B, C
    local sq_A, p, q
    local cb_p, D

    -- normal form: x^3 + Ax^2 + Bx + C = 0
    A = c1 / c0
    B = c2 / c0
    C = c3 / c0

    -- substitute x = y - A/3 to eliminate quadric term: x^3 + px + q = 0
    sq_A = A * A
    p = (1 / 3) * (-(1 / 3) * sq_A + B)
    q = 0.5 * ((2 / 27) * A * sq_A - (1 / 3) * A * B + C)

    -- use Cardano's formula
    cb_p = p * p * p
    D = q * q + cb_p

    if IsZero(D) then
        if IsZero(q) then -- one triple solution
            s0 = 0
            num = 1
            --return s0
        else -- one single and one double solution
            local u = CubeRoot(-q)
            s0 = 2 * u
            s1 = -u
            num = 2
            --return s0, s1
        end
    elseif (D < 0) then -- Casus irreducibilis: three real solutions
        local phi = (1 / 3) * math.acos(-q / math.sqrt(-cb_p))
        local t = 2 * math.sqrt(-p)

        s0 = t * math.cos(phi)
        s1 = -t * math.cos(phi + math.pi / 3)
        s2 = -t * math.cos(phi - math.pi / 3)
        num = 3
        --return s0, s1, s2
    else -- one real solution
        local sqrt_D = math.sqrt(D)
        local u = CubeRoot(sqrt_D - q)
        local v = -CubeRoot(sqrt_D + q)

        s0 = u + v
        num = 1

        --return s0
    end

    -- resubstitute
    sub = (1 / 3) * A

    if (num > 0) then s0 = s0 - sub end
    if (num > 1) then s1 = s1 - sub end
    if (num > 2) then s2 = s2 - sub end

    return s0, s1, s2
end;]]

local SolveQuartic = function(C0, C1, C2, C3, C4)
    local Coeffs = {};
    local A, B, C, D = C1 / C0, C2 / C0, C3 / C0, C4 / C0;

    local P = -3 * A * A / 8 + B;
    local Q = A * A * A / 8 - A * B / 2 + C
    local R = -3 * A * A * A * A / 256 + A * A * B / 16 - A * C / 4 + D
    local Results = {SolveCubic(1, 2 * P, P * P - 4 * R, -Q * Q)};
    local U = Results[1];

    local Res = {};
    if not U then
        return nil;
    elseif IsZero(U) then
        local V = math.sqrt(P * P - 4 * R);
        local Temp = math.sqrt(-P + (12 * A * A - 4 * V) / U);
        if Temp ~= nil then
            table.insert(Res, (-3 * A * A / 4 + math.sqrt(2) * V) / 2 - Temp / 2 - A / 4);
            table.insert(Res, (-3 * A * A / 4 + math.sqrt(2) * V) / 2 + Temp / 2 - A / 4);
        end
    elseif U > 0 then
        local Y = math.sqrt(U);
        local V = math.sqrt(P * P - 4 * R);
        local Temp = math.sqrt(-P - (12 * A * A + 4 * V) / U);
        if Temp ~= nil then
            table.insert(Res, (-3 * A * A / 4 + math.sqrt(2) * V) / 2 - Y / 2 - Temp / 2 - A / 4);
            table.insert(Res, (-3 * A * A / 4 + math.sqrt(2) * V) / 2 - Y / 2 + Temp / 2 - A / 4);
        end;
    else
        return nil;
    end;

    for Index1 = 1, #Res do
        local Z = Res[Index1];
        Coeffs[3] = Z;
        Coeffs[2] = P / 2 - Z * Z - Q / Z;
        Coeffs[1] = Z - A / 4;
        Coeffs[0] = 1;

        local Results = {SolveQuadric(Coeffs[0], Coeffs[1], Coeffs[2])};
        for Index2 = 1, #Results do
            if IsZero(Results[Index2]) then Results[Index2] = 0; end;
            table.insert(Res, Results[Index2]);
        end;
    end;

    return unpack(Res);
end;
--[[local SolveQuartic = function(c0, c1, c2, c3, c4)
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

    return s3, s2, s1, s0;
    --return s0, s1, s2, s3
    --return {s3, s2, s1, s0}
end;]]

function Module.SolveTrajectory(Origin, TPos, TVelocity, ProjectileSpeed, ProjectileGravity, GravityCorrection, Option)
    Gravity, GravityCorrection = ProjectileGravity or workspace.Gravity, GravityCorrection or 2;

    local Disp = (TPos - Origin);
    local GCorrection = -(Gravity / GravityCorrection);

    if Option == 1 then
        local Tof = SolveQuartic(
            GCorrection * GCorrection,
            -GravityCorrection * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - GravityCorrection * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            GravityCorrection * Disp.Y * TVelocity.Y + GCorrection * Disp.X * TVelocity.X + GravityCorrection * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        );

        if Tof <= 0 then return Origin; end;
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
            -GravityCorrection * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - GravityCorrection * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            GravityCorrection * Disp.Y * TVelocity.Y + GravityCorrection * Disp.X * TVelocity.X + GravityCorrection * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        );

        if Solutions then
            local PosRoots = {};
            for Index = 1, #Solutions do -- Filter Out The Negative Roots
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
end;

return Module;
