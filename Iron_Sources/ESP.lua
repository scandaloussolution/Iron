-- this was ripped from another one of my projects
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local debris = {ESP = {}}
local player_left
local game_id = game.PlaceId
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
plr.CharacterAdded:Connect(function(c)
	char = c
end)
local special_ids = {
	[292439477] = "Phantom Forces"
}

local game_ = special_ids[game_id] or game:GetService("MarketplaceService"):GetProductInfo(game_id).Name
local enabled = {ESP = false, ["Rainbow tracers"] = false}
local step = game:GetService("RunService").RenderStepped
if game_ ~= "Phantom Forces" then
	if player_left then
		player_left:Disconnect()
	end
	player_left = game:GetService("Players").PlayerRemoving:Connect(function(p)
		local quad = debris.ESP[p]
		if quad then
			quad[1]:Remove()
			quad[2]:Remove()
			quad[3]:Remove()

			debris.ESP[p] = nil
		end
	end)
	while enabled.ESP do 
		step:Wait()
		local first_person = uis.MouseBehavior == Enum.MouseBehavior.LockCenter
		local players = game:GetService("Players"):GetPlayers()
		local teams = game:GetService("Teams"):GetTeams()

		for i = 1, #players do 
			if players[i] ~= plr then
				if not debris.ESP[players[i]] then
					local quad = Drawing.new("Quad")
					quad.Filled = false
					quad.Thickness = 2
					quad.ZIndex = 5
					quad.Color = Color3.new(1, 0, 0)
					local line = Drawing.new("Line")
					line.Thickness = 2
					line.ZIndex = 5
					line.Color = Color3.new(1, 0, 0)
					local dot = Drawing.new("Circle")
					dot.Filled = true
					dot.Radius = 3
					dot.NumSides = 20

					debris.ESP[players[i]] = {
						quad, 
						line,
						dot
					}
				end
				local draw = debris.ESP[players[i]]
				if draw then
					local character = players[i].Character
					if character then
						local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") 
						if root then
							local quad = draw[1]
							local line = draw[2]
							local _, bound = character:GetBoundingBox()
							local centre = root.CFrame
							local point  = cam:WorldToViewportPoint((centre * CFrame.new(bound.X/2, bound.Y/2, 0)).Position)
							quad.PointA = Vector2.new(point.X, point.Y)

							point = cam:WorldToViewportPoint((centre * CFrame.new(-bound.X/2, bound.Y/2, 0)).Position)
							quad.PointB = Vector2.new(point.X, point.Y) 

							point = cam:WorldToViewportPoint((centre * CFrame.new(-bound.X/2, -bound.Y/2, 0)).Position)
							quad.PointC = Vector2.new(point.X, point.Y) 

							point = cam:WorldToViewportPoint((centre * CFrame.new(bound.X/2, -bound.Y/2, 0)).Position)
							quad.PointD = Vector2.new(point.X, point.Y) 

							if #teams > 0 then
								quad.Color = players[i].Team == plr.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
							end
							if first_person then
								line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
							else 
								local r = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
								if r then	
									point = cam:WorldToViewportPoint(r.Position)
									line.From = Vector2.new(point.X, point.Y)
								else 
									line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
								end
							end
							local head = character:FindFirstChild("Head") or root
							point = cam:WorldToViewportPoint(head.Position)
							local visible = point.Z >= 0

							if not enabled["ESP Show team"] and players[i] == plr.Team then
								visible = false
							end

							line.To = Vector2.new(point.X, point.Y)
							line.Visible = visible
							quad.Visible = visible
							draw[3].Position = line.To
							draw[3].Visible = visible

							if enabled["Rainbow tracers"]then 
								local rainbow = Color3.fromHSV((tick()%2)/2, 1, 1)
								quad.Color = rainbow
							end
							line.Color = quad.Color
							draw[3].Color = line.Color									
						end
					end
				end
			end
		end
	end
else
	if player_left then
		player_left:Disconnect()
	end
	player_left = workspace:WaitForChild("Players").DescendantRemoving:Connect(function(p)
		local quad = debris.ESP[p]
		if quad then
			quad[1]:Remove()
			quad[2]:Remove()
			quad[3]:Remove()

			debris.ESP[p] = nil
		end
	end)
	local tags = plr.PlayerGui.NonScaled.NameTag
	local children = tags:GetChildren()
	local function is_on_team(char)
		if char:FindFirstChild("Head")then
			local pos = workspace.CurrentCamera:WorldToViewportPoint(char.Head.Position)
			children = tags:GetChildren()

			for i = 1, #children do 
				local child = children[i]
				local p = child.Dot.AbsolutePosition

				if (Vector2.new(pos.X, pos.Y) - p).Magnitude <= 130 and game:GetService("Players")[child.Text].TeamColor == plr.TeamColor then
					return true, child.Text
				end
			end
		end
	end
	while enabled.ESP do 
		step:Wait()
		local first_person = true
		local players = workspace:WaitForChild("Players"):GetDescendants()

		for i = 1, #players do 
			if players[i].Name == "Player"then
				local character = players[i]
				local root = character:FindFirstChild("Torso") 
				local is_self = false
				local ally, name = nil, nil--is_on_team(character)
				if root then
					local dist = workspace.CurrentCamera.CFrame.Position - root.CFrame.Position
					is_self = dist.Magnitude < 3
				end
				if (not debris.ESP[players[i]]) and (not ally) and (not is_self)  then
					local quad = Drawing.new("Quad")
					quad.Filled = false
					quad.Thickness = 2
					quad.ZIndex = 5
					quad.Color = Color3.new(1, 0, 0)
					local line = Drawing.new("Line")
					line.Thickness = 2
					line.ZIndex = 5
					line.Color = Color3.new(1, 0, 0)
					local dot = Drawing.new("Circle")
					dot.Filled = true
					dot.Radius = 3
					dot.NumSides = 20

					debris.ESP[players[i]] = {
						quad, 
						line,
						dot
					}

				end
				local draw = debris.ESP[players[i]]
				if draw then
					if character then
						if root then
							local quad = draw[1]
							local line = draw[2]
							local _, bound = character:GetBoundingBox()
							local centre = root.CFrame
							local point  = cam:WorldToViewportPoint((centre * CFrame.new(bound.X/2, bound.Y/2, 0)).Position)
							quad.PointA = Vector2.new(point.X, point.Y)

							point = cam:WorldToViewportPoint((centre * CFrame.new(-bound.X/2, bound.Y/2, 0)).Position)
							quad.PointB = Vector2.new(point.X, point.Y) 

							point = cam:WorldToViewportPoint((centre * CFrame.new(-bound.X/2, -bound.Y/2, 0)).Position)
							quad.PointC = Vector2.new(point.X, point.Y) 

							point = cam:WorldToViewportPoint((centre * CFrame.new(bound.X/2, -bound.Y/2, 0)).Position)
							quad.PointD = Vector2.new(point.X, point.Y) 

							line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
							local head = character:FindFirstChild("Head") or root
							point = cam:WorldToViewportPoint(head.Position)
							local visible = point.Z >= 0

							if not enabled["ESP Show team"] and players[i] == plr.Team then
								visible = false
							end

							quad.Color = ally and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
							line.To = Vector2.new(point.X, point.Y)
							line.Visible = visible
							quad.Visible = visible
							draw[3].Position = line.To
							draw[3].Visible = visible

							if enabled["Rainbow tracers"]then 
								local rainbow = Color3.fromHSV((tick()%2)/2, 1, 1)
								quad.Color = rainbow
							end
							line.Color = quad.Color
							draw[3].Color = line.Color

						end
					end
				end
			end
		end

	end
end
for i, v in pairs(debris.ESP) do 
	v[1].Visible = false
	v[2].Visible = false
	v[3].Visible = false
end

return function(val, rainbow, team)
	enabled["ESP Show team"] = team
	enabled["Rainbow tracers"] = rainbow
	enabled.ESP = val
end
