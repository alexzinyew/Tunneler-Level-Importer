if not _G.createdBindables then
	_G.createdBindables = true
	_G.loadBindable = Instance.new("BindableEvent",game.ReplicatedStorage)
	_G.unloadBindable = Instance.new("BindableEvent",game.ReplicatedStorage)
	
	_G.loadBindable.Name = "LoadEvent"
	_G.unloadBindable.Name = "UnloadEvent"
	
	_G.loadBindable.Event:Connect(function(Events,...)
		loadstring(Events.Source)()(...)
	end)
	
	_G.unloadBindable.Event:Connect(function(Events,...)
		loadstring(Events.Source)()(...)
	end)
	
end

_G.importedMaps = {}

if not _G.loadHook then
	_G.loadHook = true
	local LastMap
	local Function
	for i,v in pairs(getgc()) do
		if getinfo(v) then
			if getinfo(v).name == "loadLevelScriptedEvents" then
				Function = v
			end
		end
	end
	
	if Function then
		local Old
		Old = hookfunction(Function, function(MapName, Static)
			local Map
			if table.find(_G.importedMaps,MapName) then
				Map = _G.importedMaps[MapName]
				_G.loadBindable:Fire(Map.Events, workspace.Level.Static, workspace.Props, workspace.LevelIgnoreRaycast, Map.Events, workspace.LevelTriggers)
				LastMap = MapName
			else
				Map = game.ReplicatedStorage.Levels[MapName]
				if LastMap == MapName then
					_G.unloadBindable:Fire(Map.UnloadEvents, workspace.Level.Static, workspace.Props, workspace.LevelIgnoreRaycast, Map.UnloadEvents, workspace.LevelTriggers)
				end
				LastMap = Map.Name
			end
			return Old(MapName,Static)
		end)
	end
	
end

return function(MapId,isKrnl)
	local Map
	if type(MapId) == "string" then
		if isKrnl then
			Map = game:GetObjects(getcustomasset(MapId))
		else
			Map = game:GetObjects(getsynasset(MapId))
		end
	else
		Map = game:GetObjects(MapId)
	end 
	
	if Map then
		Map.Name = string.lower(Map.Name)
		
		if table.find(_G.importedMaps,Map.Name) then
			_G.importedMaps[Map.Name]:Destroy()
			_G.importedMaps[Map.Name] = nil
		end
		
		Map.Parent = game.ReplicatedStorage.Levels
		local SpawnLocation = Map.SpawnLocation
		SpawnLocation.Parent = game.ReplicatedStorage.Levels
		SpawnLocation.Name = Map.Name
		
		_G.importedMaps[Map.Name] = Map
		
		
	else
		Map:Destroy()
		return
	end
	
end
