
function points_at_level(level)
	local bonuspoints = 2 * math.floor(level/10)
	return level + bonuspoints
end

Hooks:PostHook(MenuSetup, "init_managers", "autoload_buildb_menusetup_init", function ()
	
	if managers.job:has_active_job() then return end
	
	local reputation = managers.experience:current_level()
	if reputation == 0 then return end
	
	--really stupid way to load buildb in a mod that isn't buildb (shouldn't be necessary?)
	if not BuilDB then
		local ourModPath = ModPath
		ModPath = ModPath .. '../BuilDB/'
		dofile(ModPath .. '../BuilDB/lua/_buildb.lua')
		log("[ABB] BUILDB WAS MISSING; loading it at " .. ModPath .. '../BuilDB/lua/_buildb.lua')
		ModPath = ourModPath
	end
	
	BuilDB:load_db()
	if (not BuilDB.builds) then return end
	
	log("[ABB] Checking for BuilDB builds to autoload...")
	
	--make the database of skillset names we have autoloadable builds for
	local autoloadable = {}
	local bestlevels = {}
	for i, v in ipairs(BuilDB.builds) do
		local str = v.title
		local level_loc1,level_loc2 = string.find(str, " Level ")
		if (level_loc1 and level_loc2) then
			local name = string.sub(str, 1, level_loc1-1)
			local level = tonumber(string.sub(str, level_loc2+1))
			--log(name .. ", " .. level)
			if (level <= reputation) then
				if (not autoloadable[name] or bestlevels[name] < level) then
					autoloadable[name] = v.url
					bestlevels[name] = level
				end
			end
		end
	end
	
	local wearechecking = "[ABB] Autoloadable builds: "
	for i, v in pairs(autoloadable) do
		wearechecking = wearechecking .. i .. " Level " .. bestlevels[i] .. ", "
	end
	log(wearechecking)
	
	for i, v in ipairs(managers.multi_profile._global._profiles) do
		local name = v.name
		local skillset = v.skillset
		local pointsused = managers.skilltree:total_points_spent(managers.skilltree._global.skill_switches[skillset])
		if (autoloadable[name] and points_at_level(bestlevels[name]) > pointsused) then
			--it's safest to import by switching over to that profile/set and then switching back after
			--than try to manually modify the profiles/sets
			local orig = managers.multi_profile._global._current_profile
			managers.multi_profile:set_current_profile(i)
			BDB_Format_PD2Builder:import(autoloadable[name])
			managers.multi_profile:set_current_profile(orig)
			log("[ABB] " .. name .. " Profile Autoloaded")
		end
	end
	
	--same code but for skill switches
	for i, v in ipairs(managers.skilltree._global.skill_switches) do
		local name = v.name
		local pointsused = managers.skilltree:total_points_spent(v)
		if (autoloadable[name] and points_at_level(bestlevels[name]) > pointsused) then
			local orig = managers.skilltree._global.selected_skill_switch
			managers.skilltree:switch_skills(i)
			--ignore everything after an ampersand (deployable/throwable info) when importing a skillset
			for firstpart in string.gmatch(autoloadable[name], "([^&]*)") do
				BDB_Format_PD2Builder:import(firstpart)
				break
			end
			managers.skilltree:switch_skills(orig)
			log("[ABB] " .. name .. " Skillset Autoloaded")
		end
	end
end)
