local Type, StrTypes = typeof or type, {["boolean"] = true, ["table"] = true, ["userdata"] = true, ["function"] = true, ["number"] = true};
local RawEqual = rawequal or function(A, B) return A == B; end;
local CountTable = function(Table) local Count = 0; for _, _ in next, Table do Count = Count + 1; end; return Count; end;
local StringRet = function(Object, Typ)
    local Ret, MetaTable, OldFunc;
    if not (Typ == "table") then return tostring(Object); end;

    MetaTable = (getrawmetatable or debug.getmetatable or getmetatable)(Object);
    if not MetaTable then return tostring(Object); end;

    OldFunc = rawget(MetaTable, "__tostring");
    if OldFunc ~= nil then rawset(MetaTable, "__tostring", nil); end;
    Ret = tostring(Object);
    if OldFunc ~= nil then rawset(MetaTable, "__tostring", OldFunc); end;
    return Ret;
end;

local function FormatValue(Value)
    local TypOf = Type(Value);
    local FormatTable = {
        string = function(Val) return '"' .. Val .. '"' end,
        number = function(Val)
            if Val == math.huge then return "math.huge"; elseif Val == -math.huge then return "-math.huge"; end;
            return tonumber(Val);
        end,
        boolean = function(Val) return Val and "true" or "false"; end,
        Instance = function(Val) return Val:GetFullName(); end,
        BrickColor = function(Val) return ("BrickColor.new(%d)"):format(Val.Number); end,
        CFrame = function(Val) return ("CFrame.new(%s)"):format(table.concat({Val:GetComponents()}, ", ")); end,
        Color3 = function(Val) return ("Color3.fromRGB(%d, %d, %d)"):format(Val.R * 255, Val.G * 255, Val.B * 255); end,
        Vector2 = function(Val) return ("Vector2.new(%s, %s)"):format(Val.X, Val.Y); end,
        Vector2int16 = function(Val) return ("Vector2int16.new(%d, %d)"):format(Val.X, Val.Y); end,
        Vector3 = function(Val) return ("Vector3.new(%s, %s, %s)"):format(Val.X, Val.Y, Val.Z); end,
        Vector3int16 = function(Val) return ("Vector3int16.new(%d, %d, %d)"):format(Val.X, Val.Y, Val.Z); end,
        UDim2 = function(Val) return ("UDim2.new(%d, %d, %d, %d)"):format(Val.X.Scale, Val.X.Offset, Val.Y.Scale, Val.Y.Offset); end,
        UDim = function(Val) return ("UDim.new(%d, %d)"):format(Val.Scale, Val.Offset); end,
        DateTime  = function(Val) return ("DateTime.fromIsoDate(%q)"):format(Val:ToIsoDate()); end,
        NumberRange = function(Val) return ("NumberRange.new(%s, %s)"):format(Val.Min, Val.Max); end,
        NumberSequence = function(Val) return ("NumberSequence.new(%s)"):format(table.concat(Val.Keyframes, ", ")); end,
        Rect = function(Val) return ("Rect.new(%s, %s, %s, %s)"):format(Val.Min.X, Val.Min.Y, Val.Max.X, Val.Max.Y); end,
        Random = function(Val) return ("Random.new(%d)"):format(Val.Seed); end;
        Ray = function(Val) return ("Ray.new(%s, %s)"):format(FormatValue(Val.Origin), FormatValue(Val.Direction)); end,
        Enum = function(Val) return ("%s.%s"):format(Val.EnumType.Name, Val.Name); end;
        EnumItem = function(Val) return ("%s.%s"):format(Val.EnumType.Name, Val.Name); end;
        RBXScriptConnection = function() return "<RBXScriptConnection>"; end,
        RBXScriptSignal = function() return "<RBXScriptSignal>"; end,
        Axes = function(Val)
            local AxesTable = {}; for _, Axis in ipairs(Enum.Axis:GetEnumItems()) do if Val[Axis.Name] then table.insert(AxesTable, ("Enum.Axis.%s"):format(Axis.Name)); end; end;
            return ("Axes.new(%s)"):format(table.concat(AxesTable, ", "));
        end,
        Faces = function(Val)
            local FacesTable = {}; for _, Face in ipairs(Enum.NormalId:GetEnumItems()) do if Val[Face.Name] then table.insert(FacesTable, ("Enum.NormalId.%s"):format(Face.Name)); end; end;
            return ("Faces.new(%s)"):format(table.concat(FacesTable, ", "));
        end,
        TweenInfo = function(Val)
            if typeof(Val.EasingStyle) == "EnumItem" and typeof(Val.EasingDirection) == "EnumItem" then
                local Fields = {
                    ("Time = %f"):format(Val.Time),
                    ("EasingStyle = Enum.EasingStyle.%s"):format(Val.EasingStyle.Name),
                    ("EasingDirection = Enum.EasingDirection.%s"):format(Val.EasingDirection.Name)
                };
                return ("TweenInfo.new(%s)"):format(table.concat(Fields, ", "));
            else
                return "TweenInfo.new()";
            end;
        end;
        Default = function(Val, Typ) return Typ .. ".new(" .. tostring(Val) .. ")" end
    };

    if StrTypes[TypOf] then
        return StringRet(Value, TypOf);
    else
        local FormatFunction = FormatTable[TypOf] or FormatTable.Default
        return FormatFunction(Value, TypOf);
    end;
end;

SerializeTable = function(Table, Padding, Cache, StringRep, ConcatTable, MaxDepth)
    local Str, Count, Num = "", 1, #Table or CountTable(Table);
    local HasEntries = Count > 0;


    Cache, Padding, StringRep, ConcatTable, MaxDepth = Cache or {}, Padding or 1, StringRep or string.rep, ConcatTable or table.concat, MaxDepth or math.huge;

    local function LocalizedFormat(Value, IsTable, Depth)
        if Depth >= MaxDepth then return tostring(Value); end;
        return IsTable and (Cache[Value][2] >= Padding) and SerializeTable(Value, Padding + 1, Cache, StringRep, ConcatTable) or FormatValue(Value);
    end;

    Cache[Table] = {Table, 0};

    for Index, Value in next, Table do
        local TypeIndex, TypeValue = Type(Index) == "table", Type(Value) == "table";
        local CachedIndex, CachedValue = Cache[Index], Cache[Value];
        Cache[Index], Cache[Value] = not CachedIndex and TypeIndex and {Index, Padding} or CachedIndex, not CachedValue and TypeValue and {Value, Padding} or CachedValue;
        Str = ("%s%s[%s] = %s%s\n"):format(Str, StringRep("    ", Padding), LocalizedFormat(Index, TypeIndex, Padding), LocalizedFormat(Value, TypeValue, Padding), (Count < Num and "," or ""));
        Count = Count + 1;
    end;

    return ("{" .. (HasEntries and "\n" or "")) .. Str .. (HasEntries and StringRep("    ", Padding - 1) or "") .. "}";
end;

return SerializeTable;