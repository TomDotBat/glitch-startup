local seq = {}

local s = (ScrH() / 1080)

local glitchLogo = Material("glitchfire/logo/logo.png", "smooth")
local logoS = s*340

surface.CreateFont("gfStartupTitle", {
	font = "Roboto",
	extended = false,
	size = s*90,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

surface.CreateFont("gfStartupHint", {
	font = "Roboto",
	extended = false,
	size = s*28,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true
})

local rgb = {Color(255, 0, 0, 200), Color(0, 255, 0, 200), Color(0, 0, 255, 200)}
local intensity = 10
local nextGlitch = 0
local glitchCount = 0
local hintStart = false
local hintWait = 10

seq[1] = function()
	surface.SetDrawColor(color_black)
	surface.DrawRect(0, 0, ScrW(), ScrH())

	surface.SetFont("gfStartupTitle")
	local textH = select(2, surface.GetTextSize("Glitch Fire"))

	local cx, cy = (ScrW()-logoS)/2, (ScrH()-logoS)/2 - textH + s*25

	surface.SetDrawColor(color_white)
	surface.SetMaterial(glitchLogo)
	surface.DrawTexturedRect(cx, cy, logoS, logoS)

	if CurTime() >= nextGlitch then
		local dx, dy = 0, 0

		for i = 1, 3 do
			local ox, oy = 0, 0

			dx = dx + math.random(-intensity, intensity)
			dy = dy + math.random(-intensity, intensity)

			ox = cx + dx
			oy = cy + dy

			draw.SimpleText("Glitch Fire", "gfStartupTitle", ox + (logoS/2), oy + logoS + s*70, rgb[i], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		glitchCount = glitchCount + FrameTime() * 70

		if glitchCount > 20 then 
			glitchCount = 1
			nextGlitch = CurTime() + 2
		end
	else
		draw.SimpleText("Glitch Fire", "gfStartupTitle", cx + (logoS/2), cy + logoS + s*70, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if !hintStart then
		hintStart = CurTime() + hintWait
	end

	if CurTime() > hintStart then
		draw.SimpleText("Press SPACE to continue", "gfStartupHint", 0+s*8, ScrH()-s*18, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end	
end

local inStartTime = 0
local inEndTime = false
local fadeInTime = 1

local seqEnd = 0

seq[2] = function()
	seq[1]()

	if !inEndTime then
		inStartTime = CurTime()
		inEndTime = CurTime() + fadeInTime
		seqEnd = CurTime() + 150
	else
		if CurTime() <= inEndTime then
			surface.SetDrawColor(Color(0, 0, 0, ((CurTime() - inStartTime) / fadeInTime) * 255))
			surface.DrawRect(0, 0, ScrW(), ScrH())
		else
			return true
		end
	end
	
end

local waitEndTime = false
local waitTime = 0.3

seq[3] = function()
	surface.SetDrawColor(color_black)
	surface.DrawRect(0, 0, ScrW(), ScrH())

	if !waitEndTime then
		waitEndTime = CurTime() + waitTime
	else
		if CurTime() > waitEndTime then
			return true
		end
	end
end

local outStartTime = 0
local outEndTime = false
local fadeOutTime = 1

seq[4] = function()
	seq[5]()

	if !outEndTime then
		outStartTime = CurTime()
		outEndTime = CurTime() + fadeOutTime

		surface.SetDrawColor(color_black)
	else
		if CurTime() <= outEndTime then
			surface.SetDrawColor(Color(0, 0, 0, 255 - ((CurTime() - outStartTime) / fadeOutTime) * 255))
		else
			return true
		end
	end

	surface.DrawRect(0, 0, ScrW(), ScrH())
end

local logoCol = Color(255, 255, 255, 190)

seq[5] = function()
	local cx, cy = (ScrW()-logoS) - s*10, (ScrH()-logoS) - s*40

	surface.SetDrawColor(logoCol)
	surface.SetMaterial(glitchLogo)
	surface.DrawTexturedRect(cx, cy, logoS, logoS)

	if CurTime() > seqEnd then
		return true
	end	
end

return seq