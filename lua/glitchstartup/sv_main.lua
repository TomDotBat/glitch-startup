
local startingPlayers = {}

hook.Add("PlayerInitialSpawn", "GlitchStartPlayerSpawn", function(ply)
	if ply:IsBot() then return end
	if ply:GetInfoNum("gf_introskip", 1) == 1 then return end

	startingPlayers[ply:SteamID()] = true
	timer.Create("GFStart:" .. ply:SteamID(), 5, 35, function()
		if !IsValid(ply) then return end

		if ply:GetInfoNum("gf_introskip", 1) == 1 then
			local ent, pos = hook.Run("PlayerSelectSpawn", ply)
    		timer.Simple(0, function() if IsValid(ply) then ply:SetPos(pos or ent:GetPos()) end end)

    		timer.Remove("GFStart:" .. ply:SteamID())

			return
		end

		ply:SetPos(Vector(2791.807129, 943.257751, 905.260498))
	end)
end)

net.Receive("GFStartupDone", function(len, ply)
	if !startingPlayers[ply:SteamID()] then return end
	startingPlayers[ply:SteamID()] = false

	timer.Remove("GFStart:" .. ply:SteamID())

    local ent, pos = hook.Run("PlayerSelectSpawn", ply)
    timer.Simple(0, function() if IsValid(ply) then ply:SetPos(pos or ent:GetPos()) end end)
end)

util.AddNetworkString("GFStartupDone")