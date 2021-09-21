local deployable = 0
local grenade = 0
local setname = ""
local origset = 0

Hooks:PreHook(MenuCallbackHandler, "_increase_infamous", "autoload_buildb_menumanager_preinfamy", function (self)
	--store our deployable, throwable, set #1 name, and this profile's current skillset
	deployable = managers.blackmarket:equipped_deployable()
	grenade = managers.blackmarket:equipped_grenade()
	setname = managers.skilltree._global.skill_switches[1].name
	orig = managers.skilltree._global.selected_skill_switch
	--reset skilltrees now so they don't become suspended
	managers.skilltree:reset_skilltrees()
end)
Hooks:PostHook(MenuCallbackHandler, "_increase_infamous", "autoload_buildb_menumanager_postinfamy", function (self)
	managers.blackmarket:equip_deployable({name=deployable,target_slot=1})
	managers.blackmarket:equip_grenade(grenade)
	managers.skilltree._global.skill_switches[1].name = setname
	managers.skilltree:switch_skills(orig)
end)