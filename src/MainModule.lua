--[[

██████╗░██████╗░██████╗░██╗░░░░░██████╗░███████╗██╗░░░██╗
██╔══██╗██╔══██╗██╔══██╗██║░░░░░██╔══██╗██╔════╝██║░░░██║
██████╔╝██████╔╝██████╔╝██║░░░░░██║░░██║█████╗░░╚██╗░██╔╝
██╔═══╝░██╔══██╗██╔═══╝░██║░░░░░██║░░██║██╔══╝░░░╚████╔╝░
██║░░░░░██║░░██║██║░░░░░███████╗██████╔╝███████╗░░╚██╔╝░░
╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚══════╝╚═════╝░╚══════╝░░░╚═╝░░░

Product Diagnostic Tool V3 (Modified by prpldev, original creator printersofa)

--]]


local diag = {}
local gui = script.WHDT
local LogAmt = 0
local http = game:GetService("HttpService")
local marketplaceservice = game:GetService("MarketplaceService")
local groupservice = game:GetService("GroupService")
local status = gui.Background.Window.Status
local LogService = game:GetService("LogService")
local ButtonInformation = {nil,nil} -- {State,Decision}

-- literally just takes the inputted string and decides what color its assigned too
function decideColor(color)
	if color == "red" or color == "r" then
		return Color3.fromRGB(255, 66, 66)
	elseif color == "green" or color == "g" then
		return Color3.fromRGB(38, 255, 118)
	elseif color == "yellow" or color == "y" then
		return Color3.fromRGB(245, 255, 139)
	elseif color == "blue" or color == "b" then
		return Color3.fromRGB(4, 176, 255)
	end
end

-- adds items to the list (how it displays the results of the current check instead of the previously giant textbox)
function addItem(Type : string, Message : string, Color : string)
	if Type == "warning" or Type == "warn" or Type == "w" then
		local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
		Clone.Icon.Image = "rbxassetid://11419713314"
		Clone.Icon.ImageColor3 = decideColor(Color)
		Clone.Message.Text = Message
		Clone.Visible = true
		Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
		Clone.Name = tostring(LogAmt+1)
	elseif Type == "success" or Type == "yes" or Type == "y" then
		local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
		Clone.Icon.Image = "rbxassetid://11419719540"
		Clone.Icon.ImageColor3 = decideColor(Color)
		Clone.Message.Text = Message
		Clone.Visible = true
		Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
		Clone.Name = tostring(LogAmt+1)
	elseif Type == "failure" or Type == "no" or Type == "n" then
		local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
		Clone.Icon.Image = "rbxassetid://11419709766"
		Clone.Icon.ImageColor3 = decideColor(Color)
		Clone.Message.Text = Message
		Clone.Visible = true
		Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
		Clone.Name = tostring(LogAmt+1)
	elseif Type == "httpon" or Type == "httpoff" then
		if Type == "httpon" then
			local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
			Clone.Icon.Image = "rbxassetid://11963348609"
			Clone.Icon.ImageColor3 = decideColor(Color)
			Clone.Message.Text = Message
			Clone.Visible = true
			Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
			Clone.Name = tostring(LogAmt+1)
		else
			local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
			Clone.Icon.Image = "rbxassetid://11963348339"
			Clone.Icon.ImageColor3 = decideColor(Color)
			Clone.Message.Text = Message
			Clone.Visible = true
			Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
			Clone.Name = tostring(LogAmt+1)
		end
	elseif Type == "lock" then
		local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
		Clone.Icon.Image = "rbxassetid://14187755345"
		Clone.Icon.ImageColor3 = decideColor(Color)
		Clone.Message.Text = Message
		Clone.Visible = true
		Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
		Clone.Name = tostring(LogAmt+1)
	elseif Type == "info" then
		local Clone = gui.Background.Window.HolderFrame.ScrollingFrame.Template:Clone()
		Clone.Icon.Image = "rbxassetid://11422155687"
		Clone.Icon.ImageColor3 = decideColor(Color)
		Clone.Message.Text = Message
		Clone.Visible = true
		Clone.Parent = gui.Background.Window.HolderFrame.ScrollingFrame
		Clone.Name = tostring(LogAmt+1)
	else
		return {false,"Invalid type."}
	end
	LogAmt = LogAmt+1
end

local allowedDiag = true

function diag.runDiagnostics()
	-- establish variables
	local results = {}
	local resultscode = {}
	local restricted = false
	local wrestricted = false
	local unpublished = false

	-- double check the resets if its the same session
	LogAmt = 0
	gui.Parent = game.CoreGui
	status.Text = ""
	for i,v in pairs(gui.Background.Window.HolderFrame.ScrollingFrame:GetChildren()) do
		if v.Name ~= "Template" and v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	unpublished = false
	wrestricted = false
	restricted = false
	gui.Background.Window.SupportCode.Title.Visible = false
	gui.Background.Window.SupportCode.Code.Visible = false
	gui.Background.Window.SupportCode.Code.Text = ""


	-- game publish check (printersofa + prpldev)
	status.Text = "Checking game status..."
	if game.CreatorId ~= 998796 and game.CreatorId ~= 0 and game.CreatorId ~= nil then
		addItem("yes","This game is published.","green")
		table.insert(resultscode, 1)
	else
		addItem("no","This game is not published, publish it using <b>File > Publish to Roblox</b>.","red")
		table.insert(resultscode, 0)
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)

	-- creator type check (printersofa)
	status.Text = "Checking game creator type..."
	if game.CreatorType == Enum.CreatorType.User then
		if not unpublished then
			addItem("yes","The creator of this game is a <b>user</b>.","green")
		end
		table.insert(resultscode, 1)
	elseif game.CreatorType == Enum.CreatorType.Group then
		addItem("yes","This game is a <b>group</b> game.","green")
		table.insert(resultscode, 0)
	else
		addItem("no","An error occured while checking this game's creator type.","red")
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)

	-- turnstile license check (printersofa + prpldev)
	status.Text = "Checking for license (Turnstiles)..."
	if game.CreatorType == Enum.CreatorType.User and not unpublished then
		if marketplaceservice:UserOwnsGamePassAsync(game.CreatorId, 12447387) then
			addItem("yes","The creator of this game owns the Turnstile gamepass.","green")
			table.insert(resultscode, 1)
		else
			addItem("warn","The creator of this game does not own the Turnstile gamepass.","yellow")
			table.insert(resultscode, 0)
		end
	elseif game.CreatorType == Enum.CreatorType.Group then
		local groupinfo = groupservice:GetGroupInfoAsync(game.CreatorId)
		if marketplaceservice:UserOwnsGamePassAsync(groupinfo.Owner.Id, 12447387) then
			addItem("yes","The group owner owns the Turnstile gamepass.","green")
			table.insert(resultscode, 1)
		else
			addItem("warn","The group owner does not own the Turnstile gamepass.","yellow")
			table.insert(resultscode, 0)
		end
	else
		if game.CreatorId ~= 998796 and game.CreatorId ~= 0 and game.CreatorId ~= nil then
			addItem("no","An error occured while checking this game's creator type.","red")
		else
			addItem("warn","License checks cannot be performed on unpublished games.","yellow")
		end
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)

	-- autopro license check (printersofa + prpldev)
	status.Text = "Checking for license (AutoPro)..."
	if game.CreatorType == Enum.CreatorType.User and not unpublished then
		if marketplaceservice:UserOwnsGamePassAsync(game.CreatorId, 17531859) then
			addItem("yes","The creator of this game owns the AutoPro gamepass.","green")
			table.insert(resultscode, 1)
		else
			addItem("warn","The creator of this game does not own the AutoPro gamepass.","yellow")
			table.insert(resultscode, 0)
		end
	elseif game.CreatorType == Enum.CreatorType.Group then
		local groupinfo = groupservice:GetGroupInfoAsync(game.CreatorId)
		if marketplaceservice:UserOwnsGamePassAsync(groupinfo.Owner.Id, 17531859) then
			addItem("yes","The group owner owns the AutoPro gamepass.","green")
			table.insert(resultscode, 1)
		else
			addItem("warn","The group owner does not own the AutoPro gamepass.","yellow")
			table.insert(resultscode, 0)
		end
	else
		if game.CreatorId ~= 998796 and game.CreatorId ~= 0 and game.CreatorId ~= nil then
			addItem("no","An error occured while checking this game's creator type.","red")
		else
			addItem("warn","License checks cannot be performed on unpublished games.","yellow")
		end
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)

	-- http requests check (printersofa)
	status.Text = "Checking HTTP Requests..."
	if game.HttpService.HttpEnabled == true then
		addItem("httpon","HTTP Requests are enabled.","green")
		table.insert(resultscode, 1)
	else
		addItem("httpoff","HTTP Requests are not enabled.","red")
		ButtonState = {"HTTP",nil}
		gui.Background.Window.SelectionButtons.Approve.Visible = true
		gui.Background.Window.SelectionButtons.Deny.Visible = true
		gui.Background.Window.SupportCode.Title.Text = "Give this tool access to change <b>HTTPServices</b>?"
		gui.Background.Window.SupportCode.Title.Visible = true
		while gui.Background.Window.SelectionButtons.Approve.Visible == true do wait() end
		gui.Background.Window.SupportCode.Title.Text = ""
		gui.Background.Window.SupportCode.Title.Visible = false
		if ButtonState[2] == true then
			game.HttpService.HttpEnabled = true
			addItem("info","Whitehill Diagnostics has automatically enabled HTTP Requests.","blue")
			addItem("httpon","HTTP Requests are now enabled.","green")
			table.insert(resultscode, 1)
		elseif ButtonState[2] == false then
			table.insert(resultscode, 0)
		end
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)

	-- axon licensing query (prpldev)
	status.Text = "Checking Axon Licenses..."
	local heldLicenses = {}
	local ownerid = 0
	if game.CreatorType == Enum.CreatorType.User then
		ownerid = game.CreatorId
	elseif game.CreatorType == Enum.CreatorType.Group then
		local groupinfo = groupservice:GetGroupInfoAsync(game.CreatorId)
		ownerid = groupinfo.Owner.Id
	end
	if game.CreatorId ~= 998796 and game.CreatorId ~= 0 and game.CreatorId ~= nil then else
		addItem("warn","License checks cannot be performed on unpublished games.","yellow")
	end
	local apiUrl = "https://axon.whitehill.club/api/licences/user/"..ownerid
	if not unpublished then
		local success, response = pcall(http.GetAsync, http, apiUrl)
		if success then
			local jsonResponse = http:JSONDecode(response)
			if jsonResponse.success then
				for _, entry in ipairs(jsonResponse.data) do
					local productName = entry.product.name
					table.insert(heldLicenses,tostring(productName))
				end
				addItem("yes","Axon license check successful.","green")
			else
				table.insert(resultscode,0)
			end
		else
			addItem("no","Axon license check failed.","red")
		end
	end

	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)	

	-- non owned but installed products check/licensing (prpldev)
	status.Text = "Checking licenses (this could take several minutes)..."
	if workspace:FindFirstChild("JSM | Retail POS System NO") then
		if not table.find(heldLicenses,"JSM RetailPOS Mainbanks") then
			addItem("warn","Game has the <b>Mainbanks</b> system installed but game owner does not hold a license.","yellow")
			table.insert(resultscode,1)
		else
			table.insert(resultscode,0)
		end
	else
		table.insert(resultscode,0)
	end
	if game.ServerStorage:FindFirstChild("JSM | ATM Tools") then
		if not table.find(heldLicenses,"JSM ATM") then
			addItem("warn","Game has the <b>JSM ATM</b> system installed but game owner does not hold a license.","yellow")
			table.insert(resultscode,1)
		else
			table.insert(resultscode,0)
		end
	else
		table.insert(resultscode,0)
	end
	if workspace:FindFirstChild("JSM | CafePOS-Lite Terminal") then
		if not table.find(heldLicenses,"JSM CafePOS Lite") then
			addItem("warn","Game has the <b>CafePOS Lite</b> system installed but game owner does not hold a license.","yellow")
			table.insert(resultscode,1)
		else
			table.insert(resultscode,0)
		end
	else
		table.insert(resultscode,0)
	end
	if workspace:FindFirstChild("JSM | SelfCheckout V3") then
		if not table.find(heldLicenses,"JSM Self Checkout") then
			addItem("warn","Game has the <b>SCO V3</b> system installed but game owner does not hold a license.","yellow")
			table.insert(resultscode,1)
		else
			table.insert(resultscode,0)
		end
	else
		table.insert(resultscode,0)
	end
	if workspace:FindFirstChild("JSM | EAS SensorMatic") then
		if not table.find(heldLicenses,"JSM EAS") then
			addItem("warn","Game has the <b>JSM EAS</b> system installed but game owner does not hold a license.","yellow")
			table.insert(resultscode,1)
		else
			table.insert(resultscode,0)
		end
	else
		table.insert(resultscode,0)
	end

	task.wait(2)
	status.Text = status.Text.." Done"
	task.wait(1)


	-- product bug/setup error check (prpldev)
	status.Text = "Checking products (this could take several minutes)..."
	if workspace:FindFirstChild("JSM | SelfCheckout V3") then
		local scoMain = workspace:FindFirstChild("JSM | SelfCheckout V3")
		if scoMain:FindFirstChild("Terminals") then
			local count = 0
			for i,v in pairs(scoMain.Terminals:GetChildren()) do
				count += 1
			end
			if count >= 50 then
				addItem("warn","The <b>SCO V3</b> install has over 50 terminals.","yellow")
				table.insert(resultscode,1)
			else
				table.insert(resultscode,0)
			end
		end
	else
		table.insert(resultscode,0)
	end

	task.wait(2)
	status.Text = status.Text.." Done"
	task.wait(1)

	-- whitehill door weld check (printersofa)
	status.Text = "Checking for welds (this could take several minutes)..."
	local wdoors = {}
	for index, value in pairs(workspace:GetDescendants()) do
		if string.sub(value.Name, 1, 6) == "DWProx" and value:FindFirstChild("Settings") then
			table.insert(wdoors, value)
		end
	end
	for pos, door in pairs(wdoors) do
		for index, value in pairs(door:GetDescendants()) do
			if value:IsA("BasePart") and (value.Name == "Door" or value.Name == "KickPlate" or value.Parent.Name == "DOORL" or value.Parent.Name == "DOORR") then
				for i, pweld in pairs(door:GetDescendants()) do
					if pweld:IsA("Weld") then
						wrestricted = true
					end
					if wrestricted then
						break
					end
				end
			end
			if wrestricted then
				break
			end
		end
		if wrestricted then
			break
		end
	end
	if wrestricted then
		addItem("warn","One or more of your doors is welded to other parts. Check that Join Surfaces is disabled and try reinserting the doors.","yellow")
		table.insert(resultscode, 1)
	else
		addItem("yes","No weld issues were found.","green")
		table.insert(resultscode, 0)
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(1)	

	-- whitehill door collision check (printersofa)
	status.Text = "Checking for collisions (this could take several minutes)..."
	local doors = {}
	for index, value in pairs(workspace:GetDescendants()) do
		if string.sub(value.Name, 1, 6) == "DWProx" and value:FindFirstChild("Settings") then
			table.insert(doors, value)
		end
	end
	for pos, door in pairs(doors) do
		for index, value in pairs(door:GetDescendants()) do
			if value:IsA("BasePart") and (value.Name == "Door" or value.Name == "KickPlate" or value.Parent.Name == "DOORL" or value.Parent.Name == "DOORR") then
				for i, touching in pairs(value:GetTouchingParts()) do
					if not touching:IsDescendantOf(door) then
						restricted = true
					end
					if restricted then
						break
					end
				end
			end
			if restricted then
				break
			end
		end
		if restricted then
			break
		end
	end
	if restricted then
		addItem("warn","One or more doors may be colliding with other parts in your game","yellow")
		table.insert(resultscode, 1)
	else
		addItem("yes","No collision issues were found.","green")
		table.insert(resultscode, 0)
	end
	task.wait(2)
	status.Text = status.Text .. " Done"
	task.wait(4)

	-- process results into a readable number by the bot and the user (todo)
	local rnum = math.random(100,999)

	local resultsstring = ""
	for i,v in pairs(resultscode) do
		resultsstring = resultsstring..tostring(v)
	end

	-- display code + title
	gui.Background.Window.SupportCode.Code.Text = resultsstring
	gui.Background.Window.SupportCode.Title.Visible = true
	gui.Background.Window.SupportCode.Code.Visible = true

	status.Text = "Diagnostic Complete"

	addItem("info","The diagnostics check is now complete and will close in 10 seconds.","blue")

	-- reset stuff for next usage on game incase its the same session
	task.wait(10)
	for i,v in pairs(gui.Background.Window.HolderFrame.ScrollingFrame:GetChildren()) do
		if v.Name ~= "Template" and v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	gui.Background.Window.SupportCode.Title.Visible = false
	gui.Background.Window.SupportCode.Code.Visible = false
	gui.Parent = script
	table.clear(heldLicenses)
end

gui.Background.Window.SelectionButtons.Approve.Activated:Connect(function()
	if ButtonState[1] ~= nil then
		ButtonState[2] = true
		gui.Background.Window.SelectionButtons.Approve.Visible = false
		gui.Background.Window.SelectionButtons.Deny.Visible = false
	end
end)

gui.Background.Window.SelectionButtons.Deny.Activated:Connect(function()
	if ButtonState[1] ~= nil then
		ButtonState[2] = false
		gui.Background.Window.SelectionButtons.Approve.Visible = false
		gui.Background.Window.SelectionButtons.Deny.Visible = false
	end
end)

return diag
