local autoa1000 = nil
	autoa1000 = window_rooms:AddToggle({
		Name = "Auto A-1000",
		Value = false,
		Callback = function(val, oldval)
			if flags.noa90 == false then noa90btn:Set(true);oldnormalmessage("AUTO A-1000", "Enabled Harmless A90", 5) end

			if PathRunning == true then 
				PathRunning = false
				task.wait()
			end

			flags.autorooms = val
			if val then
				local goingToHide = false
				local HideCheck = game:GetService("RunService").RenderStepped:Connect(function()
					if flags.autorooms == true then
						game.Players.LocalPlayer.Character.HumanoidRootPart.CanCollide = false
						game.Players.LocalPlayer.Character.Collision.CanCollide = false
						game.Players.LocalPlayer.Character.Collision.Size = Vector3.new(8, game.Players.LocalPlayer.Character.Collision.Size.Y, 8)
						game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 21

						local Part = getWalkPart()
						local A60_A120 = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
						if A60_A120 then
							if Part then
								if isLocker(Part) then
									if A60_A120.Main.Position.Y > -4 then
										if plr:DistanceFromCharacter(Part.Door.Position) <= 9 then
											goingToHide = true
											if plr.Character.HumanoidRootPart.Anchored == false then
												fireproximityprompt(Part.HidePrompt)
											end
											--else if plr:DistanceFromCharacter(Part.Door.Position) <= 11.5 then plr.Character:PivotTo(Part.Door.CFrame) end
										end
									end
								end
							end
						else
							if plr.Character.HumanoidRootPart.Anchored == true then 
								repeat task.wait() until not (workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120"))
								unhidefunc();goingToHide = false 
							end
						end

						if game.Players.LocalPlayer.Character.Humanoid.Health < 1 then autoa1000:Set(false) end
					else
						game.Players.LocalPlayer.Character.HumanoidRootPart.CanCollide = true
						game.Players.LocalPlayer.Character.Collision.CanCollide = true
						game.Players.LocalPlayer.Character.Collision.Size = Vector3.new(4, game.Players.LocalPlayer.Character.Collision.Size.Y, 4)
					end

					if flags.autorooms_blockcontrols == false then
						plr.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
					end
				end)

				while flags.autorooms do
					task.wait();if flags.noa90 == false then noa90btn:Set(true);oldnormalmessage("AUTO A-1000", "Enabled Harmless A90", 5) end
					--repeat task.wait() until goingToHide == false and plr.Character.HumanoidRootPart.Anchored == false

					local Part = getWalkPart()
					if goingToHide == false or not isLocker(Part) then
						unhidefunc()
					end

					local Highlight = Instance.new("Highlight", Pathfinding_Highlights)
					Highlight.FillColor = Color3.fromRGB(85, 255, 0)
					Highlight.Adornee = Part.Door

					task.spawn(function()
						if flags.autorooms_debug == true then
							if isLocker(Part) then
								oldnormalmessage("AUTO A-1000 [DEBUG]", "Trying to go to "..Part.Name..".", 5)
							else
								oldnormalmessage("AUTO A-1000 [DEBUG]", "Trying to go to next door ("..(game:GetService("ReplicatedStorage").GameData.LatestRoom.Value + 1)..").", 5)
							end
						end
					end)

					local Path = PathfindingService:CreatePath({ 
						WaypointSpacing = 1, 
						AgentRadius = 0.8,
						AgentCanJump = false 
					})

					local HRP = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local Humanoid = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
					if not HRP then HRP = game.Players.LocalPlayer.Character.PrimaryPart end

					local Success, ErrorMessage = pcall(function()
						Path:ComputeAsync(HRP.Position - Vector3.new(0, 3, 0), Part.Door.Position)
					end)

					if Success and Path.Status == Enum.PathStatus.Success then 
						PathRunning = true
						local waypoints = Path:GetWaypoints()
						VisualizerFolder:ClearAllChildren()
						PathModule.visualize(waypoints)

						for i, v in pairs(waypoints) do
							if HRP.Anchored == false then
								if PathRunning == false then
									pcall(function() Highlight.OutlineTransparency = 1 end);pcall(function() Highlight.FillTransparency = 1 end);pcall(function() Highlight.Adornee = nil end)
									Pathfinding_Highlights:ClearAllChildren()
									VisualizerFolder:ClearAllChildren()
									break
								else
									Humanoid:MoveTo(v.Position)
									Humanoid.MoveToFinished:Wait()
								end
							end
						end

						if isLocker(Part) then
							repeat task.wait() until HRP.Anchored == false or plr.Character:GetAttribute("Hiding") == false or PathRunning == false
						end
						PathRunning = false
					end

					pcall(function() Highlight.OutlineTransparency = 1 end);pcall(function() Highlight.FillTransparency = 1 end);pcall(function() Highlight.Adornee = nil end)
					Pathfinding_Highlights:ClearAllChildren()
					VisualizerFolder:ClearAllChildren()
				end

				task.spawn(function()
					repeat task.wait() until flags.autorooms == false and goingToHide == false
					HideCheck:Disconnect()
				end)
			else
				plr.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
			end
		end
	})
