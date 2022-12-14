if _G.Connections == nil then
	_G.Connections = {}
end
local assetType = type(_G.map)
local Map = game:GetObjects(assetType == "number" and _G.map or _G.userIsKRNL and getcustomasset(_G.map) or getsynasset(_G.map))[1]

Map.Name = string.lower(Map.Name)

if game.ReplicatedStorage.Levels:FindFirstChild(Map.Name) then
	game.ReplicatedStorage.Levels[Map.Name]:Destroy()
end

Map.Parent = game.ReplicatedStorage.Levels

for _,Translation in pairs(Map.Translations:GetChildren()) do
	local Pack = require(game.ReplicatedStorage.Translations[Translation.Name])
	local Translations = loadstring(Translation.Source)()
	for i,v in pairs(Translations) do
		Pack[i] = v
	end
end
