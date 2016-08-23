--[[-------------------------------------------------------------------------------
    Broker Specializations
    A Data Broker add-on for quickly switching your specialization with gear set and loot specialization
    By: Shenton

    Localization-enUS.lua
-------------------------------------------------------------------------------]]--

local L = LibStub("AceLocale-3.0"):NewLocale("Broker_Specializations", "enUS", true);

if L then
-- Addon name
L["Broker Specializations"] = true;
-- Words
L["Automation"] = true;

L["Close"] = true;
L["Configuration"] = true;

L["Enabled"] = true;

L["Icon"] = true;

L["Minimap"] = true;

L["None"] = true;

L["Text"] = true;

-- Common
L["Not available"] = true;
L["Current specialization ( %s )"] = true;
L["Not defined"] = true;

-- DropDown
L["Specializations switch"] = true;
L["Gear set"] = true;
L["Loot specialization"] = true;
L["Other switches"] = true;

-- Messages
L["Failed to load configuration, reason: %s."] = true;
L["Cannot switch specialization in combat."] = true;
L["You cannot select the same specialization with Dual Specialization Mode."] = true;

-- Config
L["Broker Specializations configuration loader"] = true;
L["Load configuration"] = true;
L["Options"] = true;
L["Data Broker"] = true;
L["Display name"] = true;
L["Display the current specialization name on the Data Broker display."] = true;
L["Display loot specialization"] = true;
L["Display the current loot specialization on the Data Broker display."] = true;
L["Display loot bag"] = true;
L["When loot specialization display mode is text, display a bag icon before it."] = true;
L["Loot specialization mode"] = true;
L["Select in which mode the loot specialization will be displayed. Text or icon."] = true;
L["Switch gear with specialization"] = true;
L["Switch to the selected equipment set when switching a specialization. Set this within the specialization tab."] = true;
L["Switch loot specialization with specialization"] = true;
L["Switch to the selected loot specialization when switching a specialization. Set this within the specialization tab."] = true;
L["Select this to use gear set %s when switching to specialization %s."] = true;
L["Select this to use current specialization for loot specialization when switching to specialization %s."] = true;
L["Select this to use %s for loot specialization when switching to specialization %s."] = true;
L["Display minimap button"] = true;
L["Display the minimaps icon. Uncheck this to hide it."] = true;
L["Dual Specialization"] = true;
L["Enable the Dual Specialization mode. Switch between two defined specializations with a single click."] = true;
L["Specialization One"] = true;
L["Select the first specialization for the Dual mode."] = true;
L["Specialization Two"] = true;
L["Select the second specialization for the Dual mode."] = true;

-- Tooltip
L["Current specialization: %s"] = true;
L["Current equipment set: %s"] = true;
L["Current loot specialization: %s"] = true;
L["Dual specialization mode is enabled"] = true;
L["Switch to: %s"] = true;
L["With equipment set: %s"] = true;
L["And loot specialization: %s"] = true;
L["|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."] = true;
L["|cFFC79C6ELeft-Click: |cFF33FF99Dual specialization switch.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."] = true;
end
