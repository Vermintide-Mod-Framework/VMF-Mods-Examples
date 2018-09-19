VMF has its own settings manager, which is used for storing and accessing mod's data.
- It operates within mods namespace, meaning 2 mods can have 2 different settings under the same name.
- It can store values of following types:
  - `boolean`
  - `number`
  - `string`
  - `table` (Only array-like, or map-like, but not mixed [\[See the difference between table types here\]](https://gist.github.com/Azumgi/8b567cfcdab902445eee01eef300bd76))
- It saves data in the game's config file, so it can be accessed between game sessions.
  - File's location:
    - VT1: `%AppData%\Fatshark\Warhammer End Times Vermintide\user_settings.config`
    - VT2: `%AppData%\Fatshark\Vermintide 2\user_settings.config`
  - Events, when data is saved to the file:
    - Game state changing.
    - Mods reloading.
    - Mod Options menu closing.

If the game will crash before reaching any of these events, changed settings won't be saved.

There are 2 ways of interacting with mod's settings.
- Directly
- Via Mod Options menu

# Interacting with mod's settings directly

```lua
mod:set(setting_id, setting_value, notify_mod)
```

Saves mod's data under specified `setting_id`.

- `setting_id` *[string]* - Setting's identifier.

- `setting_value` *[allowed_types]* - Saved data.

- `notify_mod` *[boolean]* - (optional) If `true`, event `mod.on_setting_changed` will be called.

```lua
mod:get(setting_id)
```

Returns saved mod's data or `nil`.

- `setting_id` *[string]* - Setting's identifier.


Performance notes:
- Storing and retrieving tables is slow because they are cloned every time you save/access them. So try to save them only when your mod is about to be unloaded, and retrieve them when mod is loaded.
- `mod:get` and `mod:set` calls are pretty fast, but accessing local variables is much faster. Don't use these calls if you don't really need to.

You can also specify callback

```lua
mod.on_setting_changed(setting_id)
```

which will be called when mod's setting is changed via:
- Mod Options.
- `mod:set` call with `notify_mod` argument set to `true`.

# Interacting with mod's settings via Mod Options

You can create options for your mod, so mod's users will be able to change mod's settings themselves.

Options can be defined in `mod_data.options`. It has 2 fields:
- `widgets` - options widgets definition
- `collapsed_widgets` - list of `setting_id`s of widgets that should be collapsed by default (used only when mod is initialized for the first time)

All widgets (except for `group`) have both `setting_id` and `default_value` field.

When mod's widgets are successfully initialized, VMF will iterate through all widgets, and if setting of some widget was not set before, it will be set to `default_value`. It all happens during `mod_data` initialization, so when your mod's script will be executed, all setting in widgets will be already initialized.

Since Mod Options in built upon settings manager calls, you can get your settings via `mod:get`. You can also do `mod:set`, but it must contain acceptable value for widget, otherwise it can lead to unexpected consequences.


# Widgets definition

Generic widget data specific for all widgets (with few exceptions).

```lua
{
  setting_id    = "setting_id",
  type          = "group/checkbox/dropdown/keybind/numeric",
  title         = "title_localization_id",
  tooltip       = "tooltip_localization_id",
  default_value = --[[value]],  -- all widgets, except 'group'
  sub_widgets   = { --[[...]] } -- 'group', 'checkbox', 'dropdown' widgets
}
```

- `setting_id` *[string]* - Setting's identifier which will be used to save the value currently picked in this widget as the regular setting. This string will be also used as localization_id for widget's title, if `title` is not specified, and `setting_id .. "_description"` as tooltip's localization_id, if `tooltip` is not specified.

- `type` *[string]* - Widget's type.

- `title` *[string]* - (optional) Is used as localization_id for widget's title.

- `tooltip` *[string]* - (optional) Is used as localization_id for widget's tooltip.

- `default_value` *[widget-specific]* - If setting with `setting_id` wasn't set before, it will be set to this value. (Exception: 'group' widget does not require `default_value`)

- `sub_widgets` *[table]* - Child widgets of current widget. They can be hidden by either collapsing parent widget or by meeting some condition in parent widget.

It is advised to not specify `title` and `tooltip`, as it will add more visual clutter without any benefits, since `settig_id` is already used to localize title and tooltip. So in the next examples they will be skipped.


## Group

This widget doesn't do anything by itself. It just groups other widgets.

```lua
{
  setting_id  = "setting_id",
  type        = "group",
  sub_widgets = { --[[...]] }
}
```

This is the only widget that doesn't do anything with its setting. It's needed only for widget identifying.

Child widgets can be hidden only by widget collapsing.

## Checkbox

Simple togglable widget with only 2 states.

```lua
{
  setting_id    = "setting_id",
  type          = "checkbox",
  default_value = true,
  sub_widgets   = { --[[...]] } -- optional
}
```

Widget's setting must have `boolean` type.

Child widgets will be hidden when widget's setting is set to `false`.

## Dropdown

Widget that allows to have 2 and more options to be picked from.

```lua
{
  setting_id    = "setting_id",
  type          = "dropdown",
  default_value = --[[value]],
  options = {
    {text = "option_one_localization_id",   value = --[[value]], show_widgets = { --[[...]] }},
    {text = "option_two_localization_id",   value = --[[value]], show_widgets = { --[[...]] }},
    {text = "option_three_localization_id", value = --[[value]], show_widgets = { --[[...]] }},
    {text = "option_four_localization_id",  value = --[[value]], show_widgets = { --[[...]] }},
    {text = "option_five_localization_id",  value = --[[value]], show_widgets = { --[[...]] }}
  },
  sub_widgets = { --[[...]] } -- optional
}
```

Widget's setting must have `string`, `number` or `boolean` type.

- `options` *[table]* - Defines list of options that user will be able to pick from.

  - `text` *[string]* - Option's localization_id.

  - `value` - Widget's setting will be set to this value, when this option is picked.

  - `show_widgets` *[table]* - (optional) Table with indices of sub_widgets that will become visible, when this option is picked. If not specified, all sub_widgets will be hidden.

## Keybind

**IMPORTANT: this description is made for keybind system that is not ready yet. I'll start working on it, once widget definition system is ready. For now, it will work only for `keybind_global = false, keybind_trigger = "pressed", keybind_type = "function_call"`**

Widget that allows user to define custom keybinds of any type. Note, there are no checks for duplicating keybinds.

```lua
{
  setting_id      = "setting_id",
  type            = "keybind",
  default_value   = { --[[...]] },
  keybind_global  = true,       -- optional
  keybind_trigger = "pressed/released/held",
  keybind_type    = "function_call/view_toggle/mod_toggle",
  function_name   = "whatever", -- required, if (keybind_type == "function_call")
  view_name       = "whatever"  -- required, if (keybind_type == "view_toggle")
}
```

Widget's setting must be a `table` with 0-4 elements. 0 elements means the keybind is not specified. Specified keybind has to have at least `[1]` element. Elements `[2]`, `[3]` and `[4]` are optional. All 4 elements should have `string` type.

<details>
  <summary>
    Allowed values for table's elements
  </summary>

  `[1]` element:

  | Key Name | Value |
  | --- | --- |
  | Backspace | `backspace` |
  | Tab | `tab` |
  | Enter | `enter` |
  | Caps Lock | `caps lock` |
  | Space | `space` |
  | Page Up | `page up` |
  | Page Down | `page down` |
  | End | `end` |
  | Home | `home` |
  | Left | `left` |
  | Up | `up` |
  | Right | `right` |
  | Down | `down` |
  | Insert | `insert` |
  | Delete | `delete` |
  | 0 | `0` |
  | 1 | `1` |
  | 2 | `2` |
  | 3 | `3` |
  | 4 | `4` |
  | 5 | `5` |
  | 6 | `6` |
  | 7 | `7` |
  | 8 | `8` |
  | 9 | `9` |
  | A | `a` |
  | B | `b` |
  | C | `c` |
  | D | `d` |
  | E | `e` |
  | F | `f` |
  | G | `g` |
  | H | `h` |
  | I | `i` |
  | J | `j` |
  | K | `k` |
  | L | `l` |
  | M | `m` |
  | N | `n` |
  | O | `o` |
  | P | `p` |
  | Q | `q` |
  | R | `r` |
  | S | `s` |
  | T | `t` |
  | U | `u` |
  | V | `v` |
  | W | `w` |
  | X | `x` |
  | Y | `y` |
  | Z | `z` |
  | Win | `win` |
  | Right Win | `right win` |
  | Numpad 0 | `numpad 0` |
  | Numpad 1 | `numpad 1` |
  | Numpad 2 | `numpad 2` |
  | Numpad 3 | `numpad 3` |
  | Numpad 4 | `numpad 4` |
  | Numpad 5 | `numpad 5` |
  | Numpad 6 | `numpad 6` |
  | Numpad 7 | `numpad 7` |
  | Numpad 8 | `numpad 8` |
  | Numpad 9 | `numpad 9` |
  | Numpad * | `numpad *` |
  | Numpad + | `numpad +` |
  | Numpad - | `numpad -` |
  | Numpad . | `numpad .` |
  | Numpad / | `numpad /` |
  | Numpad Enter | `numpad enter` |
  | F1 | `f1` |
  | F2 | `f2` |
  | F3 | `f3` |
  | F4 | `f4` |
  | F5 | `f5` |
  | F6 | `f6` |
  | F7 | `f7` |
  | F8 | `f8` |
  | F9 | `f9` |
  | F10 | `f10` |
  | F11 | `f11` |
  | F12 | `f12` |
  | Num Lock | `num lock` |
  | Scroll Lock | `scroll lock` |
  | Browser Back | `browser back` |
  | Browser Forward | `browser forward` |
  | Browser Refresh | `browser refresh` |
  | Browser Stop | `browser stop` |
  | Browser Search | `browser search` |
  | Browser Favorites | `browser favorites` |
  | Browser Home | `browser home` |
  | Volume Mute | `volume mute` |
  | Volume Down | `volume down` |
  | Volume Up | `volume up` |
  | Next Track | `next track` |
  | Previous Track | `previous track` |
  | Stop | `stop` |
  | Play/Pause | `play pause` |
  | Mail | `mail` |
  | Media | `media` |
  | Start Application 1 | `start app 1` |
  | Start Application 2 | `start app 2` |
  | ; | `;` |
  | = | `=` |
  | , | `,` |
  | - | `-` |
  | . | `.` |
  | / | `/` |
  | \` | `` ` `` |
  | [ | `[` |
  | \\ | `\\` |
  | ] | `]` |
  | ' | `'` |
  | Mouse Left | `mouse left` |
  | Mouse Right | `mouse right` |
  | Mouse Middle | `mouse middle` |
  | Mouse Extra 1 | `mouse extra 1` |
  | Mouse Extra 2 | `mouse extra 2` |
  | Mouse Wheel Up | `mouse wheel up` |
  | Mouse Wheel Down | `mouse wheel down` |
  | Mouse Wheel Left | `mouse wheel left` |
  | Mouse Wheel Right | `mouse wheel right` |

  `[2]`, `[3]` and `[4]` elements:

  | Key Name | Value |
  | --- | --- |
  | Ctrl | `ctrl` |
  | Alt | `alt` |
  | Shift | `shift` |
</details>

- `keybind_global` *[boolean]* - (optional) If `true`, keybind will be triggered even when pressed in some menu / loading screen etc.

- `keybind_trigger` *[string]* - when specified keybind's action is triggered.

  | Value | Trigger |
  | --- | --- |
  | `pressed` | Keybind is pressed |
  | `released` | Keybind is released |
  | `held` | 2 times: when keybind is pressed and when it's released |

- `keybind_type` *[string]* - specifies keybind's action.

  | Value | Behavior |
  | --- | --- |
  | `function_call` | Calls function, specified as mod.`function_name`. If `keybind_trigger` is `held`, calls it 2 times and passes `true` as the first parameter on the first call. |
  | `view_toggle` | Opens / closes custom view with `view_name` name. |
  | `mod_toggle` | Toggles mod's state (enables / disables it). |

- `function_name` *[string]* - *(if keybind_type == "function_call")* Mod's function name to be called.

- `view_name` *[string]* - *(if keybind_type == "view_toggle")* Custom view's name to be toggled.

## Numeric

Widget that allows user to set number value within certain range via widget's slider or manually.

```lua
{
  setting_id      = "setting_id",
  type            = "numeric",
  default_value   = 0,
  range           = {-100, 100},
  unit_text       = "unit_text_localization_id", -- optional
  decimals_number = 2                            -- optional
}
```

Widget's setting must have `number` type.

`range` *[table]* - Defines minimum and maximum number's value. Must contain 2 elements of `number` type, such as `[1]` < `[2]`

`unit_text` *[string]* - (optional) localization_id of text which will be appended to numeric value. It is visible only in mod options and is not appended to actual setting's value.

`decimals_number` *[number]* - (optional) Allowed number of decimal digits for widget's setting's value.

# Localization

It is advised to always let VMF automatically localize options. Because:
- It makes widget definition code much smaller and more readable.
- It allows you to create options fast without worrying about coming up with options names and tooltips, as you can do it later.
- It will motivate you to use localization file, so others will be able to translate your mod to other languages.

But if you want to disable localization for something specific, you can override default localization settings. There are 4 tiers:

- `mod_data.options.localize`
  - `mod_data.options.widgets.localize`
    - `specific_widget.localize`
      - `specific_widget.some_table_field.localize`

Overriding localization setting for higher tier also override it for lower tiers. So, for example, if you will do

```lua
mod_data.options = {
  widgets = {
    localize = false,
    {
      -- [[...]]
    },
    -- [[...]]
  }
}
```

this will disable localization for all widgets. But you can override localization from lower tiers. Example:

```lua
{
  setting_id    = "setting_id",
  type          = "dropdown",
  localize      = false,
  title         = "Whatever", -- Not localized
  tooltip       = "Whatever", -- Not localized
  default_value = "option_one",
  options = {
    localize = true,
    {text = "option_one",  value = "option_one"}, -- Localized
    {text = "option_two",  value = "option_two"}, -- Localized
    {text = "option_five", value = "option_five"} -- Localized
  }
}
```

# Some tips

- Don't set default keybinds if there's no important reason to do this. Let users set keybinds. Otherwise, it will lead to a lot of collisions between mods' keybinds and confusion for end users.

- If you have dropdown widget with option `off`, `disable` or similar. You should split it so enabling/disabling option will be in parent checkbox and other options will be in child dropdown.
  ```lua
  {
    setting_id    = "something",
    type          = "dropdown",
    default_value = "mode_1",
    options = {
      {text = "disable_something", value = "off"},
      {text = "something_mode_1",  value = "mode_1"},
      {text = "something_mode_2",  value = "mode_2"}
    }
  }
  ```
  =>
  ```lua
  {
    setting_id    = "something_active",
    type          = "checkbox",
    default_value = true,
    sub_widgets = {
      {
        setting_id    = "something_mode",
        type          = "dropdown",
        default_value = "mode_1",
        options = {
          {text = "something_mode_1",  value = "mode_1"},
          {text = "something_mode_2",  value = "mode_2"}
        }
      }
    }
  },

  ```
  Good design.

- If you have text in localization file that doesn't need to be translated to other languages, just leave it in `en`. Because if localization for current game language is not found VMF will look for English localization.

- Don't forget to check values of parent widgets when processing settings from child widgets. You don't make them parent for nothing. Well, mostly.