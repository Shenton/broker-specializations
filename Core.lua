--[[-------------------------------------------------------------------------------
    Broker Specializations
    A Data Broker add-on for quickly switching your specialization with gear set and loot specialization
    By: Shenton

    Core.lua
-------------------------------------------------------------------------------]]--

--[[-------------------------------------------------------------------------------
    FindGlobals
-------------------------------------------------------------------------------]]--

-- GLOBALS: PlaySound, DEFAULT_CHAT_FRAME, GetSpecialization, GetNumSpecializations, GetSpecializationInfo
-- GLOBALS: GetLootSpecialization, UseEquipmentSet, SetLootSpecialization, SetSpecialization, GetNumEquipmentSets
-- GLOBALS: GetEquipmentSetInfo, UIDropDownMenu_AddButton, UIDROPDOWNMENU_MENU_VALUE, GetEquipmentSetInfoByName
-- GLOBALS: CloseDropDownMenus, LoadAddOn, INTERFACEOPTIONS_ADDONCATEGORIES, CreateFrame, InterfaceOptions_AddCategory
-- GLOBALS: InterfaceAddOnsList_Update, InterfaceOptionsFrame_OpenToCategory, LibStub, UnitLevel, ToggleDropDownMenu
-- GLOBALS: GameTooltip

--[[-------------------------------------------------------------------------------
    Global to local
-------------------------------------------------------------------------------]]--

local ipairs = ipairs;
local select = select;
local table = table;
local _G = _G;

--[[-------------------------------------------------------------------------------
    Libs & addon global
-------------------------------------------------------------------------------]]--

-- Ace libs (<3)
local A = LibStub("AceAddon-3.0"):NewAddon("Broker_Specializations", "AceConsole-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_Specializations", false);

-- Addon global
_G["BrokerSpecializationsGlobal"] = A;
A.L = L;

-- LibDBIcon
A.icon = LibStub("LibDBIcon-1.0");

--[[-------------------------------------------------------------------------------
    Variables
-------------------------------------------------------------------------------]]--

A.version = GetAddOnMetadata("Broker_Specializations", "Version");

-- Text colors
A.color =
{
    RED = "|cffff3333",
    GREEN = "|cff33ff99",
    BLUE = "|cff3399ff",
    -- WHITE = "|cffffffff",
    -- DRUID = "|cffff7d0a",
    -- DEATHKNIGHT = "|cffc41f3b",
    -- HUNTER = "|cffabd473",
    -- MAGE = "|cff69ccf0",
    -- MONK = "|cff00ff96",
    -- PALADIN = "|cfff58cba",
    PRIEST = "|cffffffff",
    -- ROGUE = "|cfffff569",
    -- SHAMAN = "|cff0070de",
    -- WARLOCK = "|cff9482c9",
    -- WARRIOR = "|cffc79c6e",
    -- POOR = "|cff9d9d9d",
    -- COMMON = "|cffffffff",
    -- UNCOMMON = "|cff1eff00",
    -- RARE = "|cff0070dd",
    -- EPIC = "|cffa335ee",
    -- LEGENDAY = "|cffff8000",
    -- ARTIFACT = "|cffe6cc80",
    -- HEIRLOOM = "|cffe6cc80",
    RESET = "|r",
};

A.questionMark = "Interface\\ICONS\\INV_Misc_QuestionMark";
A.lootBagIcon = "|TInterface\\ICONS\\INV_Misc_Bag_10_Green:16:16:0:0|t";

A.showLootSpecModes =
{
    text = L["Text"],
    icon = L["Icon"],
};

--[[-------------------------------------------------------------------------------
    Common methods
-------------------------------------------------------------------------------]]--

function A:SlashCommand()
end

--- Send a message to the chat frame with the addon name colored
-- @param text String, The message to display
-- @param color Bool, if true will color in red
-- @param silent Bool, if true will not play the whisper sound
function A:Message(text, color, silent)
    if ( color == "debug" ) then
        color = A.color["BLUE"];
    elseif ( color ) then
        color = A.color["RED"];
    else
        color = A.color["GREEN"]
    end

    if ( not silent ) then
        PlaySound("TellMessage");
    end

    DEFAULT_CHAT_FRAME:AddMessage(color..L["Broker Specializations"]..": "..A.color["RESET"]..text);
end

function A:ShowHideMinimap()
    if ( A.db.profile.minimap.hide ) then
        A.icon:Hide("Broker_SpecializationsLDB");
    else
        A.icon:Show("Broker_SpecializationsLDB");
    end
end

--- Called on load, or when switching profile
function A:SetEverything()
    A.currentSpec = GetSpecialization();
    A:SetSpecializationsDatabase();
    A:SetLootSpecOptions();
    A:SetGearSetsDatabase();
    A:UpdateBroker();
end

--[[-------------------------------------------------------------------------------
    Specializations methods
-------------------------------------------------------------------------------]]--

function A:SetSpecializationsDatabase()
    A.specDB = {};
    A.numSpecializations = GetNumSpecializations();

    for i=1,A.numSpecializations do
        local id, name, _, icon = GetSpecializationInfo(i);

        local current = A.currentSpec == i and 1 or nil;

        A.specDB[i] =
        {
            id = id,
            name = name,
            icon = icon,
            current = current,
        };
    end
end

--- Return the current specialization infos
-- @return index, ID, name, icon
function A:GetCurrentSpecInfos()
    for k,v in ipairs(A.specDB) do
        if ( v.current ) then
            return k, v.id, v.name, v.icon;
        end
    end

    return nil;
end

--- Return the specialization infos by ID
-- @return index, ID, name, icon
function A:GetSpecInfosByID(ID)
    for k,v in ipairs(A.specDB) do
        if ( ID == v.id ) then
            return k, v.id, v.name, v.icon;
        end
    end

    return nil;
end

--- Return the current loot specialization infos
-- @return specID, specName, lootSpecText, lootSpecIcon
function A:GetCurrentLootSpecInfos()
    local lootSpec = GetLootSpecialization();

    if ( lootSpec == 0 ) then
        local _, ID, name, icon = A:GetCurrentSpecInfos();

        return ID, name, L["Current specialization ( %s )"]:format(name), icon;
    else
        local _, ID, name, icon = A:GetSpecInfosByID(lootSpec);

        return ID, name, name, icon;
    end
end

--- This is called when switching specialization
-- It will change the gear set and the loot spec
function A:SetGearAndLootAfterSwitch()
    if ( A.inCombat ) then
        A.setGearAndLootAfterSwitchDelayed = 1;
    end

    local _, specID = A:GetCurrentSpecInfos();

    if ( A.db.profile.switchGearWithSpec ) then
        if ( A.db.profile.specOptions[specID].gearSet ) then
            local name = A:GetGearSetInfos(A.db.profile.specOptions[specID].gearSet);
            UseEquipmentSet(name);
        end
    end

    if ( A.db.profile.switchLootWithSpec ) then
        if ( A.db.profile.specOptions[specID].lootSpec ) then
            SetLootSpecialization(A.db.profile.specOptions[specID].lootSpec);
        end
    end
end

--- Will call SetSpecialization() if not in combat
function A:SetSpecialization(specIndex)
    if ( A.inCombat ) then
        A:Message(L["Cannot switch specialization in combat."], 1);
        return;
    end

    SetSpecialization(specIndex);
end

--- Return the specialization index Dual mode should switch to
function A:DualSwitchTo()
    if ( A.numSpecializations > 2 ) then
        if ( A.currentSpec == A.db.profile.dualSpecOne ) then
            return A.db.profile.dualSpecTwo;
        elseif ( A.currentSpec == A.db.profile.dualSpecTwo ) then
            return A.db.profile.dualSpecOne;
        else -- If the current spec is not a defined one, default to the first
            return A.db.profile.dualSpecOne;
        end
    else -- Demon Hunter, easy mode
        if ( A.currentSpec == 1 ) then
            return 2;
        else
            return 1;
        end
    end

    -- Return something in case everything fail
    return 1;
end

--- Return informations about the Dual spec switched to
function A:DualSpecSwitchToInfos()
    local switchToIndex = A:DualSwitchTo();
    local name, icon, gearSet, gearSetIcon, lootName, lootIcon, _;

    -- Those should be always available
    name = A.specDB[switchToIndex].name;
    icon = A.specDB[switchToIndex].icon;

    -- Those are user defined and can be nil
    if ( A.db.profile.specOptions[A.specDB[switchToIndex].id] ) then
        if ( A.db.profile.specOptions[A.specDB[switchToIndex].id].gearSet ) then
            gearSet, gearSetIcon = A:GetGearSetInfos(A.db.profile.specOptions[A.specDB[switchToIndex].id].gearSet);
        else
            gearSet = L["Not defined"];
            gearSetIcon = A.questionMark;
        end

        if ( A.db.profile.specOptions[A.specDB[switchToIndex].id].lootSpec ) then
            if ( A.db.profile.specOptions[A.specDB[switchToIndex].id].lootSpec == 0 ) then
                lootName = L["Current specialization ( %s )"]:format(name);
                lootIcon = icon;
            else
                _, _, lootName, lootIcon = A:GetSpecInfosByID(A.db.profile.specOptions[A.specDB[switchToIndex].id].lootSpec);
            end
        else
            lootName = L["Not defined"];
            lootIcon = A.questionMark;
        end
    else
        gearSet = L["Not defined"];
        gearSetIcon = A.questionMark;
        lootName = L["Not defined"];
        lootIcon = A.questionMark;
    end

    return name, icon, gearSet, gearSetIcon, lootName, lootIcon;
end

--- Switch between two defined spec
function A:DualSwitch()
    A:SetSpecialization(A:DualSwitchTo());
end

--- Called on load, will add spec table to the database option if missing
function A:SetLootSpecOptions()
    local lootSpec = GetLootSpecialization();

    for k,v in ipairs(A.specDB) do
        if ( not A.db.profile.specOptions[v.id] ) then
            A.db.profile.specOptions[v.id] =
            {
                lootSpec = lootSpec,
            };
        end
    end
end

--[[-------------------------------------------------------------------------------
    Gear sets methods
-------------------------------------------------------------------------------]]--

--- Set gear sets database
function A:SetGearSetsDatabase()
    local num = GetNumEquipmentSets();
    local name, icon, id;

    A.gearSetsDB = {};

    if ( num > 0 ) then
        for i=1,num do
            name, icon, id = GetEquipmentSetInfo(i);

            icon = icon or A.questionMark;

            A.gearSetsDB[i] =
            {
                name = name,
                icon = icon,
                id = id,
            };
        end
    end
end

--- Return informations about the current equipped gear set
-- I could have used the gearSetDB table
-- but for that I will have to monitor every modification of the user equipment
-- and those events fire a lot
function A:GetCurrentGearSet()
    local num = GetNumEquipmentSets();
    local name, icon, _, current;

    if ( num > 0 ) then
        for i=1,num do
            name, icon, _, current = GetEquipmentSetInfo(i);

            if ( current ) then
                return name, icon;
            end
        end
    end

    return L["None"], A.questionMark;
end

--- Return informations about a gear set
-- @param gearSet The gear set name or ID
function A:GetGearSetInfos(gearSet)
    if ( type(gearSet) == "number" ) then
        for _,v in ipairs(A.gearSetsDB) do
            if ( gearSet == v.id ) then
                return v.name, v.icon, v.id;
            end
        end
    else
        for _,v in ipairs(A.gearSetsDB) do
            if ( gearSet == v.name ) then
                return v.name, v.icon, v.id;
            end
        end
    end

    return L["None"], A.questionMark;
end

--[[-------------------------------------------------------------------------------
    Data Broker methods
-------------------------------------------------------------------------------]]--

--- Get the Data Broker text
function A:GetDataBrokerText(name)
    local text = "";

    if ( not name ) then
        name = select(3, A:GetCurrentSpecInfos());
    end

    if ( A.db.profile.showSpecName ) then
        text = name;
    end

    if ( A.db.profile.showLootSpec ) then
        local _, specName, _, textIcon = A:GetCurrentLootSpecInfos();

        if ( text ~= "" ) then
            text = text.." ";
        end

        if ( A.db.profile.showLootSpecTextMode ) then
            text = text.."("..(A.db.profile.showLootSpecBagIcon and A.lootBagIcon.." " or "")..specName..")";
        else
            text = text.."(|T"..textIcon..":16:16:0:0|t)";
        end
    end

    return text;
end

--- Update the LDB button and icon
function A:UpdateBroker()
    local _, _, name, icon = A:GetCurrentSpecInfos();

    A.ldb.text = A:GetDataBrokerText(name);
    A.ldb.icon = icon;
end

--[[-------------------------------------------------------------------------------
    Dropdown menu
-------------------------------------------------------------------------------]]--

local function DropdownMenu(self, level)
    if ( not level ) then return; end

    local info = self.info;

    if ( level == 1 ) then
        -- Specializations switch (title)
        info.isTitle = 1;
        info.text = L["Specializations switch"];
        info.notCheckable = 1;
        info.icon = nil;
        info.disabled = nil;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.keepShownOnClick = nil;
        info.hasArrow = nil;
        info.isTitle = nil;
        info.iconOnly = nil;
        info.iconInfo = nil;
        info.notClickable = nil;
        info.notCheckable = 1;

        -- Specializations list (switch)
        for k,v in ipairs(A.specDB) do
            info.text = v.name;
            info.icon = v.icon;
            info.disabled = v.current;
            info.func = function() A:SetSpecialization(k); end;
            UIDropDownMenu_AddButton(info, level);
        end

        -- Separator
        info.text = "";
        info.isTitle = 1;
        info.notClickable = 1;
        info.iconOnly = 1;
        info.icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
        info.iconInfo =
        {
            tCoordLeft = 0,
            tCoordRight = 1,
            tCoordTop = 0,
            tCoordBottom = 1,
            tSizeX = 0,
            tSizeY = 8,
            tFitDropDownSizeX = 1,
        };
        UIDropDownMenu_AddButton(info, level);

        -- Other switches (title)
        info.text = L["Other switches"];
        info.notCheckable = 1;
        info.isTitle = 1;
        info.icon = nil;
        info.disabled = nil;
        info.iconOnly = nil;
        info.iconInfo = nil;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.isTitle = nil;
        info.notClickable = nil;
        info.keepShownOnClick = 1;
        info.hasArrow = 1;

        -- Gear sets switch
        info.text = L["Gear set"];
        info.value = "GEARSET";
        info.disabled = GetNumEquipmentSets() == 0 and 1 or nil;
        UIDropDownMenu_AddButton(info, level);

        -- Loot specialization switch
        info.text = L["Loot specialization"];
        info.value = "LOOTSPEC";
        info.disabled = nil;
        UIDropDownMenu_AddButton(info, level);

        -- Separator
        info.text = "";
        info.value = nil;
        info.isTitle = 1;
        info.notClickable = 1;
        info.hasArrow = nil;
        info.iconOnly = 1;
        info.icon = "Interface\\Common\\UI-TooltipDivider-Transparent";
        info.iconInfo =
        {
            tCoordLeft = 0,
            tCoordRight = 1,
            tCoordTop = 0,
            tCoordBottom = 1,
            tSizeX = 0,
            tSizeY = 8,
            tFitDropDownSizeX = 1,
        };
        UIDropDownMenu_AddButton(info, level);

        -- Configuration panel
        info.text = L["Configuration"];
        info.icon = nil;
        info.keepShownOnClick = nil;
        info.hasArrow = nil;
        info.disabled = nil;
        info.isTitle = nil;
        info.notClickable = nil;
        info.iconOnly = nil;
        info.iconInfo = nil;
        info.func = function() A:OpenConfigPanel(); end;
        UIDropDownMenu_AddButton(info, level);

        -- Close
        info.text = L["Close"];
        info.func = function() CloseDropDownMenus(); end;
        UIDropDownMenu_AddButton(info, level);
    elseif ( level == 2 ) then
        if ( UIDROPDOWNMENU_MENU_VALUE == "GEARSET" ) then
            -- Set options
            info.keepShownOnClick = nil;
            info.hasArrow = nil;
            info.isTitle = nil;
            info.notClickable = nil;
            info.iconOnly = nil;
            info.iconInfo = nil;
            info.value = nil;

            for _,v in ipairs(A.gearSetsDB) do
                info.text = v.name;
                info.icon = v.icon;
                info.padding = 20;
                info.disabled = select(3, GetEquipmentSetInfoByName(v.name));
                info.func = function() UseEquipmentSet(v.name); end;
                UIDropDownMenu_AddButton(info, level);
            end
        elseif ( UIDROPDOWNMENU_MENU_VALUE == "LOOTSPEC" ) then
            -- Set options
            info.keepShownOnClick = nil;
            info.hasArrow = nil;
            info.isTitle = nil;
            info.notClickable = nil;
            info.iconOnly = nil;
            info.iconInfo = nil;
            info.value = nil;
            info.notCheckable = 1;

            local currentLootSpec = GetLootSpecialization();
            local _, ID, name, icon = A:GetCurrentSpecInfos();

            -- Current Spec
            info.text = L["Current specialization ( %s )"]:format(name);
            info.icon = icon;
            info.disabled = currentLootSpec == 0 and 1 or nil;
            info.func = function() SetLootSpecialization(0); end;
            UIDropDownMenu_AddButton(info, level);

            for _,v in ipairs(A.specDB) do
                info.text = v.name;
                info.icon = v.icon;
                info.disabled = currentLootSpec == v.id and 1 or nil;
                info.func = function() SetLootSpecialization(v.id); end;
                UIDropDownMenu_AddButton(info, level);
            end
        end
    end
end

--[[-------------------------------------------------------------------------------
    Ace3 config database
-------------------------------------------------------------------------------]]--

A.aceDefaultDB =
{
    profile =
    {
        showSpecName = 1,
        showLootSpec = 1,
        showLootSpecTextMode = 1,
        showLootSpecBagIcon = 1,
        minimap =
        {
            hide = false
        },
        switchGearWithSpec = nil,
        switchLootWithSpec = nil,
        specOptions = {},
        dualSpecEnabled = nil,
        dualSpecOne = 1,
        dualSpecTwo = 2,
    },
};

--[[-------------------------------------------------------------------------------
    Config panel loader
-------------------------------------------------------------------------------]]--

--- Load config addon and remove config loader from Blizzard options frame
function A:LoadAddonConfig()
    local loaded, reason = LoadAddOn("Broker_SpecializationsConfig");

    if ( loaded ) then
        local categories = INTERFACEOPTIONS_ADDONCATEGORIES;
        local cat;

        for i=1,#categories do
            if ( categories[i].name == L["Broker Specializations configuration loader"] ) then
                cat = i;
            end
        end

        table.remove(categories, cat);
    elseif ( reason ) then
        reason = _G["ADDON_"..reason];
        A:Message(L["Failed to load configuration, reason: %s."]:format(reason), 1, 1);
    end

    return loaded;
end

--- Add to blizzard options frame a temporary category
function A:AddToBlizzTemp()
    local f  = CreateFrame("Frame", "BrokerSpecializationsTempConfigFrame");
    f.name = L["Broker Specializations configuration loader"];

    local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
    b:SetSize(140, 22);
    b:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -20);
    b:SetText(L["Load configuration"]);
    b:SetScript("OnClick", function(self)
        local loaded = A:LoadAddonConfig();

        if ( loaded ) then
            InterfaceAddOnsList_Update();
            InterfaceOptionsFrame_OpenToCategory(A.configurationPanel);
        end
    end);

    InterfaceOptions_AddCategory(f);
end

--- Display configuration panel
-- Load it if needed
function A:OpenConfigPanel()
    if ( A.configurationPanel ) then
        InterfaceOptionsFrame_OpenToCategory(A.configurationPanel);
    else
        local loaded = A:LoadAddonConfig();

        if ( loaded ) then
            InterfaceOptionsFrame_OpenToCategory(A.configurationPanel);
        end
    end
end

--[[-------------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]--

function A:PLAYER_ENTERING_WORLD()
    A:SetEverything();
    A:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function A:PLAYER_SPECIALIZATION_CHANGED()
    local oldSpec = A.currentSpec;

    A.currentSpec = GetSpecialization();
    A:SetSpecializationsDatabase();
    A:UpdateBroker();

    if ( oldSpec ~= A.currentSpec ) then
        A:SetGearAndLootAfterSwitch();
    end
end

function A:PLAYER_LOOT_SPEC_UPDATED()
    A:UpdateBroker();
end

function A:EQUIPMENT_SETS_CHANGED()
    A:SetGearSetsDatabase();
end

function A:PLAYER_REGEN_DISABLED()
    A.inCombat = 1;
end

function A:PLAYER_REGEN_ENABLED()
    if ( A.setGearAndLootAfterSwitchDelayed ) then
        A:SetGearAndLootAfterSwitchDelayed();
        A.setGearAndLootAfterSwitchDelayed = nil;
    end

    A.inCombat = nil;
end

function A:PLAYER_LEVEL_UP(event, level)
    if ( level >= 10) then
        A:Enable();
        A:PLAYER_ENTERING_WORLD();
        A:UnregisterEvent("PLAYER_LEVEL_UP");
    end
end

--[[-------------------------------------------------------------------------------
    Ace3 Init
-------------------------------------------------------------------------------]]--

--- AceAddon callback
-- Called after the addon is fully loaded
function A:OnInitialize()
    A.db = LibStub("AceDB-3.0"):New("brokerSpecializationsDB", A.aceDefaultDB);

    if ( UnitLevel("player") < 10 ) then
        A:SetEnabledState(false);
        A:RegisterEvent("PLAYER_LEVEL_UP");
    end
end

--- AceAddon callback
-- Called during the PLAYER_LOGIN event
function A:OnEnable()
    A:RegisterChatCommand("brokerspec", "SlashCommand");
    A:RegisterChatCommand("spec", "SlashCommand");
    A:RegisterChatCommand("bs", "SlashCommand");

    A.db.RegisterCallback(self, "OnProfileChanged", "SetEverything");
    A.db.RegisterCallback(self, "OnProfileCopied", "SetEverything");
    A.db.RegisterCallback(self, "OnProfileReset", "SetEverything");

    -- DropDownMenu frame & table
    A.menuFrame = CreateFrame("Frame", "Broker_SpecializationsMenuFrame");
    A.menuFrame.displayMode = "MENU";
    A.menuFrame.info = {};

    -- LDB
    A.ldb = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_SpecializationsLDB",
    {
        type = "data source",
        text = L["Not available"],
        label = L["Broker Specializations"],
        icon = A.questionMark,
        tocname = "Broker_Specializations",
        OnClick = function(self, button)
            if (button == "LeftButton") then
                --ShenDump(A.gearSetsDB)
                if ( A.db.profile.dualSpecEnabled ) then
                    A:DualSwitch();
                end
            elseif ( button == "RightButton" ) then
                if ( A.menuFrame.initialize ~= DropdownMenu ) then
                    CloseDropDownMenus();
                    A.menuFrame.initialize = DropdownMenu;
                end
                ToggleDropDownMenu(1, nil, A.menuFrame, self, 0, 0);
                GameTooltip:Hide();
            elseif ( button == "MiddleButton" ) then
                A:OpenConfigPanel();
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddDoubleLine(A.color["PRIEST"]..L["Broker Specializations"], A.color["GREEN"].." v"..A.version);
            tooltip:AddLine(" ");

            local _, _, specName, specIcon = A:GetCurrentSpecInfos();
            local _, _, lootSpecText, lootSpecIcon = A:GetCurrentLootSpecInfos();
            local gearSet, gearIcon = A:GetCurrentGearSet();

            tooltip:AddLine(L["Current specialization: %s"]:format("|T"..specIcon..":16:16:0:0|t"..A.color["PRIEST"]..specName));
            tooltip:AddLine(L["Current equipment set: %s"]:format("|T"..gearIcon..":16:16:0:0|t"..A.color["PRIEST"]..gearSet));
            tooltip:AddLine(L["Current loot specialization: %s"]:format("|T"..lootSpecIcon..":16:16:0:0|t"..A.color["PRIEST"]..lootSpecText));
            tooltip:AddLine(" ");

            if ( A.db.profile.dualSpecEnabled ) then
                specName, specIcon, gearSet, gearIcon, lootSpecText, lootSpecIcon = A:DualSpecSwitchToInfos();

                tooltip:AddLine(A.color["PRIEST"]..L["Dual specialization mode is enabled"]);
                tooltip:AddLine(L["Switch to: %s"]:format("|T"..specIcon..":16:16:0:0|t"..A.color["PRIEST"]..specName));
                tooltip:AddLine(L["With equipment set: %s"]:format("|T"..gearIcon..":16:16:0:0|t"..A.color["PRIEST"]..gearSet));
                tooltip:AddLine(L["And loot specialization: %s"]:format("|T"..lootSpecIcon..":16:16:0:0|t"..A.color["PRIEST"]..lootSpecText));
                tooltip:AddLine(" ");
            end

            if ( A.db.profile.dualSpecEnabled ) then
                tooltip:AddLine(L["|cFFC79C6ELeft-Click: |cFF33FF99Dual specialization switch.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."]);
            else
                tooltip:AddLine(L["|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."]);
            end
        end,
    });

    -- LDBIcon
    A.icon:Register("Broker_SpecializationsLDB", A.ldb, A.db.profile.minimap);
    A.icon:IconCallback("PLAYER_SPECIALIZATION_CHANGED", "Broker_SpecializationsLDB", nil, nil, A.ldb);
    A.icon:IconCallback("PLAYER_ENTERING_WORLD", "Broker_SpecializationsLDB", nil, nil, A.ldb);

    -- Events
    A:RegisterEvent("PLAYER_ENTERING_WORLD");
    A:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
    A:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED");
    A:RegisterEvent("EQUIPMENT_SETS_CHANGED");
    A:RegisterEvent("PLAYER_REGEN_DISABLED");
    A:RegisterEvent("PLAYER_REGEN_ENABLED");

    -- Add the config loader to blizzard addon configuration panel
    A:AddToBlizzTemp();
end
