--[[-------------------------------------------------------------------------------
    Broker Specializations
    A Data Broker add-on for quickly switching your specialization with gear set and loot specialization
    By: Shenton

    Core.lua
-------------------------------------------------------------------------------]]--

--[[-------------------------------------------------------------------------------
    Upvalues
-------------------------------------------------------------------------------]]--

local ipairs = ipairs;
local select = select;
local table = table;
local _G = _G;
local tonumber = tonumber;
local string = string;
local type = type;
local pairs = pairs;
local tostring = tostring;
local time = time;

-- GLOBALS: PlaySound, DEFAULT_CHAT_FRAME, GetSpecialization, GetNumSpecializations, GetSpecializationInfo
-- GLOBALS: GetLootSpecialization, SetLootSpecialization, SetSpecialization, C_EquipmentSet, C_PvP
-- GLOBALS: UIDropDownMenu_AddButton, UIDROPDOWNMENU_MENU_VALUE, InterfaceOptions_AddCategory, SortEquipmentSetIDs
-- GLOBALS: CloseDropDownMenus, LoadAddOn, INTERFACEOPTIONS_ADDONCATEGORIES, CreateFrame, SOUNDKIT, tContains
-- GLOBALS: InterfaceAddOnsList_Update, InterfaceOptionsFrame_OpenToCategory, LibStub, UnitLevel, ToggleDropDownMenu
-- GLOBALS: GameTooltip, BINDING_HEADER_BROKERSPECIALIZATIONS, BINDING_NAME_BROKERSPECIALIZATIONSONE
-- GLOBALS: BINDING_NAME_BROKERSPECIALIZATIONSTWO, BINDING_NAME_BROKERSPECIALIZATIONSTHREE, GetTalentInfoByID
-- GLOBALS: BINDING_NAME_BROKERSPECIALIZATIONSFOUR, BINDING_NAME_BROKERSPECIALIZATIONSDUAL, UIParent
-- GLOBALS: GetCursorPosition, IsShiftKeyDown, BrokerSpecializationsTalentsFrame, ChatFrame_RemoveMessageEventFilter
-- GLOBALS: ChatFrame_AddMessageEventFilter, ERR_SPELL_UNLEARNED_S, ERR_LEARN_ABILITY_S, ERR_LEARN_PASSIVE_S
-- GLOBALS: ERR_LEARN_SPELL_S, ERR_PET_LEARN_ABILITY_S, ERR_PET_LEARN_SPELL_S, ERR_PET_SPELL_UNLEARNED_S
-- GLOBALS: GetActiveSpecGroup, StaticPopup_Show, LearnPvpTalent, GetTalentInfo, LearnTalent, UnitBuff, IsResting
-- GLOBALS: GetMaxTalentTier, GetItemInfo, GetSpellInfo, GetItemCount, SetItemButtonTexture, C_SpecializationInfo
-- GLOBALS: UISpecialFrames, ButtonFrameTemplate_HidePortrait, UnitFactionGroup, UnitClass, IsControlKeyDown
-- GLOBALS: ButtonFrameTemplate_HideAttic, GetPvpTalentInfoByID, SHOW_TALENT_LEVEL, SHOW_PVP_TALENT_LEVEL

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
A.lootBagIcon = "Interface\\ICONS\\INV_Misc_Bag_10_Green";
A.profileIcon = "Interface\\ICONS\\Ability_Marksmanship"; -- Achievement_BG_returnXflags_def_WSG
A.gearSetIcon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle";

A.showLootSpecModes =
{
    text = L["Text"],
    icon = L["Icon"],
};

A.talentsSwitchItems =
{
    tome =
    {
        -- wod
        141640, -- tome-of-the-clear-mind - require lvl 15, not usable above 100 - solo version
        -- legion
        141446, -- tome-of-the-tranquil-mind - require lvl 15, no level restriction after that - solo version
        -- bfa
        153647, -- tome-of-the-quiet-mind - require lvl 15, no level restriction after that - solo version
    },
    codex =
    {
        -- wod
        141641, -- codex-of-the-clear-mind - require lvl 15, not usable above 100 - group version
        -- legion
        141333, -- codex-of-the-tranquil-mind - require lvl 15, no level restriction after that - group version
        -- bfa
        153646, -- codex-of-the-quiet-mind - require lvl 15, no level restriction after that - group version
    },
};

A.talentsSwitchBuffs =
{
    -- wod
    227563, -- tome-of-the-clear-mind
    227565, -- codex-of-the-clear-mind
    -- legion
    227041, -- tome-of-the-tranquil-mind
    226234, -- codex-of-the-tranquil-mind
    -- bfa
    256231, -- tome-of-the-quiet-mind
    256230, -- codex-of-the-quiet-mind
};

A.iconsFileDataToFilePath =
{
    [135932] = "Interface/Icons/Spell_Holy_MagicalSentry", -- ID: 62 - Class: MAGE - Spec: Arcane
    [135810] = "Interface/Icons/Spell_Fire_FireBolt02", -- ID: 63 - Class: MAGE - Spec: Fire
    [135846] = "Interface/Icons/Spell_Frost_FrostBolt02", -- ID: 64 - Class: MAGE - Spec: Frost
    [135920] = "Interface/Icons/Spell_Holy_HolyBolt", -- ID: 65 - Class: PALADIN - Spec: Holy
    [236264] = "Interface/Icons/Ability_Paladin_ShieldoftheTemplar", -- ID: 66 - Class: PALADIN - Spec: Protection
    [135873] = "Interface/Icons/Spell_Holy_AuraOfLight", -- ID: 70 - Class: PALADIN - Spec: Retribution
    [132355] = "Interface/Icons/Ability_Warrior_SavageBlow", -- ID: 71 - Class: WARRIOR - Spec: Arms
    [132347] = "Interface/Icons/Ability_Warrior_InnerRage", -- ID: 72 - Class: WARRIOR - Spec: Fury
    [132341] = "Interface/Icons/Ability_Warrior_DefensiveStance", -- ID: 73 - Class: WARRIOR - Spec: Protection
    [236159] = "Interface/Icons/Ability_Druid_KingoftheJungle", -- ID: 74 - Class: Unavailable - Spec: Ferocity
    [132150] = "Interface/Icons/Ability_EyeOfTheOwl", -- ID: 79 - Class: Unavailable - Spec: Cunning
    [132121] = "Interface/Icons/ABILITY_DRUID_DEMORALIZINGROAR", -- ID: 81 - Class: Unavailable - Spec: Tenacity
    [136096] = "Interface/Icons/Spell_Nature_StarFall", -- ID: 102 - Class: DRUID - Spec: Balance
    [132115] = "Interface/Icons/Ability_Druid_CatForm", -- ID: 103 - Class: DRUID - Spec: Feral
    [132276] = "Interface/Icons/Ability_Racial_BearForm", -- ID: 104 - Class: DRUID - Spec: Guardian
    [136041] = "Interface/Icons/SPELL_NATURE_HEALINGTOUCH", -- ID: 105 - Class: DRUID - Spec: Restoration
    [135770] = "Interface/Icons/Spell_Deathknight_BloodPresence", -- ID: 250 - Class: DEATHKNIGHT - Spec: Blood
    [135773] = "Interface/Icons/Spell_Deathknight_FrostPresence", -- ID: 251 - Class: DEATHKNIGHT - Spec: Frost
    [135775] = "Interface/Icons/Spell_Deathknight_UnholyPresence", -- ID: 252 - Class: DEATHKNIGHT - Spec: Unholy
    [461112] = "Interface/Icons/ABILITY_HUNTER_BESTIALDISCIPLINE", -- ID: 253 - Class: HUNTER - Spec: Beast Mastery
    [236179] = "Interface/Icons/Ability_Hunter_FocusedAim", -- ID: 254 - Class: HUNTER - Spec: Marksmanship
    [461113] = "Interface/Icons/Ability_Hunter_Camouflage", -- ID: 255 - Class: HUNTER - Spec: Survival
    [135940] = "Interface/Icons/Spell_Holy_PowerWordShield", -- ID: 256 - Class: PRIEST - Spec: Discipline
    [237542] = "Interface/Icons/Spell_Holy_GuardianSpirit", -- ID: 257 - Class: PRIEST - Spec: Holy
    [136207] = "Interface/Icons/Spell_Shadow_ShadowWordPain", -- ID: 258 - Class: PRIEST - Spec: Shadow
    [236270] = "Interface/Icons/Ability_Rogue_DeadlyBrew", -- ID: 259 - Class: ROGUE - Spec: Assassination
    [135340] = "Interface/Icons/INV_Sword_30", -- ID: 260 - Class: ROGUE - Spec: Outlaw
    [132320] = "Interface/Icons/Ability_Stealth", -- ID: 261 - Class: ROGUE - Spec: Subtlety
    [136048] = "Interface/Icons/Spell_Nature_Lightning", -- ID: 262 - Class: SHAMAN - Spec: Elemental
    [237581] = "Interface/Icons/Spell_Shaman_ImprovedStormstrike", -- ID: 263 - Class: SHAMAN - Spec: Enhancement
    [136052] = "Interface/Icons/Spell_Nature_MagicImmunity", -- ID: 264 - Class: SHAMAN - Spec: Restoration
    [136145] = "Interface/Icons/Spell_Shadow_DeathCoil", -- ID: 265 - Class: WARLOCK - Spec: Affliction
    [136172] = "Interface/Icons/Spell_Shadow_Metamorphosis", -- ID: 266 - Class: WARLOCK - Spec: Demonology
    [136186] = "Interface/Icons/Spell_Shadow_RainOfFire", -- ID: 267 - Class: WARLOCK - Spec: Destruction
    [608951] = "Interface/Icons/Spell_Monk_Brewmaster_Spec", -- ID: 268 - Class: MONK - Spec: Brewmaster
    [608953] = "Interface/Icons/Spell_Monk_WindWalker_Spec", -- ID: 269 - Class: MONK - Spec: Windwalker
    [608952] = "Interface/Icons/Spell_Monk_MistWeaver_Spec", -- ID: 270 - Class: MONK - Spec: Mistweaver
    [236159] = "Interface/Icons/Ability_Druid_KingoftheJungle", -- ID: 535 - Class: Unavailable - Spec: Ferocity
    [132150] = "Interface/Icons/Ability_EyeOfTheOwl", -- ID: 536 - Class: Unavailable - Spec: Cunning
    [132121] = "Interface/Icons/ABILITY_DRUID_DEMORALIZINGROAR", -- ID: 537 - Class: Unavailable - Spec: Tenacity
    [1247264] = "Interface/Icons/Ability_DemonHunter_SpecDPS", -- ID: 577 - Class: DEMONHUNTER - Spec: Havoc
    [1247265] = "Interface/Icons/Ability_DemonHunter_SpecTank", -- ID: 581 - Class: DEMONHUNTER - Spec: Vengeance
};

-- Fake method until the config is loaded
A.ConfigNotifyChange = function() end;

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
    --@debug@
    elseif ( arg == "icons" ) then
        A:SpecIconsTable();
    --@end-debug@
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
        PlaySound(SOUNDKIT.TELL_MESSAGE);
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

--- Return the number of entries in a non integer indexed table
-- function A:TableCount(tbl)
    -- local count = 0;

    -- for _ in pairs(tbl) do
        -- count = count + 1;
    -- end

    -- return count;
-- end

--- Simple shallow copy for copying specialization profiles
-- Shamelessly ripped off from Ace3 AceDB-3.0
-- Did I say I love you guys? :p
function A:CopyTable(src, dest)
    if ( type(dest) ~= "table" ) then dest = {}; end

    if ( type(src) == "table" ) then
        for k,v in pairs(src) do
            if ( type(v) == "table" ) then
                v = A:CopyTable(v, dest[k]);
            end

            dest[k] = v;
        end
    end

    return dest;
end

--- pairs function with alphabetic sort
function A:PairsByKeys(t, f)
    local a, i = {}, 0;

    for n in pairs(t) do a[#a+1] = n; end
    table.sort(a, f);

    local iter = function()
        i = i + 1;
        if ( not a[i] ) then
            return nil;
        else
            return a[i], t[a[i]];
        end
    end

    return iter;
end

--- Compare two tables
-- Return true if they are identical, false otherwise
-- function A:CompareTables(t1, t2)
    -- if ( type(t1) ~= "table" or type(t2) ~= "table" ) then return nil; end

    -- if ( #t1 ~= #t2 ) then return nil; end

    -- for k,v in pairs(t1) do
        -- if ( type(v) == "table" ) then
            -- if ( type(t2[k]) == "table" ) then
                -- if ( not A:CompareTables(t2[k], v) ) then
                    -- return nil;
                -- end
            -- else
                -- return nil;
            -- end
        -- elseif ( t2[k] ~= v ) then
            -- return nil;
        -- end
    -- end

    -- return 1;
-- end

--- Replace a character in a string
-- @param pos The position of the character to replace
-- @param str The string
-- @param r The character
function A:ReplaceChar(pos, str, r)
    r = tostring(r);
    return ("%s%s%s"):format(str:sub(1,pos-1), r, str:sub(pos+1))
end

--- Check and clean the database
-- Added to prevent the player from using a copied profile from another class
function A:CleanupDatabase()
    -- Reset specializations and talents options if there is a class mismatch
    if ( A.db.profile.playerClass and A.db.profile.playerClass ~= "" and A.db.profile.playerClass ~= A.playerClass ) then
        A.db.profile.specOptions = {};
        A:SetLootSpecOptions();
        A.db.profile.dualSpecOne = 1;
        A.db.profile.dualSpecTwo = 2;
        A.db.profile.talentsProfiles = {};
        A:Message(L["A class mismatch was detected, your specializations and talents options have been reset."], 1);
    end

    -- This will remove old talents profiles
    -- No message here this was alpha
    for k,v in pairs(A.db.profile.talentsProfiles) do
        if ( not v.specialization ) then
            A.db.profile.talentsProfiles[k] = nil;
        end
    end
end

--- Called on load, or when switching profile
function A:SetEverything()
    A.playerClass = select(2, UnitClass("player"));
    A.playerFaction = UnitFactionGroup("player");
    A.playerLevel = UnitLevel("player");

    A.currentSpec = GetSpecialization();
    A:SetSpecializationsDatabase();

    A.currentTalents = A:GetTalentsString();

    if ( A.playerClass == "HUNTER" ) then
        A.currentPetSpec = GetSpecialization(false, true);
        A:SetPetSpecializationsDatabase();
    end

    A:SetBindingsNames();
    A:SetLootSpecOptions();
    A:SetGearSetsDatabase();
    A:UpdateBroker();
    A:SetTalentsSwitchBuffsNames();
    A:CacheTalentsSwitchItems();
    A:ConfigNotifyChange();

    -- Calling CleanupDatabase before setting the player class in the DB
    -- It's very unlikely to happen, but in case of rename it will handle things
    A:CleanupDatabase();
    A.db.profile.playerClass = A.playerClass;
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

        if ( type(icon) == "number" and A.iconsFileDataToFilePath[icon] ) then
            icon = A.iconsFileDataToFilePath[icon];
        end

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

        if ( type(icon) == "number" and A.iconsFileDataToFilePath[icon] ) then
            icon = A.iconsFileDataToFilePath[icon];
        end

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

        if ( type(icon) == "number" and A.iconsFileDataToFilePath[icon] ) then
            icon = A.iconsFileDataToFilePath[icon];
        end

        return ID, name, L["Current specialization ( %s )"]:format(name or L["None"]), icon;
    else
        local _, ID, name, icon = A:GetSpecInfosByID(lootSpec);

        if ( type(icon) == "number" and A.iconsFileDataToFilePath[icon] ) then
            icon = A.iconsFileDataToFilePath[icon];
        end

        return ID, name, name, icon;
    end
end

--- This is called when switching specialization
-- It will change the gear set and the loot spec
function A:SetGearAndLootAfterSwitch()
    if ( A.inCombat ) then
        A.setGearAndLootAfterSwitchDelayed = 1;
        return;
    end

    local _, specID = A:GetCurrentSpecInfos();

    if ( A.db.profile.switchGearWithSpec ) then
        local currentTalentsProfile = A:GetCurrentUsedTalentsProfile();

        if ( A.db.profile.switchGearWithTalents and currentTalentsProfile and A.db.profile.talentsProfiles[currentTalentsProfile].gearSet ) then
            C_EquipmentSet.UseEquipmentSet(A.db.profile.talentsProfiles[currentTalentsProfile].gearSet);
        elseif ( A.db.profile.specOptions[specID].gearSet ) then
            local setID = select(3, A:GetGearSetInfos(A.db.profile.specOptions[specID].gearSet));
            C_EquipmentSet.UseEquipmentSet(setID);
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

    A:SetChatFilterCallback();
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
    local equipmentSetIDs = SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs())

    A.gearSetsDB = {};

    if ( #equipmentSetIDs > 0 ) then
        for i=1,#equipmentSetIDs do
            local name, icon, id = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[i]);

            if ( name and id ) then
                icon = icon or A.questionMark;
                A.gearSetsDB[#A.gearSetsDB+1] =
                {
                    name = name,
                    icon = icon,
                    id = id,
                };
            end
        end
    end
end

--- Return informations about the current equipped gear set
-- I could have used the gearSetDB table
-- but for that I will have to monitor every modification of the user equipment
-- and those events fire a lot
function A:GetCurrentGearSet()
    local equipmentSetIDs = SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs())

    if ( #equipmentSetIDs > 0 ) then
        for i=1,#equipmentSetIDs do
            local name, icon, _, current, numItems = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[i]);

            if ( (current and numItems > 8) ) then
                icon = icon or A.questionMark;

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

    if ( A.db.profile.showSpecName ) then
        if ( A.db.profile.brokerShortNames ) then
            local specID = select(2, A:GetCurrentSpecInfos());

            name = A.db.profile.specOptions[specID].shortName or L[tostring(specID)] or name or select(3, A:GetCurrentSpecInfos());
        else
            name = name or select(3, A:GetCurrentSpecInfos());
        end

        if ( not name ) then return; end

        text = name or select(3, A:GetCurrentSpecInfos());
    end

    if ( A.db.profile.showLootSpec ) then
        local specID, specName, _, specIcon = A:GetCurrentLootSpecInfos();

        if ( A.db.profile.brokerShortNames ) then
            specName = A.db.profile.specOptions[specID].shortName or L[tostring(specID)] or specName;
        end

        if ( not specName or not specIcon ) then return; end

        text = A.db.profile.brokerShortText and text.."/" or text.." ";

        if ( A.db.profile.showLootSpecTextMode == "text" ) then
            text = text..
            (A.db.profile.brokerShortText and "" or "(")..
            (A.db.profile.showLootSpecBagIcon and "|T"..A.lootBagIcon..":"..A.db.profile.lootSpecIconSize..":"..A.db.profile.lootSpecIconSize..":0:0|t " or "")..
            specName..
            (A.db.profile.brokerShortText and "" or ")");
        else
            text = text..
            (A.db.profile.brokerShortText and "" or "(")..
            "|T"..specIcon..":"..A.db.profile.lootSpecIconSize..":"..A.db.profile.lootSpecIconSize..":0:0|t"..
            (A.db.profile.brokerShortText and "" or ")");
        end
    end

    if ( A.db.profile.showGearSet ) then
        local gearSet, gearIcon = A:GetCurrentGearSet();

        if ( not gearSet or not gearIcon ) then return; end

        text = A.db.profile.brokerShortText and text.."/" or text.." ";

        if ( A.db.profile.showGearSetTextMode == "text" ) then
            text = text..
            ((A.db.profile.brokerRedNone and gearSet == L["None"]) and A.color.RED or "")..
            (A.db.profile.brokerShortText and "" or "(")..
            (A.db.profile.showGearSetArmorIcon and "|T"..A.gearSetIcon..":"..A.db.profile.lootSpecIconSize..":"..A.db.profile.lootSpecIconSize..":0:0|t " or "")..
            gearSet..
            (A.db.profile.brokerShortText and "" or ")")..
            (A.db.profile.brokerRedNone and A.color.RESET or "");
        else
            text = text..
            ((A.db.profile.brokerRedNone and gearSet == L["None"]) and A.color.RED or "")..
            (A.db.profile.brokerShortText and "" or "(")..
            "|T"..gearIcon..":"..A.db.profile.lootSpecIconSize..":"..A.db.profile.lootSpecIconSize..":0:0|t"..
            (A.db.profile.brokerShortText and "" or ")")..
            (A.db.profile.brokerRedNone and A.color.RESET or "");
        end
    end

    if ( A.db.profile.showTalentProfileName ) then
        local currentTalentsProfile = A:GetCurrentUsedTalentsProfile() or L["None"];

        text = A.db.profile.brokerShortText and text.."/" or text.." ";

        text = text..
        ((A.db.profile.brokerRedNone and currentTalentsProfile == L["None"]) and A.color.RED or "")..
        (A.db.profile.brokerShortText and "" or "(")..
        (A.db.profile.showTalentProfileIcon and "|T"..A.profileIcon..":"..A.db.profile.lootSpecIconSize..":"..A.db.profile.lootSpecIconSize..":0:0|t " or "")..
        currentTalentsProfile..
        (A.db.profile.brokerShortText and "" or ")")..
        (A.db.profile.brokerRedNone and A.color.RESET or "");
    end

    return text;
end

--- Update the LDB button and icon
function A:UpdateBroker()
    local _, _, name, icon = A:GetCurrentSpecInfos();
    local text = A:GetDataBrokerText(name);

    if ( not text ) then return; end

    A.ldb.text = text;
    A.ldb.icon = icon;
end

--[[-------------------------------------------------------------------------------
    Talents frame
-------------------------------------------------------------------------------]]--

-- Frame scripts
function A:TalentsFrameOnLoad(self) -- Set the frame
    ButtonFrameTemplate_HideAttic(self);
    ButtonFrameTemplate_HidePortrait(self);
    self.TopTileStreaks:Hide();
    self:SetClampedToScreen(true);
    self.TitleText:ClearAllPoints();
    self.TitleText:SetPoint("TOP", self, "TOP", -12, -4);
    self.closeButton:SetText(L["Close"]);
    table.insert(UISpecialFrames, self:GetName());
    self.buttonsPool = {};
end

function A:TalentsFrameOnShow(self) -- Set the pvp tab icon, call the data update method
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

    -- Set the pvp icon
    if ( A.playerFaction == "Alliance" ) then
        self.PvpTab.Icon:SetTexture("Interface\\ICONS\\Achievement_Garrison_Monument_Alliance_PVP");
    elseif ( A.playerFaction == "Horde" ) then
        self.PvpTab.Icon:SetTexture("Interface\\ICONS\\Achievement_Garrison_Monument_Horde_PVP");
    else -- Pandaren < 10
        self.PvpTab.Icon:SetTexture("Interface\\ICONS\\Achievement_Character_Pandaren_Female");
    end

    A:TalentsFrameUpdate();
end

function A:TalentsFrameOnHide(self) -- Clean the buttons
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
    A.talentsFrame.currentTab = nil;
    A:StoreAllButtonToPool();
end

-- Frames pool system
local buttonPoolCount = 0;
local buttonPool = {};
function A:GetButtonFromPool()
    local button = table.remove(buttonPool);

    if ( button ) then return button; end

    buttonPoolCount = buttonPoolCount + 1;
    button = CreateFrame("Button", "BrokerSpecializationsTalentButton"..buttonPoolCount, A.talentsFrame, "BrokerSpecializationsButtonTemplate");

    return button;
end

function A:StoreButtonToPool(button)
    button:Hide();
    A:HideOverlay(button);
    button:ClearAllPoints();
    button.talentGroup = nil;
    button:SetID(0);
    SetItemButtonTexture(button, nil);
    button:RegisterForDrag();
    button.SpellHighlightTexture:SetShown(false);
    button.icon:SetDesaturated(false);
    button.pvpIndex = nil;
    table.insert(buttonPool, button);
end

function A:StoreAllButtonToPool()
    local button = table.remove(A.talentsFrame.buttonsPool);

    while button do
        A:StoreButtonToPool(button);
        button = table.remove(A.talentsFrame.buttonsPool);
    end
end

-- Glowing overlay pool system
local glowOverlays = {};
local numOverlays = 0;
function A:GetOverlay()
    local overlay = table.remove(glowOverlays);

    if ( not overlay ) then
        numOverlays = numOverlays + 1;
        overlay = CreateFrame("Frame", "BrokerSpecializationsTalentsFrameTalentButtonOverlay"..numOverlays, UIParent, "ActionBarButtonSpellActivationAlert");
    end

    return overlay;
end

function A:ShowOverlay(button)
    if ( button.overlay ) then return; end

    local frameWidth, frameHeight = button:GetSize();

    button.overlay = A:GetOverlay();
    button.overlay:SetParent(button);
    button.overlay:ClearAllPoints();
    button.overlay:SetSize(frameWidth * 1.4, frameHeight * 1.4);
    button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -frameWidth * 0.2, frameHeight * 0.2);
    button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", frameWidth * 0.2, -frameHeight * 0.2);
    button.overlay.animIn:Play();
end

function A:HideOverlay(button)
    if ( button.overlay ) then
        local overlay = button.overlay.animOut:GetParent();

        if ( button.overlay.animIn:IsPlaying() ) then
            button.overlay.animIn:Stop();
        end

        if ( button.overlay:IsVisible() ) then
            button.overlay.animOut:Play();
        end

        button.overlay:Hide();
        table.insert(glowOverlays, overlay);
        button.overlay = nil;
    end
end

-- Tabs methods
function A:TalentsTabOnClick(self)
    if ( A.talentsFrame.currentTab == "talents" ) then return; end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
    A:StoreAllButtonToPool();
    A:SetTalentsFrameForTalents();
    A.talentsFrame.currentTab = "talents";
    A:TalentsFrameUpdate();
end

function A:PvpTabOnClick(self)
    if ( A.talentsFrame.currentTab == "pvp" ) then return; end

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
    A:StoreAllButtonToPool();
    A:SetTalentsFrameForPvp();
    A.talentsFrame.currentTab = "pvp";
    A:TalentsFrameUpdate();
end

function A:SetTalentsFrameForTalents()
    -- Already set, nothing to do here
    if ( A.talentsFrame.currentTab == "talents" ) then return; end

    -- Title
    A.talentsFrame.TitleText:SetText(L["Talents"]);

    -- Tabs
    A.talentsFrame.TalentsTab.Hider:Hide();
    A.talentsFrame.TalentsTab.Highlight:Hide();
    A.talentsFrame.TalentsTab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.78906250, 0.95703125);
    A.talentsFrame.PvpTab.Hider:Show();
    A.talentsFrame.PvpTab.Highlight:Show();
    A.talentsFrame.PvpTab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000);

    -- Buttons
    local talentGroup = GetActiveSpecGroup(false);
    local tiers = GetMaxTalentTier();
    local lastRelativeTo = A.talentsFrame;

    for i=1,tiers do
        local button1 = A:GetButtonFromPool();
        local button2 = A:GetButtonFromPool();
        local button3 = A:GetButtonFromPool();

        A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button1;
        A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button2;
        A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button3;

        if ( i == 1 ) then
            button2:SetPoint("TOP", lastRelativeTo, "TOP", 0, -68);
        else
            button2:SetPoint("TOP", lastRelativeTo, "BOTTOM", 0, -6);
        end

        button1:SetPoint("RIGHT", button2, "LEFT", -6, 0);
        button3:SetPoint("LEFT", button2, "RIGHT", 6, 0);
        lastRelativeTo = button2;
    end

    -- Set Frame size
    A.talentsFrame:SetSize(148, 134 + (42 * tiers));
end

function A:SetTalentsFrameForPvp()
    -- Already set, nothing to do here
    if ( A.talentsFrame.currentTab == "pvp" ) then return; end

    -- Title
    A.talentsFrame.TitleText:SetText(L["PvP"]);

    -- Tabs
    A.talentsFrame.PvpTab.Hider:Hide();
    A.talentsFrame.PvpTab.Highlight:Hide();
    A.talentsFrame.PvpTab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.78906250, 0.95703125);
    A.talentsFrame.TalentsTab.Hider:Show();
    A.talentsFrame.TalentsTab.Highlight:Show();
    A.talentsFrame.TalentsTab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000);

    -- Buttons
    local lastRelativeTo = A.talentsFrame;
    local heightCount = 1;
    local widthCount = 3;

    -- PvP "trinkets"
    local button1 = A:GetButtonFromPool();
    local button2 = A:GetButtonFromPool();
    local button3 = A:GetButtonFromPool();

    A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button1;
    A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button2;
    A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button3;
    button1.pvpIndex = 1;
    button2.pvpIndex = 1;
    button3.pvpIndex = 1;
    button1:SetPoint("TOPLEFT", lastRelativeTo, "TOPLEFT", 12, -68);
    button2:SetPoint("LEFT", button1, "RIGHT", 6, 0);
    button3:SetPoint("LEFT", button2, "RIGHT", 6, 0);
    lastRelativeTo = button1;

    -- PvP talents cache
    A.talentsFrame.pvpTalentsDB = {};

    local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(2);
    local talentGroup = GetActiveSpecGroup(false);

    for i=1,#slotInfo.availableTalentIDs do
        local talentID, _, texture, _, _, _, unlocked = GetPvpTalentInfoByID(slotInfo.availableTalentIDs[i], talentGroup, false);

        if ( unlocked ) then
            A.talentsFrame.pvpTalentsDB[i] =
            {
                talentID = talentID,
                texture = texture,
            };
        end
    end

    for i=2,4 do
        local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i);

        if ( not slotInfo.enabled ) then break; end

        local button1, buttonX, lastButton;

        for j=1,#A.talentsFrame.pvpTalentsDB do
            if ( j == 1 ) then
                button1 = A:GetButtonFromPool();
                A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = button1;
                button1.pvpIndex = i;
                lastButton = button1;
            else
                buttonX = A:GetButtonFromPool();
                A.talentsFrame.buttonsPool[#A.talentsFrame.buttonsPool+1] = buttonX;
                buttonX.pvpIndex = i;
                buttonX:SetPoint("LEFT", lastButton, "RIGHT", 6, 0);
                lastButton = buttonX;
            end
        end

        button1:SetPoint("TOP", lastRelativeTo, "BOTTOM", 0, -6);
        lastRelativeTo = button1;
        heightCount = heightCount + 1;
    end

    -- Set Frame height
    widthCount = #A.talentsFrame.pvpTalentsDB > 3 and #A.talentsFrame.pvpTalentsDB;
    A.talentsFrame:SetSize(20 + (42 * widthCount), 134 + (42 * heightCount));
end

-- Tome/codex cache/data methods
local talentsSwitchItemsCached = {};
function A:CacheTalentsSwitchItems()
    for k,v in pairs(A.talentsSwitchItems) do
        for kk,vv in ipairs(v) do
            local itemName , _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(vv);

            if ( not itemName or not itemTexture ) then
                A:ScheduleTimer("CacheTalentsSwitchItems", 0.5);
                return;
            end

            if ( not talentsSwitchItemsCached[k] ) then
                talentsSwitchItemsCached[k] = {};
            end

            talentsSwitchItemsCached[k][kk] =
            {
                itemName = itemName,
                itemTexture = itemTexture,
            };
        end
    end
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
                return;
            end

        end
    end
end

function A:GetTalentsSwitchItemsTable()
    local startIndex = 1;
    local tomeTable = { count = 0, };
    local codexTable = { count = 0, };
    local lastCountBank = 0;
    local lastCountBankItemName = "";

    if ( UnitLevel("player") > 100 ) then -- Ignore wod items
        startIndex = 2;
    end

    for i=startIndex,#A.talentsSwitchItems.tome do
        local itemID = A.talentsSwitchItems.tome[i];
        local itemName = talentsSwitchItemsCached.tome[i].itemName;
        local itemTexture = talentsSwitchItemsCached.tome[i].itemTexture;
        local count = GetItemCount(itemID, false);
        local countBank = GetItemCount(itemID, true);

        if ( (count > 0 and not tomeTable.itemID) or (i == #A.talentsSwitchItems.tome and not tomeTable.itemID) ) then
            tomeTable =
            {
                itemID = itemID,
                itemTexture = itemTexture,
                count = count,
                countBank = countBank,
                oldCountBank = 0,
                oldCountBankItemName = "",
                itemName = itemName,
            };

            if ( lastCountBank > 0 ) then
                tomeTable.oldCountBank = lastCountBank;
                tomeTable.oldCountBankItemName = lastCountBankItemName;
            end
        elseif ( countBank > 0 ) then
            lastCountBank = countBank;
            lastCountBankItemName = itemName;
        end
    end

    lastCountBank = 0;
    lastCountBankItemName = "";

    for i=startIndex,#A.talentsSwitchItems.codex do
        local itemID = A.talentsSwitchItems.codex[i];
        local itemName = talentsSwitchItemsCached.codex[i].itemName;
        local itemTexture = talentsSwitchItemsCached.codex[i].itemTexture;
        local count = GetItemCount(itemID, false);
        local countBank = GetItemCount(itemID, true);

        if ( (count > 0 and not codexTable.itemID) or (i == #A.talentsSwitchItems.codex and not codexTable.itemID) ) then
            codexTable =
            {
                itemID = itemID,
                itemTexture = itemTexture,
                count = count,
                countBank = countBank,
                oldCountBank = 0,
                oldCountBankItemName = "",
                itemName = itemName,
            };

            if ( lastCountBank > 0 ) then
                codexTable.oldCountBank = lastCountBank;
                codexTable.oldCountBankItemName = lastCountBankItemName;
            end
        elseif ( countBank > 0 ) then
            lastCountBank = countBank;
            lastCountBankItemName = itemName;
        end
    end

    return tomeTable, codexTable;
end

-- Button click methods
function A:TalentButtonOnClick(button)
    if ( A.inCombat ) then return; end

    if ( button:GetParent().currentTab == "talents" ) then
        if ( A:LearnTalent(button:GetID()) ) then
            A:TalentsFrameUpdate();
        end
    else
        if ( A:LearnPvpTalent(button:GetID(), button.pvpIndex) ) then
            A:TalentsFrameUpdate();
        end
    end
end

function A:ItemButtonPostClick(button)
    A:TalentsFrameUpdate();
end

-- The main update talents frame method
function A:TalentsFrameUpdate()
    -- Talents
    if ( A.talentsFrame.currentTab == "talents" ) then
        local talentGroup = GetActiveSpecGroup(false);
        local tiers = GetMaxTalentTier();
        local index = 1;

        for i=1,tiers do
            for j=1,3 do
                local button = A.talentsFrame.buttonsPool[index];
                local talentID, _, texture, selected = GetTalentInfo(i, j, talentGroup, false);

                button.talentGroup = talentGroup;
                button:SetID(talentID);
                SetItemButtonTexture(button, texture);
                button.SpellHighlightTexture:SetShown(selected);
                button:RegisterForDrag(selected and "LeftButton" or nil);
                button.icon:SetDesaturated(not selected);
                button:Show();
                index = index + 1;
            end
        end
    --- PvP talents
    else
        local talentGroup = GetActiveSpecGroup(false);
        local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs();
        local index = 1;

        local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1);

        for i=1,#slotInfo.availableTalentIDs do
            local button = A.talentsFrame.buttonsPool[index];
            local selected = slotInfo.selectedTalentID == slotInfo.availableTalentIDs[i] and true or nil;
            local talentID, _, texture = GetPvpTalentInfoByID(slotInfo.availableTalentIDs[i], talentGroup, false);

            button.talentGroup = talentGroup;
            button:SetID(talentID);
            SetItemButtonTexture(button, texture);

            if ( selected ) then
                A:ShowOverlay(button);
                button:RegisterForDrag("LeftButton");
            else
                A:HideOverlay(button);
                button:RegisterForDrag();
            end

            button:Show();
            index = index + 1;
        end

        for i=2,4 do
            local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(i);

            if ( not slotInfo.enabled ) then break; end

            for j=1,#A.talentsFrame.pvpTalentsDB do
                local button = A.talentsFrame.buttonsPool[index];
                local data = A.talentsFrame.pvpTalentsDB[j];
                local selected = slotInfo.selectedTalentID == data.talentID and true or nil;
                local unavailable = tContains(selectedPvpTalents, data.talentID) and true or nil;

                button.talentGroup = talentGroup;
                button:SetID(data.talentID);
                SetItemButtonTexture(button, data.texture);

                if ( selected ) then
                    A:ShowOverlay(button);
                    button:RegisterForDrag("LeftButton");
                else
                    A:HideOverlay(button);
                    button:RegisterForDrag();
                end

                button.icon:SetDesaturated((unavailable and not selected));
                button:Show();
                index = index + 1;
            end
        end
    end

    -- Talents switch items
    -- No need to check the minimum level requirement (which is 15)
    -- If we are here the player got some talents to choose from
    local tome, codex = A:GetTalentsSwitchItemsTable();

    local button = _G["BrokerSpecializationsTalentsFrameItemButtonTome"];
    button:SetID(tome.itemID);
    button.icon:SetTexture(tome.itemTexture);
    button.count:SetText(tome.count);
    button.countNum = tome.count;
    button.countBank = tome.countBank;
    button.oldCountBank = tome.oldCountBank;
    button.oldCountBankItemName = tome.oldCountBankItemName;
    button.itemName = tome.itemName;

    if ( tome.count == 0 ) then
        button:SetAttribute("item", nil);
        button.icon:SetDesaturated(true);
    else
        button:SetAttribute("item", tome.itemName);
        button.icon:SetDesaturated(false);
    end

    button = _G["BrokerSpecializationsTalentsFrameItemButtonCodex"];
    button:SetID(codex.itemID);
    button.icon:SetTexture(codex.itemTexture);
    button.count:SetText(codex.count);
    button.countNum = codex.count;
    button.countBank = codex.countBank;
    button.oldCountBank = codex.oldCountBank;
    button.oldCountBankItemName = codex.oldCountBankItemName;
    button.itemName = codex.itemName;

    if ( codex.count == 0 ) then
        button:SetAttribute("item", nil);
        button.icon:SetDesaturated(true);
    else
        button:SetAttribute("item", codex.itemName);
        button.icon:SetDesaturated(false);
    end
end

-- Display info on the tome/codex tooltip
function A:SetSwitchItemsTooltip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
    GameTooltip:SetItemByID(frame:GetID());

    -- If the player is resting, display a message on the tooltip
    if ( IsResting() ) then
        GameTooltip:AddLine(A.color["RED"]..L["You are resting."]);
    end

    -- Check if the player is already buffed
    for i=1,40 do
        local buffName = UnitBuff("player", i);

        if ( buffName ) then
            if ( tContains(A.talentsSwitchBuffsNames, buffName) ) then
                GameTooltip:AddLine(A.color["RED"]..L["You are already buffed with %s."]:format(A.talentsSwitchBuffsNames[i]));
                break;
            end
        else
            break;
        end
    end

    if ( frame.oldCountBank > 0 ) then
        GameTooltip:AddLine(L["You have %d %s (old content item) in your bank."]:format(frame.oldCountBank, frame.oldCountBankItemName));
    end

    if ( frame.countNum == 0 and frame.countBank > 0 ) then
        GameTooltip:AddLine(L["You have %d %s in your bank."]:format(frame.countBank, frame.itemName));
    end

    -- Needed to update the tooltip height
    GameTooltip:Show();
end

-- This is the called method to display the frame
function A:TalentsFrameShowOrHide(relativeTo, tab)
    if ( A.talentsFrame:IsShown() ) then
        A.talentsFrame:Hide();
    else
        tab = tab or "talents";

        if ( tab == "talents" ) then
            if ( A.playerLevel < SHOW_TALENT_LEVEL ) then
                return;
            else
                A:SetTalentsFrameForTalents();
            end
        elseif ( tab == "pvp" ) then
            if ( not C_PvP.IsWarModeFeatureEnabled() or A.playerLevel < SHOW_PVP_TALENT_LEVEL ) then
                return;
            else
                A:SetTalentsFrameForPvp();
            end
        else
            return;
        end

        local point, relativePoint = A:SmartAnchor();
        A.talentsFrame:ClearAllPoints();
        A.talentsFrame:SetPoint(point, relativeTo, relativePoint, 0, 0);
        A.talentsFrame.currentTab = tab;
        CloseDropDownMenus();
        A:HideTooltip();
        A.talentsFrame:Show();
    end
end

-- Combat protected talents selection methods, with spam removal
function A:LearnTalent(id)
    if ( A.inCombat ) then
        A:Message(L["Cannot switch talents in combat."], 1);
        return;
    end

    A:SetChatFilterCallback();
    LearnTalent(id);
end

function A:LearnPvpTalent(id, index)
    if ( A.inCombat ) then
        A:Message(L["Cannot switch talents in combat."], 1);
        return;
    end

    A:SetChatFilterCallback();
    LearnPvpTalent(id, index);
end

--[[-------------------------------------------------------------------------------
    Talents profile
-------------------------------------------------------------------------------]]--

StaticPopupDialogs["BROKERSPECIALIZATIONS_ADD_TALENTS_PROFILE"] = {
    text = L["Enter the name of your talents profile."],
    button1 = L["Add"],
    button2 = L["Cancel"],
    hasEditBox = 1,
    maxLetters = 31,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    OnShow = function(self)
        self.button1:Disable();
        self.button2:Enable();
        self.editBox:SetFocus();
    end,
    EditBoxOnTextChanged = function (self)
        local name = self:GetText();
        name = tostring(name);

        if ( name ~= "" ) then
            self:GetParent().button1:Enable();
        else
            self:GetParent().button1:Disable();
        end
    end,
    OnAccept = function(self)
        A:AddTalentsProfile(self.editBox:GetText());
    end,
    EditBoxOnEnterPressed = function(self)
        A:AddTalentsProfile(self:GetText());
        self:GetParent():Hide();
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
    OnHide = function(self)
        self.editBox:SetText("");
    end,
};

function A:AddTalentsProfile(name)
    name = tostring(name);

    if ( name == "" ) then
        A:Message(L["The talents profile name is empty."], 1);
        return;
    end

    if ( A.db.profile.talentsProfiles[name] ) then
        A:Message(L["The profile %s already exists, please choose another name."]:format(name), 1);
        return;
    end

    local _, specID, specName, specIcon = A:GetCurrentSpecInfos();

    A.db.profile.talentsProfiles[name] =
    {
        specialization = specID,
        specName = specName,
        specIcon = specIcon,
        talents = A:GetTalentsSnapshot(),
        string = A:GetTalentsString(),
    };

    A:UpdateBroker();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

function A:AddTalentsProfilePopup()
    StaticPopup_Show("BROKERSPECIALIZATIONS_ADD_TALENTS_PROFILE");
end

function A:GetTalentsSnapshot()
    local talentGroup = GetActiveSpecGroup(false);
    local tbl = {};

    for i=1,7 do
        for j=1,3 do
            local talentID, _, _, selected = GetTalentInfo(i, j, talentGroup, false);

            if ( selected ) then
                tbl[i] = talentID;
            end
        end
    end

    return tbl;
end

function A:GetTalentsString()
    local talentGroup = GetActiveSpecGroup(false);
    local str = "";

    for i=1,7 do
        for j=1,3 do
            local talentID, _, _, selected = GetTalentInfo(i, j, talentGroup, false);

            if ( selected ) then
                str = str..tostring(j);
            end
        end
    end

    return str;
end

function A:SetTalentsProfile(name)
    if ( A.inCombat ) then return; end
    if ( not name or name == "" ) then return; end

    A:SetTalentsBrute(name);

    if ( A.db.profile.switchGearWithTalents and A.db.profile.talentsProfiles[name].gearSet ) then
        local setID = select(3, A:GetGearSetInfos(A.db.profile.talentsProfiles[name].gearSet));
        C_EquipmentSet.UseEquipmentSet(setID);
    end

    A:UpdateBroker();
    A:RefreshTooltip();
end

function A:SetTalentsBrute(name)
    if ( A.db.profile.talentsProfiles[name] and A.db.profile.talentsProfiles[name].talents ) then
        for k,v in pairs(A.db.profile.talentsProfiles[name].talents) do
            A:LearnTalent(v);
        end
    end
end

--- This will return true if we got at least 1 talent profile for the current spec
function A:GotTalentsProfile()
    local currentSpecID = select(2, A:GetCurrentSpecInfos());

    for _,v in pairs(A.db.profile.talentsProfiles) do
        if ( v.specialization == currentSpecID ) then
            return 1;
        end
    end

    return nil;
end

--- Get current used talents profile
function A:GetCurrentUsedTalentsProfile()
    local currentSpecID = select(2, A:GetCurrentSpecInfos());

    for k,v in pairs(A.db.profile.talentsProfiles) do
        if ( v.specialization == currentSpecID and A.currentTalents == v.string ) then
            return k;
        end
    end

    return nil;
end

--[[-------------------------------------------------------------------------------
    Hide spam
-------------------------------------------------------------------------------]]--

--- Build the strings filter table
-- Basically removing format conversion characters from GlobalStrings
function A:BuildFilterTable()
    local str;
    local globalStrings =
    {
        ERR_SPELL_UNLEARNED_S,
        ERR_LEARN_ABILITY_S,
        ERR_LEARN_PASSIVE_S,
        ERR_LEARN_SPELL_S,
        ERR_PET_LEARN_ABILITY_S,
        ERR_PET_LEARN_SPELL_S,
        ERR_PET_SPELL_UNLEARNED_S,
    };

    A.filterTable = {};

    for _,v in ipairs(globalStrings) do
        str = string.gsub(v, "%.", "");
        str = string.gsub(str, "%%s", ".+");
        A.filterTable[#A.filterTable+1] = str;
    end
end

--- Filter callback function
-- Called by "ChatFrame_MessageEventHandler" from ChatFrame.lua
A.ChatFilter = function(self, event, msg, ...)
    if ( A.inCombat ) then return; end

    if ( not A.filterTable ) then A:BuildFilterTable(); end

    for _,v in ipairs(A.filterTable) do
        if ( string.find(msg, v) ) then return 1; end
    end

    return nil;
end

--- Set the chat filter callback
function A:SetChatFilterCallback()
    if ( not A.chatFilterTimer and A.db.profile.chatFilter ) then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", A.ChatFilter);
        A.chatFilterTimer = A:ScheduleTimer("UnsetChatFilterCallback", 15);
    end
end

-- Unset the chat filter callback, this is called by AceTimer after spec/talent switch
function A:UnsetChatFilterCallback()
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", A.ChatFilter);
    A.chatFilterTimer = nil;
end

--[[-------------------------------------------------------------------------------
    Dropdown menu
-------------------------------------------------------------------------------]]--

local function DropdownMenu(self, level)
    if ( not level ) then return; end

    local info = self.info;

    if ( level == 1 ) then
        if ( not A.db.profile.switchTooltip ) then
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
        end

        -- Talents profiles (title)
        info.text = L["Talents profiles"];
        info.notCheckable = 1;
        info.isTitle = 1;
        info.icon = nil;
        info.disabled = nil;
        info.iconOnly = nil;
        info.iconInfo = nil;
        UIDropDownMenu_AddButton(info, level);

        -- Add profile
        info.text = L["Add"];
        info.keepShownOnClick = nil;
        info.hasArrow = nil;
        info.disabled = nil;
        info.isTitle = nil;
        info.notClickable = nil;
        info.func = function() A:AddTalentsProfilePopup(); end;
        UIDropDownMenu_AddButton(info, level);

        if ( not A.db.profile.talentsSwitchTooltip ) then
            -- Talents profile (menu)
            info.text = L["Profiles"];
            info.value = "TALENTSPROFILES";
            info.keepShownOnClick = 1;
            info.hasArrow = 1;
            if ( A:GotTalentsProfile() ) then
                info.disabled = nil;
            else
                info.disabled = 1;
            end
            UIDropDownMenu_AddButton(info, level);
        end

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

        -- Other switches (title)
        info.text = L["Other switches"];
        info.notCheckable = 1;
        info.isTitle = 1;
        info.icon = nil;
        info.disabled = nil;
        info.iconOnly = nil;
        info.iconInfo = nil;
        info.keepShownOnClick = nil;
        info.hasArrow = nil;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.isTitle = nil;
        info.notClickable = nil;
        info.keepShownOnClick = 1;
        info.hasArrow = 1;

        -- Gear sets switch (menu)
        info.text = L["Gear set"];
        info.value = "GEARSET";
        info.disabled = #A.gearSetsDB == 0 and 1 or nil;
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
                info.disabled = select(4, C_EquipmentSet.GetEquipmentSetInfo(v.id));
                info.func = function() C_EquipmentSet.UseEquipmentSet(v.id); end;
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
        elseif ( UIDROPDOWNMENU_MENU_VALUE == "TALENTSPROFILES" ) then
            local currentSpecID = select(2, A:GetCurrentSpecInfos());
            local currentTalentsProfile = A:GetCurrentUsedTalentsProfile();
            local disabled;

            for k,v in A:PairsByKeys(A.db.profile.talentsProfiles) do
                if ( v.specialization == currentSpecID ) then
                    if ( currentTalentsProfile == k ) then
                        disabled = 1;
                    else
                        disabled = nil;
                    end

                    info.text = k;
                    info.icon = nil;
                    info.padding = 0;
                    info.disabled = disabled;
                    info.func = function() A:SetTalentsProfile(k); end;
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        end
    end
end

--[[-------------------------------------------------------------------------------
    Tooltip
-------------------------------------------------------------------------------]]--

function A:HideTooltip()
    if ( A.tip:IsAcquired("BrokerSpecializationsTooltip") ) then
        local tip = A.tip:Acquire("BrokerSpecializationsTooltip");

        tip:Release();
        tip = nil;
    end
end

function A:RefreshTooltip()
    if ( A.tip:IsAcquired("BrokerSpecializationsTooltip") ) then
        local tip = A.tip:Acquire("BrokerSpecializationsTooltip");

        tip:Release();
        A:Tooltip(tip.brokerSpecializationsAnchorFrame);
    end
end

function A:Tooltip(anchorFrame)
    A:HideTooltip();

    local tip = A.tip:Acquire("BrokerSpecializationsTooltip", 2, "LEFT", "LEFT");
    local line;
    tip.brokerSpecializationsAnchorFrame = anchorFrame;
    anchorFrame.brokerSpecializationsTooltip = tip;

    tip:AddHeader(A.color["PRIEST"]..L["Broker Specializations"]);
    tip:SetCell(1, 2, A.color["GREEN"].." v"..A.version, nil, "RIGHT");
    tip:AddLine(" ");

    if ( A.db.profile.switchTooltip ) then
        line = tip:AddLine();
        tip:SetCell(line, 1, A.color["GREEN"]..L["Specializations switch"], nil, nil, 2);

        for k,v in ipairs(A.specDB) do
            line = tip:AddLine();

            if ( v.current ) then
                tip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["POOR"]..v.name, nil, nil, 2);
            else
                tip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["PRIEST"]..v.name, nil, nil, 2);
                tip:SetCellScript(line, 1, "OnMouseUp", function()
                    A:SetSpecialization(k);
                    A:HideTooltip();
                end);
            end
        end

        if ( A.playerClass == "HUNTER" ) then
            tip:AddLine(" ");
            line = tip:AddLine();
            tip:SetCell(line, 1, A.color["GREEN"]..L["Pet specializations switch"], nil, nil, 2);

            for k,v in ipairs(A.petSpecDB) do
                line = tip:AddLine();

                if ( v.current ) then
                    tip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["POOR"]..v.name, nil, nil, 2);
                else
                    tip:SetCell(line, 1, "|T"..v.icon..":16:16:0:0|t"..A.color["PRIEST"]..v.name, nil, nil, 2);
                    tip:SetCellScript(line, 1, "OnMouseUp", function()
                        A:SetSpecialization(k, true);
                        A:HideTooltip();
                    end);
                end
            end
        end

        tip:AddLine(" ");
    end

    if ( A.db.profile.talentsSwitchTooltip and A:GotTalentsProfile() ) then
        line = tip:AddLine();
        tip:SetCell(line, 1, A.color["GREEN"]..L["Talents profiles switch"], nil, nil, 2);

        local currentSpecID = select(2, A:GetCurrentSpecInfos());
        local currentTalentsProfile = A:GetCurrentUsedTalentsProfile();
        local disabled;

        for k,v in A:PairsByKeys(A.db.profile.talentsProfiles) do
            if ( v.specialization == currentSpecID ) then
                line = tip:AddLine();

                if ( k == currentTalentsProfile ) then
                    tip:SetCell(line, 1, A.color["POOR"]..k, nil, nil, 2);
                else
                    tip:SetCell(line, 1, A.color["PRIEST"]..k, nil, nil, 2);
                    tip:SetCellScript(line, 1, "OnMouseUp", function()
                        A:SetTalentsProfile(k);
                        A:HideTooltip();
                    end);
                end
            end
        end

        tip:AddLine(" ");
    end

    if ( (not A.db.profile.switchTooltip or (A.db.profile.tooltipInfos and A.db.profile.switchTooltip))
    and (not A.db.profile.talentsSwitchTooltip or (A.db.profile.tooltipInfos and A.db.profile.talentsSwitchTooltip)) )then
        local _, _, specName, specIcon = A:GetCurrentSpecInfos();
        local _, _, lootSpecText, lootSpecIcon = A:GetCurrentLootSpecInfos();
        local gearSet, gearIcon = A:GetCurrentGearSet();
        local currentTalentsProfile = A:GetCurrentUsedTalentsProfile() or L["None"];

        line = tip:AddLine();
        tip:SetCell(line, 1, A.color["GREEN"]..L["Informations"], nil, nil, 2);
        tip:AddLine(L["Current specialization"], "|T"..specIcon..":16:16:0:0|t"..A.color["PRIEST"]..specName);
        tip:AddLine(L["Current equipment set"], "|T"..gearIcon..":16:16:0:0|t"..A.color["PRIEST"]..gearSet);
        tip:AddLine(L["Current loot specialization"], "|T"..lootSpecIcon..":16:16:0:0|t"..A.color["PRIEST"]..lootSpecText);
        tip:AddLine(L["Current talents profile"], A.color["PRIEST"]..currentTalentsProfile);
        tip:AddLine(" ");

        if ( A.db.profile.dualSpecEnabled ) then
            specName, specIcon, gearSet, gearIcon, lootSpecText, lootSpecIcon = A:DualSpecSwitchToInfos();

            line = tip:AddLine();
            tip:SetCell(line, 1, A.color["GREEN"]..L["Dual specialization mode is enabled"], nil, nil, 2);
            tip:AddLine(L["Switch to"], "|T"..specIcon..":16:16:0:0|t"..A.color["PRIEST"]..specName);
            if ( A.db.profile.switchGearWithSpec ) then
                tip:AddLine(L["With equipment set"], "|T"..gearIcon..":16:16:0:0|t"..A.color["PRIEST"]..gearSet);
            end
            if ( A.db.profile.switchLootWithSpec ) then
                tip:AddLine(L["With loot specialization"], "|T"..lootSpecIcon..":16:16:0:0|t"..A.color["PRIEST"]..lootSpecText);
            end
            tip:AddLine(" ");
        end
    end

    if ( A.db.profile.dualSpecEnabled ) then
        line = tip:AddLine();
        tip:SetCell(line, 1, L["|cFFC79C6ELeft-Click: |cFF33FF99Dual specialization switch.\n|cFFC79C6EShift+Left-Click: |cFF33FF99Open the quick talents switch panel.\n|cFFC79C6EControl+Left-Click: |cFF33FF99Open the quick PvP talents switch panel.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."], nil, nil, 2);
    else
        line = tip:AddLine();
        tip:SetCell(line, 1, L["|cFFC79C6ELeft-Click: |cFF33FF99Open the quick talents switch panel.\n|cFFC79C6EShift+Left-Click: |cFF33FF99Open the quick PvP talents switch panel.\n|cFFC79C6ERight-Click: |cFF33FF99Open the quick access menu.\n|cFFC79C6EMiddle-Click: |cFF33FF99Open the configuration panel."], nil, nil, 2);
    end

    tip:SmartAnchorTo(anchorFrame);
    tip:SetAutoHideDelay(0.01, anchorFrame, A.HideTooltip);
    tip:Show();
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
        showLootSpecTextMode = "text",
        showLootSpecBagIcon = 1,
        lootSpecIconSize = 16,
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
        switchTooltip = nil,
        tooltipInfos = 1,
        talentsProfiles = {},
        chatFilter = nil,
        playerClass = "";
        talentsSwitchTooltip = nil,
        showGearSet = nil,
        showGearSetTextMode = "text",
        showGearSetArmorIcon = 1,
        showTalentProfileName = nil,
        showTalentProfileIcon = 1,
        brokerShortText = nil,
        brokerShortNames = nil,
        brokerRedNone = nil,
        switchGearWithTalents = nil,
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
    A:SetTalentsProfilesStrings();
    A:UnregisterEvent("PLAYER_ENTERING_WORLD");
end

function A:PLAYER_TALENT_UPDATE()
    -- Doing specialization stuff here, Hunters seem to get spec info from the server later than other classes
    -- This is to handle the case when the player got a new pvp talent in combat
    if ( A.inCombat ) then
        A.playerTalentUpdateDelayed = 1;
        return;
    end

    if ( A.talentsFrame:IsShown() ) then
        A:TalentsFrameUpdate();
    end

    local oldSpec = A.currentSpec;
    A.currentSpec = GetSpecialization();
    A.currentTalents = A:GetTalentsString();

    if ( oldSpec ~= A.currentSpec ) then
        A:SetSpecializationsDatabase();
        A:SetGearAndLootAfterSwitch();
    end

    A:UpdateBroker();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

function A:PET_SPECIALIZATION_CHANGED()
    A.currentPetSpec = GetSpecialization(false, true);
    A:SetPetSpecializationsDatabase();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

function A:PLAYER_LOOT_SPEC_UPDATED()
    A:UpdateBroker();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

function A:EQUIPMENT_SETS_CHANGED()
    A:SetGearSetsDatabase();
    A:UpdateBroker();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

function A:PLAYER_REGEN_DISABLED()
    A.inCombat = 1;

    if ( A.talentsFrame:IsShown() ) then
        A.talentsFrame:Hide();
    end
end

function A:PLAYER_REGEN_ENABLED()
    if ( A.setGearAndLootAfterSwitchDelayed ) then
        A:SetGearAndLootAfterSwitch();
        A.setGearAndLootAfterSwitchDelayed = nil;
    end

    if ( A.playerTalentUpdateDelayed ) then
        A:PLAYER_TALENT_UPDATE();
        A.playerTalentUpdateDelayed = nil;
    end

    A.inCombat = nil;
end

function A:PLAYER_LEVEL_UP(event, level)
    if ( A:IsEnabled() ) then
        A.playerLevel = UnitLevel("player");
        A.playerLeveledUpTalents = true;
        A.playerLeveledUpPvp = true;
    elseif ( level >= 10 ) then
        A:UnregisterEvent("PLAYER_LEVEL_UP");
        A:Enable();
        A:PLAYER_ENTERING_WORLD();
    end
end

function A:BAG_UPDATE()
    if ( A.talentsFrame:IsShown() ) then
        A:TalentsFrameUpdate();
    end
end

function A:EQUIPMENT_SWAP_FINISHED(event, success, set)
    A:UpdateBroker();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

function A:PLAYER_EQUIPMENT_CHANGED()
    A:UpdateBroker();
    A:RefreshTooltip();
    A:ConfigNotifyChange();
end

--[[-------------------------------------------------------------------------------
    Database fixes
-------------------------------------------------------------------------------]]--

--- This will create the talents profiles strings if they are missing
function A:SetTalentsProfilesStrings()
    for k,v in pairs(A.db.profile.talentsProfiles) do
        if ( not v.string ) then
            local str = "0000000";

            for kk,vv in ipairs(v.talents) do
                local _, _, _, _, _, _, _, row, column = GetTalentInfoByID(vv);

                str = A:ReplaceChar(row, str, column);
            end

            v.string = str;
        end
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
                    if ( IsShiftKeyDown() ) then
                        A:TalentsFrameShowOrHide(self);
                    elseif ( IsControlKeyDown() ) then
                        A:TalentsFrameShowOrHide(self, "pvp");
                    else
                        A:DualSwitch();
                    end
                else
                    if ( IsShiftKeyDown() ) then
                        A:TalentsFrameShowOrHide(self, "pvp");
                    else
                        A:TalentsFrameShowOrHide(self);
                    end
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
            if ( A.db.profile.switchTooltip or A.db.profile.talentsSwitchTooltip ) then return; end

            A.tip:Release(self.brokerSpecializationsTooltip);
            self.brokerSpecializationsTooltip = nil;
        end,
    });

    -- LDBIcon
    A.icon:Register("Broker_SpecializationsLDB", A.ldb, A.db.profile.minimap);
    A.icon:IconCallback("PLAYER_SPECIALIZATION_CHANGED", "Broker_SpecializationsLDB", nil, nil, A.ldb);
    A.icon:IconCallback("PLAYER_ENTERING_WORLD", "Broker_SpecializationsLDB", nil, nil, A.ldb);

    -- Events
    A:RegisterEvent("PLAYER_ENTERING_WORLD");
    A:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED");
    A:RegisterEvent("EQUIPMENT_SETS_CHANGED");
    A:RegisterEvent("PLAYER_REGEN_DISABLED");
    A:RegisterEvent("PLAYER_REGEN_ENABLED");
    A:RegisterEvent("BAG_UPDATE");
    A:RegisterEvent("PET_SPECIALIZATION_CHANGED");
    A:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
    A:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    A:RegisterEvent("PLAYER_TALENT_UPDATE");
    A:RegisterEvent("PLAYER_LEVEL_UP");

    -- Add the config loader to blizzard addon configuration panel
    A:AddToBlizzTemp();
end
