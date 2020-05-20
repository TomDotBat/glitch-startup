
gfStartingUp = true
local skipIntro = CreateClientConVar("gf_introskip", "0", true, true, "Should the server intro be auto-skipped?", 0, 1)

local stage = 1
local sequences = include("cl_sequences.lua")

local origins = {}
--Downtown Tits
origins[1] = {pos = Vector(-1365.730591, -758.009277, 364.608917), ang = Angle(28.730629, -129.638443, 0.000000)}
origins[2] = {pos = Vector(2440.674561, -605.533203, 86.830132), ang = Angle(7.139653, -45.626160, 0.000000)}
origins[3] = {pos = Vector(-2963.744385, -4498.527344, 111.685303), ang = Angle(6.881521, -42.615189, 0.000000)}
origins[4] = {pos = Vector(2134.380615, 526.385559, 140.560089), ang = Angle(17.117889, 35.749134, 0.000000)}

--Evocity
--origins[1] = {pos = Vector(-5595.119629, -7490.044922, 236.963928), ang = Angle(-7.139664, -127.792236, 0.000000)}
--origins[2] = {pos = Vector(-8923.150391, -11022.519531, 361.743866), ang = Angle(0.000008, 140.080322, 0.000000)}
--origins[3] = {pos = Vector(-5532.839844, 13687.004883, 669.056213), ang = Angle(10.666464, -146.452408, 0.0000000)}
--origins[4] = {pos = Vector(1572.101807, 4611.073242, 726.608826), ang = Angle(13.849203, 59.485683, 0.000000)}

local selectedOrigin = math.random(1, #origins)

local songUrls = {}
songUrls[1] = "http://content.glitchfire.com/darkrp/sound/home-beforethenight.mp3"
songUrls[2] = "http://content.glitchfire.com/darkrp/sound/justice-genesis.mp3"
songUrls[3] = "http://content.glitchfire.com/darkrp/sound/madeon-lalune.mp3"

if IsValid(prestartpanel) then
	prestartpanel:Remove()
end
prestartpanel = nil

soundStream = false
local endingMusic = false

local function endMenu()
	stage = 1
	endingMusic = true
	prestartpanel:Remove()
	hook.Remove("CalcView", "GFStartCalcView")
	hook.Remove("HUDShouldDraw", "GFStartDisableHUD")
	hook.Remove("GFStartKeyPress", "GFStartKeyPress")
	hook.Remove("CreateMove", "GFStartCreateMove")

	gfStartingUp = false

	net.Start("GFStartupDone")
	net.SendToServer()

	hook.Run("GFStartupDone")
end

local function createPanel()
	prestartpanel = vgui.Create("Panel")
	prestartpanel:SetPos(0, 0)
	prestartpanel:SetSize(ScrW(), ScrH())
	prestartpanel:MakePopup()
	prestartpanel:SetMouseInputEnabled(false)
	prestartpanel:SetKeyboardInputEnabled(false)
	prestartpanel.Paint = function()
		if !sequences[stage] then endMenu() return end

		if sequences[stage]() then 
			stage = stage + 1
		end
	end
end

local function camMovement(ply, pos, angles, fov)
	local view = {}
	view.origin = origins[selectedOrigin].pos
    view.angles = origins[selectedOrigin].ang + Angle(math.sin(RealTime()*0.5) * 0.5, -math.cos(RealTime()*0.5) * 0.5, 0)
    view.fov = fov
	
	return view
end

local function hideHUD(name)
	return false
end

local keyCooldown = 0
local function onKeyPress(pl, key)
	if key == IN_JUMP and CurTime() > keyCooldown then --key == IN_ATTACK or key == IN_ATTACK2 or key == IN_FORWARD
		stage = stage + 1
		keyCooldown = CurTime() + 1
	end
end

local function blockMove(cmd)
	--cmd:ClearButtons()
	cmd:ClearMovement()
	cmd:SetMouseX(0)
	cmd:SetMouseY(0)
end

local function handleMusic()
	if endingMusic then
		if !soundStream then
			hook.Remove("Think", "GFStartThink")
		else
			if !(soundStream == true) then
				if IsValid(soundStream) then
					if soundStream:GetVolume() <= 0 then
						hook.Remove("Think", "GFStartThink")
						soundStream:Stop()
						soundStream = nil
					else
						soundStream:SetVolume(math.max(0, soundStream:GetVolume() - FrameTime()/5))
					end
				else
					hook.Remove("Think", "GFStartThink")
				end
			end
		end
		
	end

	if stage != 4 then return end

	if !soundStream then
		soundStream = true
		sound.PlayURL(songUrls[math.random(1, #songUrls)], "noplay", function(chan, err, str)
			if IsValid(chan) then
				chan:SetVolume(0.4)
				chan:Play()
				soundStream = chan
			end
		end)
	end
end

local function startMenu()
	timer.Remove("GFStartupFix")
	system.FlashWindow()

	if !skipIntro:GetBool() then 
		createPanel()
		selectedOrigin = math.random(1, #origins)

		if !IsValid(prestartpanel) then
			createPanel()
		end

		if IsValid(soundStream) then
			soundStream:Stop()
			soundStream = nil
		end

		GetConVar("simple_thirdperson_enabled"):SetBool(false)

		hook.Add("CalcView", "GFStartCalcView", camMovement)
		hook.Add("HUDShouldDraw", "GFStartDisableHUD", hideHUD)
		hook.Add("KeyPress", "GFStartKeyPress", onKeyPress)
		hook.Add("CreateMove", "GFStartCreateMove", blockMove)
		hook.Add("Think", "GFStartThink", handleMusic)

		endingMusic = false
	end
end
hook.Add("InitPostEntity", "GFStartInit", function()
	timer.Simple(.2, function()
		startMenu()
	end)
end)