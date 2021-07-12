local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

-- These are just default values. Use the GUI to change settings.

-- UI
Defaults["ui-scale"] = 0.71111111111111
Defaults["ui-display-welcome"] = true
Defaults["ui-display-dev-tools"] = false
Defaults["ui-display-whats-new"] = true -- NYI

-- Main
Defaults["ui-style"] = "HydraUI"

Defaults["ui-header-font"] = "Roboto"
Defaults["ui-widget-font"] = "Roboto"
Defaults["ui-button-font"] = "Roboto"

Defaults["ui-header-texture"] = "HydraUI 4"
Defaults["ui-widget-texture"] = "HydraUI 4"
Defaults["ui-button-texture"] = "HydraUI 4"

Defaults["ui-header-font-color"] = "FFE6C0"
Defaults["ui-header-texture-color"] = "424242"

Defaults["ui-window-bg-color"] = "424242"
Defaults["ui-window-main-color"] = "2B2B2B"

Defaults["ui-widget-color"] = "FFC44D"
Defaults["ui-widget-bright-color"] = "8E8E8E"
Defaults["ui-widget-bg-color"] = "424242"
Defaults["ui-widget-font-color"] = "FFFFFF"

Defaults["ui-button-font-color"] = "FFC44D"
Defaults["ui-button-texture-color"] = "616161"

Defaults["ui-font-size"] = 12
Defaults["ui-header-font-size"] = 14
Defaults["ui-title-font-size"] = 16

Defaults["ui-highlight-texture"] = "Blank" -- TBI
Defaults["ui-highlight-color"] = "FFFFFF" -- TBI

Defaults["ui-picker-palette"] = "Default"
--Defaults["ui-picker-format"] = "Hex"
--Defaults["ui-picker-show-texture"] = true

Defaults["gui-enable-fade"] = false
Defaults["gui-faded-alpha"] = 20
Defaults["gui-hide-in-combat"] = true

-- Custom colors; The commented colors are 10% darker, I like it better on lighter textures
Defaults["color-death-knight"] = "C41F3B" -- 7F222D
Defaults["color-demon-hunter"] = "A330C9" -- 922BB4
Defaults["color-druid"] = "FF7D0A" -- E56F08
Defaults["color-hunter"] = "ABD473" -- 98BD66
Defaults["color-mage"] = "40C7EB" -- 38B2D2
Defaults["color-monk"] = "00FF96" -- 00E586
Defaults["color-paladin"] = "F58CBA" -- DB7DA7
Defaults["color-priest"] = "FFFFFF" -- E5E5E5
Defaults["color-rogue"] = "FFF569" -- E5DB5D
Defaults["color-shaman"] = "0070DE" -- 0046C6
Defaults["color-warlock"] = "8787ED" -- 6969B8
Defaults["color-warrior"] = "C79C6E" -- B28B62

-- Power Types
Defaults["color-mana"] = "477CB2" -- 0000FF for the default mana color
Defaults["color-rage"] = "E53935" -- FF0000 ^
Defaults["color-energy"] = "FFEB3B" -- FFFF00 ^
Defaults["color-focus"] = "FF7F3F"

-- Reactions
Defaults["color-reaction-1"] = "BF4400" -- Hated
Defaults["color-reaction-2"] = "BF4400" -- Hostile
Defaults["color-reaction-3"] = "BF4400" -- Unfriendly
Defaults["color-reaction-4"] = "E5B200" -- Neutral
Defaults["color-reaction-5"] = "009919" -- Friendly
Defaults["color-reaction-6"] = "009919" -- Honored
Defaults["color-reaction-7"] = "009919" -- Revered
Defaults["color-reaction-8"] = "009919" -- Exalted

-- Zone PVP Types
Defaults["color-sanctuary"] = "68CCEF"
Defaults["color-arena"] = "FF1919"
Defaults["color-hostile"] = "FF1919"
Defaults["color-combat"] = "FF1919"
Defaults["color-friendly"] = "19FF19"
Defaults["color-contested"] = "FFB200"
Defaults["color-other"] = "FFECC1"

-- Debuff Types
Defaults["color-curse"] = "9900FF"
Defaults["color-disease"] = "996600"
Defaults["color-magic"] = "3399FF"
Defaults["color-poison"] = "009900"
Defaults["color-none"] = "000000"

-- Happiness
Defaults["color-happiness-1"] = "C62828" -- "8BC94D"
Defaults["color-happiness-2"] = "FBC02D" -- "FFC44D"
Defaults["color-happiness-3"] = "4CAF50" -- "EE4D4D"

-- Combo Points
Defaults["color-combo-1"] = "FF6666"
Defaults["color-combo-2"] = "FFB266"
Defaults["color-combo-3"] = "FFFF66"
Defaults["color-combo-4"] = "B2FF66"
Defaults["color-combo-5"] = "66FF66"

-- Casting
Defaults["color-casting-start"] = "4C9900"
Defaults["color-casting-stopped"] = "F39C12"
Defaults["color-casting-interrupted"] = "D35400"
Defaults["color-casting-uninterruptible"] = "FF4444"
Defaults["color-casting-success"] = "4C9900" -- NYI

-- Mirror Timers
Defaults["color-mirror-exhaustion"] = "FFE500"
Defaults["color-mirror-breath"] = "007FFF"
Defaults["color-mirror-death"] = "FFB200"
Defaults["color-mirror-feign-death"] = "FFB200"

-- Other
Defaults["color-tapped"] = "A6A6A6"
Defaults["color-disconnected"] = "A6A6A6"

-- Chat
Defaults["chat-enable"] = true
Defaults["chat-bg-opacity"] = 70
Defaults["chat-enable-url-links"] = true
Defaults["chat-enable-discord-links"] = true
Defaults["chat-enable-email-links"] = true
Defaults["chat-enable-friend-links"] = true
Defaults["chat-font"] = "PT Sans"
Defaults["chat-font-size"] = 12
Defaults["chat-font-flags"] = ""
Defaults["chat-tab-font"] = "Roboto"
Defaults["chat-tab-font-size"] = 12
Defaults["chat-tab-font-flags"] = ""
Defaults["chat-tab-font-color"] = "FFFFFF"
Defaults["chat-tab-font-color-mouseover"] = "FFCE54"
Defaults["chat-frame-width"] = 392
Defaults["chat-frame-height"] = 104
Defaults["chat-enable-fading"] = false
Defaults["chat-fade-time"] = 15
Defaults["chat-link-tooltip"] = true
Defaults["chat-shorten-channels"] = true

-- Chat Bubbles
Defaults["chat-bubbles-enable"] = true
Defaults["chat-bubbles-opacity"] = 100
Defaults["chat-bubbles-font"] = "PT Sans"
Defaults["chat-bubbles-font-size"] = 14
Defaults["chat-bubbles-font-flags"] = ""

-- Experience
Defaults["experience-enable"] = true
Defaults["experience-width"] = 310
Defaults["experience-height"] = 18
Defaults["experience-mouseover"] = false
Defaults["experience-mouseover-opacity"] = 0
Defaults["experience-display-level"] = false
Defaults["experience-display-progress"] = true
Defaults["experience-display-percent"] = true
Defaults["experience-display-rested-value"] = true
Defaults["experience-show-tooltip"] = true
Defaults["experience-animate"] = true
Defaults["experience-progress-visibility"] = "ALWAYS"
Defaults["experience-percent-visibility"] = "ALWAYS"
Defaults["experience-bar-color"] = "4C9900" -- 1AE045
Defaults["experience-rested-color"] = "00B4FF"

-- Reputation
Defaults["reputation-enable"] = true
Defaults["reputation-width"] = 310
Defaults["reputation-height"] = 18
Defaults["reputation-mouseover"] = false
Defaults["reputation-mouseover-opacity"] = 0
Defaults["reputation-display-progress"] = true
Defaults["reputation-display-percent"] = true
Defaults["reputation-show-tooltip"] = true
Defaults["reputation-animate"] = true
Defaults["reputation-progress-visibility"] = "ALWAYS"
Defaults["reputation-percent-visibility"] = "ALWAYS"

-- Auras
Defaults["auras-enable"] = true
Defaults["auras-size"] = 30
Defaults["auras-spacing"] = 2
Defaults["auras-row-spacing"] = 16
Defaults["auras-per-row"] = 12

-- Minimap
Defaults["minimap-enable"] = true
Defaults["minimap-size"] = 140
Defaults["minimap-show-top"] = true
Defaults["minimap-show-bottom"] = true
Defaults["minimap-buttons-enable"] = true
Defaults["minimap-buttons-size"] = 22
Defaults["minimap-buttons-spacing"] = 2
Defaults["minimap-buttons-perrow"] = 5

-- Cooldowns
Defaults["cooldowns-enable"] = true

-- Right Window
Defaults["right-window-enable"] = true
Defaults["right-window-size"] = "SINGLE"
Defaults["right-window-width"] = 392
Defaults["right-window-height"] = 128
Defaults["right-window-opacity"] = 70

-- Bags Frame
Defaults["bags-frame-visiblity"] = "SHOW"
Defaults["bags-frame-opacity"] = 40
Defaults["bags-frame-max"] = 100
Defaults["bags-frame-size"] = 32

-- Auto Repair
Defaults["auto-repair-enable"] = true
Defaults["auto-repair-report"] = true

-- Auto Vendor
Defaults["auto-vendor-enable"] = true
Defaults["auto-vendor-report"] = true

-- Dismount
Defaults["dismount-enable"] = true

-- Tooltips
Defaults["tooltips-enable"] = true
Defaults["tooltips-on-cursor"] = false
Defaults["tooltips-show-id"] = false
Defaults["tooltips-display-realm"] = true
Defaults["tooltips-display-title"] = true
Defaults["tooltips-display-rank"] = false
Defaults["tooltips-font"] = "Roboto"
Defaults["tooltips-font-size"] = 12
Defaults["tooltips-font-flags"] = ""
Defaults["tooltips-hide-on-unit"] = "NEVER"
Defaults["tooltips-hide-on-item"] = "NEVER"
Defaults["tooltips-hide-on-action"] = "NEVER"
Defaults["tooltips-health-bar-height"] = 15
Defaults["tooltips-show-health-text"] = true
Defaults["tooltips-show-target"] = true
Defaults["tooltips-cursor-anchor"] = "ANCHOR_CURSOR"
Defaults["tooltips-cursor-anchor-x"] = 0
Defaults["tooltips-cursor-anchor-y"] = 8
Defaults["tooltips-show-price"] = true
Defaults["tooltips-show-health"] = true

-- Bags
Defaults["bags-loot-from-left"] = false

-- Quests
Defaults["quest-watch-font"] = "Roboto"
Defaults["quest-watch-font-size"] = 12
Defaults["quest-watch-font-flags"] = ""
Defaults["quest-watch-font-flags"] = ""