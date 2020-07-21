local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

-- These are just default values. Use the GUI to change settings.

-- UI
Defaults["ui-scale"] = 0.71111111111111
Defaults["ui-display-welcome"] = true
Defaults["ui-display-dev-tools"] = false
Defaults["ui-display-whats-new"] = true -- NYI

-- Main
Defaults["ui-style"] = "vUI"

Defaults["ui-header-font"] = "Roboto"
Defaults["ui-widget-font"] = "Roboto"
Defaults["ui-button-font"] = "Roboto"

Defaults["ui-header-texture"] = "vUI 4"
Defaults["ui-widget-texture"] = "vUI 4"
Defaults["ui-button-texture"] = "vUI 4"

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
Defaults["color-fuel"] = "008C7F"
Defaults["color-insanity"] = "6600CC"
Defaults["color-holy-power"] = "F2E599"
Defaults["color-fury"] = "C842FC"
Defaults["color-pain"] = "FF9C00"
Defaults["color-runic-power"] = "00D1FF"
Defaults["color-chi"] = "B5FFEA"
Defaults["color-maelstrom"] = "007FFF"
Defaults["color-lunar-power"] = "4C84E5"
Defaults["color-arcane-charges"] = "1E88E5"
Defaults["color-ammo-slot"] = "CC9900"
Defaults["color-soul-shards"] = "D35832" -- 7F518C for the default soul shards color
Defaults["color-runes"] = "9905CC" -- 7F7F7F ^
Defaults["color-combo-points"] = "FFF468"

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

-- Combo Points
Defaults["color-combo-1"] = "FF6666"
Defaults["color-combo-2"] = "FFB266"
Defaults["color-combo-3"] = "FFFF66"
Defaults["color-combo-4"] = "B2FF66"
Defaults["color-combo-5"] = "66FF66"
Defaults["color-combo-6"] = "66FF66"

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

-- Action Bars
Defaults["ab-enable"] = true

Defaults["ab-show-hotkey"] = true
Defaults["ab-show-count"] = true
Defaults["ab-show-macro"] = true

Defaults["ab-font"] = "PT Sans"
Defaults["ab-font-size"] = 12
Defaults["ab-cd-size"] = 18
Defaults["ab-font-flags"] = ""

Defaults["ab-bar1-enable"] = true
Defaults["ab-bar1-hover"] = false
Defaults["ab-bar1-button-size"] = 32
Defaults["ab-bar1-button-gap"] = 2
Defaults["ab-bar1-button-max"] = 12
Defaults["ab-bar1-per-row"] = 12

Defaults["ab-bar2-enable"] = true
Defaults["ab-bar2-hover"] = false
Defaults["ab-bar2-button-size"] = 32
Defaults["ab-bar2-button-gap"] = 2
Defaults["ab-bar2-button-max"] = 12
Defaults["ab-bar2-per-row"] = 12

Defaults["ab-bar3-enable"] = true
Defaults["ab-bar3-hover"] = false
Defaults["ab-bar3-button-size"] = 32
Defaults["ab-bar3-button-gap"] = 2
Defaults["ab-bar3-button-max"] = 12
Defaults["ab-bar3-per-row"] = 12

Defaults["ab-bar4-enable"] = true
Defaults["ab-bar4-hover"] = false
Defaults["ab-bar4-button-size"] = 32
Defaults["ab-bar4-button-gap"] = 2
Defaults["ab-bar4-button-max"] = 12
Defaults["ab-bar4-per-row"] = 1

Defaults["ab-bar5-enable"] = true
Defaults["ab-bar5-hover"] = false
Defaults["ab-bar5-button-size"] = 32
Defaults["ab-bar5-button-gap"] = 2
Defaults["ab-bar5-button-max"] = 12
Defaults["ab-bar5-per-row"] = 1

Defaults["ab-pet-enable"] = true
Defaults["ab-pet-hover"] = false
Defaults["ab-pet-button-size"] = 32
Defaults["ab-pet-button-gap"] = 2
Defaults["ab-pet-per-row"] = 1

Defaults["ab-stance-enable"] = true
Defaults["ab-stance-hover"] = false
Defaults["ab-stance-button-size"] = 32
Defaults["ab-stance-button-gap"] = 2
Defaults["ab-stance-per-row"] = 12

Defaults["ab-extra-button-size"] = 60

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
Defaults["reputation-display-progress"] = true
Defaults["reputation-display-percent"] = true
Defaults["reputation-show-tooltip"] = true
Defaults["reputation-animate"] = true
Defaults["reputation-progress-visibility"] = "ALWAYS"
Defaults["reputation-percent-visibility"] = "ALWAYS"

-- Azerite
Defaults["azerite-enable"] = true
Defaults["azerite-width"] = 310
Defaults["azerite-height"] = 18
Defaults["azerite-display-progress"] = true
Defaults["azerite-display-percent"] = true
Defaults["azerite-show-tooltip"] = true
Defaults["azerite-animate"] = true
Defaults["azerite-progress-visibility"] = "ALWAYS"
Defaults["azerite-percent-visibility"] = "ALWAYS"

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
Defaults["minimap-show-tracking"] = true
Defaults["minimap-buttons-enable"] = true
Defaults["minimap-buttons-size"] = 22
Defaults["minimap-buttons-spacing"] = 2
Defaults["minimap-buttons-perrow"] = 5

-- Cooldowns
Defaults["cooldowns-enable"] = true

-- Meter Container
Defaults["meters-container-show"] = true

-- Micro Buttons
Defaults["micro-buttons-visiblity"] = "SHOW"
Defaults["micro-buttons-opacity"] = 40

-- Bags Frame
Defaults["bags-frame-visiblity"] = "SHOW"
Defaults["bags-frame-opacity"] = 40

-- Auto Repair
Defaults["auto-repair-enable"] = true
Defaults["auto-repair-use-guild"] = true
Defaults["auto-repair-report"] = true

-- Auto Vendor
Defaults["auto-vendor-enable"] = true
Defaults["auto-vendor-report"] = true

-- Announcements
Defaults["announcements-enable"] = true
Defaults["announcements-channel"] = "GROUP"

-- Unitframes
Defaults["unitframes-enable"] = true
Defaults["unitframes-only-player-debuffs"] = false
Defaults["unitframes-show-player-buffs"] = true
Defaults["unitframes-show-druid-mana"] = true

-- Unitframes: Player
Defaults["unitframes-player-width"] = 238
Defaults["unitframes-player-health-height"] = 28
Defaults["unitframes-player-health-reverse"] = false
Defaults["unitframes-player-health-color"] = "CLASS"
Defaults["unitframes-player-health-smooth"] = true
Defaults["unitframes-player-power-height"] = 15
Defaults["unitframes-player-power-reverse"] = false
Defaults["unitframes-player-power-color"] = "POWER"
Defaults["unitframes-player-power-smooth"] = true
Defaults["unitframes-player-health-left"] = ""
Defaults["unitframes-player-health-right"] = "[HealthPercent]"
Defaults["unitframes-player-power-left"] = "[HealthValues]"
Defaults["unitframes-player-power-right"] = "[PowerValues]"
Defaults["unitframes-player-cast-width"] = 250
Defaults["unitframes-player-cast-height"] = 24
Defaults["unitframes-player-enable-castbar"] = true

-- Unitframes: Target
Defaults["unitframes-target-width"] = 238
Defaults["unitframes-target-health-height"] = 28
Defaults["unitframes-target-health-reverse"] = false
Defaults["unitframes-target-health-color"] = "CLASS"
Defaults["unitframes-target-health-smooth"] = true
Defaults["unitframes-target-power-height"] = 15
Defaults["unitframes-target-power-reverse"] = false
Defaults["unitframes-target-power-color"] = "POWER"
Defaults["unitframes-target-power-smooth"] = true
Defaults["unitframes-target-health-left"] = "[LevelColor][Level][Plus]|r [Name30]"
Defaults["unitframes-target-health-right"] = "[HealthPercent]"
Defaults["unitframes-target-power-left"] = "[HealthValues]"
Defaults["unitframes-target-power-right"] = "[PowerValues]"
Defaults["unitframes-target-cast-width"] = 250
Defaults["unitframes-target-cast-height"] = 22
Defaults["unitframes-target-enable-castbar"] = true

-- Unitframes: Target of Target
Defaults["unitframes-targettarget-width"] = 110
Defaults["unitframes-targettarget-health-height"] = 26 
Defaults["unitframes-targettarget-health-reverse"] = false
Defaults["unitframes-targettarget-health-color"] = "CLASS"
Defaults["unitframes-targettarget-health-smooth"] = true
Defaults["unitframes-targettarget-enable-power"] = true
Defaults["unitframes-targettarget-power-height"] = 3
Defaults["unitframes-targettarget-power-reverse"] = false
Defaults["unitframes-targettarget-power-color"] = "POWER"
Defaults["unitframes-targettarget-power-smooth"] = true
Defaults["unitframes-targettarget-health-left"] = "[Name10]"
Defaults["unitframes-targettarget-health-right"] = "[HealthPercent]"

-- Unitframes: Pet
Defaults["unitframes-pet-width"] = 110
Defaults["unitframes-pet-health-height"] = 26
Defaults["unitframes-pet-health-reverse"] = false
Defaults["unitframes-pet-health-color"] = "CLASS"
Defaults["unitframes-pet-health-smooth"] = true
Defaults["unitframes-pet-enable-power"] = true
Defaults["unitframes-pet-power-height"] = 3
Defaults["unitframes-pet-power-reverse"] = false
Defaults["unitframes-pet-power-color"] = "POWER"
Defaults["unitframes-pet-power-smooth"] = true
Defaults["unitframes-pet-health-left"] = "[Name10]"
Defaults["unitframes-pet-health-right"] = "[HealthPercent]"

-- Focus
Defaults["unitframes-focus-width"] = 200
Defaults["unitframes-focus-health-height"] = 26
Defaults["unitframes-focus-health-reverse"] = false
Defaults["unitframes-focus-health-color"] = "CLASS"
Defaults["unitframes-focus-health-smooth"] = true
Defaults["unitframes-focus-power-height"] = 6
Defaults["unitframes-focus-power-reverse"] = false
Defaults["unitframes-focus-power-color"] = "POWER"
Defaults["unitframes-focus-power-smooth"] = true
Defaults["unitframes-focus-health-left"] = "[Name10]"
Defaults["unitframes-focus-health-right"] = "[HealthPercent]"

-- Unitframes: Bosses
Defaults["unitframes-boss-enable"] = true
Defaults["unitframes-boss-width"] = 238
Defaults["unitframes-boss-health-height"] = 28
Defaults["unitframes-boss-health-reverse"] = false
Defaults["unitframes-boss-health-color"] = "CLASS"
Defaults["unitframes-boss-health-smooth"] = true
Defaults["unitframes-boss-power-height"] = 16
Defaults["unitframes-boss-power-reverse"] = false
Defaults["unitframes-boss-power-color"] = "POWER"
Defaults["unitframes-boss-power-smooth"] = true

-- Unitframes: Party
Defaults["party-enable"] = true
Defaults["party-width"] = 78
Defaults["party-show-debuffs"] = true
Defaults["party-show-role"] = true
Defaults["party-show-aurawatch"] = true
Defaults["party-in-range"] = 100
Defaults["party-out-of-range"] = 50
Defaults["party-health-height"] = 40
Defaults["party-health-reverse"] = false
Defaults["party-health-color"] = "CLASS"
Defaults["party-health-orientation"] = "HORIZONTAL"
Defaults["party-health-smooth"] = true
Defaults["party-power-height"] = 6
Defaults["party-power-reverse"] = false
Defaults["party-power-color"] = "POWER"
Defaults["party-power-smooth"] = true
Defaults["party-x-offset"] = 2
Defaults["party-y-offset"] = 0
Defaults["party-point"] = "LEFT"

-- Unitframes: Party Pets
Defaults["party-pets-enable"] = true
Defaults["party-pets-width"] = 78
Defaults["party-pets-health-height"] = 22
Defaults["party-pets-health-reverse"] = false
Defaults["party-pets-health-color"] = "CLASS"
Defaults["party-pets-health-orientation"] = "HORIZONTAL"
Defaults["party-pets-health-smooth"] = true
Defaults["party-pets-power-height"] = 0 -- NYI

-- Unitframes: Raid
Defaults["raid-enable"] = true
Defaults["raid-width"] = 78
Defaults["raid-in-range"] = 100
Defaults["raid-out-of-range"] = 50
Defaults["raid-health-height"] = 22
Defaults["raid-health-reverse"] = false
Defaults["raid-health-color"] = "CLASS"
Defaults["raid-health-orientation"] = "HORIZONTAL"
Defaults["raid-health-smooth"] = true
Defaults["raid-power-height"] = 2
Defaults["raid-power-reverse"] = false
Defaults["raid-power-color"] = "POWER"
Defaults["raid-power-orientation"] = "HORIZONTAL"
Defaults["raid-power-smooth"] = true
Defaults["raid-x-offset"] = 2
Defaults["raid-y-offset"] = -2
Defaults["raid-units-per-column"] = 5
Defaults["raid-max-columns"] = 8
Defaults["raid-column-spacing"] = 2
Defaults["raid-point"] = "LEFT"
Defaults["raid-column-anchor"] = "TOP"
Defaults["raid-sorting-method"] = "GROUP"

-- Name Plates
Defaults["nameplates-enable"] = true
Defaults["nameplates-width"] = 134
Defaults["nameplates-height"] = 14
Defaults["nameplates-font"] = "Roboto"
Defaults["nameplates-font-size"] = 12
Defaults["nameplates-font-flags"] = ""
Defaults["nameplates-cc-health"] = false
Defaults["nameplates-top-text"] = ""
Defaults["nameplates-topleft-text"] = "[LevelColor][Level][Plus]|r [Name20]"
Defaults["nameplates-topright-text"] = ""
Defaults["nameplates-bottom-text"] = ""
Defaults["nameplates-bottomleft-text"] = ""
Defaults["nameplates-bottomright-text"] = "[HealthPercent]"
Defaults["nameplates-display-debuffs"] = true
Defaults["nameplates-only-player-debuffs"] = true
Defaults["nameplates-health-color"] = "CLASS"
Defaults["nameplates-health-smooth"] = true
Defaults["nameplates-enable-elite-indicator"] = true
Defaults["nameplates-enable-target-indicator"] = true
Defaults["nameplates-target-indicator-size"] = "SMALL"
Defaults["nameplates-enable-castbar"] = true
Defaults["nameplates-castbar-height"] = 12
Defaults["nameplates-castbar-enable-icon"] = true

-- Tooltips
Defaults["tooltips-enable"] = true
Defaults["tooltips-on-cursor"] = false
Defaults["tooltips-cursor-anchor"] = "RIGHT"
Defaults["tooltips-cursor-anchor-offset-x"] = 0
Defaults["tooltips-cursor-anchor-offset-y"] = 8
Defaults["tooltips-show-id"] = false
Defaults["tooltips-display-realm"] = true
Defaults["tooltips-display-title"] = true
Defaults["tooltips-font"] = "Roboto"
Defaults["tooltips-font-size"] = 12
Defaults["tooltips-font-flags"] = ""
Defaults["tooltips-hide-on-unit"] = "NEVER"
Defaults["tooltips-hide-on-item"] = "NEVER"
Defaults["tooltips-hide-on-action"] = "NEVER"
Defaults["tooltips-health-bar-height"] = 15
Defaults["tooltips-show-health-text"] = true
Defaults["tooltips-show-target"] = true

-- Bags
Defaults["bags-loot-from-left"] = false

-- Data Texts
Defaults["data-text-font"] = "Roboto"
Defaults["data-text-font-size"] = 12
Defaults["data-text-font-flags"] = ""
Defaults["data-text-label-color"] = "FFFFFF"
Defaults["data-text-value-color"] = "FFC44D"
Defaults["data-text-chat-left"] = "Gold"
Defaults["data-text-chat-middle"] = "Crit"
Defaults["data-text-chat-right"] = "Durability"
Defaults["data-text-minimap-top"] = "Location"
Defaults["data-text-minimap-bottom"] = "Time - Local"
Defaults["data-text-enable-tooltips"] = true
Defaults["data-text-hover-tooltips"] = true
Defaults["data-text-24-hour"] = false

-- Objective Tracker
Defaults["tracker-enable"] = true
Defaults["tracker-enable-backdrop"] = false
Defaults["tracker-backdrop-opacity"] = 70
Defaults["tracker-height"] = 400
Defaults["tracker-font"] = "Roboto"
Defaults["tracker-font-size"] = 12
Defaults["tracker-font-flags"] = ""
Defaults["tracker-header-font"] = "Roboto"
Defaults["tracker-header-font-size"] = 12
Defaults["tracker-header-font-flags"] = ""
Defaults["tracker-module-font"] = "Roboto"
Defaults["tracker-module-font-size"] = 12
Defaults["tracker-module-font-flags"] = ""
Defaults["tracker-module-font-color"] = "FFE6C0"
Defaults["tracker-color-normal"] = "FAFAFA"
Defaults["tracker-color-normal-highlight"] = "FFFFFF"
Defaults["tracker-color-header"] = "FFB54F"
Defaults["tracker-color-header-highlight"] = "FFFFFF"
Defaults["tracker-color-failed"] = "D32F2F"
Defaults["tracker-color-failed-highlight"] = "F44336"
Defaults["tracker-color-timeleft"] = "D32F2F"
Defaults["tracker-color-timeleft-highlight"] = "F44336"
Defaults["tracker-color-complete"] = "A0A0A0"