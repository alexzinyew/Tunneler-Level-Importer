if _G.Connections == nil then
	_G.Connections = {}
end
local Map = game:GetObjects("rbxassetid://".._G.map)[1]
local loadCustomLevelScriptedEvents

if Map:IsA("Folder") then
	local New = Instance.new("Model",game.ReplicatedStorage.Levels)
	for _,Obj in pairs(Map:GetChildren()) do
		Obj.Parent = New
	end
	New.Name = Map.Name
	Map:Destroy()
	Map = New
end
Map.Name = string.lower(Map.Name)

if game.ReplicatedStorage.Levels:FindFirstChild(Map.Name) then
	game.ReplicatedStorage.Levels[Map.Name]:Destroy()
end


if not game.ReplicatedStorage:FindFirstChild("loadCustomLevelScriptedEvents") then
	loadCustomLevelScriptedEvents = Instance.new("BindableEvent",game.ReplicatedStorage)
	loadCustomLevelScriptedEvents.Name = "loadCustomLevelScriptedEvents"
else
	loadCustomLevelScriptedEvents = game.ReplicatedStorage:FindFirstChild("loadCustomLevelScriptedEvents")
end

local Events = Map:WaitForChild("Events")

for _,Translation in pairs(Events.Translations:GetChildren()) do
	local Pack = require(game.ReplicatedStorage.Translations[Translation.Name])
	local Translations = loadstring(Translation.Source)()
	for i,v in pairs(Translations) do
		Pack[i] = v
	end
end

Map.Parent = game.ReplicatedStorage.Levels
Map.SpawnLocation.Name = Map.Name
if game.ReplicatedStorage.SpawnLocations:FindFirstChild(Map.Name) then
	game.ReplicatedStorage.SpawnLocations:FindFirstChild(Map.Name):Destroy()
end
Map[Map.Name].Parent = game.ReplicatedStorage.SpawnLocations

loadCustomLevelScriptedEvents.Event:Connect(function(...)
	if Events then
		loadstring(Events.Source)()(...)
	end
end)

for _,Function in pairs(getgc()) do
	if type(Function) == "function" and getinfo(Function).name then
		if getinfo(Function).name == "loadLevelScriptedEvents" then
			local OldFunc
			OldFunc = hookfunction(Function, function(MapName,Static)
				if MapName == Map.Name and Map:FindFirstChild("Events") then
					loadCustomLevelScriptedEvents:Fire(workspace.Level.Static,workspace.Props,workspace.LevelIgnoreRaycast, Events, workspace.LevelTriggers)
				else
					for i,v in pairs(_G.Connections) do
						v:Disconnect()
					end
				end
				return OldFunc(MapName,Static)
			end)
		end
	end
end
