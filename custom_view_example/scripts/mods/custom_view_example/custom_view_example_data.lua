return {
  name = "[Example] Custom View",
  is_togglable = true,
  options = {
    widgets = {
      {
        setting_id      = "open_custom_view_keybind",
        type            = "keybind",
        default_value   = {"n"},
        keybind_trigger = "pressed",
        keybind_type    = "view_toggle",
        view_name       = "custom_view", -- system view name
        transition_data = {
          -- Views transitions which will be used to toggle view. Only transitions registered for this view can be used.
          open_view_transition_name    = "custom_view_open",
          close_view_transition_name   = "custom_view_close",
          -- Optional params which will be passed to corresponding transitions and to 'on_enter'/'on_exit' view methods.
          open_view_transition_params  = "some_string",
          close_view_transition_params = {"some_table_with_string"},
          -- Fade screen to black for a moment when opening view and when closing it.
          -- transition_fade              = true
        }
      }
    }
  }
}
