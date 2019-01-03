return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Package Management Example mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("package_management_example", {
			mod_script = "scripts/mods/package_management_example/package_management_example",
			mod_data   = "scripts/mods/package_management_example/package_management_example_data",
		})
	end,
	packages = {
		"resource_packages/package_management_example/default"
	}
}