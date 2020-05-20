if SERVER then
	include("glitchstartup/sv_main.lua")
	AddCSLuaFile()
	AddCSLuaFile("glitchstartup/cl_main.lua")
	AddCSLuaFile("glitchstartup/cl_sequences.lua")
else
	include("glitchstartup/cl_main.lua")
end