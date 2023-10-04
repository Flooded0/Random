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
        return {Real = -P, Imag1 =  SqrtD * InvA / 2, Imag2 = -SqrtD * InvA / 2};
    else -- if D > 0
        local SqrtD = math.sqrt(D);
        return SqrtD - P, -SqrtD - P;
    end;
end;

--[[local SolveCubic = function(A, B, C, D)
    local Discriminant, CoefficientA, CoefficientB, CoefficientC;

    CoefficientA, CoefficientB, CoefficientC= B / A, C / A, D / A;

    local P = (-(1 / 3) * (CoefficientA * CoefficientA) + CoefficientB) / 3;
    local Q = ((2 / 27) * (CoefficientA * CoefficientA * CoefficientA) - (1 / 3) * (CoefficientA * CoefficientB) + CoefficientC) / 2;

    local CB_P = P * P * P;
    Discriminant = Q * Q + CB_P;

    if IsZero(Discriminant) then
        if IsZero(Q) then
            return 0;
        else
            local u = CubeRoot(-Q);
            return 2 * u - (1 / 3) * CoefficientA, -u - (1 / 3) * CoefficientA;
        end;
    elseif Discriminant < 0 then
        local Phi = (1 / 3) * math.acos(-Q / math.sqrt(-CB_P));
        local T = 2 * math.sqrt(-P);
        return T * math.cos(Phi) - (1 / 3) * CoefficientA, -T * math.cos(Phi + math.pi / 3) - (1 / 3) * CoefficientA, -T * math.cos(Phi - math.pi / 3) - (1 / 3) * CoefficientA;
    else
        local SqrtD = math.sqrt(Discriminant);
        local U = CubeRoot(SqrtD - Q);
        local V = -CubeRoot(SqrtD + Q);
        return U + V - (1 / 3) * CoefficientA;
    end;
end;]]
local SolveCubic = function(a, b, c, d)
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

local SolveQuartic = function(a, b, c, d, e)
    local NumSolutions;
    local Solutions = {};

    local A = b / a;
    local B = c / a;
    local C = d / a;
    local D = e / a;

    local SqA = A * A;
    local P = -0.375 * SqA + B;
    local Q = 0.125 * SqA * A - 0.5 * A * B + C;
    local R = -(3 / 256) * SqA * SqA + 0.0625 * SqA * B - 0.25 * A * C + D;

    if IsZero(R) then
        -- No Absolute Term: y(y^3 + py + q) = 0
        local CubicCoeffs = {Q, P, 0, 1};
        local CubicRoots = {SolveCubic(1, CubicCoeffs[3], CubicCoeffs[2], CubicCoeffs[1])};
        NumSolutions = #CubicRoots;
        for I, Root in ipairs(CubicRoots) do
            Solutions[I] = Root - 0.25 * A; -- Subtract Sub Directly Here
        end;
    else
        -- Solve the resolvent cubic ...
        local CubicCoeffs = {0.5 * R * P - 0.125 * Q * Q, -R, -0.5 * P};
        local CubicRoots = {SolveCubic(1, CubicCoeffs[3], CubicCoeffs[2], CubicCoeffs[1])};
        NumSolutions = #CubicRoots;

        -- ... And Take One Real Solution ...
        local Z = CubicRoots[1];

        -- ... To Build Two Quadratic Equations
        local U = Z * Z - R;
        local V = 2 * Z - P;

        if U > 0 then
            U = math.sqrt(U);
        else
            U = 0;
        end; if V > 0 then
            V = math.sqrt(V);
        else
            V = 0;
        end;

        local QuadCoeffs1 = {Z - U, Q < 0 and -V or V};
        local QuadCoeffs2 = {Z + U, Q < 0 and V or -V};

        -- Solve The Quadratic Equations
        local QuadRoots1, QuadRoots2 = {SolveQuadric(1, QuadCoeffs1[2], QuadCoeffs1[1])}, {SolveQuadric(1, QuadCoeffs2[2], QuadCoeffs2[1])};
        local NumQuadRoots1, NumQuadRoots2 = #QuadRoots1, #QuadRoots2;

        -- Add The Roots To The Solutions
        for I = 1, NumQuadRoots1 do
            Solutions[I] = QuadRoots1[I] - 0.25 * A; -- Subtract Sub Directly Here
        end; for I = 1, NumQuadRoots2 do
            Solutions[NumQuadRoots2 + I] = QuadRoots2[I] - 0.25 * A -- Subtract Sub directly here
        end

        NumSolutions = NumQuadRoots1 + NumQuadRoots2;
    end;

    return unpack(Solutions, 1, NumSolutions);
end;

function Module.SolveTrajectory(Origin, TPos, TVelocity, ProjectileSpeed, ProjectileGravity, GravityCorrection, Option)
    Gravity, GravityCorrection, Option = ProjectileGravity or workspace.Gravity, GravityCorrection or 2, Option or 1;

    local Disp = (TPos - Origin);
    GCorrection = -(Gravity / GravityCorrection);

    if Option == 1 then
        -- Solve the quartic equation
        local Tof = {SolveQuartic(
            GCorrection * GCorrection,
            -2 * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - 2 * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            2 * Disp.Y * TVelocity.Y + 2 * Disp.X * TVelocity.X + 2 * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        )};

        -- Check If There Are Valid Solutions And Tof > 0
        if #Tof > 0 then
            for _, TofS in ipairs(Tof) do
                if TofS > 0 then
                    -- Calculate The Updated Position (Return It)
                    return Origin + Vector3.new(
                        (Disp.X + TVelocity.X * TofS) / TofS,
                        (Disp.Y + TVelocity.Y * TofS - GCorrection * TofS * TofS) / TofS,
                        (Disp.Z + TVelocity.Z * TofS) / TofS
                    );
                end;
            end;
        end;
    elseif Option == 2 then
        -- Solve The Quartic Equation
        local Solutions = {SolveQuartic(
            GCorrection * GCorrection,
            -2 * TVelocity.Y * GCorrection,
            TVelocity.Y * TVelocity.Y - 2 * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
            2 * Disp.Y * TVelocity.Y + 2 * Disp.X * TVelocity.X + 2 * Disp.Z * TVelocity.Z,
            Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
        )};

        -- Check If There Are Valid Solutions
        if Solutions then
            local PosRoots = {};

            -- Find Positive Roots
            for _, Solution in ipairs(Solutions) do
                if Solution > 0 then
                    table.insert(PosRoots, Solution);
                end;
            end;

            -- Check If There Are Positive Roots
            if PosRoots[1] then
                local PR = PosRoots[1]

                -- Calculate The Updated Position Based On The First Positive Root
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
