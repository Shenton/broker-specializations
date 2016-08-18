--[[-------------------------------------------------------------------------------
    Broker Specializations
    A Data Broker add-on for quickly switching your specialization with gear set and loot specialization
    By: Shenton

    Core.lua
-------------------------------------------------------------------------------]]--

-- Ace libs (<3)
local A = LibStub("AceAddon-3.0"):NewAddon("Broker_Specializations", "AceConsole-3.0", "AceEvent-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_Specializations", false);

-- Addon global
_G["BrokerSpecializationsGlobal"] = A;

-- LibDBIcon
A.icon = LibStub("LibDBIcon-1.0");
