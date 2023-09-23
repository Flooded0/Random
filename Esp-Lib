local CCamera, WFFC, WTVP, PlrServ, Client, RunService, InputService = workspace.CurrentCamera, workspace.FindFirstChild, workspace.CurrentCamera.WorldToViewportPoint, game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("RunService"), game:GetService("UserInputService");

if getgenv().Esp then
	getgenv().Esp:Unload();
end;

local Esp = {
    Settings = {
        Enabled = false,
        Players = true,
        Objects = false,

        AutoRemove = true,
        IgnoreHumID = false,
        FaceCamera = false,
        TeamColor = false,
        TeamMates = true,
        TOutline = true,
        TextFont = "Plex", --["UI", "System", "Plex", "Monospace"]
        TextSize = 14.5,
        TextSurround = 1, --["None", "[]", "--", "<>"]
        TextCase = 1, --["Normal", "LowerCase", "UpperCase"]
        Color = Color3.fromRGB(255, 255, 255),

        UsePDisCheck = false,
        UseODisCheck = false,
        P_MaxDistance = math.huge,
        O_MaxDistance = math.huge,

        Box = {Enabled = false, Color = Color3.new(1, 1, 1), TH = 1, Shift = CFrame.new(0, -0.4, 0), Size = Vector3.new(4, 5, 0)},
        Name = {Enabled = false, Color = Color3.new(1, 1, 1), Pos = "Bottom"}, --[Top, Bottom, Left, Right];
        Distance = {Enabled = false, Color = Color3.new(1, 1, 1), Pos = "Bottom", Mode = "Meters"}, --[Top, Bottom, Left, Right]; --["Meters", "Studs"];
        Health = {Enabled = false, Pos = "Bottom"}, --[Top, Bottom, Left, Right];
        HealthBar = {Enabled = false, Color = Color3.new(1, 1, 1), Pos = "Bottom"}, --[Top, Bottom, Left, Right];
        Tool = {Enabled = false, Color = Color3.new(1, 1, 1), Pos = "Bottom"},
        Info = {Enabled = false, Color = Color3.new(1, 1, 1), Pos = "Bottom"},
        ViewAngle = {Enabled = false, Color = Color3.new(1, 1, 1), TH = 1},
        Tracer = {Enabled = false, Color = Color3.new(1, 1, 1), Pos = "Bottom", TH = 1, AShift = 1}, --[Mouse, Top, Bottom, Left, Right];
        OSArrow = {Enabled = false, Enabled2 = false, Color = Color3.new(1, 1, 1), Trans = .5, OutlineColor = Color3.new(0, 0, 0), OutlineTrans = 1, Size = 6, Width = 0.5, Radius = 150, Style = "", Modes = {}} --[Name, Distance];
    },
    DrawOrder = {
        Box = 0,
        Name = 2,
        Distance = 2,
        Health = 2,
        Tool = 2,
        Info = 2,
        ViewAngle = 1,
        Tracer = 1
    },
    Objects = setmetatable({}, {__mode = "kv"}),
    OverRides = {}
};

getgenv().Esp = Esp;

function Esp:IsInT(Table, Value) return table.find(Table, Value) ~= nil; end;
function Esp:Draw(Obj, Props)
    local New = Drawing.new(Obj);
    for Property, Value in pairs(Props or {}) do
        New[Property] = Value;
    end;
    return New;
end;
function Esp:DrawDynamic(Class, Props, ...)
    local New = Class.new(...);
    for Property, Value in pairs(Props or {}) do
        New[Property] = Value;
    end;
    return New;
end;

function Esp:GetScreenPos(Position, Camera)
    local Pos = typeof(Position) ~= "CFrame" and Position or Position.Position;
    local ScreenPos, IsOnScreen = Camera:WorldToViewportPoint(Pos);
    return Vector2.new(ScreenPos.X, ScreenPos.Y), IsOnScreen;
end;

function Esp:GetTool(Obj)
    local Ov = self.OverRides.GetTool;
    if Ov then return Ov(Obj); end;

    local Tool = Obj and Obj:FindFirstChildOfClass("Tool");
    return Tool and Tool.Name or "None";
end;

function Esp:GetInfo(Obj)
    local Ov = self.OverRides.GetInfo;
    if Ov then return Ov(Obj); end;

    local Plr = Esp:GetPlrFromChar(Obj)
    return Plr.AccountAge or "N/A";
end;

function Esp:GetHealth(Obj)
    local Ov = self.OverRides.GetHealth;
    if Ov then return Ov(Obj); end;

    local Humanoid = Obj and Obj:FindFirstChildOfClass("Humanoid");
    if not Humanoid then return 0, 0; end;
    return Humanoid.Health, Humanoid.MaxHealth;
end;

function Esp:GetHitBoxFromChar(Char, BodyPart)
    local Ov = self.OverRides.GetHitBoxFromChar;
    if Ov then return Ov(Char, BodyPart); end;

    BodyPart = BodyPart or "Head";
    if not Char then return; end;

    local BodyPartToReturn;
    if game.GameId == 1168263273 or game.PlaceId == 1168263273 then
        BodyPartToReturn = WFFC(Char.Body, BodyPart) or WFFC(Char.Body, "Chest");
    else
        BodyPartToReturn = WFFC(Char, BodyPart) or WFFC(Char, "UpperTorso");
    end;

    if not BodyPartToReturn then return; end;
    return BodyPartToReturn;
end;

function Esp:GetPlrFromChar(Char)
    local Ov = self.OverRides.GetPlrFromChar;
    if Ov then return Ov(Char); end;

    return PlrServ:GetPlayerFromCharacter(Char);
end;

function Esp:GetObject(Obj)
    return self.Objects[Obj];
end;

function Esp:GetTeam(Player)
    local Ov = self.OverRides.GetTeam;
    if Ov then return Ov(Player); end;

    return Player and Player.Team or nil;
end;

function Esp:IsTeamMate(Player)
    local Ov = self.OverRides.IsTeamMate;
    if Ov then return Ov(Player); end;

    return self:GetTeam(Player) == self:GetTeam(Client);
end;

function Esp:GetColor(Obj)
    local Ov = self.OverRides.GetColor;
    if Ov then return Ov(Obj); end;

    local Player = self:GetPlrFromChar(Obj);
    return Player and self.Settings.TeamColor and Player.Team and Player.Team.TeamColor.Color or self.Settings.Color or Color3.new(1, 0, 0);
end;

function Esp:Toggle(State)
    self.Settings.Enabled = State;

    if not State then
        for _, B in pairs(self.Objects) do
            if B.Type == "Box" then
                if B.Temporary then
                    B:Remove();
                else
                    for _, D in pairs(B.Components) do
                        --if D == "Highlight" then
                            --D.Enabled = false;
                        --else
                            D.Visible = false;
                        --end;
                    end;
                end;
            end;
        end;
    end;
end;

function Esp:AddObjectListener(Parent, Options)
    local NewListener = function(Obj)
        if type(Options.Type) == "string" and Obj:IsA(Options.Type) or Options.Type == nil then
            if type(Options.Name) == "string" and Obj.Name == Options.Name or Options.Name == nil then
                if not Options.Validator or Options.Validator(Obj) then
                    local Box = Esp:Add(Obj, {
                        PrimaryPart = type(Options.PrimaryPart) == "string" and Obj:WaitForChild(Options.PrimaryPart) or typeof(Options.PrimaryPart) == "function" and Options.PrimaryPart(Obj),
                        Color = typeof(Options.Color) == "function" and Options.Color(Obj) or Options.Color,
                        ColorDynamic = Options.ColorDynamic,
                        Name = typeof(Options.CustomName) == "function" and Options.CustomName(Obj) or Options.CustomName,
                        IsEnabled = Options.IsEnabled,
                        RenderInNil = Options.RenderInNil
                    });

                    if Options.OnAdded then
                        coroutine.wrap(Options.OnAdded)(Box);
                    end;
                end;
            end;
        end;
    end;

    if Options.Recursive then
        Parent.DescendantAdded:Connect(NewListener);
        for _, B in pairs(Parent:GetDescendants()) do
            coroutine.wrap(NewListener)(B);
        end
    else
        Parent.ChildAdded:Connect(NewListener);
        for _, B in pairs(Parent:GetChildren()) do
            coroutine.wrap(NewListener)(B);
        end;
    end;
end;

local Plr_MT = {};
do --[Plr-MT];
    Plr_MT.__index = Plr_MT;

    function Plr_MT:Remove()
        Esp.Objects[self.Object] = nil;
        for Index, Component in pairs(self.Components) do
            --if Index == "Highlight" then
                --Component.Enabled = false;
                --Component:Remove();
            --else
                --if Component.Visible then
                    Component.Visible = false;
                    Component:Remove();
                --end;
            --end;
            self.Components[Index] = nil;
        end;
    end;

    function Plr_MT:Update()
        if not self.PrimaryPart then return self:Remove(); end; --warn("Not Supposed To Print", self.Object)

        --[[local Color;
        if Esp.Settings.Highlighted == self.Object then
            Color = Esp.Settings.HighlightColor;
        else
            Color = self.Color or self.ColorDynamic and self:ColorDynamic() or Esp:GetColor(self.Object) or Esp.Settings.Color;
        end;]]

        local Color = self.Color or self.ColorDynamic and self:ColorDynamic() or Esp:GetColor(self.Object) or Esp.Settings.Color;

        local Allow = true;
        if Esp.OverRides.UpdateAllow and not Esp.OverRides.UpdateAllow(self) then Allow = false; end;
        if self.Player and not Esp.Settings.TeamMates and Esp:IsTeamMate(self.Player) then Allow = false; end;
        if self.Player and not Esp.Settings.Players then Allow = false; end;
        if self.IsEnabled and (type(self.IsEnabled) == "string" and not Esp[self.IsEnabled] or typeof(self.IsEnabled) == "function" and not self:IsEnabled()) then Allow = false; end;
        if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then Allow = false; end;
        if not Allow then
            for Index, Component in pairs(self.Components) do
                --if Index == "Highlight" then
                    --Component.Enabled = false;
                --else
                    Component.Visible = false;
                --end;
            end;

            return;
        end;

        if Esp.Settings.Highlighted == self.Object then Color = Esp.Settings.HighlightColor; end;
        local IsPHighlighted = (Esp.Settings.Highlighted == self.Object and self.Player ~= nil);

        local CF = self.PrimaryPart.CFrame;
        if Esp.Settings.FaceCamera then CF = CFrame.new(CF.Position, CCamera.CFrame.Position); end;
        local DistanceV = (CF.Position - CCamera.CFrame.Position).Magnitude;
        if self.Player and Esp.Settings.UsePDisCheck and math.floor(DistanceV) > Esp.Settings.P_MaxDistance then
            for Index, Component in pairs(self.Components) do
                --if Index == "Highlight" then
                    --Component.Enabled = false;
                --else
                    Component.Visible = false;
                --end;
            end;

            return;
        end;
        --self.Distance = DistanceV;

        local Box_S, Name_S, Distance_S, HealthT_S, HealthB_S, ToolT_S, InfoT_S, ViewAngle_S, Tracer_S, OSArrow_S = Esp.Settings.Box, Esp.Settings.Name, Esp.Settings.Distance, Esp.Settings.Health, Esp.Settings.HealthBar, Esp.Settings.Tool, Esp.Settings.Info, Esp.Settings.ViewAngle, Esp.Settings.Tracer, Esp.Settings.OSArrow;

        local Size = self.Size;
        local Locs = {
            TopLeft = CF * Box_S.Shift * CFrame.new(Size.X / 2, Size.Y / 2, 0),
            TopRight = CF * Box_S.Shift * CFrame.new(-Size.X / 2, Size.Y / 2, 0),
            BottomLeft = CF * Box_S.Shift * CFrame.new(Size.X / 2, -Size.Y / 2, 0),
            BottomRight = CF * Box_S.Shift * CFrame.new(-Size.X / 2, -Size.Y / 2, 0),
            TagPos = CF * Box_S.Shift * CFrame.new(0, -Size.Y / 2, 0),
            Torso = CF * Box_S.Shift
        };

        if Box_S.Enabled then
            local TopLeft, Vis1 = CCamera:WorldToViewportPoint(Locs.TopLeft.Position);
            local TopRight, Vis2 = CCamera:WorldToViewportPoint(Locs.TopRight.Position);
            local BottomLeft, Vis3 = CCamera:WorldToViewportPoint(Locs.BottomLeft.Position);
            local BottomRight, Vis4 = CCamera:WorldToViewportPoint(Locs.BottomRight.Position);

            if self.Components.Quad then
                if Vis1 or Vis2 or Vis3 or Vis4 then
                    self.Components.Quad.Visible = true;
                    self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y);
                    self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y);
                    self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y);
                    self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y);
                    self.Components.Quad.Color = Color;
                    self.Components.Quad.ZIndex = Esp.DrawOrder.Box + (IsPHighlighted and 1 or 0);
                else
                    self.Components.Quad.Visible = false;
                end;
            end;
        else
            self.Components.Quad.Visible = false;
        end;

        if Name_S.Enabled then
            local TagPos, Vis5 = CCamera:WorldToViewportPoint(Locs.TagPos.Position);

            if self.Components.Name then
                if Vis5 then
                    self.Components.Name.Visible = true;
                    self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y);
                    self.Components.Name.Text = self.Name;
                    self.Components.Name.Color = Color;
                    self.Components.Name.ZIndex = Esp.DrawOrder.Name + (IsPHighlighted and 1 or 0);
                    if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                        self.Components.Name.Font = Drawing.Fonts[Esp.Settings.TextFont];
                    end;
                else
                    self.Components.Name.Visible = false;
                end;
            end;
        else
            self.Components.Name.Visible = false;
        end;

        if Distance_S.Enabled then
            local TagPos, Vis6 = CCamera:WorldToViewportPoint(Locs.TagPos.Position);
            local Mode = Distance_S.Mode;

            if Vis6 then
                self.Components.Distance.Visible = true;
                self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 12);
                self.Components.Distance.Text = Mode == "Meters" and tostring(math.floor(DistanceV / 3)) .. "m" or Mode == "Studs" and tostring(math.floor(DistanceV / 1)) .. "s";
                self.Components.Distance.Color = Color;
                self.Components.Distance.ZIndex = Esp.DrawOrder.Distance + (IsPHighlighted and 1 or 0);
                if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                    self.Components.Distance.Font = Drawing.Fonts[Esp.Settings.TextFont];
                end;
            else
                self.Components.Distance.Visible = false;
            end;
        else
            self.Components.Distance.Visible = false;
        end;

        if HealthT_S.Enabled then
            local TagPos, Vis7 = CCamera:WorldToViewportPoint(Locs.TagPos.Position);

            if Vis7 then
                if self.Object and self.Object:FindFirstChildOfClass("Humanoid") then
                    local R, G = Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 8);
                    local Health, MaxHealth = Esp:GetHealth(self.Object), self.Object:FindFirstChildOfClass("Humanoid").MaxHealth;

                    self.Components.Health.Visible = true;
                    self.Components.Health.Position = Vector2.new(TagPos.X, TagPos.Y + 24.5);
                    self.Components.Health.Text = tostring(math.floor(Health + 0.5));
                    self.Components.Health.Color = R:lerp(G, Health / MaxHealth);
                    self.Components.Health.ZIndex = Esp.DrawOrder.Health + (IsPHighlighted and 1 or 0);
                    if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                        self.Components.Health.Font = Drawing.Fonts[Esp.Settings.TextFont];
                    end;
                end;
            else
                self.Components.Health.Visible = false;
            end;
        else
            self.Components.Health.Visible = false;
        end;

        --[[if HealthB_S.Enabled then
            local TorsoPos, Vis7 = CCamera:WorldToViewportPoint(Locs.Torso.Position);

            if Vis7 then
                if self.Object and self.Object:FindFirstChildOfClass("Humanoid") then
                    local R, G = Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 8);
                    local Health, MaxHealth = Esp:GetHealth(self.Object), self.Object:FindFirstChildOfClass("Humanoid").MaxHealth;

                    local HBSize = Vector2.new(1, -(Locs.Torso.Size.Y * (Health / MaxHealth)));
                    local HBPos = Vector2.new(TorsoPos.X - (3 + HBSize.X), TorsoPos.Y + Locs.Torso.Size.Y);
                    self.Components.HealthBar.Visible = true;
                    self.Components.HealthBar.Color = R:lerp(G, Health / MaxHealth);
                    self.Components.HealthBar.Transparency = 1;
                    self.Components.HealthBar.Size = HBSize;
                    self.Components.HealthBar.Position = HBPos;
                    --self.Components.HealthBarOutline.Visible = true;
                    --self.Components.HealthBarOutline.Transparency = 1;
                    --self.Components.HealthBarOutline.Size = Vector2.new(HBSize.X, -Locs.Torso.Size.Y) + Vector2.new(2, -2);
                    --self.Components.HealthBarOutline.Position = HBPos - Vector2.new(1, -1);
                end;
            else
                self.Components.HealthBar.Visible = false;
                self.Components.HealthBarOutline.Visible = false;
            end;
        else
            self.Components.HealthBar.Visible = false;
            self.Components.HealthBarOutline.Visible = false;
        end;]]

        if ToolT_S.Enabled then
            local TagPos, Vis8 = CCamera:WorldToViewportPoint(Locs.TagPos.Position);

            if Vis8 then
                if self.Object then
                    local Tool = Esp:GetTool(self.Object);

                    self.Components.Tool.Visible = true;
                    self.Components.Tool.Position = Vector2.new(TagPos.X + 1, TagPos.Y + 36);
                    self.Components.Tool.Text = tostring(Tool);
                    self.Components.Tool.Color = Color;
                    self.Components.Tool.ZIndex = Esp.DrawOrder.Tool + (IsPHighlighted and 1 or 0);
                    if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                        self.Components.Tool.Font = Drawing.Fonts[Esp.Settings.TextFont];
                    end;
                end;
            else
                self.Components.Tool.Visible = false;
            end;
        else
            self.Components.Tool.Visible = false;
        end;

        if InfoT_S.Enabled then
            local TagPos, Vis8 = CCamera:WorldToViewportPoint(Locs.TagPos.Position);

            if Vis8 then
                if self.Object then
                    local Info = Esp:GetInfo(self.Object);

                    self.Components.Info.Visible = true;
                    self.Components.Info.Position = Vector2.new(TagPos.X + 1, TagPos.Y + 36);
                    self.Components.Info.Text = tostring(Info);
                    self.Components.Info.Color = Color;
                    self.Components.Info.ZIndex = Esp.DrawOrder.Info + (IsPHighlighted and 1 or 0);
                    if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                        self.Components.Info.Font = Drawing.Fonts[Esp.Settings.TextFont];
                    end;
                end;
            else
                self.Components.Info.Visible = false;
            end;
        else
            self.Components.Info.Visible = false;
        end;

        if ViewAngle_S.Enabled then
            local _, Vis9 = CCamera:WorldToViewportPoint(Locs.Torso.Position);

            if Vis9 then
                if self.Object and self.Object:FindFirstChild("Head") then
                    local PHead = self.Object.Head;
                    local FromHead = CCamera:WorldToViewportPoint(PHead.CFrame.Position);
                    local ToPoint = CCamera:WorldToViewportPoint((PHead.CFrame + (PHead.CFrame.LookVector * 3)).Position);

                    self.Components.ViewAngle.Visible = true;
                    self.Components.ViewAngle.From = Vector2.new(FromHead.X, FromHead.Y);
                    self.Components.ViewAngle.To = Vector2.new(ToPoint.X, ToPoint.Y);
                    self.Components.ViewAngle.Color = ViewAngle_S.Color;
                    self.Components.ViewAngle.ZIndex = Esp.DrawOrder.ViewAngle + (IsPHighlighted and 1 or 0);
                end;
            else
                self.Components.ViewAngle.Visible = false;
            end;
        else
            self.Components.ViewAngle.Visible = false;
        end;

        if Tracer_S.Enabled then
            local TorsoPos, Vis10 = CCamera:WorldToViewportPoint(Locs.Torso.Position);
            local Pos = Tracer_S.Pos;

            if Vis10 then
                self.Components.Tracer.Visible = true;
                self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y);
                self.Components.Tracer.To = Pos == "Mouse" and InputService:GetMouseLocation() or Pos == "Top" and Vector2.new(CCamera.ViewportSize.X / 2, 0) or Pos == "Bottom" and Vector2.new(CCamera.ViewportSize.X / 2, CCamera.ViewportSize.Y / Tracer_S.AShift) or Pos == "Left" or Pos == "Right";
                self.Components.Tracer.Color = Tracer_S.Color;
                self.Components.Tracer.ZIndex = Esp.DrawOrder.Tracer + (IsPHighlighted and 1 or 0);
            else
                self.Components.Tracer.Visible = false;
            end;
        else
            self.Components.Tracer.Visible = false;
        end;

        local _, Vis11 = CCamera:WorldToViewportPoint(Locs.Torso.Position);
        if not Vis11 then
            local ScreenCenter = Vector2.new(CCamera.ViewportSize.X / 2, CCamera.ViewportSize.Y / 2);
            local ObjSpacePoint = (CFrame.new().PointToObjectSpace(CCamera.CFrame, Locs.Torso.Position) * Vector3.new(1, 0, 1)).Unit;
            local CrossVec = Vector3.new().Cross(ObjSpacePoint, Vector3.new(0, OSArrow_S.Width, 1));
            local RightVec = Vector2.new(CrossVec.X, CrossVec.Z);
            local ArrowPos = ScreenCenter + Vector2.new(ObjSpacePoint.X, ObjSpacePoint.Z) * OSArrow_S.Radius;
            local ArrowDir = (ArrowPos - ScreenCenter).Unit;
            local PointB, PointC = ScreenCenter + ArrowDir * (OSArrow_S.Radius - OSArrow_S.Size) + RightVec * OSArrow_S.Size, ScreenCenter + ArrowDir * (OSArrow_S.Radius - OSArrow_S.Size) + -RightVec * OSArrow_S.Size;

            if OSArrow_S.Enabled then
                self.Components.Arrow.Visible = true;
                self.Components.Arrow.Filled = true;
                self.Components.Arrow.Color = OSArrow_S.Color;
                self.Components.Arrow.Transparency = OSArrow_S.Trans;
                self.Components.Arrow.PointA = ArrowPos;
                self.Components.Arrow.PointB = PointB;
                self.Components.Arrow.PointC = PointC;
            else
                self.Components.Arrow.Visible = false
            end;

            if OSArrow_S.Enabled2 then
                self.Components.Arrow2.Visible = true;
                self.Components.Arrow2.Filled = false;
                self.Components.Arrow2.Color = OSArrow_S.OutlineColor;
                self.Components.Arrow2.Transparency = OSArrow_S.OutlineTrans;
                self.Components.Arrow2.PointA = ArrowPos;
                self.Components.Arrow2.PointB = PointB;
                self.Components.Arrow2.PointC = PointC;
            else
                self.Components.Arrow2.Visible = false;
            end;

            local OSize = OSArrow_S.Size + 15
            local BoxPos = Vector2.new(ArrowPos + PointB + PointC / 3 - Vector2.new(OSize / 2, OSize / 2));
            local BoxSize = Vector2.new(OSize - 2, OSize);

            if Esp:IsInT(OSArrow_S.Modes, "Name") then
                self.Components.Name.Visible = true;
                self.Components.Name.Position = ArrowPos + Vector2.new(BoxSize.X / 6 + BoxPos.X, BoxSize.X + BoxPos.Y - 3);
                self.Components.Name.Text = self.Name;
                self.Components.Name.Color = Color;
                self.Components.Name.ZIndex = Esp.DrawOrder.Name + (IsPHighlighted and 1 or 0);
                if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                    self.Components.Name.Font = Drawing.Fonts[Esp.Settings.TextFont];
                end;
            else
                self.Components.Name.Visible = false;
            end;

            if Esp:IsInT(OSArrow_S.Modes, "Distance") then
                local Mode = Distance_S.Mode;

                self.Components.Distance.Visible = true;
                self.Components.Distance.Position = ArrowPos + Vector2.new(BoxSize.X / 6 + BoxPos.X, BoxSize.X + BoxPos.Y + 6.5);
                self.Components.Distance.Text = Mode == "Meters" and tostring(DistanceV) .. "m" or Mode == "Studs" and tostring(DistanceV) .. "s";
                self.Components.Distance.Color = Color;
                self.Components.Distance.ZIndex = Esp.DrawOrder.Distance + (IsPHighlighted and 1 or 0);
                if Drawing.Fonts and Drawing.Fonts[Esp.Settings.TextFont] then
                    self.Components.Distance.Font = Drawing.Fonts[Esp.Settings.TextFont];
                end;
            else
                self.Components.Distance.Visible = false;
            end;
        else
            self.Components.Arrow.Visible = false;
            self.Components.Arrow2.Visible = false;
        end;
    end;
end;

--[[local Object_MT = {};
do --[Object-MT]
    Object_MT.__index = Object_MT;
end;]]

function Esp:Add(Obj, Options)
    if not Obj.Parent and not Options.RenderInNil then
        return warn(Obj, "Has No Parent");
    end;

    local EspS = self.Settings;
    local Box = setmetatable({
        Name = Options.Name or Obj.Name,
        Type = "Box",
        Color = Options.Color, --or self:GetColor(Obj),
        Size = Options.Size or EspS.Box.Size,
        Object = Obj,
        Player = Options.Player or PlrServ:GetPlayerFromCharacter(Obj),
        PrimaryPart = Options.PrimaryPart or (Obj.ClassName == "Model" and (Obj.PrimaryPart or Obj:FindFirstChild("HumanoidRootPart") or Obj:FindFirstChildWhichIsA("BasePart")) or Obj:IsA("BasePart") and Obj),
        Components = {},
        IsEnabled = Options.IsEnabled,
        Temporary = Options.Temporary,
        ColorDynamic = Options.ColorDynamic,
        RenderInNil = Options.RenderInNil
    }, Plr_MT);

    if self:GetObject(Obj) then self:GetObject(Obj):Remove(); end;

    local Components, IsEnabled = Box.Components, EspS.Enabled;
    Components["Quad"] = Esp:Draw("Quad", {
        Thickness = EspS.Box.TH,
        Color = Box.Color,
        Transparency = 1,
        Filled = false,
        Visible = IsEnabled and EspS.Box.Enabled,
        ZIndex = self.DrawOrder.Box
    }); Components["Name"] = Esp:Draw("Text", {
        Text = Box.Name,
        Color = Box.Color,
        Center = true,
        Outline = EspS.TOutline,
        Size = EspS.TextSize,
        Visible = IsEnabled and EspS.Name.Enabled,
        ZIndex = self.DrawOrder.Name
    }); Components["Distance"] = Esp:Draw("Text", {
        Color = Box.Color,
        Center = true,
        Outline = EspS.TOutline,
        Size = EspS.TextSize,
        Visible = IsEnabled and EspS.Distance.Enabled,
        ZIndex = self.DrawOrder.Distance
    }); Components["Health"] = Esp:Draw("Text", {
        Center = true,
        Outline = EspS.TOutline,
        Size = EspS.TextSize,
        Visible = IsEnabled and EspS.Health.Enabled,
        ZIndex = self.DrawOrder.Health
    }); --[[Components["HealthBar"] = Esp:Draw("Line", {
        Thickness = 1,
        Transparency = 1,
        Visible = IsEnabled and EspS.HealthBar.Enabled
    }); Components["HealthBarOutline"] = Esp:Draw("Line", {
        Thickness = 2,
        Transparency = 1
        Visible = IsEnabled and EspS.HealthBar.Enabled
    });]] Components["Tool"] = Esp:Draw("Text", {
        Color = Box.Color,
        Center = true,
        Outline = EspS.TOutline,
        Size = EspS.TextSize,
        Visible = IsEnabled and EspS.Tool.Enabled,
        ZIndex = self.DrawOrder.Tool
    }); Components["Info"] = Esp:Draw("Text", {
        Color = Box.Color,
        Center = true,
        Outline = EspS.TOutline,
        Size = EspS.TextSize,
        Visible = IsEnabled and EspS.Info.Enabled,
        ZIndex = self.DrawOrder.Info
    }); Components["ViewAngle"] = Esp:Draw("Line", {
        Thickness = EspS.ViewAngle.TH,
        Transparency = 1,
        Visible = IsEnabled and EspS.ViewAngle.Enabled,
        ZIndex = self.DrawOrder.ViewAngle
    }); Components["Tracer"] = Esp:Draw("Line", {
        Thickness = EspS.Tracer.TH,
        Transparency = 1,
        Visible = IsEnabled and EspS.Tracer.Enabled,
        ZIndex = self.DrawOrder.Tracer
    });

    Components["Arrow"] = Esp:Draw("Triangle", {Thickness = 1});
    Components["Arrow2"] = Esp:Draw("Triangle", {Thickness = 1});

    self.Objects[Box] = Box;

    local AutoRemove = EspS.AutoRemove ~= false;
    Obj.AncestryChanged:Connect(function(_, Parent)
        if Parent == nil and AutoRemove then
            Box:Remove(); --self:Remove();
        end;
    end);

    Obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if Obj.Parent == nil and AutoRemove then
            Box:Remove(); --self:Remove();
        end;
    end);

    local Hum = Obj:FindFirstChildOfClass("Humanoid");
    if Hum and (not Esp.Settings.IgnoreHumID) then
        Hum.Died:Connect(function()
            if AutoRemove then
                Box:Remove(); --self:Remove();
            end;
		end);
    end;

    return Box;
end;

local CharAdded = function(Char)
    local Player = PlrServ:GetPlayerFromCharacter(Char);

    if not Char:FindFirstChild("HumanoidRootPart") then
        local Ev; Ev = Char.ChildAdded:Connect(function(A)
            if A.Name == "HumanoidRootPart" then
                Ev:Disconnect()
                Esp:Add(Char, {
                    Name = Player.Name,
                    Player = Player,
                    PrimaryPart = A
                });
            end;
        end);
    else
        Esp:Add(Char, {
            Name = Player.Name,
            Player = Player,
            PrimaryPart = Char.HumanoidRootPart
        });
    end;
end;

local PlayerAdded = function(Player)
    Player.CharacterAdded:Connect(CharAdded);
    if Player.Character then
        coroutine.wrap(CharAdded)(Player.Character);
    end; --[[else
        Player.CharacterAdded:Wait()
        coroutine.wrap(CharAdded)(Player.Character);
    end]]
end;

PlrServ.PlayerAdded:Connect(PlayerAdded);
for _, Player in pairs(PlrServ:GetPlayers()) do
    if Player ~= Client then
        PlayerAdded(Player);
    end;
end;

function Esp:Unload()
	if self.OnRenderStepped then
        self.OnRenderStepped:Disconnect();
    end;

	for _, Obj in pairs(self.Objects) do
		if Obj.Remove then
			Obj:Remove();
		end;
	end;

	table.clear(self.Objects);
end;

Esp.OnRenderStepped = RunService.RenderStepped:Connect(function()
    CCamera = workspace.CurrentCamera;
    for _, A in (Esp.Settings.Enabled and pairs or ipairs)(Esp.Objects) do
        if A.Update then
            local Success, Error = pcall(A.Update, A);
            if not Success then
                warn("[EU]", Error, A.Object:GetFullName());
            end;
        end;
    end;
end);

return Esp;

--[[Esp:Toggle(true);

Esp.Settings.Box.Shift, Esp.Settings.Box.Size = CFrame.new(0, -0, 0), Vector3.new(4, 5.5, 0);
Esp.OverRides.GetHealth, Esp.OverRides.GetTool = function(Char)
    if not Char or typeof(Char) ~= "Instance" then return 0, 0; end;

    local Stats, Humanoid = Char:FindFirstChild("Stats"), Char:FindFirstChildOfClass("Humanoid");
    if not Stats or not Humanoid then return 0, 0; end;

    local Health = Stats:FindFirstChild("Health");
    if Health then
        return (Health.Base.Value + (Health.Bonus.Value or 0)), (Humanoid.MaxHealth + (Health.Bonus.Value or 0));
    else
        return -1, (Humanoid.MaxHealth + (Health.Bonus.Value or 0));
    end;
end, function(Char)
    if not Char or typeof(Char) ~= "Instance" then return "None"; end;
    local Equipped = Char:FindFirstChild("Equipped");
    local Tool = Equipped and Equipped:FindFirstChildOfClass("Model");
    return Tool and tostring(Tool):gsub("Mod%d+", "") or "None";
end;]]
