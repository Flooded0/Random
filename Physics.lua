local Physics = {};

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
end; local SolveCubic = function(C0, C1, C2, C3)
	local S0, S1, S2, Num, Sub, A, B, C, SQ_A, P, Q, CB_P, D;

	-- Normal Form: x^3 + Ax^2 + Bx + C = 0
	A, B, C = C1 / C0, C2 / C0, C3 / C0;

	-- Substitute x = y - A/3 To Eliminate Quadric Term: x^3 + px + q = 0
	SQ_A = A * A;
	P = (1 / 3) * (-(1 / 3) * SQ_A + B);
	Q = 0.5 * ((2 / 27) * A * SQ_A - (1 / 3) * A * B + C);

	-- Use Cardano's Formula
	CB_P = P * P * P;
	D = Q * Q + CB_P;

	if IsZero(D) then
        if IsZero(Q) then -- One Triple Solution
            S0 = 0;
            Num = 1;
            --return S0
        else -- One Single & One Double Solution
            local u = CubeRoot(-Q);
            S0 = 2 * u;
            S1 = -u;
            Num = 2;
            --return S0, S1
        end;
	elseif (D < 0) then -- Casus Irreducibilis: Three Real Solutions
        local Phi = (1 / 3) * math.acos(-Q / math.sqrt(-CB_P))
        local T = 2 * math.sqrt(-P)

        S0 = T * math.cos(Phi);
        S1 = -T * math.cos(Phi + math.pi / 3);
        S2 = -T * math.cos(Phi - math.pi / 3);
        Num = 3
        --return S0, S1, S2
	else -- One Real Solution
        local sqrt_D = math.sqrt(D);
        local u = CubeRoot(sqrt_D - Q);
        local v = -CubeRoot(sqrt_D + Q);

        S0 = u + v;
        Num = 1;
        --return S0
	end;

	-- Resubstitute
	Sub = (1 / 3) * A;

	if (Num > 0) then S0 = S0 - Sub; end;
	if (Num > 1) then S1 = S1 - Sub; end;
	if (Num > 2) then S2 = S2 - Sub; end;

	return S0, S1, S2;
end; local SolveQuartic = function(C0, C1, C2, C3, C4)
    local S0, S1, S2, S3, Z, U, V, Sub, A, B, C, D, SQ_A, P, Q, R, Num;
    local Coeffs = {};

    -- Mormal Form: x^4 + Ax^3 + Bx^2 + Cx + D = 0
    A, B, C, D = C1 / C0, C2 / C0, C3 / C0, C4 / C0;

    -- Substitute x = y - A/4 To Eliminate Cubic Term: x^4 + px^2 + qx + r = 0
    SQ_A = A * A;
    P = -0.375 * SQ_A + B;
    Q = 0.125 * SQ_A * A - 0.5 * A * B + C;
    R = -(3 / 256) * SQ_A * SQ_A + 0.0625 * SQ_A * B - 0.25 * A * C + D;

    if IsZero(R) then
        -- No Absolute Term: y(y^3 + py + q) = 0
        Coeffs[3] = Q;
        Coeffs[2] = P;
        Coeffs[1] = 0;
        Coeffs[0] = 1;

        local Results = {SolveCubic(Coeffs[0], Coeffs[1], Coeffs[2], Coeffs[3])};
        Num = #Results; S0, S1, S2 = Results[1], Results[2], Results[3];
    else
        -- Solve The Resolvent Cubic …
        Coeffs[3] = 0.5 * R * P - 0.125 * Q * Q;
        Coeffs[2] = -R;
        Coeffs[1] = -0.5 * P;
        Coeffs[0] = 1;

        S0, S1, S2 = SolveCubic(Coeffs[0], Coeffs[1], Coeffs[2], Coeffs[3]);

        -- … & Take The one Real Solution …
        Z = S0;

        -- … To Build Two Quadric Equations
        U = Z * Z - Q;
        V = 2 * Z - P;

        if IsZero(U) then
            U = 0;
        elseif (U > 0) then
            U = math.sqrt(U);
        else return;
        end; if IsZero(V) then
            V = 0;
        elseif (V > 0) then
            V = math.sqrt(V);
        else return;
        end;

        Coeffs[2] = Z - U;
        Coeffs[1] = Q < 0 and -V or V;
        Coeffs[0] = 1;

        do
            local Results = {SolveQuadric(Coeffs[0], Coeffs[1], Coeffs[2])};
            Num = #Results; S0, S1 = Results[1], Results[2];
        end;

        Coeffs[2] = Z + U;
        Coeffs[1] = Q < 0 and V or -V;
        Coeffs[0] = 1;

        if (Num == 0) then
            local Results = {SolveQuadric(Coeffs[0], Coeffs[1], Coeffs[2])};
            Num = Num + #Results; S0, S1 = Results[1], Results[2];
        end; if (Num == 1) then
            local Results = {SolveQuadric(Coeffs[0], Coeffs[1], Coeffs[2])}
            Num = Num + #Results; S1, S2 = Results[1], Results[2];
        end; if (Num == 2) then
            local Results = {SolveQuadric(Coeffs[0], Coeffs[1], Coeffs[2])};
            Num = Num + #Results; S2, S3 = Results[1], Results[2];
        end;
    end;

    -- Resubstitute
    Sub = 0.25 * A;

    if (Num > 0) then S0 = S0 - Sub; end;
    if (Num > 1) then S1 = S1 - Sub; end;
    if (Num > 2) then S2 = S2 - Sub; end
    if (Num > 3) then S3 = S3 - Sub; end;

    return S3, S2, S1, S0;
    --return S0, S1, S2, S3;
    --return {S3, S2, S1, S0};
end;

function Physics.SolveTrajectory(Origin, TPos, TVelocity, ProjectileSpeed, ProjectileGravity, GravityCorrection, Option)
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

--[[local T = workspace.;
print(T.Position)
print(Physics.SolveTrajectory(workspace:FindFirstChildOfClass("Camera").CFrame.Position - Vector3.new(0, 1, 0), T.Position, T.AssemblyLinearVelocity, 100, 5, 2, 1));]]

return Physics;

--[[local Physics = {};

local DotF = function(V1, V2) return V1:Dot(V2); end;
local QuarticRoots = function(A, B, C, D, E)
    local X0, X1, X2, X3;
    local M10 = 3 * A;
    local M0 = -B / (4 * A);
    local M4 = C * C - 3 * B * D + 12 * A * E;
    local M6 = (B * B / (4 * A) - 2 / 3 * C) / A;
    local M9 = ((B * (4 * C - B * B / A)) / A - (8 * D)) / A;
    local M5 = C * (2 * C * C - 9 * B * D - 72 * A * E) + 27 * A * D * D + 27 * B * B * E;
    local M11 = M5 * M5 - 4 * M4 * M4 * M4;
    local M7;

    if M11 < 0 then
        local Th = math.atan2((-M11) ^ 0.5, M5) / 3;
        local M = ((M5 * M5 - M11) / 4) ^ (1 / 6);
        M7 = (M4 / M + M) / M10 * math.cos(Th);
    else
        local M8 = (M5 + M11 ^ 0.5) / 2;
        M8 = M8 < 0 and -(-M8) ^ (1 / 3) or M8 ^ (1 / 3);
        M7 = (M4 / M8 + M8) / M10;
    end;

    local M2 = 2 * M6 - M7;
    local m12 = M6 + M7;

    if m12 < 0 then
        local M3i = M9 / (4 * (-m12) ^ 0.5);
        local M13 = (M3i * M3i + M2 * M2) ^ (1 / 4) * math.cos(math.atan2(M3i, M2) / 2) / 2;
        X0 = M0 - M13;
        X1 = M0 - M13;
        X2 = M0 + M13;
        X3 = M0 + M13;
    else
        local M1 = m12 ^ 0.5;
        local M3 = M9 / (4 * M1);
        local M14 = M2 - M3;
        local M15 = M2 + M3;

        if M14 < 0 then
            X0 = M0 - M1 / 2;
            X1 = M0 - M1 / 2;
        else
            local m16 = M14 ^ 0.5;
            X0 = M0 - (M1 + m16) / 2;
            X1 = M0 - (M1 - m16) / 2;
        end;

        if M15 < 0 then
            X2 = M0 + M1 / 2;
            X3 = M0 + M1 / 2;
        else
            local M17 = M15 ^ 0.5;
            X2 = M0 + (M1 - M17) / 2;
            X3 = M0 + (M1 + M17) / 2;
        end;

        if X1 < X0 then X0, X1 = X1, X0; end;
        if X2 < X1 then X1, X2 = X2, X1; end;
        if X3 < X2 then X2, X3 = X3, X2; end;
        if X1 < X0 then X0, X1 = X1, X0; end;
        if X2 < X1 then X1, X2 = X2, X1; end;
        if X1 < X0 then X0, X1 = X1, X0; end;
    end;

    return X0, X1, X2, X3;
end; local CubicRoots = function(A, B, C, D)
    local X0, X1, X2;
    local D0 = B * B - 3 * A * C;
    local D1 = 2 * B * B * B + 27 * A * A * D - 9 * A * B * C;
    local CD = D1 * D1 - 4 * D0 * D0 * D0;
    local M0 = -1 / (3 * A);

    if CD < 0 then
        local CR, CI = D1 / 2, (-CD) ^ 0.5 / 2;
        local Th = math.atan2(CI, CR) / 3;
        local M = (CR * CR + CI * CI) ^ (1 / 6);
        local CRN, CIN = M * math.cos(Th), M * math.sin(Th);
        --local M1 = (1 + D0 / (M * M)) / 2;
        local M2 = (CIN * D0 + (CRN - 2 * B) * M * M) / (6 * A * M * M);
        local M3 = CI * (D0 + M * M) / (2 * 3 ^ 0.5 * A * M * M);
        X0 = -(B + CR * (1 + D0 / (M * M))) / (3 * A);
        X1 = M2 - M3;
        X2 = M2 + M3;
    else
        local C3 = (D1 + (CD) ^ 0.5) / 2;
        local CN = C3 < 0 and -(-C3) ^ (1 / 3) or C3 ^ (1 / 3);
        X0 = M0 * (B + CN + D0 / CN);
        X1 = M0 * (B - (CN * CN + D0) / (2 * CN));
        X2 = X1;
    end;

    if X1 < X0 then X0, X1 = X1, X0; end;
    if X2 < X1 then X1, X2 = X2, X1; end;
    if X1 < X0 then X0, X1 = X1, X0; end;

    return X0, X1, X2;
end; local QuadraticRoots = function(A, B, C)
    local P = -B / (2 * A);
    local Q2 = P * P - C / A;

    if Q2 > 0 then
        local Q = Q2 ^ 0.5;
        return P - Q, P + Q;
    else
        return P, P;
    end;
end;

local SolveMoar;
Solve = function(a, b, c, d, e)
    if math.abs(a * a) < 1e-32 then
        return Solve(b, c, d, e)
    elseif e then
        if math.abs(e * e) < 1e-32 then
            return SolveMoar(a, b, c, d)
        elseif math.abs(b * b) < 1e-12 and math.abs(d * d) < 1e-12 then
            local roots = {}
            local r0, r1 = QuadraticRoots(a, c, e)

            if r0 then
                if r0 > 0 then
                    local x = math.sqrt(r0)
                    roots[#roots + 1] = -x
                    roots[#roots + 1] = x
                elseif r0 * r0 < 1e-32 then
                    roots[#roots + 1] = 0
                end
            end

            if r1 then
                if r1 > 0 then
                    local x = math.sqrt(r1)
                    roots[#roots + 1] = -x
                    roots[#roots + 1] = x
                elseif r1 * r1 < 1e-32 then
                    roots[#roots + 1] = 0
                end
            end

            table.sort(roots)
            return unpack(roots)
        else
            local roots = {}
            local found = {}
            local x0, x1, x2, x3 = QuarticRoots(a, b, c, d, e)
            local d0, d1, d2 = CubicRoots(4 * a, 3 * b, 2 * c, d)
            local m0, m1, m2, m3, M4 = -math.huge, d0, d1, d2, math.huge
            local l0, l1, l2, l3, l4 = a * math.huge, (((a * d0 + b) * d0 + c) * d0 + d) * d0 + e, (((a * d1 + b) * d1 + c) * d1 + d) * d1 + e, (((a * d2 + b) * d2 + c) * d2 + d) * d2 + e, a * math.huge

            if (l0 <= 0) == (0 <= l1) then
                if not roots[#roots + 1] then
                    return
                end
                roots[#roots + 1] = x0
                found[x0] = true
            end

            if (l1 <= 0) == (0 <= l2) and not found[x1] then
                roots[#roots + 1] = x1
                found[x1] = true
            end

            if (l2 <= 0) == (0 <= l3) and not found[x2] then
                roots[#roots + 1] = x2
                found[x2] = true
            end

            if (l3 <= 0) == (0 <= l4) and not found[x3] then
                roots[#roots + 1] = x3
            end

            return unpack(roots)
        end
    elseif d then
        if math.abs(d * d) < 1e-32 then
            return SolveMoar(a, b, c)
        elseif math.abs(b * b) < 1e-12 and math.abs(c * c) < 1e-12 then
            local p = d / a
            return p < 0 and (-p)^(1/3) or -p^(1/3)
        else
            local roots = {}
            local found = {}
            local x0, x1, x2 = CubicRoots(a, b, c, d)
            local d0, d1 = QuadraticRoots(3 * a, 2 * b, c)
            local l0, l1, l2, l3 = -a * math.huge, ((a * d0 + b) * d0 + c) * d0 + d, ((a * d1 + b) * d1 + c) * d1 + d, a * math.huge

            if (l0 <= 0) == (0 <= l1) then
                roots[#roots + 1] = x0
                found[x0] = true
            end

            if (l1 <= 0) == (0 <= l2) and not found[x1] then
                roots[#roots + 1] = x1
                found[x1] = true
            end

            if (l2 <= 0) == (0 <= l3) and not found[x2] then
                roots[#roots + 1] = x2
            end

            return unpack(roots)
        end
    elseif c then
        local p = -b / (2 * a)
        local q2 = p * p - c / a

        if q2 > 0 then
            local q = math.sqrt(q2)
            return p - q, p + q
        elseif q2 == 0 then
            return p
        end
    elseif b then
        if math.abs(a * a) > 1e-32 then
            return -b / a;
        end;
    end;
end; SolveMoar = function(A, B, C, D, E)
	local Good, Roots = true, {Solve(A, B, C, D, E)};
	for Index = 1, #Roots do if Roots[Index] == 0 then Good = false; break; end; end;
	if Good then Roots[#Roots + 1] = 0; table.sort(Roots); end;
	return unpack(Roots);
end;

function Physics.TimeToHit(TPosition, ProjectileSpeed, StartingPosition, Gravity)
    local Distance = (TPosition - StartingPosition).Magnitude;
    return ProjectileSpeed / Gravity + math.sqrt(2 * Distance / Gravity + ProjectileSpeed ^ 2 / Gravity ^ 2);
end; function Physics.Trajectory(PlrPosition, PlrVelocity, PlrAcceleration, TPosition, TVelocity, TAcceleration, Separation)
    local RPosition, RVelocity, RAcceleration = TPosition - PlrPosition, TVelocity - PlrVelocity, TAcceleration - PlrAcceleration;
    local Time0, Time1, Time2, Time3 = QuarticRoots(
        DotF(RAcceleration, RAcceleration) / 4,
        DotF(RAcceleration, RVelocity),
        DotF(RAcceleration, RPosition) + DotF(RVelocity, RVelocity) - Separation ^ 2,
        2 * DotF(RPosition, RVelocity),
        DotF(RPosition, RPosition)
    );

    if Time0 and Time0 > 0 then
        return RAcceleration * Time0 / 2 + TVelocity + RPosition / Time0, Time0;
    elseif Time1 and Time1 > 0 then
        return RAcceleration * Time1 / 2 + TVelocity + RPosition / Time1, Time1;
    elseif Time2 and Time2 > 0 then
        return RAcceleration * Time2 / 2 + TVelocity + RPosition / Time2, Time2;
    elseif Time3 and Time3 > 0 then
        return RAcceleration * Time3 / 2 + TVelocity + RPosition / Time3, Time3;
    end;
end;

-- Test the QuadraticRoots function
local a, b, c = 1, -3, 2
local x0, x1, x2 = QuadraticRoots(a, b, c)
print("Quadratic Roots:")
print("x0:", x0)
print("x1:", x1)
print("x2:", x2)

-- Test the CubicRoots function
local a, b, c, d = 1, -6, 11, -6
local x0, x1, x2 = CubicRoots(a, b, c, d)
print("\nCubic Roots:")
print("x0:", x0)
print("x1:", x1)
print("x2:", x2)

-- Test the QuarticRoots function
local a, b, c, d, e = 1, -10, 35, -50, 24
local x0, x1, x2, x3 = QuarticRoots(a, b, c, d, e)
print("\nQuartic Roots:")
print("x0:", x0)
print("x1:", x1)
print("x2:", x2)
print("x3:", x3)

-- Test the Trajectory function
local PlrPosition = Vector3.new(0, 0, 0)
local PlrVelocity = Vector3.new(2, 0, 0)
local PlrAcceleration = Vector3.new(0, -9.81, 0) -- Earth gravity
local TPosition = Vector3.new(10, 0, 0)
local TVelocity = Vector3.new(0, 0, 0)
local TAcceleration = Vector3.new(0, -9.81, 0) -- Earth gravity
local Separation = 5

local result, time = Physics.Trajectory(PlrPosition, PlrVelocity, PlrAcceleration, TPosition, TVelocity, TAcceleration, Separation)
print("\nTrajectory Calculation:")
print("Resulting Position:", result)
print("Time to Intercept:", time)


local Delta_TimeToHit = Physics.TimeToHit(Target, ProjectileSpeed, Args[4], -(game:GetService("Workspace").Gravity / 2))
local Delta_Target = TPart.Position + (TPart.AssemblyLinearVelocity * Delta_TimeToHit)

local Curve = Physics.Trajectory(Args[4], Vector3.new(), Vector3.new(0, -(game:GetService("Workspace").Gravity / 2), 0), Delta_Target, Vector3.new(), Vector3.new(), ProjectileSpeed)
--if Curve then
	local CurrentSpread = (math.random(0, -(Flags[GameTitle .. " SAAccuracyV"]) + 100) / 100) * 5;
	local PPos = Args[4] + Curve + Vector3.new(CurrentSpread, CurrentSpread, CurrentSpread);
	Args[5] = (PPos - Args[4]).Unit;
--end;

return Physics;]]