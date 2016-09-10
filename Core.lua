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
-- GLOBALS: GameTooltip, BINDING_HEADER_BROKERSPECIALIZATIONS, BINDING_NAME_BROKERSPECIALIZATIONSONE
-- GLOBALS: BINDING_NAME_BROKERSPECIALIZATIONSTWO, BINDING_NAME_BROKERSPECIALIZATIONSTHREE
-- GLOBALS: BINDING_NAME_BROKERSPECIALIZATIONSFOUR, BINDING_NAME_BROKERSPECIALIZATIONSDUAL

--[[-------------------------------------------------------------------------------
    Global to local
-------------------------------------------------------------------------------]]--

local ipairs = ipairs;
local select = select;
local table = table;
local _G = _G;
local tonumber = tonumber;
local string = string;
local type = type;

--[[-------------------------------------------------------------------------------
    Libs & addon global
-------------------------------------------------------------------------------]]--

-- Libs (<3)
local A = LibStub("AceAddon-3.0"):NewAddon("Broker_Specializations", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_Specializations", false);
A.icon = LibStub("LibDBIcon-1.0");
A.tip = LibStub('LibQTip-1.0');

-- Addon global
_G["BrokerSpecializationsGlobal"] = A;
A.L = L;

--[[-------------------------------------------------------------------------------
    Bindings names
-------------------------------------------------------------------------------]]--

BINDING_HEADER_BROKERSPECIALIZATIONS = L["Broker Specializations"];
BINDING_NAME_BROKERSPECIALIZATIONSONE = L["Switch to specialization one"];
BINDING_NAME_BROKERSPECIALIZATIONSTWO = L["Switch to specialization two"];
BINDING_NAME_BROKERSPECIALIZATIONSTHREE = L["Switch to specialization three"];
BINDING_NAME_BROKERSPECIALIZATIONSFOUR = L["Switch to specialization four"];
BINDING_NAME_BROKERSPECIALIZATIONSDUAL = L["Dual Specialization switch"];

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
    POOR = "|cff9d9d9d",
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

A.talentsSwitchItems =
{
    { -- wod
        141640, -- tome-of-the-clear-mind - require lvl 15, not usable above 100 - solo version
        141641, -- codex-of-the-clear-mind - require lvl 15, not usable above 100 - group version
    },
    { -- legion
        141446, -- tome-of-the-tranquil-mind - require lvl 15, no level restriction after that - solo version
        141333, -- codex-of-the-tranquil-mind - require lvl 15, no level restriction after that - group version
    },
};

A.talentsSwitchBuffs =
{
    -- wod <= 100
    227563, -- tome-of-the-clear-mind
    227565, -- codex-of-the-clear-mind
    -- legion > 100
    227041, -- tome-of-the-tranquil-mind
    226234, -- codex-of-the-tranquil-mind
};

--[[-------------------------------------------------------------------------------
    Common methods
-------------------------------------------------------------------------------]]--

function A:SlashCommand(arg, ...)
    if ( arg == "" ) then
        if ( A.db.profile.dualSpecEnabled ) then
            A:DualSwitch();
        else
            A:OpenConfigPanel();
        end
    elseif ( arg == "config" ) then
        A:OpenConfigPanel();
    elseif ( arg == "minimap" ) then
        A.db.profile.minimap.hide = not A.db.profile.minimap.hide;
        A:ShowHideMinimap();
    elseif ( arg == "help" ) then
        A:Message(L["COMMAND_HELP"]);
    else
        if ( tonumber(arg) ) then -- A number was provided, this is a spec switch
            arg = tonumber(arg);

            if ( A.specDB[arg] ) then -- The spec exists
                A:SetSpecialization(arg);
                return; -- break
            end
        end

        -- Searching for spec name
        arg = string.lower(arg);

        for k,v in ipairs(A.specDB) do
            if ( arg == string.lower(v.name) ) then -- Got a match
                A:SetSpecialization(k);
                return; -- break
            end
        end

        -- Display the commands help
        A:Message(L["COMMAND_HELP"]);
    end
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

function A:SetBindingsNames()
    BINDING_NAME_BROKERSPECIALIZATIONSONE = A.specDB[1] and L["Switch to %s"]:format(A.specDB[1].name) or L["Switch to specialization one"];
    BINDING_NAME_BROKERSPECIALIZATIONSTWO = A.specDB[2] and L["Switch to %s"]:format(A.specDB[2].name) or L["Switch to specialization two"];
    BINDING_NAME_BROKERSPECIALIZATIONSTHREE = A.specDB[3] and L["Switch to %s"]:format(A.specDB[3].name) or L["Switch to specialization three"];
    BINDING_NAME_BROKERSPECIALIZATIONSFOUR = A.specDB[4] and L["Switch to %s"]:format(A.specDB[4].name) or L["Switch to specialization four"];
end

--- "Smart" anchor, frame is clamped to screen, we just need TOP or BOTTOM
-- @return point and relativePoint
function A:SmartAnchor()
    local s = UIParent:GetEffectiveScale();
    local _, py = UIParent:GetCenter();
    local _, y = GetCursorPosition();

    py = py * s;

    if ( y > py ) then
        return "TOP", "BOTTOM";
    else
        return "BOTTOM", "TOP";
    end
end

--- Called on load, or when switching profile
function A:SetEverything()
    A.playerClass = select(2, UnitClass("player"));

    A.currentSpec = GetSpecialization();
    A:SetSpecializationsDatabase();

    if ( playerClass == "HUNTER" ) then
        A.currentPetSpec = GetSpecialization(false, true);
        A:SetPetSpecializationsDatabase();
    end

    A:SetBindingsNames()
    A:SetLootSpecOptions();
    A:SetGearSetsDatabase();
    A:UpdateBroker();
    A:SetTalentsSwitchBuffsNames();
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

function A:SetPetSpecializationsDatabase()
    A.petSpecDB = {};
    A.numSpecializations = GetNumSpecializations(false, true);

    for i=1,A.numSpecializations do
        local id, name, _, icon = GetSpecializationInfo(i, false, true);

        local current = A.currentPetSpec == i and 1 or nil;

        A.petSpecDB[i] =
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
function A:SetSpecialization(specIndex, isPet)
    if ( A.inCombat ) then
        A:Message(L["Cannot switch specialization in combat."], 1);
        return;
    end

    SetSpecialization(specIndex, isPet);
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
    if ( not A.db.profile.dualSpecEnabled ) then return; end

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
    Talents frame
-------------------------------------------------------------------------------]]--

function A:TalentsFrameOnLoad(self)
    --self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
    --self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
    ButtonFrameTemplate_HidePortrait(self);
    self.TitleText:SetText(L["Talents"]);
    self.closeButton:SetText(L["Close"]);
end

function A:TalentsFrameOnShow(self)
    PlaySound("igCharacterInfoOpen");
    A:TalentsFrameUpdate();
end

function A:TalentsFrameUpdate()
    local talentGroup = GetActiveSpecGroup(false);
    local tiers = GetMaxTalentTier();

    -- Talents
    for i=1,7 do
        if ( i <= tiers ) then -- Player got the level for this tier, setting and showing buttons
            local _, selectedTalent = GetTalentTierInfo(i, talentGroup, false);

            for j=1,3 do
                local talentID, name, texture, selected, available = GetTalentInfo(i, j, talentGroup, false);
                local button = _G["BrokerSpecializationsTalentsFrameTalentButtonRow"..i.."Col"..j];

                button.talentGroup = talentGroupG;
                button:SetID(talentID);
                SetItemButtonTexture(button, texture);

                if ( selectedTalent == 0 ) then
                    button.icon:SetDesaturated(false);
                else
                    if ( selected ) then
                        button.icon:SetDesaturated(false);
                    else
                        button.icon:SetDesaturated(true);
                    end
                end

                button:Show();
            end
        else -- Player do not got the level for this tier, resetting and hiding buttons
            for j=1,3 do
                local button = _G["BrokerSpecializationsTalentsFrameTalentButtonRow"..i.."Col"..j];

                button.talentGroup = nil;
                button:SetID(0); -- SetID require a value
                SetItemButtonTexture(button, "Interface\\ICONS\\INV_Misc_QuestionMark");
                button.icon:SetDesaturated(false);
                button:Hide();
            end
        end
    end

    -- Talents switch items
    -- No need to check the minimum level requirement (which is 15)
    -- If we are here the player got some talents to choose from
    local playerLevel = UnitLevel("player");
    local solo, group, count, countBank;
    local switchItemsHeight = 0;
    local button1 = _G["BrokerSpecializationsTalentsFrameItemButton1"];
    local button2 = _G["BrokerSpecializationsTalentsFrameItemButton2"];

    for k,v in ipairs(A.talentsSwitchItems) do
        for kk,vv in ipairs(v) do
            count = GetItemCount(vv, false);
            countBank = GetItemCount(vv, true);

            if ( (count > 0 or (count == 0 and countBank > 0)) -- We got this item, or we got it in the bank
            and ((playerLevel <= 100 and k == 1) or (playerLevel > 100 and k == 2)) -- This check if we are using the correct table
            -- This check if we already got a solo or group item, or if we got 0 and >0 in the bank from the last pass
            and (((not solo and kk == 1) or (solo == 0 and kk == 1)) or ((not group and kk == 2) or (group == 0 and kk == 2))) ) then
                local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(vv);

                button = _G["BrokerSpecializationsTalentsFrameItemButton"..kk];
                button:SetID(vv);
                button.icon:SetTexture(itemTexture);
                button.count:SetText(count);
                button.countNum = count;
                button.countBank = countBank;

                -- Doing this to inform the player he got some in his bank
                -- The display is handled by the xml
                if ( count == 0 ) then
                    button:SetAttribute("item", nil);
                    button.icon:SetDesaturated(true);
                else
                    button:SetAttribute("item", itemName);
                    button.icon:SetDesaturated(false);
                end

                if ( kk == 1 ) then
                    solo = count;
                else
                    group = count;
                end
            end
        end
    end

    -- Buttons visibility and anchors
    if ( solo and group ) then
        button1:ClearAllPoints();
        button1:SetPoint("BOTTOM", BrokerSpecializationsTalentsFrameBottomCloseButton, "TOP", -21, 6);
        button1:Show();

        button2:ClearAllPoints();
        button2:SetPoint("LEFT", button1, "RIGHT", 6, 0);
        button2:Show();

        switchItemsHeight = 42;
    elseif ( solo ) then
        button1:ClearAllPoints();
        button1:SetPoint("BOTTOM", BrokerSpecializationsTalentsFrameBottomCloseButton, "TOP", 0, 6);
        button1:Show();

        button2:Hide();
        button2:SetAttribute("item", nil);

        switchItemsHeight = 42;
    elseif ( group ) then
        button1:Hide();
        button1:SetAttribute("item", nil);

        button2:ClearAllPoints();
        button2:SetPoint("BOTTOM", BrokerSpecializationsTalentsFrameBottomCloseButton, "TOP", 0, 6);
        button2:Show();

        switchItemsHeight = 42;
    else
        button1:Hide();
        button1:SetAttribute("item", nil);

        button2:Hide();
        button2:SetAttribute("item", nil);
    end

    -- Set frame size
    -- Title height offset + close button height + his offset + offset = 28 + 22 + 4 + 6 = 60 - This is static
    -- Now add talent button height + offset * tiers = 36 + 6 * x - This is variable
    -- And if we got some switch items add the height of a button + offset = 36 + 6 = 42 - This is defined above
    A.talentsFrame:SetHeight(60 + (42 * tiers) + switchItemsHeight);
end

function A:TalentButtonOnClick(button)
    if ( A.inCombat ) then return; end

    if ( LearnTalent(button:GetID()) ) then
        A:TalentsFrameUpdate();
    end
end

function A:ItemButtonPostClick(button)
    A:TalentsFrameUpdate();
end

function A:SetTalentsSwitchBuffsNames()
    if ( not A.talentsSwitchBuffsNames ) then
        A.talentsSwitchBuffsNames = {};

        for _,v in ipairs(A.talentsSwitchBuffs) do
            local name = GetSpellInfo(v);

            if ( name ) then
                A.talentsSwitchBuffsNames[#A.talentsSwitchBuffsNames+1] = name;
            else
                A:ScheduleTimer("SetTalentsSwitchBuffsNames", 0.5);
            end

        end
    end
end

function A:SetSwitchItemsTooltip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
    GameTooltip:SetItemByID(frame:GetID());

    -- If the player is resting, display a message on the tooltip
    if ( IsResting() ) then
        GameTooltip:AddLine(A.color["RED"]..L["You are resting."]);
    end

    -- Check if the player is already buffed
    local index = UnitLevel("player") > 100 and 3 or 1; -- Start at index 3 if the player is above 100

    for i=index,#A.talentsSwitchBuffsNames do
        if ( UnitBuff("player", A.talentsSwitchBuffsNames[i]) ) then
            GameTooltip:AddLine(A.color["RED"]..L["You are already buffed with %s."]:format(A.talentsSwitchBuffsNames[i]));
            break;
        end
    end

    -- Needed to update the tooltip height
    GameTooltip:Show();
end

function A:TalentsFrameShowOrHide(relativeTo)
    if ( A.talentsFrame:IsShown() ) then
        A.talentsFrame:Hide();
    else
        if ( GetMaxTalentTier() == 0 ) then return; end

        local point, relativePoint = A:SmartAnchor();
        A.talentsFrame:ClearAllPoints();
        A.talentsFrame:SetPoint(point, relativeTo, relativePoint, 0, 0);
        CloseDropDownMenus();
        A:HideTooltip();
        A.talentsFrame:Show();
    end
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
            info.padding = 20;
            info.disabled = v.current;
            info.func = function() A:SetSpecialization(k); end;
            UIDropDownMenu_AddButton(info, level);
        end

        -- Pet specializations (menu)
        if ( A.playerClass == "HUNTER") then
            info.text = L["Pet"];
            info.value = "HUNTERPET";
            -- Set options
            info.isTitle = nil;
            info.notClickable = nil;
            info.icon = nil;
            info.keepShownOnClick = 1;
            info.hasArrow = 1;
            UIDropDownMenu_AddButton(info, level);
        end

        -- Separator
        info.text = "";
        info.isTitle = 1;
        info.notClickable = 1;
        info.iconOnly = 1;
        info.hasArrow = nil;
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

        -- Gear sets switch (menu)
        info.text = L["Gear set"];
        info.value = "GEARSET";
        info.disabled = GetNumEquipmentSets() == 0 and 1 or nil;
        UIDropDownMenu_AddButton(info, level);

        -- Loot specialization switch (menu)
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
                info.padding = 20;
                info.disabled = currentLootSpec == v.id and 1 or nil;
                info.func = function() SetLootSpecialization(v.id); end;
                UIDropDownMenu_AddButton(info, level);
            end
        elseif ( UIDROPDOWNMENU_MENU_VALUE == "HUNTERPET" ) then
            for k,v in ipairs(A.petSpecDB) do
                info.text = v.name;
                info.icon = v.icon;
                info.padding = 20;
                info.disabled = v.current;
                info.func = function() A:SetSpecialization(k, true); end;
                UIDropDownMenu_AddButton(info, level);
            end
        end
    end
end

--[[-------------------------------------------------------------------------------
    Tooltips
-------------------------------------------------------------------------------]]--

function A:HideTooltip()
    if ( A.tip:IsAcquired("BrokerSpecializationsTooltip") ) then
        local tooltip = A.tip:Acquire("BrokerSpecializationsTooltip");

        tooltip:Release();
        tooltip = nil;
    end
end

function A:RefreshTooltip()
    if ( A.tip:IsAcquired("BrokerSpecializationsTooltip") ) then
        local tooltip = A.tip:Acquire("BrokerSpecializationsTooltip");

        tooltip:Release();
        A:Tooltip(tooltip.anchorFrame);
    end
end

function A:Tooltip(anchorFrame)
    local tooltip = A.tip:Acquire("BrokerSpecializationsTooltip", 2, "LEFT", "LEFT");
    local line;
    tooltip.anchorFrame = anchorFrame;
    anchorFrame.tooltip = tooltip;

    tooltip:AddHeader(A.color["PRIEST"]..L["Broker Specializations"]);
    tooltip:SetCell(1, 2, A.color["GREEN"].." v"..A.version, nil, "RIGHT");
    tooltip:AddLine(" ");

    if ( A.db.profile.switchTooltip ) then
        line = tooltip:AddLine();
        tooltip:SetCell(line, 1, A.color["GREEN"]..L["Specializations switch"], nil, nil, 2);

        for k,v in ipairs(A.specDB) do
            line = tooltip:AddLine();

            if ( v.current ) then
                tooltip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["POOR"]..v.name, nil, nil, 2);
            else
                tooltip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["PRIEST"]..v.name, nil, nil, 2);
                tooltip:SetCellScript(line, 1, "OnMouseUp", function()
                    A:SetSpecialization(k);
                    A:HideTooltip();
                end);
            end
        end

        if ( A.playerClass == "HUNTER" ) then
            tooltip:AddLine(" ");
            line = tooltip:AddLine();
            tooltip:SetCell(line, 1, A.color["GREEN"]..L["Pet specializations switch"], nil, nil, 2);

            for k,v in ipairs(A.petSpecDB) do
                line = tooltip:AddLine();

                if ( v.current ) then
                    tooltip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["POOR"]..v.name, nil, nil, 2);
                else
                    tooltip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["PRIEST"]..v.name, nil, nil, 2);
                    tooltip:SetCellScript(line, 1, "OnMouseUp", function()
                        A:SetSpecialization(k, true);
                        A:HideTooltip();
                    end);
                end
            end
        end

        tooltip:AddLine(" ");
    end

    if ( not A.db.profile.switchTooltip or (A.db.profile.tooltipInfos and A.db.profile.switchTooltip) ) then
        local _, _, specName, specIcon = A:GetCurrentSpecInfos();
        local _, _, lootSpecText, lootSpecIcon = A:GetCurrentLootSpecInfos();
        local gearSet, gearIcon = A:GetCurrentGearSet();

        line = tooltip:AddLine();
        tooltip:SetCell(line, 1, A.color["GREEN"]..L["Informations"], nil, nil, 2);
        tooltip:AddLine(L["Current specialization"], "|T"..specIcon..":16:16:0:0|t"..A.color["PRIEST"]..specName);
        tooltip:AddLine(L["Current equipment set"], "|T"..gearIcon..":16:16:0:0|t"..A.color["PRIEST"]..gearSet);
        tooltip:AddLine(L["Current loot specialization"], "|T"..lootSpecIcon..":16:16:0:0|t"..A.color["PRIEST"]..lootSpecText);
        tooltip:AddLine(" ");

        if ( A.db.profile.dualSpecEnabled ) then
            specName, specIcon, gearSet, gearIcon, lootSpecText, lootSpecIcon = A:DualSpecSwitchToInfos();

            line = tooltip:AddLine();
            tooltip:SetCell(line, 1, A.color["GREEN"]..L["Dual specialization mode is enabled"], nil, nil, 2);
            tooltip:AddLine(L["Switch to"], "|T"..specIcon..":16:16:0:0|t"..A.color["PRIEST"]..specName);
            tooltip:AddLine(L["With equipment set"], "|T"..gearIcon..":16:16:0:0|t"..A.color["PRIEST"]..gearSet);
            tooltip:AddLine(L["And loot specialization"], "|T"..lootSpecIcon..":16:16:0:0|t"..A.color["PRIEST"]..lootSpecText);
            tooltip:AddLine(" ");
        end
    end

    if ( A.db.profile.dualSpecEnabled ) then
        line = tooltip:AddLine();
        tooltip:SetCell(line, 1, L["|cFFC79C6ELeft-Click: |cFF33FF99Dual specialization switch.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."], nil, nil, 2);
    else
        line = tooltip:AddLine();
        tooltip:SetCell(line, 1, L["|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."], nil, nil, 2);
    end

    tooltip:SmartAnchorTo(anchorFrame);
    tooltip:Show();
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
        talentFrameEnabled = 1,
        switchTooltip = nil,
        tooltipInfos = 1,
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
    A:RefreshTooltip();

    if ( A.talentsFrame:IsShown() ) then
        A:TalentsFrameUpdate();
    end

    if ( oldSpec ~= A.currentSpec ) then
        A:SetGearAndLootAfterSwitch();
    end
end

function A:PET_SPECIALIZATION_CHANGED()
    A.currentPetSpec = GetSpecialization(false, true);
    A:SetPetSpecializationsDatabase();
    A:RefreshTooltip();
end

function A:PLAYER_LOOT_SPEC_UPDATED()
    A:UpdateBroker();
end

function A:EQUIPMENT_SETS_CHANGED()
    A:SetGearSetsDatabase();
end

function A:PLAYER_REGEN_DISABLED()
    A.inCombat = 1;

    if ( A.talentsFrame:IsShown() ) then
        A.talentsFrame:Hide();
    end
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

function A:BAG_UPDATE()
    if ( A.talentsFrame:IsShown() ) then
        A:TalentsFrameUpdate();
    end
end

--[[-------------------------------------------------------------------------------
    Ace3 Init
-------------------------------------------------------------------------------]]--

--- AceAddon callback
-- Called after the addon is fully loaded
function A:OnInitialize()
    A.db = LibStub("AceDB-3.0"):New("brokerSpecializationsDB", A.aceDefaultDB);
    A.talentsFrame = BrokerSpecializationsTalentsFrame;

    if ( UnitLevel("player") < 10 ) then
        A:SetEnabledState(false);
        A:RegisterEvent("PLAYER_LEVEL_UP");
    end
end

--- AceAddon callback
-- Called during the PLAYER_LOGIN event
function A:OnEnable()
    A:RegisterChatCommand("brokerspecializations", "SlashCommand");
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
                if ( A.db.profile.dualSpecEnabled ) then
                    if ( IsShiftKeyDown() and A.db.profile.talentFrameEnabled ) then
                        A:TalentsFrameShowOrHide(self);
                    else
                        A:DualSwitch();
                    end
                elseif ( A.db.profile.talentFrameEnabled ) then
                    A:TalentsFrameShowOrHide(self);
                end
            elseif ( button == "RightButton" ) then
                if ( A.menuFrame.initialize ~= DropdownMenu ) then
                    CloseDropDownMenus();
                    A.menuFrame.initialize = DropdownMenu;
                end
                ToggleDropDownMenu(1, nil, A.menuFrame, self, 0, 0);
                A:HideTooltip();
            elseif ( button == "MiddleButton" ) then
                A:OpenConfigPanel();
            end
        end,
        OnEnter = function(self)
            if ( A.talentsFrame:IsShown() ) then return; end

            A:Tooltip(self);
        end,
        OnLeave = function(self)
            if ( A.db.profile.switchTooltip ) then return; end

            A.tip:Release(self.tooltip);
            self.tooltip = nil;
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
    A:RegisterEvent("BAG_UPDATE");
    A:RegisterEvent("PET_SPECIALIZATION_CHANGED");

    -- Add the config loader to blizzard addon configuration panel
    A:AddToBlizzTemp();
end
