--[[
AC6-FIX V1.0.0
	By lumen695
]]

local prefix = "[AC6-FIX]:"

local ac6_list = {}
local whitelist_sounds = {}

local TargetNames = { "AC6C_Stock_Sound", "AC6C_Boost_Sound" }

local http = game:GetService("HttpService")

function deleteSound(sound)
	for i, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Sound") and v.Name == sound["name"] and tostring(v.SoundId) == tostring(sound["id"]) then
			v:Destroy()
		else
			continue
		end
	end
end

function listen(keyList)
	for i, v in pairs(keyList) do
		local ac6: RemoteEvent = ac6_list[v]

		ac6.OnServerEvent:Connect(function(player: Player, ...)
			local args = { ... }

			local _success, response = pcall(function()
				if not args[2] or not args[4] then
					return false
				end

				if string.sub(args[4], 1, 10) == "rbxassetid" then
					local sound = whitelist_sounds[args[2]]

					if args[2] ~= sound["name"] or args[4]:sub(14) ~= tostring(sound["id"]:sub(14)) then
						deleteSound(sound)
						player:Kick(prefix .. " You were kicked from the game for using an exploit.")
					end
				end

				return true
			end)
			if response then
				warn(prefix, response)
			end
		end)
	end
end

function updateList()
	local keys = {}

	for i, v in pairs(workspace:GetDescendants()) do
		if v:IsA("LocalScript") and table.find(TargetNames, v.Name) then
			local ac6 = v:FindFirstChild("AC6_FE_Sounds")

			for i, sound in pairs(v:GetChildren()) do
				if sound:IsA("Sound") then
					whitelist_sounds[sound.Name] = {
						["id"] = sound.SoundId,
						["name"] = sound.Name,
					}
				end
			end

			if ac6 and not ac6:GetAttribute("key") then
				local key = http:GenerateGUID(false)
				ac6:SetAttribute("key", key)
				table.insert(keys, key)
				ac6_list[key] = ac6
			end
		end
	end

	listen(keys)
end

warn(prefix, "The system will start in 2 seconds.")

task.wait(2)

warn(prefix, "It has started")

while task.wait(1) do
	updateList()
end
