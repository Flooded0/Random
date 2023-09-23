local Assets = {
    3570695787, 5941353943, 4155801252, 2592362371, 2454009026, 6282522798, 4632082392,
    5843010904, 5553946656, 6071575925, 6071579801, 6073763717, 6214418014, 6214412460, 6214416834, 6214375242, 6214404863, 6214374619, 6214320051, 6214318622, 6073743871, 5351821237, 159454288, 1417494643, 570557727, 264907379, 11711560928, 10300256322, 12652997937, 11696859404, 10341849875, 14007782187, -- BackGround_IDs
    446111271, 967852047, 1263079249, 1177196540, 6091329339, 9744090087, 2200369468, 2141833720, 1275200298, 8236412732, 4595131819, 7151842823, 7151778302, 6333823534, 6511613786, 5864341017, 12781806168, -- BTracer_IDs
    8133639623, --CVMTexturesT
};

for _, B in pairs(Assets) do
    game:GetService("ContentProvider"):Preload("rbxassetid://" .. B);
end;

-- | Services
getgenv().RunService = game:GetService("RunService");
getgenv().TextService = game:GetService("TextService");
getgenv().InputService = game:GetService("UserInputService");
getgenv().HttpService = game:GetService("HttpService");
getgenv().CoreGui = game:GetService("CoreGui");
getgenv().SetClipB = setclipboard or (syn and syn.write_clipboard) or write_clipboard or writeclipboard or clipboard_set or toclipboard or set_clipboard or (Clipboard and Clipboard.set) or print;

if getgenv().libraryX then
    getgenv().libraryX:Unload();
end;

local libraryX = {
    Title = "Snow",
    Draggable = true,
    Open = false,
    MouseState = InputService.MouseIconEnabled,
    PopUp = nil,
    Tabs = {},
    Flags = {},
    Options = {},

    Connections = {},
    Instances = {},
    Notifications = {},
    --Indicators = {},

    TabSize = 1,
    Theme = {},
    FolderName = "Snow_Configs",
    GameTitle = "Universal",
    FileText = ".O"
};

getgenv().libraryX = libraryX;

-- | Locals
local Dragging, DragInput, DragStart, StartPos, DragObject;
local BlackListedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Escape};
local WhiteListedMouseInputs = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3};

-- | Functions
--[[libraryX.Round = function(Num, Bracket)
    if typeof(Num) == "Vector2" then
        return Vector2.new(libraryX.Round(Num.X), libraryX.Round(Num.Y));
    elseif typeof(Num) == "Vector3" then
        return Vector3.new(libraryX.Round(Num.X), libraryX.Round(Num.Y), libraryX.Round(Num.Z));
    elseif typeof(Num) == "Color3" then
        return libraryX.Round(Num.R * 255), libraryX.Round(Num.G * 255), libraryX.Round(Num.B * 255);
    else
        return Num - Num % (Bracket or 1);
    end;
end;]]

local IsFinite = function(Num)
    return typeof(Num) == "number" and Num == Num and math.abs(Num) ~= math.huge and math.abs(Num) ~= 1/0;
end;

libraryX.Round = function(Num, Bracket, Direction)
    assert(typeof(Num) == "number" or typeof(Num) == "Vector2" or typeof(Num) == "Vector3" or typeof(Num) == "Color3", "Invalid Input Type");
    assert(Bracket == nil or (typeof(Bracket) == "number" and Bracket > 0), "Bracket Must Be A Positive Number Or Nil");
    assert(Direction == nil or Direction == "Up" or Direction == "Down" or Direction == "ToEven" or Direction == "Nearest", "Direction Must Be 'Up', 'Down', 'ToEven', 'Nearest', Or nil")

    if typeof(Num) == "number" then
        if not IsFinite(Num) then return Num; end;
        Bracket = Bracket or 1;
        Direction = Direction or "Nearest";

        if Direction == "Up" then
            return  math.ceil(Num / Bracket) * Bracket;
        elseif Direction == "Down" then
            return math.floor(Num / Bracket) * Bracket;
        elseif Direction == "ToEven" then
            local FloorNum = math.floor(Num / Bracket) * Bracket;
            local CeilNum = math.ceil(Num / Bracket) * Bracket;
            local DiffFloor = math.abs(Num - FloorNum);
            local DiffCeil = math.abs(Num - CeilNum);
            if DiffFloor < DiffCeil or (DiffFloor == DiffCeil and FloorNum % (2 * Bracket) == 0) then
                return FloorNum;
            else
                return CeilNum;
            end;
        else -- "Nearest"
            return Num - Num % Bracket + (Num % Bracket >= Bracket / 2 and Bracket or 0); --return Num - Num % Bracket; --return math.floor(Num / Bracket + 0.5) * Bracket
        end;
    elseif typeof(Num) == "Vector2" or typeof(Num) == "Vector3" then
        local RoundedComponents = {};
        for _, Component in ipairs({Num.X, Num.Y, Num.Z}) do
            local RoundedComponent = libraryX.Round(Component, Bracket, Direction);
            if math.abs(Component - RoundedComponent) < 1e-10 then
                RoundedComponent = Component;
            end;

            table.insert(RoundedComponents, RoundedComponent);
        end;

        if typeof(Num) == "Vector2" then
            return Vector2.new(unpack(RoundedComponents));
        elseif typeof(Num) == "Vector3" then
            return Vector3.new(unpack(RoundedComponents));
        end;
    elseif typeof(Num) == "Color3" then
        return libraryX.Round(Num.R * 255, Bracket, Direction), libraryX.Round(Num.G * 255, Bracket, Direction), libraryX.Round(Num.B * 255, Bracket, Direction);
    else
        warn("Invalid Input Type | Function Round");
    end;
end;

--[[libraryX.FormatNumber = function(Num, DecimalPlaces)
    return tonumber(("%." .. DecimalPlaces .. "f"):format(Num));
end;]] libraryX.FormatNumber = function(Num, DecimalPlaces)
    local Pattern = "^-?%d+%.?%d" .. DecimalPlaces .. "?";
    local Formatted = ("%." .. DecimalPlaces .. "f"):format(Num);
    local Result = Formatted:match(Pattern);

    if Result and DecimalPlaces > 0 then
        local DecimalIndex = Result:find("%.");
        if DecimalIndex == nil then
            Result = Result .. ".";
            DecimalIndex = #Result;
        end;
        Result = Result .. string.rep("0", DecimalPlaces - (#Result - DecimalIndex))
    end;

    return tonumber(Result);
end;

libraryX.GetTextBounds = function(Text, Font, Size, XY, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(9e9, 9e9));
    return (XY == "1" and Bounds.X or XY == "2" and Bounds.Y);
end;

function libraryX:Create(Class, Properties)
    if not Class then return nil; end;
    local IsDrawingClass = {Square = true, Line = true, Text = true, Quad = true, Circle = true, Triangle = true};
    local New = IsDrawingClass[Class] and Drawing.new(Class) or Instance.new(Class);

    for Property, Value in pairs(Properties or {}) do
        New[Property] = Value;
    end;

    table.insert(self.Instances, {Object = New, Method = IsDrawingClass[Class]});
    return New;
end;

function libraryX:AddConnection(Connection, Name, CallBack)
    CallBack = typeof(Name) == "function" and Name or CallBack;
    local NewConnection = Connection:Connect(CallBack);
    if Name ~= CallBack then
        self.Connections[Name] = NewConnection;
    else
        table.insert(self.Connections, NewConnection);
    end;
    return NewConnection;
end;

--[[function libraryX:BindToRenderStep(Name, Priority, CallBack)
    local FakeConnection = {};
    function FakeConnection:Disconnect() RunService:UnbindFromRenderStep(Name); end;
    RunService:BindToRenderStep(Name, Priority, CallBack);
    return FakeConnection;
end;]]

function libraryX:Unload()
    InputService.MouseIconEnabled = self.MouseState;

    --for A in pairs(self.Flags) do self.Flags[A] = nil; end;
    for Index, Conn in pairs(self.Connections) do
        Conn:Disconnect();
        self.Connections[Index] = nil;
    end;
    for Index, Inst in pairs(self.Instances) do
        if Inst.Method then
            pcall(function() Inst.Object:Destroy(); end);
        else
            Inst.Object:Destroy();
        end;
        self.Instances[Index] = nil;
    end;
    for _, Option in ipairs(self.Options) do
        if Option.Type == "Toggle" and Option.SetState then
            coroutine.wrap(Option.SetState)(Option);
        end;
    end;

    if libraryX.OnUnload then libraryX:OnUnload(); end;
    if self.Base then self.Base:Destroy(); end;

    table.clear(libraryX); --libraryX = nil;
    getgenv().libraryX = nil;
end; function libraryX:OnUnload(Callback)
    libraryX.OnUnload = Callback;
end;

function libraryX:LoadConfig(Config, JsonStr)
    local ReadData, DecodedJSON = pcall(function()
        return JsonStr and HttpService:JSONDecode(JsonStr) or HttpService:JSONDecode((readfile or read)(self.FolderName .. "/" .. self.GameTitle .. "/" .. Config .. self.FileText))
    end);

    DecodedJSON = ReadData and DecodedJSON or {};

    if table.find(self:GetConfigs(), Config) then
        for _, Option in pairs(self.Options) do
            if Option.HasInit and Option.Type ~= "Button" and Option.Flag and not Option.SkipFlag then
                if Option.Type == "Toggle" then
                    task.spawn(function() Option:SetState(DecodedJSON[Option.Flag] == 1); end);
                elseif Option.Type == "Color" and DecodedJSON[Option.Flag] then
                    task.spawn(function()
                        Option:SetColor(DecodedJSON[Option.Flag]);
                        if Option.Trans then
                            Option:SetTrans(DecodedJSON[Option.Flag .. " Transparency"]);
                        end;
                    end);
                elseif Option.Type == "Bind" then
                    task.spawn(function() Option:SetKey(DecodedJSON[Option.Flag]); end);
                elseif Option.Type == "List" then
                    task.spawn(function() Option:SetValue(DecodedJSON[Option.Flag]); end);
                else
                    task.spawn(function() Option:SetValue(DecodedJSON[Option.Flag]); end);
                end;
            end;
        end;
    end;
end; function libraryX:SaveConfig(Config, UseClipboard, JsonStr)
    local DecodedJSON = table.find(self:GetConfigs(), Config) and not JsonStr and HttpService:JSONDecode((readfile or read)(self.FolderName .. "/" .. self.GameTitle .. "/" .. Config .. self.FileText)) or JsonStr and HttpService:JSONDecode(JsonStr) or {}

    for _, Option in pairs(self.Options) do
        if Option.Type ~= "Button" and Option.Flag and not Option.SkipFlag then
            if Option.Type == "Toggle" then
                DecodedJSON[Option.Flag] = Option.State and 1 or 0;
            elseif Option.Type == "Color" then
                DecodedJSON[Option.Flag] = {Option.Color.R, Option.Color.G, Option.Color.B};
                if Option.Trans then
                    DecodedJSON[Option.Flag .. " Transparency"] = Option.Trans;
                end;
            elseif Option.Type == "Bind" and Option.Key:lower() ~= "none" then
                DecodedJSON[Option.Flag] = Option.Key;
            elseif Option.Type == "List" then
                DecodedJSON[Option.Flag] = Option.Value;
            else
                DecodedJSON[Option.Flag] = Option.Value;
            end;
        end;
    end;

    if UseClipboard then
        SetClipB(HttpService:JSONEncode(DecodedJSON));
    else
        (writefile or write)(self.FolderName .. "/" .. self.GameTitle .. "/" .. Config .. self.FileText, HttpService:JSONEncode(DecodedJSON));
    end;
end; function libraryX:GetConfigs()
    if not (isfolder or is_folder)(self.FolderName) then
        makefolder(self.FolderName);
    end; if not (isfolder or is_folder)(self.FolderName .. "/" .. self.GameTitle) then
        makefolder(self.FolderName .. "/" .. self.GameTitle);
        return {};
    end;

    local Files, Count = {}, 0;
    local FileList, FileTextLength = listfiles(self.FolderName .. "/" .. self.GameTitle), #self.FileText or 0;

    for Index = 1, #FileList do
        local FilePath = FileList[Index];
        if FilePath:sub(-FileTextLength) == self.FileText then
            Count = Count + 1;
            local FileName = FilePath:gsub(self.FolderName .. "/" .. self.GameTitle .. "[/\\]", ""):gsub(self.FileText, "");
            Files[Count] = FileName;
        end;
    end;

    --[[local Files, FileTextLength = {}, #self.FileText;
    for _, FilePath in ipairs(listfiles(self.FolderName)) do
        if FilePath:sub(-FileTextLength) == self.FileText then
            local FilePath = FilePath:sub(#self.FolderName + 1, -FileTextLength - 1):gsub("[/\\]", "");
            table.insert(Files, FilePath);
        end;
    end;]]

    --[[local Files, FileTextLength = {}, #self.FileText;
    for _, FileName in next, listfiles(self.FolderName .. "/" .. self.GameTitle) do
        if FileName:sub(-FileTextLength) == self.FileText then
            local FilePath = FileName:gsub(self.FolderName .. "/" .. self.GameTitle .. "[/\\]", ""):gsub(self.FileText, "");
            table.insert(Files, FilePath);
        end;
    end;]]

    return Files;
end;

--[[
libraryX.TIndicator = libraryX:Indicator({Title = "Target Info", Enabled = true});
libraryX.TTName = libraryX.TIndicator:AddValue({Key = "Name		:", Value = "nil"});
libraryX.TDisplay = libraryX.TIndicator:AddValue({Key = "DName    :", Value = "nil"});
libraryX.THealth = libraryX.TIndicator:AddValue({Key = "Health   :", Value = "0"});
libraryX.TDistance = libraryX.TIndicator:AddValue({Key = "Distance :", Value = "0m"});
libraryX.TTool = libraryX.TIndicator:AddValue({Key = "Weapon   :", Value = "nil"});

OtherS:AddToggle({Text = "Target Indicator", Flag = "TIndicator", CallBack = function(State)
    libraryX.TIndicator:SetEnabled(State);
end})
OtherS:AddSlider({Text = "Position X", Flag = "TIndicatorX", TextPos = 2, Min = 0, Max = 100, Float = 0.1, Value = 0.5, CallBack = function(Value)
    if libraryX.Flags["TIndicator"] then
        libraryX.TIndicator:SetPosition(UDim2.new(Value / 100, 0, libraryX.Flags["TIndicatorY"] / 100, 0));
    end;
end});
OtherS:AddSlider({Text = "Position Y", Flag = "TIndicatorY", TextPos = 2, Min = 0, Max = 100, Float = 0.1, Value = 35, CallBack = function(Value)
    if libraryX.Flags["TIndicator"] then
        libraryX.TIndicator:SetPosition(UDim2.new(libraryX.Flags["TIndicatorX"] / 100, 0, Value / 100, 0));
    end;
end});
]]

function libraryX:Notify(Type, Text, Time)
    if type(Type) ~= "string" then
        return warn(("Invalid Type, Got %s, Expected String"):format(type(Type)));
    elseif type(Text) ~= "string" then
        return warn(("Invalid Text, Got %s, Expected String"):format(type(Text)));
    end;

    DTime = DTime or 4;

    local NotifyOuter = libraryX:Create("Frame", {
        BorderColor3 = Color3.new(0, 0, 0),
        Position = UDim2.new(0, 100, 0, 10),
        Size = UDim2.new(0, 0, 0, 20),
        ClipsDescendants = true,
        ZIndex = 100,
        Parent = libraryX.NotificationArea
    }); --if not NotifyOuter then return; end;

	table.insert(libraryX.Notifications, NotifyOuter);

    local NotifyInner = libraryX:Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderColor3 = Color3.fromRGB(50, 50, 50),
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 101,
        Parent = NotifyOuter
    });

    local InnerFrame = libraryX:Create("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 1, 0, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = 102,
        Parent = NotifyInner
    });

    libraryX:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0.0732026, 0.0732026, 0.0732026)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 28)),
        });
        Rotation = -90,
        Parent = InnerFrame
    });

    local ErrLookup = {Success = "Success: ", Info = "Info: ",Warning = "Warning: ", Error = "Error: ", None = ""};

    local TextLabel = libraryX:Create("TextLabel", {
        Position = UDim2.new(0, 4, 0, 0),
        Size = UDim2.new(1, -4, 1, 0),
        BackgroundTransparency = 1,
        Text =  ((ErrLookup[Type] or "") .. tostring(Text)) or "Empty",
        TextColor3 = Color3.new(1, 1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 13,
        Font = Enum.Font.Code,
        ZIndex = 103,
        Parent = InnerFrame
    }); if not TextLabel then return; end;

    local MaxSize = libraryX.GetTextBounds(TextLabel.Text, Enum.Font.Code, 13, "1");
    table.insert(libraryX.Theme, libraryX:Create("Frame", {
        BackgroundColor3 = libraryX.Flags["Menu Accent Color"],
        BorderSizePixel = 0,
        Position = UDim2.new(0, -1, 0, -4),
        Size = UDim2.new(0, MaxSize + 10, 0, 5.8),
        ZIndex = 104,
        Parent = NotifyOuter
    }));

---@diagnostic disable-next-line: need-check-nil
    pcall(NotifyOuter:TweenSize(UDim2.new(0, MaxSize + 10, 0, 20), "Out", "Quad", 0.4, true));

    task.delay(DTime, function()
---@diagnostic disable-next-line: need-check-nil
        pcall(NotifyOuter:TweenSize(UDim2.new(0, 0, 0, 20), "Out", "Quad", 0.4, true));
        task.wait(0.4);
        table.remove(libraryX.Notifications, table.find(libraryX.Notifications, NotifyOuter));
---@diagnostic disable-next-line: need-check-nil
        NotifyOuter:Destroy();
    end);
end;

-- | UI-Functions
libraryX.CreateLabel = function(Option, Parent)
    Option.Main = libraryX:Create("TextLabel", {
        LayoutOrder = Option.Position,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 0, 15),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment[Option.PosM or "Left"],
        TextYAlignment = Enum.TextYAlignment["Top"],
        Parent = Parent
    });

    function Option:SetText(Text)
        Option.Text = Text and tostring(Text) or "";
        Option.Size = UDim2.new(1, -12, 0, libraryX.GetTextBounds(Option.Main.Text, Enum.Font.Code, 18, "2", Vector2.new(Option.Main.AbsoluteSize.X, 9e9)));
    end;

    setmetatable(Option, {__newindex = function(_, B, C)
        if B == "Text" then
            Option.Main.Text, Option.Main.Size = C and tostring(C) or "", UDim2.new(1, -12, 0, libraryX.GetTextBounds(Option.Main.Text, Enum.Font.Code, 18, "2", Vector2.new(Option.Main.AbsoluteSize.X, 9e9)))
        end;
    end});

    Option.Text = Option.text;
end;

libraryX.CreateDivider = function(Option, Parent)
    Option.Main = libraryX:Create("Frame", {
        LayoutOrder = Option.Position,
        Size = UDim2.new(1, 0, 0, 17.5),
        BackgroundTransparency = 1,
        Parent = Parent
    });

    libraryX:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, -0.9, 0.5, -0.9),
        Size = UDim2.new(1, -15, 0, 1.5),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderColor3 = Color3.new(),
        Parent = Option.Main
    });

    Option.Title = libraryX:Create("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        TextColor3 =  Color3.new(1, 1, 1),
        TextWrapped = true,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment["Center"],
        Parent = Option.Main
    });

    function Option:SetText(Text)
        Option.Text = Text and tostring(Text) or "";
        Option.Size  = UDim2.new(0, libraryX.GetTextBounds(Option.Title.Text, Enum.Font.Code, 15, "1") + 10, 0, 15);
    end;

    setmetatable(Option, {__newindex = function(_, B, C)
        if B == "Text" then
            Option.Title.Text = C and tostring(C) or "";
            Option.Title.Size = C and UDim2.new(0, libraryX.GetTextBounds(Option.Title.Text, Enum.Font.Code, 15, "1") + 10, 0, 15) or UDim2.new();
            Option.Main.Size = UDim2.new(1, 0, 0, 18);
        end;
    end});

    Option.Text = Option.text;
end;

libraryX.CreateBlank = function(Option, Parent)
    Option.Main = libraryX:Create("Frame", {
        LayoutOrder = Option.Position,
        Position = UDim2.new(0.5, -1, 0.5, 0),
        BackgroundTransparency = 1;
        Parent = Parent;
    });

    function Option:SetNum(Num)
        Option.Size = UDim2.new(1, 0, 0, tostring(Num));
    end;

    setmetatable(Option, {__newindex = function(_, B, C)
        if B == "Size" then
            Option.Main.Size = UDim2.new(1, 0, 0, tostring(C));
        end;
    end});

    Option.Size = Option.size;
end;

libraryX.CreateToggle = function(Option, Parent)
    Option.HasInit = true;

    Option.Main = libraryX:Create("Frame", {
        LayoutOrder = Option.Position,
        Size = UDim2.new(1, 0, 0, 21),
        BackgroundTransparency = 1,
        Parent = Parent
    });

    local TickBox, TickBoxOverlay;
    if Option.Style then
        TickBox = libraryX:Create("ImageLabel", {
            Position = UDim2.new(0, 6, 0, 4.5),
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.new(),
            Parent = Option.Main
        });

        libraryX:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(60, 60, 60),
            Parent = TickBox
        });

        libraryX:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -6, 1, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(40, 40, 40),
            Parent = TickBox
        });

        TickBoxOverlay = libraryX:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -6, 1, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3570695787",
            ImageColor3 = libraryX.Flags["Menu Accent Color"],
            Visible = Option.State,
            Parent = TickBox
        });

        --[[libraryX:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://5941353943",
            ImageTransparency = 0.6,
            Parent = TickBox
        });]]

        table.insert(libraryX.Theme, TickBoxOverlay);
    else
        TickBox = libraryX:Create("Frame", {
            Position = UDim2.new(0, 6, 0, 4.5),
            Size = UDim2.new(0, 12, 0, 12),
            BackgroundColor3 = libraryX.Flags["Menu Accent Color"],
            BorderColor3 = Color3.new(),
            Parent = Option.Main
        });

        TickBoxOverlay = libraryX:Create("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = Option.State and 1 or 0,
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderColor3 = Color3.new(),
            Image = "rbxassetid://4155801252",
            ImageTransparency = 0.6,
            ImageColor3 = Color3.new(),
            Parent = TickBox
        });

        libraryX:Create("ImageLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://2592362371",
            ImageColor3 = Color3.fromRGB(60, 60, 60),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 62, 62),
            Parent = TickBox
        });

        --[[libraryX:Create("ImageLabel", {
            Size = UDim2.new(1, -2, 1, -2),
            Position = UDim2.new(0, 1, 0, 1),
            BackgroundTransparency = 1,
            Image = "rbxassetid://2592362371",
            ImageColor3 = Color3.new(),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 62, 62),
            Parent = TickBox
        });]]

        table.insert(libraryX.Theme, TickBox);
    end;

    Option.Interest = libraryX:Create("Frame", {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = Option.Main
    });

    Option.Title = libraryX:Create("TextLabel", {
        Position = UDim2.new(0, 24, 0, -0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = Option.Text,
        TextColor3 =  Option.State and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(180, 180, 180),
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment["Left"],
        Parent = Option.Interest
    });

    Option.Interest.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Option:SetState(not Option.State);
        elseif Input.UserInputType == Enum.UserInputType.MouseMovement and not (libraryX.Warning or libraryX.Slider) then
            local BorderColor = libraryX.Flags["Menu Accent Color"];
            if Option.Style then
                TickBox.ImageColor3 = BorderColor;
            else
                TickBox.BorderColor3 = BorderColor;
                TickBoxOverlay.BorderColor3 = BorderColor;
            end;
            if Option.Tip then
                libraryX.ToolTip.Text = Option.Tip;
                libraryX.ToolTip.Size = UDim2.new(0, libraryX.GetTextBounds(Option.Tip, Enum.Font.Code, 14, "1"), 0, 20);
            end;
        end;
    end);

    Option.Interest.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Option.Tip then
            libraryX.ToolTip.Position = UDim2.new(0, Input.Position.X + 10, 0, Input.Position.Y + 30);
        end;
    end);

    Option.Interest.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            if Option.Style then
                TickBox.ImageColor3 = Color3.new();
            else
                TickBox.BorderColor3 = Color3.new();
                TickBoxOverlay.BorderColor3 = Color3.new();
            end;
            libraryX.ToolTip.Position = UDim2.new(2);
        end;
    end);

    function Option:SetState(NewState, NoCallBack)
        self.State = type(NewState) == "boolean" and NewState or false;
        libraryX.Flags[self.Flag] = self.State;
        Option.Title.TextColor3 = self.State and Color3.fromRGB(210, 210, 210) or Color3.fromRGB(160, 160, 160);
        if Option.Style then
            TickBoxOverlay.Visible = self.State;
        else
            TickBoxOverlay.BackgroundTransparency = self.State and 1 or 0;
        end;
        if not NoCallBack then
            self.CallBack(self.State);
        end;
    end;

    --[[if Option.State ~= nil and libraryX then
        task.delay(1, function()
            Option.CallBack(Option.State);
        end);
    end;]]

    --[[if Option.State ~= nil and libraryX then
        task.defer(Option.CallBack, Option.State);
    end;]]

    setmetatable(Option, {__newindex = function(A, B, C)
        if B == "Text" then
            Option.Title.Text = tostring(C);
        end;
    end});
end;

libraryX.CreateButton = function(Option, Parent)
    Option.HasInit = true;

    Option.Main = libraryX:Create("Frame", {
        LayoutOrder = Option.Position,
        --Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Parent = Parent
    });

    if Option.Style then
        Option.Title = libraryX:Create("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -6),
            Size = UDim2.new(1, -12, 0, 14.5),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderColor3 = Color3.new(),
            Text = Option.Text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.Code,
            TextYAlignment = Enum.TextYAlignment["Top"],
            Parent = Option.Main
        });

        libraryX:Create("ImageLabel", {
            --Position = UDim2.new(0, 0, 0, 1),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://2592362371",
            ImageColor3 = Color3.fromRGB(60, 60, 60),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 62, 62),
            Parent = Option.Title
        });

        --[[libraryX:Create("ImageLabel", {
            Size = UDim2.new(1, -2, 1, -2),
            Position = UDim2.new(0, 1, 0, 1),
            BackgroundTransparency = 1,
            Image = "rbxassetid://2592362371",
            ImageColor3 = Color3.new(),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 62, 62),
            Parent = Option.Title
        });]]

        --[[libraryX:Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
            }),
            Rotation = -90,
            Parent = Option.Title
        });]]
    else
        Option.Title = libraryX:Create("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -6),
            Size = UDim2.new(1, -12, 0, 14.5),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderColor3 = Color3.new(),
            Text = Option.Text,
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 13,
            Font = Enum.Font.Code,
            TextYAlignment = Enum.TextYAlignment["Top"],
            Parent = Option.Main
        });

        libraryX:Create("ImageLabel", {
            --Position = UDim2.new(0, 0, 0, 1),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://2592362371",
            ImageColor3 = Color3.fromRGB(60, 60, 60),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 62, 62),
            Parent = Option.Title
        });
    end;

    Option.Title.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Option.CallBack();
            if libraryX then
                libraryX.Flags[Option.Flag] = true;
            end;
        elseif Input.UserInputType == Enum.UserInputType.MouseMovement then
            if not (libraryX.Warning or libraryX.Slider) then
                Option.Title.BorderColor3 = libraryX.Flags["Menu Accent Color"];
            end;
        end;
    end);

    Option.Title.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Option.Tip then
            libraryX.ToolTip.Position = UDim2.new(0, Input.Position.X + 10, 0, Input.Position.Y + 30);
        end;
    end);

    Option.Main.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Option.Tip then
            if Option.Tip then
                libraryX.ToolTip.Text = Option.Tip;
                libraryX.ToolTip.Size = UDim2.new(0, libraryX.GetTextBounds(Option.Tip, Enum.Font.Code, 14, "1"), 0, 20);
            end;
        end;
    end);

    Option.Title.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            Option.Title.BorderColor3 = Color3.new();
            libraryX.ToolTip.Position = UDim2.new(2);
        end;
    end);
end;

libraryX.CreateBind = function(Option, Parent)
    Option.HasInit = true;

    local Binding, Loop;
    if Option.Sub then
        Option.Main = Option:GetMain();
    else
        Option.Main = Option.Main or libraryX:Create("Frame", {
            LayoutOrder = Option.Position,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = Parent
        });

        libraryX:Create("TextLabel", {
            Position = UDim2.new(0, 6, 0, 0),
            Size = UDim2.new(1, -12, 1, 0),
            BackgroundTransparency = 1,
            Text = Option.Text,
            TextSize = 13,
            Font = Enum.Font.Code,
            TextColor3 = Color3.fromRGB(210, 210, 210),
            TextXAlignment = Enum.TextXAlignment["Left"],
            Parent = Option.Main
        });
    end;

    local BindInput = libraryX:Create(Option.Sub and "TextButton" or "TextLabel", {
        Position = UDim2.new(1, -6 - (Option.SubPos or 0), 0, Option.Sub and 2 or 2),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextColor3 = Color3.fromRGB(160, 160, 160),
        TextXAlignment = Enum.TextXAlignment["Right"],
        Parent = Option.Main
    });

    if Option.Sub then
        BindInput.AutoButtonColor = false;
    end;

    local Interest = Option.Sub and BindInput or Option.Main;
    if not Interest then return; end;

    Interest.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 and BindInput then
            Binding = true;
            BindInput.Text = "[...]";
            BindInput.Size = UDim2.new(0, -libraryX.GetTextBounds(BindInput.Text, Enum.Font.Code, 12, "1"), 0, 16);
            BindInput.TextColor3 = libraryX.Flags["Menu Accent Color"];
        end;
    end);

    libraryX:AddConnection(InputService.InputBegan, function(Input)
        if InputService:GetFocusedTextBox() then return; end;
        if Binding then
            local Key = (table.find(WhiteListedMouseInputs, Input.UserInputType) and not Option.NoMouse) and Input.UserInputType;
            Option:SetKey(Key or (not table.find(BlackListedKeys, Input.KeyCode)) and Input.KeyCode);
            Option.CallBack(true, 0, Option.Key, true);
        else
            if (Input.KeyCode.Name == Option.Key or Input.UserInputType.Name == Option.Key) and not Binding then
            if Option.Mode == "Toggle" then
                libraryX.Flags[Option.Flag] = not libraryX.Flags[Option.Flag];
                Option.CallBack(libraryX.Flags[Option.Flag], 0, Option.Key);
            else
                libraryX.Flags[Option.Flag] = true;
                if Loop then Loop:Disconnect(); end;
                    Loop = libraryX:AddConnection(RunService.RenderStepped, function(Step)
                        if not InputService:GetFocusedTextBox() then
                            Option.CallBack(nil, Step);
                        end;
                    end);
                    Option.CallBack(true, 0, Option.Key)
                end;
            end;
        end;
    end);

    libraryX:AddConnection(InputService.InputEnded, function(Input)
        if Option.Key:lower() ~= "none" then
            if Input.KeyCode.Name == Option.Key or Input.UserInputType.Name == Option.Key then
                if Loop then
                    Loop:Disconnect();
                    libraryX.Flags[Option.Flag] = false;
                    Option.CallBack(true, 0, Option.Key);
                end;
            end;
        end;
    end);

    function Option:SetKey(Key)
        Binding = false;
        if BindInput then BindInput.TextColor3 = Color3.fromRGB(160, 160, 160); end;
        if Loop then
            Loop:Disconnect();
            libraryX.Flags[Option.Flag] = false;
            Option.CallBack(true, 0, Option.Key);
        end;

        self.Key = Key or self.Key;
        self.Key = (self.Key.Name or self.Key);

        --local KeyMap = {["Backspace"] = "None", ["Escape"] = "None", ["CapsLock"] = "Caps", ["Control"] = "CTRL", ["Left"] = "L", ["Right"] = "R"};
        --local Replacement = KeyMap[self.Key] or self.Key
        --Replacement = Replacement:gsub("Button", ""):gsub("Mouse", "M")

        if self.Key == "Backspace" or self.Key == "Escape" then
            self.Key = "None";
            BindInput.Text = "[NONE]";
        elseif self.Key:match("Mouse") then
            self.Key:gsub("Button", ""):gsub("Mouse", "M");
        elseif self.Key:match("Shift") or self.Key:match("Alt") then
            self.Key:gsub("Left", "L"):gsub("Right", "R");
        elseif self.Key:match("Caps") then
            self.Key:gsub("CapsLock", "Caps");
        elseif self.Key:match("Control") then
            self.Key:gsub("Control", "CTRL");
        elseif self.Key:match("Left") or self.Key:match("Right") then
            self.Key:gsub("Left", "L"):gsub("Right", "R");
        end;

        if BindInput then
            BindInput.Text = "[" .. self.Key:upper() .. "]"; --Replacement:upper()
            BindInput.Size = UDim2.new(0, -libraryX.GetTextBounds(BindInput.Text, Enum.Font.Code, 12, "1"), 0, 15.5);
        end;
    end;
    Option:SetKey();
end;

libraryX.CreateSlider = function(Option, Parent)
    Option.HasInit = true;

    if Option.Sub then
        Option.Main = Option:GetMain();
        Option.Main.Size = UDim2.new(1, 0, 0, 37.5);
    else
        Option.Main = libraryX:Create("Frame", {
            LayoutOrder = Option.Position,
            Size = UDim2.new(1, 0, 0, Option.TextPos and 24 or 37.5),
            BackgroundTransparency = 1,
            Parent = Parent
        });
    end;

    Option.Slider = libraryX:Create("Frame", {
        Position = UDim2.new(0, 6, 0, (Option.Sub and 22 or Option.TextPos and 4 or 19)),
        Size = UDim2.new(1, -12, 0, 12.5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderColor3 = Color3.new(),
        Parent = Option.Main
    });

    libraryX:Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://2454009026",
        ImageColor3 = Color3.new(),
        ImageTransparency = 0.8,
        Parent = Option.Slider
    });

    Option.Fill = libraryX:Create("Frame", {
        BackgroundColor3 = libraryX.Flags["Menu Accent Color"],
        BorderSizePixel = 0,
        Parent = Option.Slider
    });

    libraryX:Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://2592362371",
        ImageColor3 = Color3.fromRGB(60, 60, 60),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 62, 62),
        Parent = Option.Slider
    });

    --[[libraryX:Create("ImageLabel", {
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://2592362371",
        ImageColor3 = Color3.new(),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 62, 62),
        Parent = Option.Slider
    });]]

    Option.Title = libraryX:Create("TextBox", {
        Position = UDim2.new((Option.Sub or Option.TextPos) and 0.5 or 0, (Option.Sub or Option.TextPos) and 0 or 6, (Option.Sub or Option.TextPos) and -0.1 or 0, -1.7),
        Size = UDim2.new(0, 0, 0, (Option.Sub or Option.TextPos) and 14 or 18),
        --Position = UDim2.new(0, 6, 0, 0),
        --Size = UDim2.new(1, - ((Option.Sub or Option.TextPos) and 12 or 6), 0, (Option.sub or Option.TextPos) and 12 or 18),
        BackgroundTransparency = 1,
        Text = (Option.Text ~= "nil" and Option.Text .. ": " or "") .. Option.Value .. Option.Suffix,
        TextSize = (Option.Sub or Option.TextPos) and 12 or 13,
        Font = Enum.Font.Code,
        TextColor3 = Color3.fromRGB(210, 210, 210),
        TextXAlignment = (Option.Sub or Option.TextPos) and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        Parent = (Option.Sub or Option.TextPos) and Option.Slider or Option.Main
    });

    table.insert(libraryX.Theme, Option.Fill);

    libraryX:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 115, 115)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
        }),
        Rotation = -90,
        Parent = Option.Fill
    });

    if Option.Min >= 0 then
        Option.Fill.Size = UDim2.new((Option.Value - Option.Min) / (Option.Max - Option.Min), 0, 1, 0);
    else
        Option.Fill.Position = UDim2.new((0 - Option.Min) / (Option.Max - Option.Min), 0, 0, 0);
        Option.Fill.Size = UDim2.new(Option.Value / (Option.Max - Option.Min), 0, 1, 0);
    end;

    local ManualInput;
    Option.Title.Focused:Connect(function()
        if not ManualInput then
            Option.Title:ReleaseFocus();
            Option.Title.Text = (Option.Text == "nil" and "" or Option.Text .. ": ") .. Option.Value .. Option.Suffix;
        end;
    end);

	Option.Title.FocusLost:Connect(function()
		Option.Slider.BorderColor3 = Color3.new();
		if ManualInput then
			local InputValue = tonumber(Option.Title.Text);
			if InputValue then
				Option:SetValue(InputValue, nil, true);
			else
				Option.Title.Text = (Option.Text == "nil" and "" or Option.Text .. ": ") .. Option.Value .. Option.Suffix;
			end;
		end;
		ManualInput = false;
	end);

	local Interest = (Option.Sub or Option.TextPos) and Option.Slider or Option.Main;
	if not Interest then return; end;

	Interest.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if InputService:IsKeyDown(Enum.KeyCode.LeftControl) or InputService:IsKeyDown(Enum.KeyCode.RightControl) then
				ManualInput = true;
				Option.Title:CaptureFocus();
			else
				libraryX.Slider = Option;
				Option.Slider.BorderColor3 = libraryX.Flags["Menu Accent Color"];
				Option:SetValue(Option.Min + ((Input.Position.X - Option.Slider.AbsolutePosition.X) / Option.Slider.AbsoluteSize.X) * (Option.Max - Option.Min));
			end;
		end;
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if not (libraryX.Warning or libraryX.Slider) then
				Option.Slider.BorderColor3 = libraryX.Flags["Menu Accent Color"];
			end;
			if Option.Tip then
				libraryX.ToolTip.Text = Option.Tip;
				libraryX.ToolTip.Size = UDim2.new(0, libraryX.GetTextBounds(Option.Tip, Enum.Font.Code, 14, "1"), 0, 20);
			end;
		end;
	end);

	Interest.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and  Option.Tip then
			libraryX.ToolTip.Position = UDim2.new(0, Input.Position.X + 5, 0, Input.Position.Y + 30);
		end;
	end);

	Interest.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			libraryX.ToolTip.Position = UDim2.new(2);
			if Option ~= libraryX.Slider then
				Option.Slider.BorderColor3 = Color3.new();
			end;
		end;
	end);

	function Option:SetValue(Value, NoCallBack, Check)
		Value = type(Value) == "number" and Value or 0;

		if self.Float < 0.5 then
			Value = libraryX.FormatNumber(libraryX.Round(Value, self.Float), 5);
		else
			Value = libraryX.Round(Value, self.Float);
		end;

		local Min, Max = self.Min, Check and math.min(self.Max, 9e9) or self.Max;
		if Check then
			Value = math.clamp(Value, Min, 9e9);
		else
			Value = math.clamp(Value, Min, Max);
		end;

		if Min >= 0 then
			pcall(self.Fill:TweenSize(UDim2.new((Value - Min) / (Max - Min), 0, 1, 0), "Out", "Quad", 0.05, true));
		else
			pcall(self.Fill:TweenPosition(UDim2.new((0 - Min) / (Max - Min), 0, 0, 0), "Out", "Quad", 0.05, true));
			pcall(self.Fill:TweenSize(UDim2.new(Value / (Max - Min), 0, 1, 0), "Out", "Quad", 0.1, true));
		end;

		libraryX.Flags[self.Flag] = Value;
		self.Value = Value;

		Option.Title.Text = (Option.Text == "nil" and "" or Option.Text .. ": ") .. self.Value .. (self.Suffix or "");

		if not NoCallBack then
			self.CallBack(Value);
		end;
	end;

	task.delay(1, function()
		if libraryX then
			Option:SetValue(Option.Value);
		end;
	end);
end;

libraryX.CreateList = function(Option, Parent)
	Option.HasInit = true;

	if Option.Sub then
		Option.Main = Option:GetMain();
		Option.Main.Size = UDim2.new(1, 0, 0, 48);
	else
		Option.Main = libraryX:Create("Frame", {
			LayoutOrder = Option.Position,
			Size = UDim2.new(1, 0, 0, Option.Text == "nil" and 30 or 43.9), -- 43.9 -- 48 
			BackgroundTransparency = 1,
			Parent = Parent
		});

		if Option.Text ~= "nil" then
			libraryX:Create("TextLabel", {
				Position = UDim2.new(0, 6.5, 0, 1.5), --(0, 6, 0, 0),
				Size = UDim2.new(1, -12, 0, 18),
				BackgroundTransparency = 1,
				Text = Option.Text,
				TextSize = 13, --15
				Font = Enum.Font.Code,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				TextXAlignment = Enum.TextXAlignment["Left"],
				Parent = Option.Main
			});
		end;
	end;

	local GetMultiText = function()
		local Values = {};
		for _, Value in next, Option.Values do
		--for Index = 1, #Option.Values do
			if Option.Value[Value] then
				table.insert(Values, tostring(Value));
			end;
		end;
		return table.concat(Values, ", ");
	end;

	Option.ListValue = libraryX:Create("TextLabel", {
		Position = UDim2.new(0, 6, 0, Option.Text == "nil" and not Option.Sub and 4 or 23),
		Size = UDim2.new(1, -12, 0, 16), --(1, -12, 0, 20), --(1, -12, 0, 22),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderColor3 = Color3.new(),
		Text = " " .. (type(Option.Value) == "string" and Option.Value or GetMultiText()),
		TextSize = 13, --15
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment["Left"],
		TextTruncate = Enum.TextTruncate["AtEnd"],
		Parent = Option.Main
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2454009026",
		ImageColor3 = Color3.new(),
		ImageTransparency = 0.8,
		Parent = Option.ListValue
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.ListValue
	});

	--[[libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.ListValue
	});]]

	Option.Arrow = libraryX:Create("ImageLabel", {
		Position = UDim2.new(1, -13.9, 0, 4), --(1, -16, 0, 7),
		Size = UDim2.new(0, 8, 0, 8),
		Rotation = 96,
		BackgroundTransparency = 1,
		Image = "rbxassetid://6282522798",
		ImageColor3 = Color3.new(1, 1, 1),
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = 0.4,
		Parent = Option.ListValue
	});

	Option.Holder = libraryX:Create("TextButton", {
		ZIndex = 4,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderColor3 = Color3.new(),
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		Parent = libraryX.Base
	});

	Option.Content = libraryX:Create("ScrollingFrame", {
		ZIndex = 4,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarImageColor3 = Color3.new(),
		ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		Parent = Option.Holder
	});

	libraryX:Create("ImageLabel", {
		ZIndex = 4,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.Holder
	});

	--[[libraryX:Create("ImageLabel", {
		ZIndex = 4,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.Holder
	});]]

	local Layout = libraryX:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		Parent = Option.Content
	}); if not Layout then return; end;

	libraryX:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		Parent = Option.Content
	});

	local ValueCount = 0;
	Layout.Changed:Connect(function()
		Option.Holder.Size = UDim2.new(0, Option.ListValue.AbsoluteSize.X, 0, 8 + (ValueCount > Option.Max and (-2 + (Option.Max * 22)) or Layout.AbsoluteContentSize.Y));
		Option.Content.CanvasSize = UDim2.new(0, 0, 0, 8 + Layout.AbsoluteContentSize.Y);
	end);

	local Interest = Option.Sub and Option.ListValue or Option.Main;
	if not Interest then return; end;

	Option.ListValue.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if libraryX.PopUp == Option then libraryX.PopUp:Close(); return; end;
			if libraryX.PopUp then libraryX.PopUp:Close(); end;
			Option.Arrow.Rotation = 1;
			Option.Open = true;
			Option.Holder.Visible = true;
			local Pos = Option.Main.AbsolutePosition;
			Option.Holder.Position = UDim2.new(0, Pos.X + 6, 0, Pos.Y + (Option.Text == "nil" and not Option.Sub and 66 or 78)); --84
			libraryX.PopUp = Option;
			Option.ListValue.BorderColor3 = libraryX.Flags["Menu Accent Color"];
		end;
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not (libraryX.Warning or libraryX.Slider) then
			Option.ListValue.BorderColor3 = libraryX.Flags["Menu Accent Color"];
		end;
	end);

	Option.ListValue.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and not Option.Open then
		  	Option.ListValue.BorderColor3 = Color3.new();
		end;
	end);

	Interest.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and Option.Tip then
			libraryX.ToolTip.Text = Option.Tip;
			libraryX.ToolTip.Size = UDim2.new(0, libraryX.GetTextBounds(Option.Tip, Enum.Font.Code, 14, "1"), 0, 20);
		end;
	end);

	Interest.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and Option.Tip then
			libraryX.ToolTip.Position = UDim2.new(0, Input.Position.X + 5, 0, Input.Position.Y + 30);
		end;
	end);

	Interest.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			libraryX.ToolTip.Position = UDim2.new(2);
		end;
	end);

	local Selected;
	function Option:AddValue(Value, State)
		if self.Labels[Value] then return; end;

		ValueCount = ValueCount + 1;

		if self.MultiSelect then
			self.Values[Value] = State;
		else
			if not table.find(self.Values, Value) then
				table.insert(self.Values, Value);
			end;
		end;

		local Label = libraryX:Create("TextLabel", {
			ZIndex = 4,
			Size = UDim2.new(1, 0, 0, 15.5), --(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text = Value,
			TextSize = 13, --15
			Font = Enum.Font.Code,
			TextTransparency = (self.MultiSelect and self.Value[Value] or self.Value == Value) and 1 or 0,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment["Left"],
			Parent = Option.Content
		});

		self.Labels[Value] = Label;

		local LabelOverlay = libraryX:Create("TextLabel", {
			ZIndex = 4,
			Size = UDim2.new(1, 0, 1, 0), --UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0.8,
			Text = " " .. Value,
			TextSize = 13, --15
			Font = Enum.Font.Code,
			TextColor3 = libraryX.Flags["Menu Accent Color"],
			TextXAlignment = Enum.TextXAlignment["Left"],
			Visible = (self.MultiSelect and self.Value[Value] or self.Value == Value),
			Parent = Label
		});

		Selected = Selected or (self.Value == Value and LabelOverlay);
		table.insert(libraryX.Theme, LabelOverlay);

		if Label then
			Label.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					if self.MultiSelect then
						self.Value[Value] = not self.Value[Value];
						self:SetValue(self.Value);
					else
						self:SetValue(Value);
						self:Close();
					end;
				end;
			end);
		end;
	end;

	for A, Value in pairs(Option.Values) do
		Option:AddValue(tostring(type(A) == "number" and Value or A));
	end;

	function Option:ReplaceList(NewTable)
		for A, Value in pairs(Option.Values) do
			Option:RemoveValue(tostring(type(A) == "number" and Value or A));
		end; for A, Value in pairs(NewTable) do
			Option:AddValue(tostring(type(A) == "number" and Value or A));
		end;
	end;

	function Option:RemoveValue(Value)
		local Label = self.Labels[Value];
		if Label then
			Label:Destroy();
			self.Labels[Value] = nil;
			ValueCount = ValueCount - 1;
			if self.MultiSelect then
				self.Values[Value] = nil;
				self:SetValue(self.Value);
			else
				local Index = table.find(self.Values, Value);
				if Index then
					table.remove(self.Values, Index);
				end;
				if self.Value == Value then
					Selected = nil;
					self:SetValue(self.Values[1] or "");
				end;
			end;
		end;
	end;

	function Option:SetValue(Value, NoCallBack)
		local MultiSelect = self.MultiSelect;

		if MultiSelect and type(Value) ~= "table" then
			Value = {};
			for _, B in pairs(self.Values) do
				Value[B] = false;
			end;
		end;

		self.Value = type(Value) == "table" and Value or tostring(table.find(self.Values, Value) and Value or self.Values[1]);
		libraryX.Flags[self.Flag] = self.Value;
		Option.ListValue.Text = " " .. (MultiSelect and GetMultiText() or self.Value);

		if MultiSelect then
			for Name, Label in pairs(self.Labels) do
				Label.TextTransparency = (self.Value[Name] and 1 or 0)
				if Label:FindFirstChild("TextLabel") then
					Label.TextLabel.Visible = self.Value[Name];
				end;
			end;
		else
			if Selected then
				Selected.TextTransparency = 0;
				if Selected:FindFirstChild("TextLabel") then
					Selected.TextLabel.Visible = false;
				end;
			end;

			if self.Labels[self.Value] then
				Selected = self.Labels[self.Value];
				Selected.TextTransparency = 1;
				if Selected:FindFirstChild("TextLabel") then
					Selected.TextLabel.Visible = true;
				end;
			end;
		end;

		if not NoCallBack then
			self.CallBack(self.Value);
		end;
	end;

	task.delay(1, function()
		if libraryX then Option:SetValue(Option.Value); end;
	end);

	function Option:Close()
		libraryX.PopUp = nil;
		Option.Arrow.Rotation = 96;
		self.Open = false;
		Option.Holder.Visible = false;
		Option.ListValue.BorderColor3 = Color3.new();
	end;

	return Option;
end;

libraryX.CreateBox = function(Option, Parent)
	Option.HasInit = true;

	Option.Main = libraryX:Create("Frame", {
		LayoutOrder = Option.Position,
		Size = UDim2.new(1, 0, 0, Option.Text == "nil" and 30 or 37.5),
		BackgroundTransparency = 1,
		Parent = Parent
	});

	if Option.Text ~= "nil" then
		Option.Title = libraryX:Create("TextLabel", {
			Position = UDim2.new(0, 6, 0, 1.7),
			Size = UDim2.new(1, -12, 0, 18),
			BackgroundTransparency = 1,
			Text = Option.Text,
			TextSize = 13,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment["Left"],
			Parent = Option.Main
		});
	end;

	Option.Holder = libraryX:Create("Frame", {
		Position = UDim2.new(0, 6, 0, (Option.Text == "nil" and 4 or 20)),
		Size = UDim2.new(1, -12, 0, 14),
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		BorderColor3 = Color3.new(),
		Parent = Option.Main
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2454009026",
		ImageColor3 = Color3.new(),
		ImageTransparency = 0.8,
		Parent = Option.Holder
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.Holder
	});

	--[[libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.Holder
	});]]

	local InputValue = libraryX:Create("TextBox", {
		Position = UDim2.new(0, 4, 0, 0),
		Size = UDim2.new(1, -4, 1, 0),
		BackgroundTransparency = 1,
		Text = "" .. (Option.Value ~= "nil" and Option.Value or ""),
		TextSize = 13,
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment["Left"],
		TextWrapped = true,
		ClearTextOnFocus = false,
		Parent = Option.Holder
	}); if not InputValue then return; end;

	InputValue.FocusLost:Connect(function(Enter)
		Option.Holder.BorderColor3 = Color3.new();
		Option:SetValue(InputValue.Text, Enter);
	end);

	InputValue.Focused:Connect(function()
		Option.Holder.BorderColor3 = libraryX.Flags["Menu Accent Color"];
	end);

	InputValue.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			InputValue.Text = "";
		end;
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if not (libraryX.Warning or libraryX.Slider) then
				Option.Holder.BorderColor3 = libraryX.Flags["Menu Accent Color"];
			end;
			if Option.Tip then
				libraryX.ToolTip.Text = Option.Tip;
				libraryX.ToolTip.Size = UDim2.new(0, libraryX.GetTextBounds(Option.Tip, Enum.Font.Code, 14, "1"), 0, 20);
			end;
		end;
	end);

	InputValue.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement and Option.Tip then
			libraryX.ToolTip.Position = UDim2.new(0, Input.Position.X + 5, 0, Input.Position.Y + 30);
		end;
	end);

	InputValue.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if not InputValue:IsFocused() and Option.Holder.BorderColor3 ~= Color3.new() then
				Option.Holder.BorderColor3 = Color3.new();
			end;
			libraryX.ToolTip.Position = UDim2.new(2);
		end;
	end);

	function Option:SetValue(Value, Enter)
		local StrValue = tostring(Value); if StrValue == "" then
			InputValue.Text = self.Value;
		end;

		libraryX.Flags[self.Flag] = StrValue;
		self.Value = StrValue;
		InputValue.Text = self.Value;
		self.CallBack(Value, Enter);
	end;

	--[[task.delay(1, function()
		if libraryX then
			Option:SetValue(Option.Value);
		end;
	end);]]
end;

libraryX.CreateCPicker = function(Option)
	Option.MainHolder = libraryX:Create("TextButton", {
		ZIndex = 4,
		Size = UDim2.new(0, Option.Trans and 200 or 184, 0, 219.5),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderColor3 = Color3.new(),
		AutoButtonColor = false,
		Visible = false,
		Parent = libraryX.Base
	});

	Option.RGBBox = libraryX:Create("Frame", {
		Position = UDim2.new(0, 6, 0, 171),
		Size = UDim2.new(0, (Option.MainHolder.AbsoluteSize.X - 12), 0, 17),
		BackgroundColor3 = Color3.fromRGB(57, 57, 57),
		BorderColor3 = Color3.new(),
		ZIndex = 5;
		Parent = Option.MainHolder
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2454009026",
		ImageColor3 = Color3.new(),
		ImageTransparency = 0.8,
		ZIndex = 6;
		Parent = Option.RGBBox
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		ZIndex = 6;
		Parent = Option.RGBBox
	});

	--[[libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		ZIndex = 6;
		Parent = Option.RGBBox
	});]]

	Option.RGBInput = libraryX:Create("TextBox", {
		Position = UDim2.new(0, 4, 0, 0),
		Size = UDim2.new(1, -4, 1, 0),
		BackgroundTransparency = 1,
		Text = tostring(Option.Color),
		TextSize = 13,
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment["Center"],
		TextWrapped = true,
		ClearTextOnFocus = false,
		ZIndex = 6;
		Parent = Option.RGBBox
	});

	Option.HexBox = Option.RGBBox:Clone();
	Option.HexBox.Position = UDim2.new(0, 6, 0, 195.5);
	Option.HexBox.Size = UDim2.new(0, (Option.MainHolder.AbsoluteSize.X - 12), 0, 17);
	Option.HexBox.Parent = Option.MainHolder;
	Option.HexInput = Option.HexBox.TextBox;

	libraryX:Create("ImageLabel", {
		ZIndex = 4,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.MainHolder
	});

	libraryX:Create("ImageLabel", {
		ZIndex = 4,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.MainHolder
	});

	local Hue, Sat, Val = Color3.toHSV(Option.Color);
	Hue, Sat, Val = Hue == 0 and 1 or Hue, Sat + 0.005, Val - 0.005;
	local EditingHue, EditingSatVal, EditingTrans;

	local TransMain;
	if Option.Trans then
		TransMain = libraryX:Create("ImageLabel", {
			ZIndex = 5,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://2454009026",
			ImageColor3 = Color3.fromHSV(Hue, 1, 1),
			Rotation = 180,
			Parent = libraryX:Create("ImageLabel", {
				ZIndex = 4,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -6, 0, 6),
				Size = UDim2.new(0, 10, 1, -60),
				BorderColor3 = Color3.new(),
				Image = "rbxassetid://4632082392",
				ScaleType = Enum.ScaleType.Tile,
				TileSize = UDim2.new(0, 5, 0, 5),
				Parent = Option.MainHolder
			})
		}); if not TransMain then return; end;

		Option.TransSlider = libraryX:Create("Frame", {
			ZIndex = 5,
			Position = UDim2.new(0, 0, Option.Trans, 0),
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = Color3.fromRGB(38, 41, 65),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			Parent = TransMain
		});

		TransMain.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				EditingTrans = true;
				Option:SetTrans(1 - ((Input.Position.Y - TransMain.AbsolutePosition.Y) / TransMain.AbsoluteSize.Y));
			end;
		end);

		TransMain.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				EditingTrans = false;
			end;
		end);
	end;

	local HueMain = libraryX:Create("Frame", {
		ZIndex = 4,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 6, 1, -55),
		Size = UDim2.new(1, Option.Trans and -28 or -12, 0, 10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(),
		Parent = Option.MainHolder
	}); if not HueMain then return; end;

	libraryX:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = HueMain
	});

	local HueSlider = libraryX:Create("Frame", {
		ZIndex = 4,
		Position = UDim2.new(1 - Hue, 0, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		BackgroundColor3 = Color3.fromRGB(38, 41, 65),
		BorderColor3 = Color3.fromRGB(255, 255, 255),
		Parent = HueMain
	});

	HueMain.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			EditingHue = true;
			X = (HueMain.AbsolutePosition.X + HueMain.AbsoluteSize.X) - HueMain.AbsolutePosition.X;
			X = math.clamp((Input.Position.X - HueMain.AbsolutePosition.X) / X, 0, 0.995);
			Option:SetColor(Color3.fromHSV(1 - X, Sat, Val));
		end;
	end);

	HueMain.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			EditingHue = false;
		end;
	end);

	local SatVal = libraryX:Create("ImageLabel", {
		ZIndex = 4,
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(1, Option.Trans and -28 or -12, 1, -75),
		BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
		BorderColor3 = Color3.new(),
		Image = "rbxassetid://4155801252",
		ClipsDescendants = true,
		Parent = Option.MainHolder
	}); if not SatVal then return; end;

	local SatValSlider = libraryX:Create("Frame", {
		ZIndex = 4,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(Sat, 0, 1 - Val, 0),
		Size = UDim2.new(0, 4, 0, 4),
		Rotation = 45,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Parent = SatVal
	});

	SatVal.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			EditingSatVal = true;
			X = (SatVal.AbsolutePosition.X + SatVal.AbsoluteSize.X) - SatVal.AbsolutePosition.X;
			Y = (SatVal.AbsolutePosition.Y + SatVal.AbsoluteSize.Y) - SatVal.AbsolutePosition.Y;
			X = math.clamp((Input.Position.X - SatVal.AbsolutePosition.X) / X, 0.005, 1);
			Y = math.clamp((Input.Position.Y - SatVal.AbsolutePosition.Y) / Y, 0, 0.995);
			Option:SetColor(Color3.fromHSV(Hue, X, 1 - Y));
		end;
	end);

	libraryX:AddConnection(InputService.InputChanged, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if EditingSatVal then
				X = (SatVal.AbsolutePosition.X + SatVal.AbsoluteSize.X) - SatVal.AbsolutePosition.X;
				Y = (SatVal.AbsolutePosition.Y + SatVal.AbsoluteSize.Y) - SatVal.AbsolutePosition.Y;
				X = math.clamp((Input.Position.X - SatVal.AbsolutePosition.X) / X, 0.005, 1);
				Y = math.clamp((Input.Position.Y - SatVal.AbsolutePosition.Y) / Y, 0, 0.995);
				Option:SetColor(Color3.fromHSV(Hue, X, 1 - Y));
			elseif EditingHue then
				X = (HueMain.AbsolutePosition.X + HueMain.AbsoluteSize.X) - HueMain.AbsolutePosition.X;
				X = math.clamp((Input.Position.X - HueMain.AbsolutePosition.X) / X, 0, 0.995);
				Option:SetColor(Color3.fromHSV(1 - X, Sat, Val));
			elseif EditingTrans then
				Option:SetTrans(1 - ((Input.Position.Y - TransMain.AbsolutePosition.Y) / TransMain.AbsoluteSize.Y));
			end;
		end;
	end);

	SatVal.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			EditingSatVal = false;
		end;
	end);

	local R, G, B = libraryX.Round(Option.Color);
	Option.HexInput.Text = ("#%02x%02x%02x"):format(R, G, B);
	Option.RGBInput.Text = table.concat({R, G, B}, ",");

	Option.RGBInput.FocusLost:Connect(function()
		local R, G, B = Option.RGBInput.Text:gsub("%s+", ""):match("(%d+),(%d+),(%d+)");
		if R and G and B then
			local Color = Color3.fromRGB(tonumber(R), tonumber(G), tonumber(B));
			return Option:SetColor(Color);
		end;

		local R, G, B = libraryX.Round(Option.Color);
		Option.RGBInput.Text = table.concat({R, G, B}, ",");
	end);

	Option.HexInput.FocusLost:Connect(function()
		local R, G, B = Option.HexInput.Text:match("#?(..)(..)(..)");
		if R and G and B then
			local Color = Color3.fromRGB(tonumber("0x" .. R), tonumber("0x" .. G), tonumber("0x" .. B));
			return Option:SetColor(Color);
		end;

		local R, G, B = libraryX.Round(Option.Color);
		Option.HexInput.Text = ("#%02x%02x%02x"):format(R, G, B);
	end);

	function Option:UpdateVisuals(Color)
		Hue, Sat, Val = Color3.toHSV(Color);
		Hue = Hue == 0 and 1 or Hue;
		SatVal.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1);
		if Option.Trans then
			TransMain.ImageColor3 = Color3.fromHSV(Hue, 1, 1);
		end;
		HueSlider.Position = UDim2.new(1 - Hue, 0, 0, 0);
		SatValSlider.Position = UDim2.new(Sat, 0, 1 - Val, 0);

		local R, G, B = libraryX.Round(Color3.fromHSV(Hue, Sat, Val));
		Option.HexInput.Text = ("#%02x%02x%02x"):format(R, G, B)
		Option.RGBInput.Text = table.concat({R, G, B}, ",");
	end;

	return Option;
end;

libraryX.CreateColor = function(Option, Parent)
	Option.HasInit = true;

	if Option.Sub then
		Option.Main = Option:GetMain();
	else
		Option.Main = libraryX:Create("Frame", {
			LayoutOrder = Option.Position,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Parent = Parent
		});

		Option.Title = libraryX:Create("TextLabel", {
			Position = UDim2.new(0, 6, 0, 0),
			Size = UDim2.new(1, -12, 1, 0),
			BackgroundTransparency = 1,
			Text = Option.Text,
			TextSize = 13,
			Font = Enum.Font.Code,
			TextColor3 = Color3.fromRGB(210, 210, 210),
			TextXAlignment = Enum.TextXAlignment["Left"],
			Parent = Option.Main
		});
	end;

	Option.Visualize = libraryX:Create(Option.Sub and "TextButton" or "Frame", {
		Position = UDim2.new(1, -(Option.SubPos or 0) - 24, 0, 4),
		Size = UDim2.new(0, 18, 0, 12),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = Option.Color,
		BorderColor3 = Color3.new(),
		Parent = Option.Main
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2454009026",
		ImageColor3 = Color3.new(),
		ImageTransparency = 0.6,
		Parent = Option.Visualize
	});

	libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.Visualize
	});

	--[[libraryX:Create("ImageLabel", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = Option.Visualize
	});]]

	local Interest = Option.Sub and Option.Visualize or Option.Main;
	if not Interest then return; end;

	if Option.Sub then
		Option.Visualize.Text = "";
		Option.Visualize.AutoButtonColor = false;
	end;

	Interest.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not Option.MainHolder then libraryX.CreateCPicker(Option); end;
			if libraryX.PopUp == Option then libraryX.PopUp:Close(); return; end;
			if libraryX.PopUp then libraryX.PopUp:Close(); end;
			Option.Open = true;
			local Pos = Option.Main.AbsolutePosition;
			Option.MainHolder.Position = UDim2.new(0, Pos.X + 36 + (Option.Trans and -16 or 0), 0, Pos.Y + 56);
			Option.MainHolder.Visible = true;
			libraryX.PopUp = Option;
			Option.Visualize.BorderColor3 = libraryX.Flags["Menu Accent Color"];
		end;
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if not (libraryX.Warning or libraryX.Slider) then
				Option.Visualize.BorderColor3 = libraryX.Flags["Menu Accent Color"];
			end;
			if Option.Tip then
				libraryX.ToolTip.Text = Option.Tip;
				libraryX.ToolTip.Size = UDim2.new(0, libraryX.GetTextBounds(Option.Tip, Enum.Font.Code, 14, "1"), 0, 20);
			end;
		end;
	end);

	Interest.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if Option.Tip then
				libraryX.ToolTip.Position = UDim2.new(0, Input.Position.X + 5, 0, Input.Position.Y + 30);
			end;
		end;
	end);

	Interest.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if not Option.Open then
				Option.Visualize.BorderColor3 = Color3.new();
			end;
			libraryX.ToolTip.Position = UDim2.new(2);
		end;
	end);

	function Option:SetColor(NewColor, NoCallBack)
		if type(NewColor) == "table" then
			NewColor = Color3.new(NewColor[1], NewColor[2], NewColor[3]);
		end;
		NewColor = NewColor or Color3.new(1, 1, 1);
		if self.MainHolder then
			self:UpdateVisuals(NewColor);
		end;
		Option.Visualize.BackgroundColor3 = NewColor;
		libraryX.Flags[self.Flag] = NewColor;
		self.Color = NewColor;
		if not NoCallBack then
			self.CallBack(NewColor);
		end;
	end;

	if Option.Trans then
		function Option:SetTrans(Value, Manual)
			Value = math.clamp(tonumber(Value) or 0, 0, 1);
			if self.TransSlider then
				self.TransSlider.Position = UDim2.new(0, 0, Value, 0);
			end;
			self.Trans = Value;
			libraryX.Flags[self.Flag .. " Transparency"] = 1 - Value;
			self.CallTrans(Value);
		end;
		Option:SetTrans(Option.Trans);
	end;

	task.delay(1, function()
		if libraryX then
			Option:SetColor(Option.Color);
		end;
	end);

	function Option:Close()
		libraryX.PopUp = nil;
		self.Open = false;
		self.MainHolder.Visible = false;
		Option.Visualize.BorderColor3 = Color3.new();
	end;
end;

function libraryX:AddTab(Title, Pos)
	local Tab = {Title = tostring(Title), Columns = {}, CanInit = true};
	table.insert(self.Tabs, Pos or #self.Tabs + 1, Tab);

	function Tab:AddColumn()
		local Column = {Sections = {}, Position = #self.Columns, CanInit = true, Tab = self};
		table.insert(self.Columns, Column);

		function Column:AddSection(Title)
			local Section = {Title = tostring(Title), Options = {}, CanInit = true, Column = self};
			table.insert(self.Sections, Section);

			function Section:AddLabel(Text)
				Option = type(Text) == "table" and Text or {text = Text};
				Option.Section = self;
				Option.Type = "Label";
				Option.PosM = Option.PosM and tostring(Option.PosM);
				Option.Position = #self.Options;
				Option.CanInit = true;
				table.insert(self.Options, Option);

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateLabel(Option, self.Content);
				else
					Option.Init = libraryX.CreateLabel;
				end;

				return Option;
			end;

			function Section:AddDivider(Text)
				Option = type(Text) == "table" and Text or {text = Text};
				Option.Section = self;
				Option.Type = "Divider";
				Option.Position = #self.Options;
				Option.CanInit = true;
				table.insert(self.Options, Option);

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateDivider(Option, self.Content);
				else
					Option.Init = libraryX.CreateDivider;
				end;

				return Option;
			end;

            function Section:AddBlank(Size)
				Option = type(Size) == "table" and Size or {size = Size};
				Option.Section = self;
				Option.Type = "Blank";
				Option.Position = #self.Options;
				Option.CanInit = true;
				table.insert(self.Options, Option);

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateBlank(Option, self.Content);
				else
					Option.Init = libraryX.CreateBlank;
				end;

				return Option;
			end;

			function Section:AddToggle(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.State = Option.State == nil and nil or (type(Option.State) == "boolean" and Option.State or false);
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.Type = "Toggle";
				Option.Position = #self.Options;
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.SubCount = 0;
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				Option.Style = Option.Style == 2;
				libraryX.Flags[Option.Flag] = Option.State;
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				function Option:AddColor(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddColor(SubOption);
				end;

				function Option:AddBind(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddBind(SubOption);
				end;

				function Option:AddList(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddList(SubOption);
				end;

				function Option:AddSlider(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddSlider(SubOption);
				end;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateToggle(Option, self.Content);
				else
					Option.Init = libraryX.CreateToggle;
				end;

				return Option;
			end;

			function Section:AddButton(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.Type = "Button";
				Option.Position = #self.Options;
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.SubCount = 0;
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				Option.Style = Option.Style == 2;
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				function Option:AddBind(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() Option.Main.Size = UDim2.new(1, 0, 0, 40) return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddBind(SubOption);
				end;

				function Option:AddColor(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() Option.Title.Size = UDim2.new(1, 0, 0, 40) return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddColor(SubOption);
				end;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateButton(Option, self.Content);
				else
					Option.Init = libraryX.CreateButton;
				end;

				return Option;
			end;

			function Section:AddBind(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.Key = (Option.Key and Option.Key.Name) or Option.Key or "None";
				Option.NoMouse = type(Option.NoMouse) == "boolean" and Option.NoMouse or false;
				Option.Mode = type(Option.Mode) == "string" and (Option.Mode == "Toggle" or Option.Mode == "Hold" and Option.Mode) or "Toggle";
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.Type = "Bind";
				Option.Position = #self.Options;
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateBind(Option, self.Content);
				else
					Option.Init = libraryX.CreateBind;
				end;

				return Option;
			end;

			function Section:AddSlider(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.Min = type(Option.Min) == "number" and Option.Min or 0;
				Option.Max = type(Option.Max) == "number" and Option.Max or 0;
				Option.Value = Option.Min < 0 and 0 or math.clamp(type(Option.Value) == "number" and Option.Value or Option.Min, Option.Min, Option.Max);
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.Float = type(Option.Value) == "number" and Option.Float or 1;
				Option.Suffix = Option.Suffix and tostring(Option.Suffix) or "";
				Option.TextPos = Option.TextPos == 2;
				Option.Type = "Slider";
				Option.Position = #self.Options;
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.SubCount = 0;
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				libraryX.Flags[Option.Flag] = Option.Value;
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				--[[if type(Option.float) == "number" then
					local _ = '' .. Option.float;
					local Num = select(2, _:gsub('%d', function(A) return A end));
					Option.Places = math.max(1, Num - 1);
				else
					Option.Places = 1;
				end]]

				function Option:AddColor(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddColor(SubOption);
				end;

				function Option:AddBind(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddBind(SubOption);
				end;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateSlider(Option, self.Content);
				else
					Option.Init = libraryX.CreateSlider;
				end;

				return Option;
			end;

            function Section:AddList(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.Values = type(Option.Values) == "table" and Option.Values or {};
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.MultiSelect = type(Option.MultiSelect) == "boolean" and Option.MultiSelect or false;
				--Option.GroupBox = (not Option.MultiSelect) and (type(Option.GroupBox) == "boolean" and Option.GroupBox or false);
				Option.Value = Option.MultiSelect and (type(Option.Value) == "table" and Option.Value or {}) or tostring(Option.Value or Option.Values[1] or "");
				if Option.MultiSelect then
					for _, B in pairs(Option.Values) do
						Option.Value[B] = false;
					end;
				end;
				Option.Max = Option.Max or 4;
				Option.Open = false;
				Option.Type = "List";
				Option.Position = #self.Options;
				Option.Labels = {};
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.SubCount = 0;
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				libraryX.Flags[Option.Flag] = Option.Value;
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				function Option:AddValue(Value, State)
					if self.MultiSelect then
						self.Values[Value] = State;
					else
						table.insert(self.Values, Value);
					end;
				end;

				function Option:AddColor(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddColor(SubOption);
				end;

				function Option:AddBind(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddBind(SubOption);
				end;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateList(Option, self.Content);
				else
					Option.Init = libraryX.CreateList;
				end;

				return Option;
			end;

			function Section:AddBox(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.Value = tostring(Option.Value or "");
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.Type = "Box";
				Option.Position = #self.Options;
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				libraryX.Flags[Option.Flag] = Option.Value;
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateBox(Option, self.Content);
				else
					Option.Init = libraryX.CreateBox;
				end;

				return Option;
			end;

			function Section:AddColor(Option)
				Option = type(Option) == "table" and Option or {};
				Option.Section = self;
				Option.Text = tostring(Option.Text);
				Option.Color = type(Option.Color) == "table" and Color3.new(Option.Color[1], Option.Color[2], Option.Color[3]) or Option.Color or Color3.new(1, 1, 1);
				Option.CallBack = typeof(Option.CallBack) == "function" and Option.CallBack or function() end;
				Option.CallTrans = typeof(Option.CallTrans) == "function" and Option.CallTrans or (Option.CallTrans == 1 and Option.CallBack) or function() end;
				Option.Open = false;
				Option.Trans = tonumber(Option.Trans);
				Option.SubCount = 1;
				Option.Type = "Color";
				Option.Position = #self.Options;
				Option.Flag = (libraryX.FlagPrefix and libraryX.FlagPrefix .. " " or "") .. (Option.Flag or Option.Text);
				Option.CanInit = (Option.CanInit ~= nil and Option.CanInit) or true;
				Option.Tip = Option.Tip and tostring(Option.Tip);
				libraryX.Flags[Option.Flag] = Option.Color;
				table.insert(self.Options, Option);
				libraryX.Options[Option.Flag] = Option;

				function Option:AddColor(SubOption)
					SubOption = type(SubOption) == "table" and SubOption or {};
					SubOption.Sub = true;
					SubOption.SubPos = self.SubCount * 24;
					function SubOption:GetMain() return Option.Main; end;
					self.SubCount = self.SubCount + 1;
					return Section:AddColor(SubOption);
				end;

				if Option.Trans then
					libraryX.Flags[Option.Flag .. " Transparency"] = Option.Trans;
				end;

				if libraryX.HasInit and self.HasInit then
					libraryX.CreateColor(Option, self.Content);
				else
					Option.Init = libraryX.CreateColor;
				end;

				return Option;
			end;

			function Section:SetTitle(NewTitle)
				self.Title = tostring(NewTitle)
				if self.TitleText then
					self.TitleText.Text = tostring(NewTitle);
				end;
			end;

			function Section:Init()
				if self.HasInit then return; end;
				self.HasInit = true;

				self.Main = libraryX:Create("Frame", {
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					BorderColor3 = Color3.new(),
					Parent = Column.Main
				});

				self.Content = libraryX:Create("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					BorderColor3 = Color3.fromRGB(60, 60, 60),
					BorderMode = Enum.BorderMode.Inset,
					Parent = self.Main
				});

				libraryX:Create("ImageLabel", {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.new(0, 1, 0, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2592362371",
					ImageColor3 = Color3.new(),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 62, 62),
					Parent = self.Main
				});

				table.insert(libraryX.Theme, libraryX:Create("Frame", {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = libraryX.Flags["Menu Accent Color"],
					BorderSizePixel = 0,
					BorderMode = Enum.BorderMode.Inset,
					Parent = self.Main
				}));

				local Layout = libraryX:Create("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2),
					Parent = self.Content
				}); if not Layout then return; end;

				libraryX:Create("UIPadding", {
					PaddingTop = UDim.new(0, 12),
					Parent = self.Content
				});

				self.TitleText = libraryX:Create("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(0, libraryX.GetTextBounds(self.Title, Enum.Font.Code, 15, "1") + 5, 0, 4);
				    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					BorderSizePixel = 0,
					Text = self.Title,
					TextSize = 13,
					Font = Enum.Font.Code,
					TextColor3 = Color3.new(1, 1, 1),
					Parent = self.Main
				});

				Layout.Changed:Connect(function()
					self.Main.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 16);
				end);

				for _, Option in next, self.Options do
					if Option.CanInit then
						Option.Init(Option, self.Content);
					end;
				end;
			end;

			if libraryX.HasInit and self.HasInit then
				Section:Init();
			end;

			return Section;
		end;

		function Column:Init()
			if self.HasInit then return; end;
			self.HasInit = true;

			self.Main = libraryX:Create("ScrollingFrame", {
				ZIndex = 2,
				Position = UDim2.new(0, 6 + (self.Position * 205), 0, -9),
				Size = UDim2.new(0, 198, 1, -4),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarImageColor3 = Color3.fromRGB(),
				ScrollBarThickness = 5,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				ScrollingDirection = Enum.ScrollingDirection.Y,
				Visible = false,
				Parent = libraryX.ColumnHolder
			});

			local Layout = libraryX:Create("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 12),
				Parent = self.Main
			}); if not Layout then return; end;

			libraryX:Create("UIPadding", {
				PaddingTop = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				Parent = self.Main
			});

			Layout.Changed:Connect(function()
				self.Main.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 14);
			end);

			for _, Section in next, self.Sections do
				if Section.CanInit and #Section.Options > 0 then
					Section:Init();
				end;
			end;
		end;

		if libraryX.HasInit and self.HasInit then
			Column:Init();
		end;

		return Column;
	end;

	function Tab:Init()
		if self.HasInit then return; end;
		self.HasInit = true;
		local Size = libraryX.GetTextBounds(self.Title, Enum.Font.Code, 15, "1") + 6;

		self.Button = libraryX:Create("TextLabel", {
			Position = UDim2.new(0, libraryX.TabSize, 0, 15),
			Size = UDim2.new(0, Size, 0, 30),
			BackgroundTransparency = 1,
			Text = self.Title,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 13,
			Font = Enum.Font.Code,
			TextWrapped = true,
			ClipsDescendants = true,
			Parent = libraryX.Main
		});
		libraryX.TabSize = libraryX.TabSize + Size;

		self.Button.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				libraryX:SelectTab(self);
			end;
		end);

		for _, Column in next, self.Columns do
			if Column.CanInit then
				Column:Init();
			end;
		end;
	end;

	if self.HasInit then
		Tab:Init();
	end;

	return Tab;
end;

function libraryX:AddWarning(Warning)
	Warning = type(Warning) == "table" and Warning or {};
	Warning.Text = tostring(Warning.Text);
	Warning.Type = Warning.Type == "Confirm" and "Confirm" or Warning.Type == "Error" and "Error" or "";

	local Answer;
	function Warning:Show()
		libraryX.Warning = Warning;
		if Warning.Main and Warning.Type == "" then return; end;
		if libraryX.Popup then libraryX.Popup:Close(); end;
		if not Warning.Main then
			Warning.Main = libraryX:Create("TextButton", {
				ZIndex = 2,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 0.6,
				BackgroundColor3 = Color3.new(),
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = libraryX.Main
			});

			Warning.Message = libraryX:Create("TextLabel", {
				ZIndex = 2,
				Position = UDim2.new(0, 20, 0.5, -50),
				Size = UDim2.new(1, -40, 0, 40),
				BackgroundTransparency = 1,
				TextSize = 14,
				Font = Enum.Font.Code,
				TextColor3 = Color3.new(1, 1, 1),
				TextWrapped = true,
				RichText = true,
				Parent = Warning.Main
			});

			if Warning.Type == "Confirm" then
				local Button = libraryX:Create("TextLabel", {
					ZIndex = 2,
					Position = UDim2.new(0.5, -105, 0.5, -10),
					Size = UDim2.new(0, 100, 0, 20),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					BorderColor3 = Color3.new(),
					Text = "Yes",
					TextSize = 14,
					Font = Enum.Font.Code,
					TextColor3 = Color3.new(1, 1, 1),
					Parent = Warning.Main
				}); if not Button then return; end;

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2454009026",
					ImageColor3 = Color3.new(),
					ImageTransparency = 0.8,
					Parent = Button
				});

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2592362371",
					ImageColor3 = Color3.fromRGB(60, 60, 60),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 62, 62),
					Parent = Button
				});

				local Button1 = libraryX:Create("TextLabel", {
					ZIndex = 2,
					Position = UDim2.new(0.5, 5, 0.5, -10),
					Size = UDim2.new(0, 100, 0, 20),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					BorderColor3 = Color3.new(),
					Text = "No",
					TextSize = 14,
					Font = Enum.Font.Code,
					TextColor3 = Color3.new(1, 1, 1),
					Parent = Warning.Main
				}); if not Button1 then return; end;

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2454009026",
					ImageColor3 = Color3.new(),
					ImageTransparency = 0.8,
					Parent = Button1
				});

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2592362371",
					ImageColor3 = Color3.fromRGB(60, 60, 60),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 62, 62),
					Parent = Button1
				});

				Button.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Answer = true;
					end;
				end);

				Button1.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Answer = false;
					end;
				end);
			elseif Warning.Type == "Error" then
				local Button = libraryX:Create("TextLabel", {
					ZIndex = 2,
					Position = UDim2.new(0.5, -50, 0.5, -10),
					Size = UDim2.new(0, 100, 0, 20),
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					BorderColor3 = Color3.new(),
					Text = "Okay",
					TextSize = 14,
					Font = Enum.Font.Code,
					TextColor3 = Color3.new(1, 1, 1),
					Parent = Warning.Main
				}); if not Button then return; end;

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2454009026",
					ImageColor3 = Color3.new(),
					ImageTransparency = 0.8,
					Parent = Button
				});

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2592362371",
					ImageColor3 = Color3.fromRGB(60, 60, 60),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 62, 62),
					Parent = Button
				});

				Button.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Answer = true;
					end;
				end);
			else
				local Button = libraryX:Create("TextLabel", {
					ZIndex = 2,
					Position = UDim2.new(0.5, -50, 0.5, -10),
					Size = UDim2.new(0, 100, 0, 20),
					BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					BorderColor3 = Color3.new(),
					Text = "Okay",
					TextSize = 14,
					Font = Enum.Font.Code,
					TextColor3 = Color3.new(1, 1, 1),
					Parent = Warning.Main
				}); if not Button then return; end;

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://2454009026",
					ImageColor3 = Color3.new(),
					ImageTransparency = 0.8,
					Parent = Button
				});

				libraryX:Create("ImageLabel", {
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BackgroundTransparency = 1,
					Image = "rbxassetid://3570695787",
					ImageColor3 = Color3.fromRGB(50, 50, 50),
					Parent = Button
				});

				Button.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Answer = true;
					end;
				end);
			end;
		end;
		Warning.Main.Visible = true;
		Warning.Message.Text = Warning.Text;

		repeat wait() until Answer ~= nil;
		spawn(Warning.Close);
		libraryX.Warning = nil;
		return Answer;
	end;

	function Warning:Close()
		Answer = nil;
		if not Warning.Main then return; end;
		Warning.Main.Visible = false;
	end;

	return Warning;
end;

function libraryX:Close()
	self.Open = not self.Open;
	InputService.MouseIconEnabled = self.Open and false or self.MouseState;

	if self.Main then
		if libraryX.Popup then self.PopUp:Close(); end;
		self.Main.Visible = self.Open;
		self.Cursor.Visible = self.Open;
		self.CursorOutline.Visible = self.Open;
	end;
end;

function libraryX:Init(...)
    local Args = {...};

	local Config = type(...) == "table" and ... or {
		Title = Args[1],
		AutoShow = Args[2] or false
	}; --AnchorPoint = Vector2.zero

    if typeof(Config.Position) ~= "UDim2" then Config.Position = UDim2.fromOffset(175, 50); end;

    --Config.AnchorPoint = Config.Center and Vector2.new(0.7, 0.7) or Config.AnchorPoint
	--Config.Position = Config.Center and UDim2.fromScale(0.5, 0.5) or Config.Position

	if self.HasInit then return; end;
	self.HasInit = true;

	self.Base = libraryX:Create("ScreenGui", {IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Global});
	if (type(syn) == "table" and typeof(syn.protect_gui) == "function" and gethui == nil) then
		pcall(function() syn.protect_gui(self.Base); end);
	end;

	if RunService:IsStudio() then
		self.Base.Parent = script.Parent.Parent;
	else
		self.Base.Parent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or CoreGui;
	end;

	self.Main = self:Create("ImageButton", {
		AutoButtonColor = false,
		AnchorPoint = Config.AnchorPoint,
		Position = Config.Position, --Position = UDim2.new(0, 100, 0, 46),
		Size = UDim2.new(0, 420, 0, 485),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Tile,
		Modal = true,
		Visible = false,
		Parent = self.Base
	});

	self.Top = self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.new(),
		Parent = self.Main
	});

	self:Create("Frame", {
        Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(1, 0, 0, 2.7),
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BorderColor3 = Color3.fromRGB(5, 5, 5),
		BackgroundTransparency = 0.6,
		ZIndex = 1,
		Parent = self.Main
	});

	libraryX:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(29, 29, 29)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 12, 12)),
		}),
		Rotation = 90,
		Parent = self.Top
	});

	local TitleLabel = self:Create("TextLabel", {
		Position = UDim2.new(0, 6, 0, -1),
		Size = UDim2.new(0, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = tostring(Config.Title) or tostring(self.Title) or "",
		Font = Enum.Font.Code,
		TextSize = 15,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment["Left"],
		Parent = self.Main
	});

	table.insert(libraryX.Theme, self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 21),
		BackgroundColor3 = libraryX.Flags["Menu Accent Color"],
		BorderSizePixel = 0,
		Parent = self.Main
	}));

	libraryX:Create("ImageLabel", {
	    Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2454009026",
		ImageColor3 = Color3.new(),
		ImageTransparency = 0.4,
		Parent = self.Top
	});

	self.TabHighlight = self:Create("Frame", {
		BackgroundColor3 = libraryX.Flags["Menu Accent Color"],
		BorderSizePixel = 0,
		Parent = self.Main
	});

	table.insert(libraryX.Theme, self.TabHighlight);

	self.ColumnHolder = self:Create("Frame", {
		Position = UDim2.new(0, 5, 0, 55),
		Size = UDim2.new(1, -10, 1, -60),
		BackgroundTransparency = 1,
		Parent = self.Main
	});

    self.NotificationArea = self:Create("Frame", {
        Position = UDim2.new(0, 10, 0, 300),
        Size = UDim2.new(0, 300, 0, 200),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = self.Base
    });

    self:Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.NotificationArea
    });

    self.Cursor = self:Create("Triangle", {
		Thickness = 1;
		Color = Color3.fromRGB(255, 255, 255),
		Filled = true;
		Visible = true;
	});
	self.CursorOutline = self:Create("Triangle", {
		Thickness = 1;
		Filled = false;
		Color = Color3.fromRGB(85, 85, 85),
		Visible = true;
	});

	self.ToolTip = self:Create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextSize = 12,
		Font = Enum.Font.Code,
		TextColor3 = Color3.new(1, 1, 1),
		Visible = true,
		ZIndex = 100 + 1,
		Parent = self.Base,
	})

	self.TAFrame = self:Create("Frame", {
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.2, 0),
		Size = UDim2.new(0.9, 5, 0.7, 0),
		Parent = self.ToolTip
	});

	self.TBorder = self:Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 1,
		Position = UDim2.new(0, -1, 0, -1);
		Size = UDim2.new(1, 2, 1, 2);
		--Style = Enum.FrameStyle.RobloxRound,
		ZIndex = 100 - 1;
		Parent = self.TAFrame;
	});

	libraryX:Create("UIGradient", {
        Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0.0732026, 0.0732026, 0.0732026)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 28)),
        });
        Rotation = -90,
        Parent = self.TAFrame
    });

	self:Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.fromRGB(60, 60, 60),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = self.Main
	});

	self:Create("ImageLabel", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://2592362371",
		ImageColor3 = Color3.new(),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 62, 62),
		Parent = self.Main
	});

	self.Top.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			DragObject = self.Main;
			Dragging = true;
			DragStart = Input.Position;
			if DragObject and DragObject.Position then
				StartPos = DragObject.Position;
			end;
			if libraryX.PopUp then libraryX.PopUp:Close(); end;
		end;
	end);

	self.Top.InputChanged:Connect(function(Input)
		if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input;
		end;
	end);

	self.Top.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false;
		end;
	end);

    function self:SetTitle(NewTitle)
        TitleLabel.Text = tostring(NewTitle)
    end;

	function self:SelectTab(Tab)
		if self.CurrentTab == Tab then return; end;
		if libraryX.PopUp then libraryX.PopUp:Close(); end;
		if self.CurrentTab then
			self.CurrentTab.Button.TextColor3 = Color3.fromRGB(255, 255, 255);
			for _, Column in next, self.CurrentTab.Columns do
				Column.Main.Visible = false;
			end;
		end;
		self.Main.Size = UDim2.new(0, 16 + ((#Tab.Columns < 2 and 2 or #Tab.Columns) * 202), 0, 485);
		--self.Main:TweenSize(UDim2.new(0, 16 + ((#Tab.Columns < 2 and 2 or #Tab.Columns) * 202), 0, 485), "Out", "Quad", 0.2, true);
		self.CurrentTab = Tab;
		Tab.Button.TextColor3 = libraryX.Flags["Menu Accent Color"];
		for _, Column in next, Tab.Columns do
			Column.Main.Visible = true;
		end;
	end;

	coroutine.wrap(function()
		while libraryX do
			task.wait(1);
			local Configs = self:GetConfigs();
			for _, C in pairs(Configs) do
				if not table.find(self.Options["Config List"].Values, C) then
					self.Options["Config List"]:AddValue(C);
				end;
			end;
			for _, C in pairs(self.Options["Config List"].Values) do
				if not table.find(Configs, C) then
					self.Options["Config List"]:RemoveValue(C);
				end;
			end;
		end;
	end)();

	for _, Tab in next, self.Tabs do
		if Tab.CanInit then
			Tab:Init();
			self:SelectTab(Tab);
		end;
	end;

	self:AddConnection(InputService.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 and self.Slider then
			self.Slider.Slider.BorderColor3 = Color3.new();
			self.Slider = nil;
		end;
	end);

	self:AddConnection(InputService.InputChanged, function(Input)
		if not self.Open then return; end;

		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			if self.Cursor then
				local MPos = InputService:GetMouseLocation();
				self.Cursor.PointA = Vector2.new(MPos.X, MPos.Y);
				self.Cursor.PointB = Vector2.new(MPos.X + 15, MPos.Y + 6);
				self.Cursor.PointC = Vector2.new(MPos.X + 6, MPos.Y + 15);
				self.CursorOutline.PointA, self.CursorOutline.PointB, self.CursorOutline.PointC = self.Cursor.PointA, self.Cursor.PointB, self.Cursor.PointC;
			end;
			if self.Slider then
				self.Slider:SetValue(self.Slider.Min + ((Input.Position.X - self.Slider.Slider.AbsolutePosition.X) / self.Slider.Slider.AbsoluteSize.X) * (self.Slider.Max - self.Slider.Min));
			end;
		end;
		if Input == DragInput and Dragging and libraryX.Draggable then
			local Delta = Input.Position - DragStart;
			local YPos = (StartPos.Y.Offset + Delta.Y) < -36 and -36 or StartPos.Y.Offset + Delta.Y;
			pcall(DragObject:TweenPosition(UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, YPos), "Out", "Quint", 0.1, true));
		end;
	end);

	ReplaceMM = function(ToHook, Method, ReplacementFunc)
        if type(Method) ~= "string" or typeof(ReplacementFunc) ~= "function" then
            self:Notify("Error", "Invalid Input To ReplaceMM");
            return;
        end;

        local Hook = nil;
        if issynapsefunction then
            Hook = hookfunction(getrawmetatable(ToHook)[Method], function(...) return ReplacementFunc(Hook, ...); end);
        else
            Hook = hookmetamethod(ToHook, Method, function(...) return ReplacementFunc(Hook, ...); end);
        end;

        if not Hook then
            self:Notify("Error", "Failed To Hook Method " .. Method);
            return;
        end;
    end;

	ReplaceMM(game, "__index", function(Old_Index, Item, Property)
		if libraryX and Property == "MouseIconEnabled" then
			return libraryX.MouseState;
		end;

		return Old_Index(Item, Property);
	end);

	ReplaceMM(game, "__newindex", function(Old_NewIndex, Item, Property, Val)
		if libraryX and Property == "MouseIconEnabled" then
			libraryX.MouseState = Val;
			if libraryX.Open then return; end;
		end;

		return Old_NewIndex(Item, Property, Val);
	end);

	if Config.AutoShow then
		task.delay(1, function()
			pcall(self.Close, self);
		end);
	end;
end;

return libraryX;
