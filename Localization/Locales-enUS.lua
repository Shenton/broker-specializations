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

L["Icon"] = true;

L["Minimap"] = true;

L["Text"] = true;

-- Common
L["Not available"] = true;
L["Current specialization ( %s )"] = true;

-- DropDown
L["Specializations switch"] = true;
L["Gear set"] = true;
L["Loot specialization"] = true;
L["Other switches"] = true;

-- Messages
L["Failed to load configuration, reason: %s."] = true;

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

-- Tooltip
L["Current specialization"] = true;
L["Current equipment set"] = true;
L["Current loot specialization"] = true;
L["|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."] = true;
end
