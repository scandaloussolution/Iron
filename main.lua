local DefaultTheme = {
	Scheme = Color3.fromRGB(110, 153, 202);
	Background = Color3.fromRGB(31, 32, 40);
	Topbar = Color3.fromRGB(22, 23, 30);
	Content = Color3.fromRGB(41, 41, 50);
	ScrollbarTrack = Color3.fromRGB(33, 34, 40);
	Text = Color3.fromRGB(255, 255, 255);
	Item = Color3.fromRGB(51, 51, 60);
}
local Theme = {}
for t,c in pairs(DefaultTheme) do
	Theme[t] = c
end 


local kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/scandaloussolution/Iron/main/Kavo.lua"))()--require(script:WaitForChild("Kavo")) 
local esp do 
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
	local game_

	if game_id >0 then
		game_ = special_ids[game_id] or game:GetService("MarketplaceService"):GetProductInfo(game_id).Name
	else 
		game_ = "Untitled"
	end
	local enabled = {ESP = false, ["Rainbow tracers"] = false}
	local step = game:GetService("RunService").RenderStepped
	esp = function(val, rainbow, team)
		enabled["ESP Show team"] = team
		enabled["Rainbow tracers"] = rainbow
		enabled.ESP = val
		if not val then
			for i, v in pairs(debris.ESP) do 
				v[1].Visible = false
				v[2].Visible = false
				v[3].Visible = false
			end
		else 
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
											quad.Color = players[i].Team == plr.Team and (_G.esp_team_col or Color3.new(1, 0, 0)) or (_G.esp_col or Color3.new(0, 1, 0))
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
												local rainbow = Color3.fromHSV((tick()%4)/4, 1, 1)
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

								if (Vector2.new(pos.X, pos.Y) - p).Magnitude <= 300 and game:GetService("Players")[child.Text].TeamColor == plr.TeamColor and pos.Z > 0 then
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
								local ally, name = is_on_team(character)
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

											quad.Color = ally and (_G.esp_team_col or Color3.new(1, 0, 0)) or (_G.esp_col or Color3.new(0, 1, 0))
											line.To = Vector2.new(point.X, point.Y)
											line.Visible = visible
											quad.Visible = visible
											draw[3].Position = line.To
											draw[3].Visible = visible

											if enabled["Rainbow tracers"]then 
											local rainbow = Color3.fromHSV((tick()%4)/4, 1, 1)
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
		end
	end
end

local name do 
	local _, n = xpcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
	end, function()
		return "Untitled"
	end)
	name = n
end

local plr = game:GetService("Players").LocalPlayer
local char
if name:lower():find("phantom forces")then
	if workspace:FindFirstChild("Ignore")then
		if workspace.Ignore:FindFirstChild("RefPlayer")then
			char = workspace.Ignore.RefPlayer
			workspace.Ignore.ChildAdded:Connect(function(c)
				if c.Name == "RefPlayer"then
					char = c
				end
			end)
		end
	end
end

if not char then
	char = plr.Character
	plr.CharacterAdded:Connect(function(c)
		char = c
	end)
end

local lib = kavo:CreateLib("Iron - "..name)
lib:EnableUI(true)

local tabs = {
	["Cheats"] = {
		sections = {
			["ESP"] = {
				desc = "Allows you to see people behind walls and know exactly where they are.",
				data = nil,
				elements = {
					["NewToggle"] = {
						{
							args = {
								"Enabled"
							},
							func = function(new)
								local drawing = {}
								new.Changed:Connect(function(toggled)
									_G.esp = toggled
									esp(_G.esp, _G.rainbow_esp, _G.show_team)
								end)
							end,
						},
						{						
							args = {
								"Rainbow"
							},
							func = function(new)
								_G.rainbow_esp = false
								new.Changed:Connect(function()
									_G.rainbow_esp = not _G.rainbow_esp
									esp(_G.esp, _G.rainbow_esp, _G.show_team)
								end)
							end,
						},
						{
							args = {
								"Show team"
							},
							func = function(new)
								_G.show_team = false
								new.Changed:Connect(function()
									_G.show_team = not _G.show_team
									esp(_G.esp, _G.rainbow_esp, _G.show_team)
								end)
							end,
						}
					},
					["NewLabel"] = {
						{
							args = {
								"This is a Synapse X exclusive!",
								nil,
								{
									Icon = "rbxassetid://3192540038"
								}
							}
						}
					},
					["NewColorPicker"] = {
						{
							args = {
								"ESP Color",
								nil,
								Color3.new(1, 0, 0),
								function(col)
									_G.esp_col = col
								end,
							}
						},
						{
							args = {
								"ESP Team Color",
								nil,
								Color3.new(0, 1, 0),
								function(col)
									_G.esp_team_col = col
								end,
							}
						},
					}
				}
			},
			["Humanoid"] = {
				desc = "Modify your humanoid",
				data = nil,
				elements = {
					["NewSlider"] = {
						{
							args = {
								"WalkSpeed",
								0,
								100,
								function(val)
									local h = char:FindFirstChildOfClass("Humanoid")
									if h then
										h.WalkSpeed = val
									end
								end,
							}
						},
						{
							args = {
								"HipHeight",
								0,
								100,
								function(val)
									local h = char:FindFirstChildOfClass("Humanoid")
									if h then
										h.HipHeight = val
									end
								end,
							}
						}
					},	
				}
			}
		},
		data = {
			Icon = "rbxassetid://7120897383"
		}
	},
	["Other"] = {
		sections = {
			["Game"] = {
				desc = "Everything related to the game",
				data = nil,
				elements = {
					["NewButton"] = {
						{
							args = {
								"Rejoin",
								nil,
								function()
									game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
								end,
							}
						}
					}
				}
			}
		}
	},	
	["Credits"] = {
		sections = {
			["How its possible"] = {
				desc = "Thank you everyone!",
				data = nil,
				elements = {
					["NewLabel"] = {
						{
							args = {
								"EwDev: KavoPlus gui utility and inspiration",
							}
						},
						{
							args = {
								"ScandalousSolution: For creating this",
							}
						},
						{
							args = {
								"Roblox: For being the crappy platform it is",
							}
						},
						{
							args = {
								"Hotel: Trivago"
							}
						}
					},
				}
			}
		}
	},
}


local colors = lib:NewTab("Theme")
local section = colors:NewSection("Color", {Hidden = true})
local theme_pickers= {}

for name, col in pairs(Theme) do
	local picker = section:NewColorPicker(name, nil, col, function(col)
		Theme[name] = col 
		lib:UpdateThemeColor(name, col)
	end)
	theme_pickers[name] = picker
end

section:NewButton("Reset", "Reset all themes", function()
	for name, col in pairs(DefaultTheme) do 
		Theme[name] = col
		theme_pickers[name]:SetColor(col)
	end
end)

for tab_name, element in next, tabs do
	local tab = lib:NewTab(tab_name, element.data)
	for section_name, section in next, element.sections do 
		local new_section = tab:NewSection(section_name, section.desc, section.data)
		for property, elements in next, section.elements do 
			for _, values in pairs(elements) do
				local new = new_section[property](new_section, unpack(values.args))
				if values.func then
					values.func(new)
				end
			end
		end
	end
end

