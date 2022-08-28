local Player = game.Players.LocalPlayer
local Character = Player.Character
local PlayerGui = Player.PlayerGui
local AxleAnimator = PlayerGui.AxleAnimator
local SpawnLocations = game.ReplicatedStorage.SpawnLocations
local CurrentLevel = PlayerGui.CurrentLevel
local AxleSound = game:GetService("SoundService").Voice.axle
local SubtitleModule = require(PlayerGui.Subtitles.SubtitleModule)
local AESN = 0
local CameraShaker = require(game.ReplicatedStorage.CameraShaker)
local Camera = workspace.CurrentCamera

local shakeCamera = function(shakeCf)
	Camera.CFrame = Camera.CFrame * shakeCf
end
camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, shakeCamera)
camShake:Start()

local API;API =  {
	DynamicMusic = PlayerGui.DynamicMusic,
	Camera = workspace.CurrentCamera,
	Shaker = camShake,
	ShakerPresets = CameraShaker.Presets,
	giveGun = function()
		PlayerGui.hasPortalGun.Value = true
	end,
	setAxleKeyFramePhase = function(Phase)
		game.Players.LocalPlayer.PlayerGui.axleKeyframePhase.Value = Phase
	end,
	upgradeGun = function()
		require(game:GetService("ReplicatedStorage").DebugCommand["portalgun_upgrade"]).runCommand()
	end,
	removeGun = function()
		PlayerGui.hasPortalGun.Value = false
	end,
	changeLevel = function(Level)
		require(game:GetService("ReplicatedStorage").DebugCommand.setlevel).runCommand({Level})
	end,
	waitForTouchTrigger = function(Object)
		local Found = false
		local Index = #_G.Connections + 1
		_G.Connections[Index] = Object.Touched:Connect(function(p190)
			if p190 == Character.LevelCollider then
				Found = true
				_G.Connections[Index]:Disconnect()
			end
		end)
		while task.wait() do
			if Found then
				break
			end	
		end
	end,
	getDistance = function(p140, p141)
		return (p140 - p141).Magnitude
	end,
	waitAxleArrived = function()
		while task.wait() do
			if (API.getDistance(AxleAnimator.wantedPosition.Value, AxleAnimator.axle.Value.Base.Position) < 0.01) then
				break
			end
			if not workspace.Level then
				break
			end	
		end
	end,
	setAxleWantedPosition = function(X, Y, Z)
		AxleAnimator.wantedPosition.Value = CFrame.new(SpawnLocations[CurrentLevel.Value].Position):PointToObjectSpace(Vector3.new(X, Y, Z))
	end,
	setAxleBaseCFrame = function(CF)
		AxleAnimator.axle.Value.Base.CFrame = CFrame.new(SpawnLocations[CurrentLevel.Value].Position):ToObjectSpace(CF)
		AxleAnimator.axle.Value.Parent = workspace
	end,
	getLevelCFrame = function(p195)
		return CFrame.new(SpawnLocations[CurrentLevel.Value].CFrame:PointToObjectSpace(p195.Position))
	end,
	setAxleExpression = function(p196)
		AxleAnimator.SetExpression:Fire(p196)
	end,
	axleExpressionSequence = function(Sequence) --i cnat really parse what this does
		coroutine.resume((coroutine.create(function()
			local v49 = AESN + 1
			AESN = v49
			local AESN = 0
			local v51, v52, v53 = ipairs(Sequence)
			while true do
				local v54, v55 = v51(v52, v53)
				if v54 then

				else
					break
				end
				v53 = v54
				local v56 = v55[1]
				if 0 < v56 - AESN then
					task.wait(v56 - AESN)
				end
				if AESN ~= v49 then
					return
				end
				API.setAxleExpression(v55[2])
				AESN = v56
			end
		end)))
	end,
	applyTranslationPack = function(Message) -- and this
		if PlayerGui.TranslationPack.Value then
			local v567, v568, v569 = pairs((require(PlayerGui.TranslationPack.Value)))
			while true do
				local v570, v571 = v567(v568, v569)
				if not v570 then
					break
				end
				v569 = v570
				if Message == v570 then
					return v571
				end	
			end
		end
		return Message
	end,
	announcerVoiceLine = function(Sound, Text)
		if CurrentLevel.Value == "menu" then
			return
		end
		Sound:Play()
		SubtitleModule.AddSubtitle("Announcer: " .. API.applyTranslationPack(Text), 5, "announcer")
	end,
	axleVoiceLine = function(SoundID, Volume, Text, doWait, Sequence)
		if CurrentLevel.Value == "menu" then
			return
		end
		AxleSound.SoundId = "rbxassetid://" .. SoundID
		AxleSound.Volume = Volume * 1.25
		if not AxleSound.IsLoaded then
			while task.wait() do
				if AxleSound.IsLoaded then
					break
				end
			end
		end
		if Sequence ~= nil then
			API.axleExpressionSequence(Sequence)
		end
		AxleSound:Play()
		if Text then
			if Text ~= "" then
				SubtitleModule.AddSubtitle("Axle: " .. API.applyTranslationPack(Text), AxleSound.TimeLength + 3, "axle")
			end
		end
		task.wait(AxleSound.TimeLength)
	end
}

return API
