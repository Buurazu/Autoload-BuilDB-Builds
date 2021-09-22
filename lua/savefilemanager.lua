Hooks:PostHook(SavefileManager, "_load_cache", "autoload_buildb_savefilemanager_load", function (self, slot)
	if slot == self.SETTING_SLOT then return end
	AutoloadBuilDB:autoload("SavefileManager:_load_cache")
end)
