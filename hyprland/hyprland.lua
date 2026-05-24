-- Hyprland 0.55 Lua config — matches waybar-theme workspace layout
-- Place at ~/.config/hypr/hyprland.lua or include from your main config
--
-- Persistent workspaces (waybar):
--   DP-1:     1, 2, 3
--   HDMI-A-1: 4, 5, 6
--   DP-2:     7, 8, 9

local hypr = hypr

-----------------------
-- Monitor setup
-----------------------
-- Adjust names/resolutions to your hardware.
hypr.monitor({
    "DP-1,3840x2160,0x0,1",
    "HDMI-A-1,2560x1440,3840x0,1",
    "DP-2,2560x1440,6400x0,1",
})

-----------------------
-- Workspace rules
-----------------------
-- Bind persistent workspaces to the monitors that waybar expects.
for _, rule in ipairs({
    { workspace = 1,  monitor = "DP-1" },
    { workspace = 2,  monitor = "DP-1" },
    { workspace = 3,  monitor = "DP-1" },
    { workspace = 4,  monitor = "HDMI-A-1" },
    { workspace = 5,  monitor = "HDMI-A-1" },
    { workspace = 6,  monitor = "HDMI-A-1" },
    { workspace = 7,  monitor = "DP-2" },
    { workspace = 8,  monitor = "DP-2" },
    { workspace = 9,  monitor = "DP-2" },
}) do
    hypr.workspacerule({
        workspace = tostring(rule.workspace),
        monitor  = rule.monitor,
        persistent = true,
    })
end
