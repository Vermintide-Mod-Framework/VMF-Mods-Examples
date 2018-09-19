return {
	run = function()
		fassert(rawget(_G, "new_mod"), "[Example Mod] Settings and Options must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("settings_and_options_example", {
			mod_script       = "scripts/mods/settings_and_options_example/settings_and_options_example",
			mod_data         = "scripts/mods/settings_and_options_example/settings_and_options_example_data",
			mod_localization = "scripts/mods/settings_and_options_example/settings_and_options_example_localization"
		})
	end,
	packages = {
		"resource_packages/settings_and_options_example/settings_and_options_example"
	}
}
