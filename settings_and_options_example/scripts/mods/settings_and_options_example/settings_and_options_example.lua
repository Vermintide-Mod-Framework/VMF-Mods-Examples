local mod = get_mod("settings_and_options_example")

-- Let's imagine these 3 settings are used tens of times every tick. So we save them in local varibales
-- because accessing local variables is much faster than retrieving them with 'mod:get'.
-- Let's consider these values some kind of states (boolean values).
local state_one
local state_two
local state_three

-- Update states' values with 2 approaches:
-- 1. If parent checkbox is disabled, all his child checkboxes are cosidered disabled as well,
--    no matter their real state.
-- 2. Get values of child checkboxes ignoring parent checkbox.
-- Generally, you should always use the 1st approach. Always consider parent widget. It's not only about checkboxes.
local function update_states()
  state_one   = mod:get("setting_one")
  state_two   = mod:get("setting_two")
  state_three = mod:get("setting_three")

  if mod:get("settings_updating_approach") == 1 then
    state_three = state_two and state_three
  end
end

-- Update states values for the first time, when script is executed.
update_states()

-- Setting_ids that should trigger 'update_states' call, when changed.
local settings_related_to_states = {
  setting_one                = true,
  setting_two                = true,
  setting_three              = true,
  settings_updating_approach = true
}
-- Callback, which will be called every time some setting of this mod will be changed from Mod Options.
function mod.on_setting_changed(setting_id)
  if settings_related_to_states[setting_id] then
    update_states()
  end
end

-- Simply show setting's states in the chat (if you want it, for some reason).
mod:command("show_state_settings", mod:localize("show_state_settings_description"), function()
  mod:echo("State One: "   .. (state_one   and "ACTIVE" or "DISABLED"))
  mod:echo("State Two: "   .. (state_two   and "ACTIVE" or "DISABLED"))
  mod:echo("State Three: " .. (state_three and "ACTIVE" or "DISABLED"))
end)




-- Function, which is called when 'solve_expression_keybind' keybind is pressed
-- Also, another example of handling parent widget, but it's dropdown this time.
-- And here we don't use settings stored in local variables, but retrieve them every call with 'mod:get'.
function mod.solve_expression()
  local expression_input   = mod:get("expression_input")
  local expression_number  = 0
  local expression_percent = 0

  if expression_input == "number" then
    expression_number = mod:get("expression_number")
  elseif expression_input == "percent" then
    expression_number = mod:get("expression_percent")
  elseif expression_input == "number_and_percent" then
    expression_number = mod:get("expression_number")
    expression_percent = mod:get("expression_percent")
  end

  local expression_result = 1500 + 4 * expression_number - 1470 * expression_percent / 100

  mod:echo_localized("result", expression_result)
end