return {
  run = function()
    fassert(rawget(_G, "new_mod"), "'[Example] Custom View' mod must be lower than Vermintide Mod Framework in your launcher's load order.")

    new_mod("custom_view_example", {
      mod_script       = "scripts/mods/custom_view_example/custom_view_example",
      mod_data         = "scripts/mods/custom_view_example/custom_view_example_data",
      mod_localization = "scripts/mods/custom_view_example/custom_view_example_localization"
    })
  end,
  packages = {
    "resource_packages/custom_view_example/custom_view_example"
  }
}
