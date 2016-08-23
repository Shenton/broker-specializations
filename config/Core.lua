--[[-------------------------------------------------------------------------------
    Broker Specializations Configuration
    A Data Broker add-on for quickly switching your specialization with gear set and loot specialization
    By: Shenton

    Core.lua
-------------------------------------------------------------------------------]]--

--[[-------------------------------------------------------------------------------
    FindGlobals
-------------------------------------------------------------------------------]]--

-- GLOBALS: LibStub

--[[-------------------------------------------------------------------------------
    Global to local
-------------------------------------------------------------------------------]]--

local ipairs = ipairs;
local _G = _G;

--[[-------------------------------------------------------------------------------
    Addon global
-------------------------------------------------------------------------------]]--

local A = _G["BrokerSpecializationsGlobal"];
local L = A.L;

--[[-------------------------------------------------------------------------------
    Configuration Panel
-------------------------------------------------------------------------------]]--

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
                    dataBroker =
                    {
                        order = 100,
                        name = L["Data Broker"],
                        type = "group",
                        inline = true,
                        args =
                        {
                            showSpecName =
                            {
                                order = 0,
                                name = L["Display name"],
                                desc = L["Display the current specialization name on the Data Broker display."],
                                type = "toggle",
                                set = function()
                                    A.db.profile.showSpecName = not A.db.profile.showSpecName;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showSpecName; end,
                            },
                            showSpecNameBlankLine =
                            {
                                order = 1,
                                name = " ",
                                width = "full",
                                type = "description",
                            },
                            showLootSpec =
                            {
                                order = 10,
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
                                order = 11,
                                name = L["Loot specialization mode"],
                                desc = L["Select in which mode the loot specialization will be displayed. Text or icon."],
                                disabled = not A.db.profile.showLootSpec,
                                type = "select",
                                values = A.showLootSpecModes,
                                set = function(info, val)
                                    if ( val == "text" ) then
                                        A.db.profile.showLootSpecTextMode = 1;
                                    else
                                        A.db.profile.showLootSpecTextMode = nil;
                                    end

                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showLootSpecTextMode and "text" or "icon"; end,
                            },
                            showLootSpecBagIcon =
                            {
                                order = 12,
                                name = L["Display loot bag"],
                                desc = L["When loot specialization display mode is text, display a bag icon before it."],
                                disabled = not A.db.profile.showLootSpec or not A.db.profile.showLootSpecTextMode and 1 or nil,
                                type = "toggle",
                                set = function()
                                    A.db.profile.showLootSpecBagIcon = not A.db.profile.showLootSpecBagIcon;
                                    A:UpdateBroker();
                                end,
                                get = function() return A.db.profile.showLootSpecBagIcon; end,
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
        },
    };

    local tabOrder = 100;

    for k,v in ipairs(A.specDB) do
        configPanel.args["spec"..v.name] =
        {
            order = tabOrder,
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
            },
        };
        tabOrder = tabOrder + 100;

        local order = 0;

        for _,vv in ipairs(A.gearSetsDB) do
            configPanel.args["spec"..v.name].args.gearSet.args[order..vv.name] =
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

        local _, _, currentName, currentIcon = A:GetCurrentSpecInfos();

        configPanel.args["spec"..v.name].args.lootSpec.args["0current"] =
        {
            order = 0,
            name = L["Current specialization ( %s )"]:format(currentName),
            image = currentIcon,
            desc = L["Select this to use current specialization for loot specialization when switching to specialization %s."]:format(v.name),
            width = "full",
            type = "toggle",
            set = function(info, val) A.db.profile.specOptions[v.id].lootSpec = val and 0 or nil; end,
            get = function() return A.db.profile.specOptions[v.id].lootSpec == 0 and 1 or nil; end,
        };

        order = 1;

        for _,vv in ipairs(A.specDB) do
            configPanel.args["spec"..v.name].args.lootSpec.args[order..vv.name] =
            {
                order = order,
                name = vv.name,
                image = vv.icon,
                desc = L["Select this to use %s for loot specialization when switching to specialization %s."]:format(vv.name, v.name),
                --width = "full",
                type = "toggle",
                set = function(info, val) A.db.profile.specOptions[v.id].lootSpec = val and vv.id or nil; end,
                get = function() return A.db.profile.specOptions[v.id].lootSpec == vv.id and 1 or nil; end,
            };
            order = order + 1;
        end
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
