local mod = get_mod("package_management_example")

local _gui_one
local _gui_two

local PACKAGES = {
  [1] = "resource_packages/package_management_example/package_one",
  [2] = "resource_packages/package_management_example/package_two"
}

local MATERIALS = {
  [1] = "materials/package_management_example/package_one_materials",
  [2] = "materials/package_management_example/package_two_materials"
}

-- #####################################################################################################################
-- ##### Local functions ###############################################################################################
-- #####################################################################################################################

-- This function is used as callback when a package is finished loading.
-- It creates gui with material from loaded package.
local function create_gui(package_name)
  mod:echo("Package '%s' finished loading.", package_name)
  -- Pick material file name depending on which one of two packages was loaded.
  local material_file_name
  if package_name == PACKAGES[1] then
    material_file_name = MATERIALS[1]
  else
    material_file_name = MATERIALS[2]
  end

  -- Create gui and assign it to eather one of two variables depending on loaded package.
  local world = Managers.world:world("top_ingame_view")
  local gui = World.create_screen_gui(world, "immediate", "material", material_file_name)
  if package_name == PACKAGES[1] then
    _gui_one = gui
  else
    _gui_two = gui
  end
end


-- Called before unloading a package containing material which is used in deletable gui.
local function destroy_gui(package_name)
  local world = Managers.world:world("top_ingame_view")
  if package_name == PACKAGES[1] then
    World.destroy_gui(world, _gui_one)
    _gui_one = nil
  else
    World.destroy_gui(world, _gui_two)
    _gui_two = nil
  end
end

-- #####################################################################################################################
-- ##### Commands ######################################################################################################
-- #####################################################################################################################

mod:command("load_package", nil, function(package_number, sync_loading)
  -- Convert value from string to boolean.
  sync_loading = sync_loading == "true"

  -- Get the full package name if package_number entered correctly.
  local package_name = PACKAGES[tonumber(package_number)]
  if package_name then
    -- 'mod:package_status' returns status string if attempt of loading package was already made
    if mod:package_status(package_name) then
      mod:echo("You can't load already loaded package.")
      return
    end
    mod:load_package(package_name, create_gui, sync_loading)

    mod:echo("Package '%s' status: %s", package_name, mod:package_status(package_name))
  end
end)


mod:command("unload_package", nil, function(package_number)
  local package_name = PACKAGES[tonumber(package_number)]
  if package_name then
    if not mod:package_status(package_name) then
      mod:echo("You can't unload already unloaded package.")
      return
    end
    destroy_gui(package_name)
    mod:unload_package(package_name)

    mod:echo("Unloaded package '%s'.", package_name)
  end
end)

-- #####################################################################################################################
-- ##### Callbacks #####################################################################################################
-- #####################################################################################################################

-- Draw loaded materials on `update` callback with Guis created specifically for these materials.
function mod.update()
  if mod:is_enabled() then
    if _gui_one then
      --           [gui]   [material]            [position]              [size]
      Gui.bitmap(_gui_one, "doge_one", Vector3(300, 300, 1000), Vector2(100, 100))
    end
    if _gui_two then
      Gui.bitmap(_gui_two, "doge_two", Vector3(500, 300, 1000), Vector2(100, 100))
    end
  end
end


-- Destroy guis and unload packages on mod unloading.
function mod.on_unload()
  for _, package_name in ipairs(PACKAGES) do
    local package_status = mod:package_status(package_name)
    if package_status == "loaded" then
      destroy_gui(package_name)
      mod:unload_package(package_name)
    end
  end
end