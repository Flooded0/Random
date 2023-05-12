local Type = typeof or type;
local StrTypes = {
    ["boolean"] = true,
    ["table"] = true,
    ["userdata"] = true,
    ["function"] = true,
    ["number"] = true,
    ["nil"] = true
};

local RawEqual = rawequal or function(A, B) return A == B; end;
local CountTable = function(Table) local Count = 0; for _, _ in next, Table do Count = Count + 1; end; return Count; end;
local StringRet = function(Object, Typ)
    local Ret, MetaTable, OldFunc;
    if not (Typ == "table" or Typ == "userdata") then return tostring(Object); end;

    MetaTable = (getrawmetatable or debug.getmetatable or getmetatable)(Object);
    if not MetaTable then return tostring(Object); end;

    OldFunc = rawget(MetaTable, "__tostring");
    if OldFunc ~= nil then rawset(MetaTable, "__tostring", nil); end;
    Ret = tostring(Object);
    if OldFunc ~= nil then rawset(MetaTable, "__tostring", OldFunc); end;
    return Ret;
end;
local function FormatValue(Value)
    local Typ = type(Value);
    local Handlers = {
        string = function() return '"' .. Value .. '"' end,
        Instance = function() return Value:GetFullName() end,
        Vector3 = function() return ("Vector3.new(%s, %s, %s)"):format(Value.X, Value.Y, Value.Z) end,
        Vector2 = function() return ("Vector2.new(%s, %s)"):format(Value.X, Value.Y) end,
        CFrame = function() return ("CFrame.new(%s, %s, %s, %s, %s, %s, %s, %s, %s)"):format(Value:components()) end,
        Color3 = function() return ("Color3.fromRGB(%d, %d, %d)"):format(Value.R * 255, Value.G * 255, Value.B * 255) end,
        UDim2 = function() return ("UDim2.new(%d, %d, %d, %d)"):format(Value.X.Scale, Value.X.Offset, Value.Y.Scale, Value.Y.Offset) end,
        UDim = function() return ("UDim.new(%d, %d)"):format(Value.Scale, Value.Offset) end,
        NumberRange = function() return ("NumberRange.new(%s, %s)"):format(Value.Min, Value.Max) end,
        Rect = function() return ("Rect.new(%s, %s, %s, %s)"):format(Value.Min.X, Value.Min.Y, Value.Max.X, Value.Max.Y) end,
        boolean = function() return Value and "true" or "false" end,
        NumberSequence = function() return ("NumberSequence.new(%s)"):format(table.concat(Value.Keyframes, ", ")) end,
        ColorSequence = function()
            local ColorTable = {}; for _, Keyframe in ipairs(Value.Keypoints) do table.insert(ColorTable, ("ColorSequenceKeypoint.new(%s, Color3.fromRGB(%d, %d, %d))"):format(Keyframe.Time, Keyframe.Value.R * 255, Keyframe.Value.G * 255, Keyframe.Value.B * 255)); end;
            return ("ColorSequence.new{%s}"):format(table.concat(ColorTable, ", "));
        end,
        BrickColor = function() return ("BrickColor.new(%d)"):format(Value.Number) end,
        Ray = function() return ("Ray.new(%s, %s)"):format(FormatValue(Value.Origin), FormatValue(Value.Direction)) end,
        Enum = function() return ("%s.%s"):format(Value.EnumType.Name, Value.Name) end,
        EnumItem = function() return ("%s.%s"):format(Value.EnumType.Name, Value.Name) end,
        TweenInfo = function()
            if typeof(Value.EasingStyle) == "EnumItem" and typeof(Value.EasingDirection) == "EnumItem" then
                local Fields = {
                    ("Time = %f"):format(Value.Time),
                    ("EasingStyle = Enum.EasingStyle.%s"):format(Value.EasingStyle.Name),
                    ("EasingDirection = Enum.EasingDirection.%s"):format(Value.EasingDirection.Name)
                };
                return ("TweenInfo.new(%s)"):format(table.concat(Fields, ", "));
            else
                return "TweenInfo.new()";
            end;
        end,
        Random = function() return ("Random.new(%d)"):format(Value.Seed) end,
        Axes = function()
            local AxesTable = {}; for _, Axis in ipairs(Enum.Axis:GetEnumItems()) do if Value[Axis.Name] then table.insert(AxesTable, ("Enum.Axis.%s"):format(Axis.Name)); end; end;
            return ("Axes.new(%s)"):format(table.concat(AxesTable, ", "));
        end,
        Faces = function()
            local FacesTable = {}; for _, Face in ipairs(Enum.NormalId:GetEnumItems()) do if Value[Face.Name] then table.insert(FacesTable, ("Enum.NormalId.%s"):format(Face.Name)); end; end;
            return ("Faces.new(%s)"):format(table.concat(FacesTable, ", "));
        end,
    };

    if StrTypes[Typ] then
        return StringRet(Value, Typ);
    elseif Handlers[Typ] then
        return Handlers[Typ]();
    elseif typeof(Value) == "Enum" then
        return Handlers.Enum();
    else
        --return ("%q"):format(tostring(Value));
        ("%s.new(%s)"):format(Typ, tostring(Value));
    end;
end;

local function SerializeTable(Table, Padding, Cache, StringRep)
    local Count, Str, Num = 1, {}, CountTable(Table);
    local HasEntries = Num > 0;

    Cache, Padding, StringRep = Cache or {}, Padding or 1, StringRep or string.rep;

    local LocalizedFormat = function(Value, IsTable)
        return IsTable and (Cache[Value][2] >= Padding) and SerializeTable(Value, Padding + 1, Cache, StringRep) or FormatValue(Value);
    end;

    Cache[Table] = {Table, 0};

    for Index, Value in next, Table do
        local IsIndexTable, IsValueTable = Type(Index) == "table", Type(Value) == "table";
        Cache[Index], Cache[Value] = Cache[Index] or IsIndexTable and {Index, Padding}, Cache[Value] or IsValueTable and {Value, Padding};
        Str[Count] = ("%s[%s] = %s%s"):format(StringRep("    ", Padding), LocalizedFormat(Index, IsIndexTable), LocalizedFormat(Value, IsValueTable), Count < Num and "," or "");
        Count = Count + 1;
    end;

    return ("{%s\n%s%s}"):format(HasEntries and "\n" or "", table.concat(Str, "\n"), HasEntries and StringRep("    ", Padding - 1) or "");
end;

return SerializeTable;
