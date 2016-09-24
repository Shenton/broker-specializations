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
L["Add"] = true;
L["Automation"] = true;

L["Cancel"] = true;
L["Close"] = true;
L["Configuration"] = true;

L["Delete"] = true;

L["Enable"] = true;
L["Enabled"] = true;

L["Icon"] = true;

L["Minimap"] = true;

L["None"] = true;

L["Options"] = true;

L["Pet"] = true;
L["Profiles"] = true;
L["PvP"] = true;

L["Rename"] = true;

L["Specializations"] = true;

L["Talents"] = true;
L["Text"] = true;
L["Tooltip"] = true;

-- Common
L["Not available"] = true;
L["Current specialization ( %s )"] = true;
L["Not defined"] = true;
--L["Quick Talents"] = true;

-- Bindings
L["Switch to specialization one"] = true;
L["Switch to specialization two"] = true;
L["Switch to specialization three"] = true;
L["Switch to specialization four"] = true;
L["Dual Specialization switch"] = true;
L["Switch to %s"] = true;

-- DropDown
L["Specializations switch"] = true;
L["Gear set"] = true;
L["Loot specialization"] = true;
L["Other switches"] = true;
L["Talents profiles"] = true;

-- Messages
L["Failed to load configuration, reason: %s."] = true;
L["Cannot switch specialization in combat."] = true;
L["You cannot select the same specialization with Dual Specialization Mode."] = true;
L["You are resting."] = true;
L["You are already buffed with %s."] = true;
L["Cannot switch talents in combat."] = true;
L["A class mismatch was detected, your specializations and talents options have been reset."] = true;
L["The talents profile name is empty."] = true;
L["The talents profile name should contains aplhanumeric characters only."] = true;

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
L["Switch with tooltip"] = true;
L["Enable this to use the tooltip to switch between your specializations."] = true;
L["Informations"] = true;
L["Add some informations to the tooltip."] = true;
L["Loot specialization icon size"] = true;
L["Set the loot specialization icon size on the Data Broker display."] = true;
L["Enable the delete button for the profile %s."] = true;
L["Delete the profile %s.\n\n|cffff3333This is definitive."] = true;
L["Enter the new name of the profile %s. It will enable the button next to this box."] = true;
L["Rename the profile %s to %s."] = true;
L["Chat filter"] = true;
L["With this enabled it will hide the talents learning/unlearning messages from your chat."] = true;
L["Switch talents with tooltip"] = true;
L["Enable this to use the tooltip to switch between your talents profiles."] = true;

-- Tooltip
L["Current specialization"] = true;
L["Current equipment set"] = true;
L["Current loot specialization"] = true;
L["Dual specialization mode is enabled"] = true;
L["Switch to"] = true;
L["With equipment set"] = true;
L["With loot specialization"] = true;
L["Pet specializations switch"] = true;
L["You have %d %s in your bank."] = true;
L["Current talents profile"] = true;
L["Talents profiles switch"] = true;
L["|cFFC79C6ELeft-Click: |cFF33FF99Open the quick talents switch panel.\n|cFFC79C6EShift+Left-Click: |cFF33FF99Open the quick PvP talents switch panel.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."] = true;
L["|cFFC79C6ELeft-Click: |cFF33FF99Dual specialization switch.\n|cFFC79C6EShift+Left-Click: |cFF33FF99Open the quick talents switch panel.\n|cFFC79C6EControl+Left-Click: |cFF33FF99Open the quick PvP talents switch panel.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."] = true;

-- Static popup
L["Enter the name of your talents profile."] = true;
L["The profile %s already exists, please choose another name."] = true;

-- Command help
L["COMMAND_HELP"] = [["Available commands: /brokerspecializations, /brokerspec, /spec, /bs. They are aliases, to prevent compatibility issues.
Without argument it will switch to the defined dual specialization if enabled or it will open the configuration panel.
/bs config, will display the configuration panel.
/bs minimap, will toggle the minimap icon visibility.
/bs followed by a number (1 to 4) will switch to a specialization, to find the number look at the add-on menu the top specialization is 1.
/bs followed by a specialization name will switch to it, this is not case sensitive."]];
end
