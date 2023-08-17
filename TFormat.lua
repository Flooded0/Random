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
    local Typ = Type(Value);

    if StrTypes[Typ] then
        return StringRet(Value, Typ);
    elseif Typ == "string" then
        return '"'.. Value ..'"';
    elseif Typ == "Instance" then
        return Value.GetFullName(Value);
    else
        return Typ .. ".new(" .. tostring(Value) .. ")";
    end;
end;

SerializeTable = function(Table, Padding, Cache, StringRep)
    local Str, Count, Num = "", 1, CountTable(Table) or #Table;
    local HasEntries = Num > 0;

    Cache, Padding, StringRep = Cache or {}, Padding or 1, StringRep or string.rep;

    local function LocalizedFormat(Value, IsTable)
        return IsTable and (Cache[Value][2] >= Padding) and SerializeTable(Value, Padding + 1, Cache, StringRep) or FormatValue(Value);
    end;

    Cache[Table] = {Table, 0};

    for Index, Value in next, Table do
        local TypeIndex, TypeValue = Type(Index) == "table", Type(Value) == "table";
        Cache[Index], Cache[Value] = (not Cache[Index] and TypeIndex) and {Index, Padding} or Cache[Index], (not Cache[Value] and TypeValue) and {Value, Padding} or Cache[Value]
        Str = ("%s%s[%s] = %s%s\n"):format(Str, StringRep("    ", Padding), LocalizedFormat(Index, TypeIndex), LocalizedFormat(Value, TypeValue), (Count < Num and "," or ""))
        Count = Count + 1;
    end;

    return ("{" .. (HasEntries and "\n" or "")) .. Str .. (HasEntries and StringRep("    ", Padding - 1) or "") .. "}";
end;

return SerializeTable;
