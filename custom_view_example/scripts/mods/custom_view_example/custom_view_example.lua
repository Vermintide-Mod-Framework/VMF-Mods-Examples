local mod = get_mod("custom_view_example")

local DEFINITIONS = mod:dofile("scripts/mods/custom_view_example/custom_view_definitions")

-- A view by itself is just a table with several callbacks required by ingame_ui. How it will behave is completely up to
-- you. In this example I'm going to create a simple view which can be toggled with a keybind. It will draw 2 rectangles
-- which are highlighted when hovered. I won't explain anything related to widget definitions, their creating, and
-- drawing because this is a different topic.

-- We're going to use Fatshark's class system to instantiate this view ('foundation/scripts/util/class.lua').
-- This means every time you execute `CustomView:new(...)`, it returns a new table which has all the
-- CustomView methods defined below and also executes `CustomView:init(...)`.
local CustomView = class()

--[[
  This method is executed every time we create a new instance of 'CustomView'. The passed 'ingame_ui_context'
  parameter is a table, which contains everything that is needed for operating this view: renderer, input manager,
  world information, etc.

  Every time level changes 'ingame_ui_context's contents are changed as well, so we want some callback to grab the
  latest 'ingame_ui_context' every time this happens. There's 'init_view_function' inside 'view_data' which does
  exactly that.

  In this example we don't update ingame UI context inside view. We just create a new instance of view every time
  'init_view_function' is called.
--]]
function CustomView:init(ingame_ui_context)
  -- Define necessary things for the rendering.
  self.ui_renderer     = ingame_ui_context.ui_renderer
  self.render_settings = {snap_pixel_positions = true}

  -- Create input service named 'custom_view', listening to keyboard, mouse and gamepad inputs,
  -- and set its keymaps and filters as 'IngameMenuKeymaps' and 'IngameMenuFilters'
  -- (which are defined inside scripts/settings/controller_settings.lua)
  --
  -- In this example we'll need input service for several things:
  --
  -- 1. Listen to 'toggle_menu' event to close this view. We're using input service and not directly listening to key
  --    presses, because user may want to rebind it. For example, default buttons to trigger 'toggle_menu' event are
  --    'Esc' for keyboard, 'Start' for xb1 controller, and 'Options' for ps4 controller.
  -- 2. Return it in `CustomView:input_service()` call, which is used by ingame_ui to do its magic related to
  --    chat window, popup windows and what else.
  -- 3. Use it in UIRenderer passes when drawing widgets to detect and process mouse clicks.
  local input_manager = ingame_ui_context.input_manager
  input_manager:create_input_service("custom_view", "IngameMenuKeymaps", "IngameMenuFilters")
  input_manager:map_device_to_service("custom_view", "keyboard")
  input_manager:map_device_to_service("custom_view", "mouse")
  input_manager:map_device_to_service("custom_view", "gamepad")
  self.input_manager = input_manager

  -- Create wwise_world which is used for making sounds (for opening view, closing view, etc.)
  local world = ingame_ui_context.world_manager:world(VT1 and "music_world" or "level_world")
  self.wwise_world = Managers.world:wwise_world(world)

  self:create_ui_elements()

  mod:echo("Custom View initialized.")
end

-- #####################################################################################################################
-- ##### Methods required by ingame_ui #################################################################################
-- #####################################################################################################################

--[[
  This method is called every frame when this view is active (has player's focus). You should use it to draw widgets,
  manage view's state, listen to some events, etc.
--]]
function CustomView:update(dt)
  -- Listen to 'toggle_menu' event and perform 'custom_view_close' transition when it's triggered.
  local input_service = self:input_service()
  if input_service:get("toggle_menu") then
    mod:handle_transition("custom_view_close", true, false, "optional_transition_params_string")
  end

  -- Draw ui elements.
  self:draw(dt)
end


--[[
  This method is called when ingame_ui performs a transition which results in this view becoming active.
  'transition_params' is an optional argument. You'll get one if you pass it to `mod:handle_transition(...)`. It will
  also be passed to a transition function.
--]]
function CustomView:on_enter(transition_params)
  mod:echo("Custom View opened. transition_params: %s", transition_params)
  WwiseWorld.trigger_event(self.wwise_world, "Play_hud_button_open")
end


--[[
  Everything is the same as for `CustomView:on_enter(...)`. But this method is called if a transition resulted in
  this view becoming inactive.
  --]]
  function CustomView:on_exit(transition_params)
    mod:echo("Custom View closed. transition_params: %s", transition_params)
    WwiseWorld.trigger_event(self.wwise_world, "Play_hud_button_close")
end


--[[ (OPTIONAL)
  This method is called when ingame_ui wants to destroy your view. It's always called when ingame_ui is destroyed at
  the end of the level and in some exotic situations.
--]]
function CustomView:destroy()
  mod:echo("Custom View destroyed.")
end


--[[
  It is used by ingame_ui to grab view's input service to perform some necessary actions under the hood.
--]]
function CustomView:input_service()
  return self.input_manager:get_service("custom_view")
end


--[[
  Redundant method that is used only in VT1 and was stripped from VT2 recently. It should suspend the view to unsuspend
  it with 'unsuspend' method later, but it's broken for a long time. It is called when countdown or final stats screen
  appear, so there's no point in suspending your view, because the level will be changed and your view will be
  destroyed before you can unsuspend it. Just close your view right away.
--]]
function CustomView:suspend()
  mod:handle_transition("custom_view_close", true)
end

-- #####################################################################################################################
-- ##### Other methods #################################################################################################
-- #####################################################################################################################

function CustomView:create_ui_elements()
  self.scenegraph = UISceneGraph.init_scenegraph(DEFINITIONS.scenegraph_definition)

  self.widgets = {}
  for widget_name, widget_definition in pairs(DEFINITIONS.widgets_definition) do
    self.widgets[widget_name] = UIWidget.init(widget_definition)
  end
end


function CustomView:draw(dt)
  local ui_renderer     = self.ui_renderer
  local render_settings = self.render_settings
  local scenegraph      = self.scenegraph
  local input_service   = self:input_service()

  UIRenderer.begin_pass(ui_renderer, scenegraph, input_service, dt, nil, render_settings)

  for _, widget in pairs(self.widgets) do
    UIRenderer.draw_widget(ui_renderer, widget)
  end

  UIRenderer.end_pass(ui_renderer)
end

-- #####################################################################################################################
-- ##### Commands ######################################################################################################
-- #####################################################################################################################

-- This doesn't have to do anything with Custom View functionality. It's here simply to show how
-- 'view_data.view_settings.blocked_transitions' work. [1-2] transitions can be called in inn, [3] can be called in game
-- Fatshark don't seem to use this in VT2 anymore for their views. So maybe at some point it will be stripped from the
-- game.
local TRANSITIONS = {
  [1] = "custom_view_transition_1_inn_only",
  [2] = "custom_view_transition_2_inn_only",
  [3] = "custom_view_transition_3_ingame_only"
}
mod:command("custom_view_transition", nil, function(transition_number)
  local transition_name = TRANSITIONS[tonumber(transition_number)]
  if transition_name then
    mod:echo("Attempt to call transition: %s", transition_name)
    mod:handle_transition(transition_name, true)
  else
    mod:echo("Wrong transition number.")
  end
end)

-- #####################################################################################################################
-- ##### View Data #####################################################################################################
-- #####################################################################################################################

-- Everything here will be injected into vanilla views handling code, which means that all transitions and views
-- will share the same name pool. So make names unique.
local view_data = {

  -- System view name. The view instance will be stored inside `ingame_ui.views[view_name]`
  view_name = "custom_view",
  view_settings = {

    -- This function should return view instance. It is called when Ingame UI creates other views
    -- (every time a level is loaded). You don't have to recreate a view instance every time this function is called,
    -- like in this example. You can just create it once somewhere outside of this function and just pass new
    -- `ingame_ui_context` to it. The advantage of not recreating your view every time is it will always remember
    -- its state between levels.
    init_view_function = function(ingame_ui_context)
      return CustomView:new(ingame_ui_context)
    end,

    -- Defines when players will be able to use this view (also, when init_view_function will be called)
    active = {
      inn = true, -- in inn/keep
      ingame = true -- during a map run
    },

    -- Forbids certain transitions
    blocked_transitions = {  -- optional
      inn = { -- in the inn/keep
        custom_view_transition_3_ingame_only = true
      },
      ingame = { -- during a map run
        custom_view_transition_1_inn_only = true,
        custom_view_transition_2_inn_only = true
      }
    }
  },

  -- You can define different transitions for your view in here, so later you will be able to call
  -- `mod:handle_transition(transition_name, ...)` for different occasions and also use them for your
  -- 'view_toggle' keybinds.
  view_transitions = {

    -- This transition shows mouse cursor if it's not shown already, blocks all input services except the one
    -- named 'custom_view' and switches current view to 'custom_view'.
    custom_view_open = function(ingame_ui, transition_params)
      if ShowCursorStack.stack_depth == 0 then
        ShowCursorStack.push()
      end

      ingame_ui.input_manager:block_device_except_service("custom_view", "keyboard", 1)
      ingame_ui.input_manager:block_device_except_service("custom_view", "mouse", 1)
      ingame_ui.input_manager:block_device_except_service("custom_view", "gamepad", 1)

      ingame_ui.menu_active = true
      ingame_ui.current_view = "custom_view"
    end,

    -- This transition hides mouse cursor, unblocks all input services and sets current view to nil.
    custom_view_close = function(ingame_ui, transition_params)
      ShowCursorStack.pop()

      ingame_ui.input_manager:device_unblock_all_services("keyboard", 1)
      ingame_ui.input_manager:device_unblock_all_services("mouse", 1)
      ingame_ui.input_manager:device_unblock_all_services("gamepad", 1)

      ingame_ui.menu_active = false
      ingame_ui.current_view = nil
    end,

    -- These transition don't do anything. They are here just to demonstrate `blocked_transitions` functionality.
    custom_view_transition_1_inn_only = function()
      mod:echo("Transition called: custom_view_transition_1_inn_only")
    end,
    custom_view_transition_2_inn_only = function()
      mod:echo("Transition called: custom_view_transition_2_inn_only")
    end,
    custom_view_transition_3_ingame_only = function()
      mod:echo("Transition called: custom_view_transition_3_ingame_only")
    end

    -- For advanced transition examples, examine `/scripts/ui/views/ingame_ui_settings.lua`.
  }
}

mod:register_view(view_data)
