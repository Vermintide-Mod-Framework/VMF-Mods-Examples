local mod = get_mod("settings_and_options_example")

return {
  name = "[Example Mod] Settings and Options",
  description = mod:localize("mod_description"),
  is_togglable = true,
  options = {
    collapsed_widgets = {
      "keybinds_group"
    },
    widgets = {
      {
        setting_id    = "setting_one",
        type          = "checkbox",
        default_value = false
      },
      {
        setting_id    = "setting_two",
        type          = "checkbox",
        default_value = true,
        sub_widgets = {
          {
            setting_id    = "setting_three",
            type          = "checkbox",
            default_value = false
          }
        }
      },
      {
        setting_id    = "settings_updating_approach",
        type          = "dropdown",
        default_value = 1,
        options = {
          {text = "updating_approach_parent_dependant",   value = 1},
          {text = "updating_approach_parent_independant", value = 2}
        }
      },
      {
        setting_id  = "expression_group",
        type        = "group",
        sub_widgets = {
          {
            setting_id    = "expression_input",
            type          = "dropdown",
            default_value = "none",
            options = {
              {text = "expression_input_none",    value = "none"},
              {text = "expression_input_number",  value = "number",             show_widgets = {1}},
              {text = "expression_input_percent", value = "percent",            show_widgets = {2}},
              {text = "expression_input_both",    value = "number_and_percent", show_widgets = {1, 2}}
            },
            sub_widgets = {
              {
                setting_id    = "expression_number",
                type          = "numeric",
                range         = {-1000, 1000},
                default_value = 0
              },
              {
                setting_id      = "expression_percent",
                type            = "numeric",
                default_value   = 100,
                range           = {0, 146.8},
                unit_text       = "unit_percentage",
                decimals_number = 1
              }
            }
          },
          {
            setting_id      = "solve_expression_keybind",
            type            = "keybind",
            default_value   = {},
            keybind_trigger = "pressed",
            keybind_type    = "function_call",
            function_name   = "solve_expression",
          }
        }
      },
      {
        setting_id  = "keybinds_group",
        type        = "group",
        sub_widgets = {
          -- I will add bunch of keybinds in here once new keybind system is ready
          {
            setting_id      = "some_keybind",
            type            = "keybind",
            default_value   = {"n", "ctrl", "alt", "shift"},
            keybind_trigger = "pressed",
            keybind_type    = "function_call",
            function_name   = "solve_expression",
          }
        }
      }
    }
  }
}