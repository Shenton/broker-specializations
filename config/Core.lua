--[[-------------------------------------------------------------------------------
    Broker Specializations Configuration
    A Data Broker add-on for quickly switching your specialization with gear set and loot specialization
    By: Shenton

    Core.lua
-------------------------------------------------------------------------------]]--

--[[-------------------------------------------------------------------------------
    FindGlobals
-------------------------------------------------------------------------------]]--

-- GLOBALS: LibStub, GetTalentInfoByID, GetSpellDescription

--[[-------------------------------------------------------------------------------
    Global to local
-------------------------------------------------------------------------------]]--

local ipairs = ipairs;
local _G = _G;
local pairs = pairs;
local tostring = tostring;

--[[-------------------------------------------------------------------------------
    Addon global
-------------------------------------------------------------------------------]]--

local A = _G["BrokerSpecializationsGlobal"];
local L = A.L;

--[[-------------------------------------------------------------------------------
    Configuration Panel
-------------------------------------------------------------------------------]]--

local profilesRenameTable = {};
local profilesDeleteTable = {};
local shortNameInput;

function A:ConfigurationPanel()
    local dualSpecSelectValues = {};

    for k,v in ipairs(A.specDB) do
        dualSpecSelectValues[k] = "|T"..v.icon..":16:16:0:0|t "..v.name;
    end

    local configPanel =
    {
        order = 0,
        name = L["Broker Specializations"],
        type = "group",
        childGroups = "tab",
        args =
        {
            --
            -- Options tab
            --
            options =
            {
                order = 0,
                name = L["Options"],
                type = "group",
                args =
                {
                    automation =
                    {
                        order = 0,
                        name = L["Automation"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            switchGearWithSpec =
                            {
                                order = 0,
                                name = L["Switch gear with specialization"],
                                desc = L["Switch to the selected equipment set when switching a specialization. Set this within the specialization tab."],
                                width = "full",
                                type = "toggle",
                                set = function() A.db.profile.switchGearWithSpec = not A.db.profile.switchGearWithSpec; end,
                                get = function() return A.db.profile.switchGearWithSpec; end,
                            },
                            switchLootWithSpec =
                            {
                                order = 0,
                                name = L["Switch loot specialization with specialization"],
                                desc = L["Switch to the selected loot specialization when switching a specialization. Set this within the specialization tab."],
                                width = "full",
                                type = "toggle",
                                set = function() A.db.profile.switchLootWithSpec = not A.db.profile.switchLootWithSpec; end,
                                get = function() return A.db.profile.switchLootWithSpec; end,
                            },
                        },
                    },
                    dualSpec =
                    {
                        order = 50,
                        name = L["Dual Specialization"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            enabled =
                            {
                                order = 0,
                                name = L["Enabled"],
                                desc = L["Enable the Dual Specialization mode. Switch between two defined specializations with a single click."],
                                width = "full",
                                type = "toggle",
                                set = function() A.db.profile.dualSpecEnabled = not A.db.profile.dualSpecEnabled; end,
                                get = function() return A.db.profile.dualSpecEnabled; end,
                            },
                            selectSpecOne =
                            {
                                order = 1,
                                name = L["Specialization One"],
                                desc = L["Select the first specialization for the Dual mode."],
                                disabled = not A.db.profile.dualSpecEnabled,
                                type = "select",
                                values = dualSpecSelectValues,
                                set = function(info, val)
                                    if ( val == A.db.profile.dualSpecTwo ) then
                                        A:Message(L["You cannot select the same specialization with Dual Specialization Mode."], 1);
                                    else
                                        A.db.profile.dualSpecOne = val;
                                    end
                                end,
                                get = function() return A.db.profile.dualSpecOne; end,
                            },
                            selectSpecTwo =
                            {
                                order = 2,
                                name = L["Specialization Two"],
                                desc = L["Select the second specialization for the Dual mode."],
                                disabled = not A.db.profile.dualSpecEnabled,
                                type = "select",
                                values = dualSpecSelectValues,
                                set = function(info, val)
                                    if ( val == A.db.profile.dualSpecOne ) then
                                        A:Message(L["You cannot select the same specialization with Dual Specialization Mode."], 1);
                                    else
                                        A.db.profile.dualSpecTwo = val;
                                    end
                                end,
                                get = function() return A.db.profile.dualSpecTwo; end,
                            },
                        },
                    },
                    tooltip =
                    {
                        order = 60,
                        name = L["Tooltip"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            switchTootip =
                            {
                                order = 0,
                                name = L["Switch with tooltip"],
                                desc = L["Enable this to use the tooltip to switch between your specializations."],
                                type = "toggle",
                                set = function() A.db.profile.switchTooltip = not A.db.profile.switchTooltip; end,
                                get = function() return A.db.profile.switchTooltip; end,
                            },
                            talentsSwitchTootip =
                            {
                                order = 1,
                                name = L["Switch talents with tooltip"],
                                desc = L["Enable this to use the tooltip to switch between your talents profiles."],
                                type = "toggle",
                                width = "double",
                                set = function() A.db.profile.talentsSwitchTooltip = not A.db.profile.talentsSwitchTooltip; end,
                                get = function() return A.db.profile.talentsSwitchTooltip; end,
                            },
                            informations =
                            {
                                order = 2,
                                name = L["Informations"],
                                desc = L["Add some informations to the tooltip."],
                                type = "toggle",
                                set = function() A.db.profile.tooltipInfos = not A.db.profile.tooltipInfos; end,
                                get = function() return A.db.profile.tooltipInfos; end,
                            },
                        },
                    },
                    chatFilter =
                    {
                        order = 70,
                        name = L["Chat filter"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            enabled =
                            {
                                order = 0,
                                name = L["Enabled"],
                                desc = L["With this enabled it will hide the talents learning/unlearning messages from your chat."],
                                type = "toggle",
                                set = function() A.db.profile.chatFilter = not A.db.profile.chatFilter; end,
                                get = function() return A.db.profile.chatFilter; end,
                            },
                        },
                    },
                    dataBroker =
                    {
                        order = 100,
                        name = L["Data Broker"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            brokerShortText =
                            {
                                order = 0,
                                name = L["Short mode"],
                                desc = L["This will remove parenthesis and spaces, plus it will separate names or icons with slashes."],
                                type = "toggle",
                                set = function()
                                    A.db.profile.brokerShortText = not A.db.profile.brokerShortText;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.brokerShortText; end,
                            },
                            brokerShortNames =
                            {
                                order = 1,
                                name = L["Short names"],
                                desc = L["This will uses short names for specializations."],
                                type = "toggle",
                                set = function()
                                    A.db.profile.brokerShortNames = not A.db.profile.brokerShortNames;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.brokerShortNames; end,
                            },
                            brokerRedNone =
                            {
                                order = 2,
                                name = L["Red none"],
                                desc = L["This will color in red gear set and talents profile names, if they are displaying \"None\"."],
                                type = "toggle",
                                set = function()
                                    A.db.profile.brokerRedNone = not A.db.profile.brokerRedNone;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.brokerRedNone; end,
                            },
                            specializationHeader =
                            {
                                order = 10,
                                name = L["Specializations"],
                                type = "header",
                            },
                            showSpecName =
                            {
                                order = 11,
                                name = L["Display name"],
                                desc = L["Display the current specialization name on the Data Broker display."],
                                type = "toggle",
                                set = function()
                                    A.db.profile.showSpecName = not A.db.profile.showSpecName;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showSpecName; end,
                            },
                            lootSpecializationHeader =
                            {
                                order = 100,
                                name = L["Loot specialization"],
                                type = "header",
                            },
                            showLootSpec =
                            {
                                order = 101,
                                name = L["Display loot specialization"],
                                desc = L["Display the current loot specialization on the Data Broker display."],
                                width = "full",
                                type = "toggle",
                                set = function()
                                    A.db.profile.showLootSpec = not A.db.profile.showLootSpec;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showLootSpec; end,
                            },
                            showLootSpecTextMode =
                            {
                                order = 102,
                                name = L["Loot specialization mode"],
                                desc = L["Select in which mode the loot specialization will be displayed. Text or icon."],
                                disabled = not A.db.profile.showLootSpec,
                                type = "select",
                                values = A.showLootSpecModes,
                                set = function(info, val)
                                    A.db.profile.showLootSpecTextMode = val;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showLootSpecTextMode; end,
                            },
                            showLootSpecBagIcon =
                            {
                                order = 103,
                                name = L["Display loot bag"],
                                desc = L["When loot specialization display mode is text, display a bag icon before it."],
                                disabled = not A.db.profile.showLootSpec or A.db.profile.showLootSpecTextMode == "icon" and true or false,
                                type = "toggle",
                                set = function()
                                    A.db.profile.showLootSpecBagIcon = not A.db.profile.showLootSpecBagIcon;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showLootSpecBagIcon; end,
                            },
                            gearSetHeader =
                            {
                                order = 200,
                                name = L["Gear set"],
                                type = "header",
                            },
                            showGearSet =
                            {
                                order = 201,
                                name = L["Display gear set"],
                                desc = L["Display the current gear set on the Data Broker display."],
                                width = "full",
                                type = "toggle",
                                set = function()
                                    A.db.profile.showGearSet = not A.db.profile.showGearSet;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showGearSet; end,
                            },
                            showGearSetTextMode =
                            {
                                order = 202,
                                name = L["Gear set mode"],
                                desc = L["Select in which mode the gear set will be displayed. Text or icon."],
                                disabled = not A.db.profile.showGearSet,
                                type = "select",
                                values = A.showLootSpecModes,
                                set = function(info, val)
                                    A.db.profile.showGearSetTextMode = val;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showGearSetTextMode; end,
                            },
                            showGearSetIcon =
                            {
                                order = 203,
                                name = L["Display armor icon"],
                                desc = L["When gear set display mode is text, display an armor icon before it."],
                                disabled = not A.db.profile.showGearSet or A.db.profile.showGearSetTextMode == "icon" and true or false,
                                type = "toggle",
                                set = function()
                                    A.db.profile.showGearSetArmorIcon = not A.db.profile.showGearSetArmorIcon;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showGearSetArmorIcon; end,
                            },
                            talentProfileHeader =
                            {
                                order = 300,
                                name = L["Talents profiles"],
                                type = "header",
                            },
                            talentProfile =
                            {
                                order = 301,
                                name = L["Display talents profile"],
                                desc = L["Display the current talents profile on the Data Broker display."],
                                --width = "full",
                                type = "toggle",
                                set = function()
                                    A.db.profile.showTalentProfileName = not A.db.profile.showTalentProfileName;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showTalentProfileName; end,
                            },
                            talentProfileIcon =
                            {
                                order = 302,
                                name = L["Display talents icon"],
                                desc = L["Display the talents icon before the text."],
                                disabled = not A.db.profile.showTalentProfileName and true or false,
                                type = "toggle",
                                set = function()
                                    A.db.profile.showTalentProfileIcon = not A.db.profile.showTalentProfileIcon;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showTalentProfileIcon; end,
                            },
                            iconSizeHeader =
                            {
                                order = 1000,
                                name = L["Icons size"],
                                type = "header",
                            },
                            iconsSize =
                            {
                                order = 1001,
                                name = L["Icons size"],
                                desc = L["Set the icons size. This will not alter the current specialization icon."],
                                --disabled = not A.db.profile.showLootSpec,
                                type = "range",
                                min = 4,
                                max = 32,
                                step = 1,
                                width = "full",
                                set = function(info, val)
                                    A.db.profile.lootSpecIconSize = val;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.lootSpecIconSize; end,
                            },
                        },
                    },
                    minimap =
                    {
                        order = 200,
                        name = L["Minimap"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            showSpecName =
                            {
                                order = 0,
                                name = L["Display minimap button"],
                                desc = L["Display the minimaps icon. Uncheck this to hide it."],
                                type = "toggle",
                                width = "full",
                                set = function()
                                    A.db.profile.minimap.hide = not A.db.profile.minimap.hide;
                                    A:ShowHideMinimap();
                                end,
                                get = function() return not A.db.profile.minimap.hide; end,
                            },
                        },
                    },
                },
            },
            specializationsOptions =
            {
                order = 100,
                name = L["Specializations"],
                type = "group",
                args = {},
            },
            talentsProfiles =
            {
                order = 200,
                name = L["Talents profiles"],
                type = "group",
                args =
                {
                    -- options =
                    -- {
                        -- order = 0,
                        -- name = L["Options"],
                        -- type = "group",
                        -- args = {},
                    -- },
                    -- profiles =
                    -- {
                        -- order = 0,
                        -- name = L["Profiles"],
                        -- type = "group",
                        -- args = {},
                    -- },
                },
            },
        },
    };

    local groupOrder = 0;
    local order = 0;

    for k,v in ipairs(A.specDB) do
        configPanel.args.specializationsOptions.args["spec"..v.name] =
        {
            order = groupOrder,
            name = "|T"..v.icon..":16:16:0:0|t "..v.name,
            type = "group",
            args =
            {
                gearSet =
                {
                    order = 0,
                    name = L["Gear set"],
                    type = "group",
                    inline = true,
                    args =
                    {
                    },
                },
                lootSpec =
                {
                    order = 100,
                    name = L["Loot specialization"],
                    type = "group",
                    inline = true,
                    args =
                    {
                    },
                },
                shortName =
                {
                    order = 200,
                    name = L["Short name"],
                    type = "group",
                    inline = true,
                    args =
                    {
                        info =
                        {
                            order = 0,
                            type = "description",
                            fontSize = "medium",
                            width = "full",
                            name = function()
                                if ( A.db.profile.specOptions[v.id].shortName ) then
                                    return L["Default short name: %s"]:format(A.color.RED..L[tostring(v.id)]..A.color.RESET).."\n"..L["Custom short name: %s"]:format(A.color.GREEN..A.db.profile.specOptions[v.id].shortName..A.color.RESET);
                                else
                                    return L["Default short name: %s"]:format(A.color.GREEN..L[tostring(v.id)]);
                                end
                            end,
                        },
                        customInput =
                        {
                            order = 100,
                            type = "input",
                            name = L["Input short name"],
                            desc = L["Input here your custom short name, and click Okay."],
                            get = function() return A.db.profile.specOptions[v.id].shortName; end,
                            set = function(info, val) shortNameInput = val; end,
                        },
                        customExecute =
                        {
                            order = 101,
                            type = "execute",
                            name = function()
                                if ( shortNameInput ) then
                                    return L["Add"].." : "..shortNameInput;
                                else
                                    return L["Add short name"];
                                end
                            end,
                            disabled = not shortNameInput,
                            desc = L["Click here to add your custom specialization short name."],
                            func = function()
                                if ( shortNameInput ) then
                                    if ( shortNameInput ~= "" ) then
                                        A.db.profile.specOptions[v.id].shortName = shortNameInput;
                                        A:UpdateBroker();
                                        A:RefreshTooltip();
                                    end
                                    shortNameInput = nil;
                                end
                            end,
                        },
                        reset =
                        {
                            order = 102,
                            type = "execute",
                            width = "full",
                            name = L["Reset short name to default"],
                            disabled = not A.db.profile.specOptions[v.id].shortName,
                            func = function()
                                A.db.profile.specOptions[v.id].shortName = nil;
                                A:UpdateBroker();
                                A:RefreshTooltip();
                            end,
                        },
                    },
                },
            },
        };
        groupOrder = groupOrder + 1;

        order = 0;

        for _,vv in ipairs(A.gearSetsDB) do
            configPanel.args.specializationsOptions.args["spec"..v.name].args.gearSet.args[order..vv.name] =
            {
                order = order,
                name = vv.name,
                image = vv.icon,
                desc = L["Select this to use gear set %s when switching to specialization %s."]:format(vv.name, v.name),
                --width = "full",
                type = "toggle",
                set = function(info, val) A.db.profile.specOptions[v.id].gearSet = val and vv.id or nil; end,
                get = function() return A.db.profile.specOptions[v.id].gearSet == vv.id and 1 or nil; end,
            };
            order = order + 1;
        end

        configPanel.args.specializationsOptions.args["spec"..v.name].args.lootSpec.args["0current"] =
        {
            order = 0,
            name = L["Current specialization ( %s )"]:format(v.name),
            image = v.icon,
            desc = L["Select this to use current specialization for loot specialization when switching to specialization %s."]:format(v.name),
            width = "full",
            type = "toggle",
            set = function(info, val) A.db.profile.specOptions[v.id].lootSpec = val and 0 or nil; end,
            get = function() return A.db.profile.specOptions[v.id].lootSpec == 0 and 1 or nil; end,
        };

        order = 1;

        for _,vv in ipairs(A.specDB) do
            configPanel.args.specializationsOptions.args["spec"..v.name].args.lootSpec.args[order..vv.name] =
            {
                order = order,
                name = vv.name,
                image = vv.icon,
                desc = L["Select this to use %s for loot specialization when switching to specialization %s."]:format(vv.name, v.name),
                type = "toggle",
                set = function(info, val) A.db.profile.specOptions[v.id].lootSpec = val and vv.id or nil; end,
                get = function() return A.db.profile.specOptions[v.id].lootSpec == vv.id and 1 or nil; end,
            };
            order = order + 1;
        end
    end

    groupOrder = 0;

    for k,v in A:PairsByKeys(A.db.profile.talentsProfiles) do
        configPanel.args.talentsProfiles.args[tostring(k)] =
        {
            order = groupOrder,
            name = tostring(k.." (|T"..v.specIcon..":16:16:0:0|t"..v.specName..")"),
            type = "group",
            inline = true,
            args =
            {
                listHeader =
                {
                    order = 0,
                    name = L["Talents List"],
                    type = "header",
                },
                renameHeader =
                {
                    order = 50,
                    name = L["Rename"],
                    type = "header",
                },
                renameProfileInput =
                {
                    order = 51,
                    name = L["Rename"],
                    desc = L["Enter the new name of the profile %s. It will enable the button next to this box."]:format(tostring(k));
                    type = "input",
                    get = function()
                        return profilesRenameTable[k] or "";
                    end,
                    set = function(info, val)
                        if ( val == "" and profilesRenameTable[k] ) then
                            profilesRenameTable[k] = nil;
                        end

                        val = tostring(val);
                        profilesRenameTable[k] = val;
                    end,
                },
                renameProfileExecute =
                {
                    order = 52,
                    name = L["Rename"],
                    desc = L["Rename the profile %s to %s."]:format(tostring(k), profilesRenameTable[k] or "");
                    type = "execute",
                    disabled = function()
                        if ( not profilesRenameTable[k] ) then
                            return true;
                        end
                    end,
                    func = function()
                        if ( A.db.profile.talentsProfiles[profilesRenameTable[k]] ) then
                            A:Message(L["The profile %s already exists, please choose another name."]:format(profilesRenameTable[k]), 1);
                            profilesRenameTable[k] = nil;
                            return;
                        end

                       A.db.profile.talentsProfiles[profilesRenameTable[k]] = {};
                       A:CopyTable(A.db.profile.talentsProfiles[k], A.db.profile.talentsProfiles[profilesRenameTable[k]]);
                       A.db.profile.talentsProfiles[k] = nil;
                       profilesRenameTable[k] = nil;
                       A:UpdateBroker();
                       A:RefreshTooltip();
                    end,
                },
                deleteHeader =
                {
                    order = 100,
                    name = L["Delete"],
                    type = "header",
                },
                deleteProfileToggle =
                {
                    order = 101,
                    name = L["Enable"],
                    desc = L["Enable the delete button for the profile %s."]:format(tostring(k));
                    type = "toggle",
                    get = profilesDeleteTable[k],
                    set = function() profilesDeleteTable[k] = not profilesDeleteTable[k]; end,
                },
                deleteProfileExecute =
                {
                    order = 102,
                    name = L["Delete"],
                    desc = L["Delete the profile %s.\n\n|cffff3333This is definitive."]:format(tostring(k));
                    type = "execute",
                    disabled = function()
                        if ( not profilesDeleteTable[k] ) then
                            return true;
                        end
                    end,
                    func = function()
                       A.db.profile.talentsProfiles[k] = nil;
                       profilesDeleteTable[k] = nil;
                       A:UpdateBroker();
                       A:RefreshTooltip();
                    end,
                },
            },
        };

        order = 1;
        for kk,vv in pairs(v.talents) do
            local _, name, texture, _, _, spellID, _, row, column = GetTalentInfoByID(vv);

            configPanel.args.talentsProfiles.args[tostring(k)].args["list"..name] =
            {
                order = order,
                type = "execute",
                name = name.." ("..row.." - "..column..")",
                desc = GetSpellDescription(spellID),
                image = texture,
            }
            order = order + 1;
        end

        groupOrder = groupOrder + 1;
    end

    -- Ace3 profiles options
    configPanel.args.profilesOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(A.db);
    configPanel.args.profilesOptions.order = 10000;

    return configPanel;
end

-- Register with AceConfig
LibStub("AceConfig-3.0"):RegisterOptionsTable("BrokerSpecializationsConfigPanel", A.ConfigurationPanel);

-- Adding add-on configuration to Blizzard UI
A.configurationPanel = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BrokerSpecializationsConfigPanel", L["Broker Specializations"]);
