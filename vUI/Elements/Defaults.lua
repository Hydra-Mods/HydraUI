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

-- Auto Repair
Defaults["auto-repair-enable"] = true
Defaults["auto-repair-use-guild"] = true
Defaults["auto-repair-report"] = true

-- Auto Vendor
Defaults["auto-vendor-enable"] = true
Defaults["auto-vendor-report"] = true

-- Announcements
Defaults["announcements-enable"] = true
Defaults["announcements-channel"] = "SELF"

-- Unitframes
Defaults["unitframes-enable"] = true
Defaults["unitframes-only-player-debuffs"] = false
Defaults["unitframes-show-player-buffs"] = true
Defaults["unitframes-show-target-buffs"] = true
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
Defaults["unitframes-player-enable-power"] = true
Defaults["unitframes-player-enable-resource"] = true
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