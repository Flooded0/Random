local Module = {};

-- Checks If Number Is Close Enough To 0 To Be Considered 0 (For Our Purposes)
local IsZero = function(Number)
	local Epsilon = 1e-9; -- Definitely Small Enough (0.000000001)
	return (Number > -Epsilon and Number < Epsilon);
end;

-- Fixes An Issue With math.pow That Returns Nan When The Result Should Be A Real Number
local CubeRoot = function(Number)
	--return (Number > 0) and math.pow(Number, (1 / 3)) or -math.pow(math.abs(Number), (1 / 3));
    return (Number > 0) and Number ^ (1 / 3) or -((-Number) ^ (1 / 3))
end

--[[
    SolveQuadric(number a, number b, number c)
    Returns Number x0, Number x1

    Solves For The Roots Of A Quadratic Equation Of The Form:
    ax^2 + bx + c = 0

    Returns Nil If The Roots Do Not Exist
	--Maybe Supports More Complex Stuff --Or Are Complex.
--]]
local SolveQuadric = function(c0, c1, c2)
	local s0, s1

	local p, q, D

	-- x^2 + px + q = 0
	p = c1 / (2 * c0)
	q = c2 / c0

	D = p * p - q

	if IsZero(D) then
		s0 = -p
		return s0
	elseif (D < 0) then
		local SqrtDiscriminant = math.sqrt(-D);
        local RealPart = -c1 / (2 * c0);
        local ImagPart = SqrtDiscriminant / (2 * c0);
        s0 = {Real = RealPart, Imag = ImagPart};
        s1 = {Real = RealPart, Imag = -ImagPart};
        return s0, s1;
		--return
	else -- if (D > 0)
		local sqrt_D = math.sqrt(D)

		s0 = sqrt_D - p
		s1 = -sqrt_D - p
		return s0, s1
	end
end

--[[
	solveCubic(number a, number b, number c, number d)
	returns number s0, number s1, number s2

	Will return nil for roots that do not exist.

	Solves for the roots of cubic polynomials of the following form:
	ax^3 + bx^2 + cx + d = 0
--]]
local SolveCubic = function(c0, c1, c2, c3)
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
end;

--[[
	solveQuartic(number a, number b, number c, number d, number e)
	returns number s0, number s1, number s2, number s3

	Will return nil for roots that do not exist.

	Solves for the roots of quartic polynomials of the form:
	ax^4 + bx^3 + cx^2 + dx + e = 0
--]]
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

	return s3, s2, s1, s0;
	--return s0, s1, s2, s3
	--return {s3, s2, s1, s0}
end;

function Module.SolveTrajectory(Origin, TPos, TVelocity, ProjectileSpeed, Gravity, GravityCorrection)
	Gravity = Gravity or workspace.Gravity;
	GravityCorrection = GravityCorrection or 2;

	local Disp = TPos - Origin;

	--local TargetX, TargetY, TargetZ = Disp.X, Disp.Y, Disp.Z;
	--local InitialVelX, InitialVelY, InitialVelZ = TVelocity.X, TVelocity.Y, TVelocity.Z
	local GCorrection = -(Gravity / GravityCorrection) -- gravity correction

	--[[local Solutions = SolveQuartic(
		GCorrection * GCorrection,
		-2 * InitialVelY * GCorrection,
		InitialVelY * InitialVelY - 2 * TargetY * GCorrection - ProjectileSpeed * ProjectileSpeed + InitialVelX * InitialVelX + InitialVelZ * InitialVelZ,
		2 * TargetY * InitialVelY + 2 * TargetX * InitialVelX + 2 * TargetZ * InitialVelZ,
		TargetY * TargetY + TargetX * TargetX + TargetZ * TargetZ
	);]]
    local T0, T1, T2, T3 = SolveQuartic(
		GCorrection * GCorrection,
		-GravityCorrection * TVelocity.Y * GCorrection,
		TVelocity.Y * TVelocity.Y - GravityCorrection * Disp.Y * GCorrection - ProjectileSpeed * ProjectileSpeed + TVelocity.X * TVelocity.X + TVelocity.Z * TVelocity.Z,
		GravityCorrection * Disp.Y * TVelocity.Y + GCorrection * Disp.X * TVelocity.X + GravityCorrection * Disp.Z * TVelocity.Z,
		Disp.Y * Disp.Y + Disp.X * Disp.X + Disp.Z * Disp.Z
	);

	local T = nil;
	if T0 and T0 > 0 then
		T = T0;
	elseif T1 and T1 > 0 then
		T = T1;
	elseif T2 and T2 > 0 then
		T = T2;
	elseif T3 and T3 > 0 then
		T = T3;
	end;

	if not T then return Origin; end;
	return Origin + Vector3.new(
		(Disp.X + TVelocity.X * T) / T,
		(Disp.Y + TVelocity.Y * T - GCorrection * T * T) / T,
		(Disp.Z + TVelocity.Z * T) / T
	);

	--[[if Solutions then
		local PosRoots = table.create(2);
		for Index = 1, #Solutions do --Filter Out The Negative Roots
			local Solution = Solutions[Index];
			if Solution > 0 then
				table.insert(PosRoots, Solution);
			end;
		end;

		if PosRoots[1] then
			local PR = PosRoots[1];
			local X = (TargetX + InitialVelX * PR) / PR;
			local Y = (TargetY + InitialVelY * PR - GCorrection * PR * PR) / PR;
			local Z = (TargetZ + InitialVelZ * PR) / PR;
			return Origin + Vector3.new(X, Y, Z);
		end;
	end;]]

	--[[if Solutions and Solutions[1] > 0 then
		local S1 = Solutions[1];
		local X = (TargetX + InitialVelX * S1) / S1;
		local Y = (TargetY + InitialVelY * S1 - GCorrection * S1 * S1) / S1;
		local Z = (TargetZ + InitialVelZ * S1) / S1;

		return Origin + Vector3.new(X, Y, Z);
	end;]]
end;

return Module;