-- WezTerm Configuration
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration
local config = wezterm.config_builder()

-- ============================================
-- APPEARANCE & COLORS
-- ============================================

-- Gruvbox Hard Dark color scheme
config.color_scheme = 'GruvboxDarkHard'

-- Alternative: Define custom Gruvbox Hard Dark if built-in is not exact
config.colors = {
  -- Gruvbox Hard Dark palette
  foreground = '#ebdbb2',
  background = '#1d2021',
  cursor_bg = '#ebdbb2',
  cursor_fg = '#1d2021',
  cursor_border = '#ebdbb2',
  selection_fg = '#1d2021',
  selection_bg = '#ebdbb2',
  
  scrollbar_thumb = '#504945',
  split = '#504945',
  
  ansi = {
    '#1d2021', -- black
    '#cc241d', -- red
    '#98971a', -- green
    '#d79921', -- yellow
    '#458588', -- blue
    '#b16286', -- magenta
    '#689d6a', -- cyan
    '#a89984', -- white
  },
  brights = {
    '#928374', -- bright black
    '#fb4934', -- bright red
    '#b8bb26', -- bright green
    '#fabd2f', -- bright yellow
    '#83a598', -- bright blue
    '#d3869b', -- bright magenta
    '#8ec07c', -- bright cyan
    '#ebdbb2', -- bright white
  },
}

-- ============================================
-- FONT CONFIGURATION
-- ============================================

config.font = wezterm.font('FiraCode Nerd Font Ret', { weight = 'Regular' })
config.font_size = 13.0

-- Enable font ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Font rendering
config.front_end = 'WebGpu'
config.freetype_load_target = 'Normal'
config.freetype_render_target = 'Normal'

-- ============================================
-- WINDOW APPEARANCE
-- ============================================

-- Window padding
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Window background opacity (1.0 = opaque, 0.0 = transparent)
config.window_background_opacity = 0.95

-- macOS-specific window blur
config.macos_window_background_blur = 20

-- Window decorations
config.window_decorations = 'RESIZE'

-- Hide tab bar when there's only one tab
config.hide_tab_bar_if_only_one_tab = true

-- Tab bar appearance
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- ============================================
-- TAB BAR STYLING
-- ============================================

config.colors.tab_bar = {
  background = '#1d2021',
  
  active_tab = {
    bg_color = '#458588',
    fg_color = '#ebdbb2',
    intensity = 'Bold',
  },
  
  inactive_tab = {
    bg_color = '#3c3836',
    fg_color = '#a89984',
  },
  
  inactive_tab_hover = {
    bg_color = '#504945',
    fg_color = '#ebdbb2',
  },
  
  new_tab = {
    bg_color = '#1d2021',
    fg_color = '#a89984',
  },
  
  new_tab_hover = {
    bg_color = '#504945',
    fg_color = '#ebdbb2',
  },
}

-- ============================================
-- SCROLLBAR
-- ============================================

config.enable_scroll_bar = true
config.scrollback_lines = 10000

-- ============================================
-- CURSOR
-- ============================================

config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 700
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ============================================
-- PERFORMANCE
-- ============================================

config.max_fps = 120
config.animation_fps = 60

-- ============================================
-- KEYBINDINGS
-- ============================================

local act = wezterm.action

config.keys = {
  -- Tab navigation
  { key = 't', mods = 'CMD', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CMD', action = act.CloseCurrentTab{ confirm = true } },
  { key = '[', mods = 'CMD', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'CMD', action = act.ActivateTabRelative(1) },
  
  -- Pane splitting
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  { key = 'D', mods = 'CMD|SHIFT', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
  
  -- Pane navigation
  { key = 'h', mods = 'CMD', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CMD', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CMD', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CMD', action = act.ActivatePaneDirection 'Down' },
  
  -- Font size
  { key = '=', mods = 'CMD', action = act.IncreaseFontSize },
  { key = '-', mods = 'CMD', action = act.DecreaseFontSize },
  { key = '0', mods = 'CMD', action = act.ResetFontSize },
  
  -- Copy/Paste
  { key = 'c', mods = 'CMD', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CMD', action = act.PasteFrom 'Clipboard' },
  
  -- Search
  { key = 'f', mods = 'CMD', action = act.Search 'CurrentSelectionOrEmptyString' },
  
  -- Clear scrollback
  { key = 'k', mods = 'CMD|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },
}

-- ============================================
-- MOUSE BINDINGS
-- ============================================

config.mouse_bindings = {
  -- Paste on right-click
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
}

-- ============================================
-- SHELL
-- ============================================

-- Use zsh as default shell
config.default_prog = { '/bin/zsh', '-l' }

-- ============================================
-- MISC SETTINGS
-- ============================================

-- Disable audible bell
config.audible_bell = 'Disabled'

-- Enable CSI u mode for better key handling
config.enable_csi_u_key_encoding = true

-- Automatically reload config
config.automatically_reload_config = true

-- Window close confirmation
config.window_close_confirmation = 'NeverPrompt'

-- Native macOS fullscreen
config.native_macos_fullscreen_mode = true

-- ============================================
-- STATUS BAR (Optional)
-- ============================================

wezterm.on('update-right-status', function(window, pane)
  -- Get the current working directory
  local cwd = pane:get_current_working_dir()
  if cwd then
    cwd = cwd.file_path
    -- Show only the last component
    cwd = cwd:match("([^/]+)$") or cwd
  else
    cwd = ''
  end
  
  -- Get date/time
  local date = wezterm.strftime '%H:%M:%S'
  
  -- Battery info (macOS)
  local battery = ''
  for _, b in ipairs(wezterm.battery_info()) do
    battery = string.format('%.0f%%', b.state_of_charge * 100)
  end
  
  -- Set the status
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#a89984' } },
    { Text = cwd .. ' | ' },
    { Foreground = { Color = '#98971a' } },
    { Text = battery .. ' | ' },
    { Foreground = { Color = '#458588' } },
    { Text = date .. ' ' },
  })
end)

-- ============================================
-- RETURN CONFIG
-- ============================================

return config
