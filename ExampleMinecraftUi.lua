Photon Custom UI Library

A lightweight, render-based GUI library designed for the Photon API. This library allows for the creation of draggable panels, toggleable modules, and various setting widgets (sliders, color pickers, keybinds) using a simple table structure.

Integration

To use this library, simply copy the ui_lib.lua code into your script. The library is driven by a global panels table which you must configure to add your features.

Configuration Structure

The interface is built by defining the panels table. Each entry in the table represents a window.

Panel Properties

name (string): The title of the window.

x, y (number): Initial screen coordinates.

w (number): Width of the window.

color (color object): The header color (e.g., colors.cat_combat).

expanded (bool): Whether the panel is open by default.

modules (table): A list of features inside this panel.

Module Properties

name (string): The name of the feature.

type (string): Usually "bool" for a toggle.

value (bool): The current state (enabled/disabled).

tooltip (optional string): Text shown when hovering.

settings (optional table): A list of sub-settings for this module.

Setting Types

Inside the settings table of a module, you can add:

Slider

type = "slider"

min, max (number): Range.

value (number): Current value.

Color Picker

type = "color"

h, s, v, a (number): HSVA values (0-1).

open (bool): Menu state (usually false).

Checkbox (Boolean)

type = "bool"

value (bool): State.

Keybind

type = "keybind"

value (number): Key code (0 for none).

mode (string): "Toggle", "Hold", "Always".

Label

type = "label"

value (string): Text to display.

Example Usage

Paste this code at the bottom of the ui_lib.lua file (or after the library code) to initialize the menu with example features.

-- Example Configuration
-- Paste this after the UI Library code

panels = {
    { name = "Combat", x = 20, y = 50, w = 180, color = colors.cat_combat, expanded = true, modules = {
        { name = "KillAura", type = "bool", value = false, tooltip = "Auto hit", settings = {
            { name = "Mode", type = "label", value = "Switch" },
            { name = "Range", type = "slider", min = 1, max = 6, value = 3 },
            { name = "Bind", type = "keybind", value = 0, mode = "Toggle" }
        }},
        { name = "Velocity", type = "bool", value = false },
        { name = "Criticals", type = "bool", value = false }
    }},
    { name = "Render", x = 220, y = 50, w = 180, color = colors.cat_render, expanded = true, modules = {
        { name = "ESP", type = "bool", value = true, settings_open = true, settings = {
            { name = "Box", type = "bool", value = true },
            { name = "Color", type = "color", h = 0.05, s = 0.8, v = 1, a = 1, open = false }
        }},
        { name = "Tracers", type = "bool", value = false },
        { name = "Nametags", type = "bool", value = false }
    }},
    { name = "Player", x = 420, y = 50, w = 180, color = colors.cat_player, expanded = true, modules = {
        { name = "AutoSprint", type = "bool", value = false },
        { name = "NoFall", type = "bool", value = false },
        { name = "FastEat", type = "bool", value = false }
    }},
    { name = "Movement", x = 620, y = 50, w = 180, color = colors.cat_move, expanded = true, modules = {
        { name = "Fly", type = "bool", value = false, settings = {
            { name = "Speed", type = "slider", min = 1, max = 10, value = 5 }
        }},
        { name = "Speed", type = "bool", value = false, settings = {
            { name = "Power", type = "slider", min = 1, max = 5, value = 2 }
        }},
        { name = "Step", type = "bool", value = false },
        { name = "LongJump", type = "bool", value = false }
    }}
}


How to use in code

To check if a feature is enabled in your logic loop:

-- Accessing the state of KillAura
if panels[1].modules[1].value == true then
    -- KillAura logic here
end
