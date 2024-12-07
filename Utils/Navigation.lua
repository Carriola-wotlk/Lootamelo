local navButtonConfig, navButtonRaid, navButtonLoot;
local navButtonConfigTexture, navButtonRaidTexture, navButtonLootTexture;
local pressTexture, normalTexture;
local menuVoices = {"Config", "Raid", "Loot"};

Lootamelo_Navigation = {};

function Lootamelo_Navigation.CloseMainFrame()
    if _G["Lootamelo_MainFrame"] then
        _G["Lootamelo_MainFrame"]:Hide();
    end
end

function Lootamelo_Navigation.MainFrameToggle(page)
    if _G["Lootamelo_MainFrame"] and _G["Lootamelo_MainFrame"]:IsShown() then
        Lootamelo_Navigation.CloseMainFrame();
    else
        Lootamelo_NavigateToPage(page);
    end
end

local function CreateNavButtons()
    local navButton, buttonText;
    for index, voice in pairs(menuVoices) do
        navButton = CreateFrame("Button", "Lootamelo_NavButton" .. voice, _G["Lootamelo_MainFrame"], "Lootamelo_NavButtonTemplate");
        buttonText = _G[navButton:GetName() .. "Text"];
        if(buttonText) then
            buttonText:SetText(voice);
        end
        navButton:SetPoint("TOPLEFT", _G["Lootamelo_MainFrame"], "TOPLEFT", 75 + ((index-1) * 128), -40);
    end
end

function Lootamelo_Navigation.PagesVariableInit()
    CreateNavButtons();
    navButtonConfig = _G["Lootamelo_NavButtonConfig"];
    navButtonRaid = _G["Lootamelo_NavButtonRaid"];
    navButtonLoot = _G["Lootamelo_NavButtonLoot"];

    pressTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-press]];
    normalTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-normal]];

    if(navButtonConfig and navButtonLoot and navButtonRaid) then
        navButtonConfigTexture = _G[navButtonConfig:GetName() .. "NormalTexture"];
        navButtonRaidTexture = _G[navButtonRaid:GetName() .. "NormalTexture"];
        navButtonLootTexture = _G[navButtonLoot:GetName() .. "NormalTexture"];
    end
end

local function ShowRaidPage()
    Lootamelo_Current_Page = "Raid";
    if(navButtonConfigTexture and navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(pressTexture);
        navButtonConfigTexture:SetTexture(normalTexture);
        navButtonLootTexture:SetTexture(normalTexture);
        if(_G["Lootamelo_ConfigFrame"]) then
            _G["Lootamelo_ConfigFrame"]:Hide();
        end

        if(_G["Lootamelo_LootFrame"]) then
            _G["Lootamelo_LootFrame"]:Hide();
        end
        
        _G["Lootamelo_RaidFrame"]:Show();

        if(Lootamelo_RaidItemSelected) then
            if(_G["Lootamelo_RaidFrameGeneral"]) then
                _G["Lootamelo_RaidFrameGeneral"]:Hide();
            end
            _G["Lootamelo_RaidFrameItemSelected"]:Show();
        else
            if(_G["Lootamelo_RaidFrameItemSelected"]) then
                _G["Lootamelo_RaidFrameItemSelected"]:Hide();
            end
            _G["Lootamelo_RaidFrameGeneral"]:Show();
        end
    end
end

local function ShowConfigPage()
    Lootamelo_Current_Page = "Config";
    if(navButtonConfigTexture and navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(normalTexture);
        navButtonConfigTexture:SetTexture(pressTexture);
        navButtonLootTexture:SetTexture(normalTexture);

        if(_G["Lootamelo_RaidFrame"]) then
            _G["Lootamelo_RaidFrame"]:Hide();
        end
        
        if(_G["Lootamelo_LootFrame"]) then
            _G["Lootamelo_LootFrame"]:Hide();
        end

        _G["Lootamelo_ConfigFrame"]:Show();
    end
end

local function ShowLootPage()
    Lootamelo_Current_Page = "Loot";
    if(navButtonConfigTexture and navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(normalTexture);
        navButtonConfigTexture:SetTexture(normalTexture);
        navButtonLootTexture:SetTexture(pressTexture);

        if(_G["Lootamelo_RaidFrame"]) then
            _G["Lootamelo_RaidFrame"]:Hide();
        end
        if(_G["Lootamelo_ConfigFrame"]) then
            _G["Lootamelo_ConfigFrame"]:Hide();
        end
        _G["Lootamelo_LootFrame"]:Show();
    end
end

function Lootamelo_NavigateToPage(page)
    Lootamelo_Current_Page = page;
    if not _G["Lootamelo_MainFrame"]:IsShown() then
        _G["Lootamelo_MainFrame"]:Show();
    end
    if(navButtonConfigTexture and navButtonRaidTexture and navButtonLootTexture) then
        if(Lootamelo_Current_Page == "Raid") then
            ShowRaidPage();
        end
        if(Lootamelo_Current_Page == "Config") then
            ShowConfigPage();
        end
        if(Lootamelo_Current_Page == "Loot") then
           ShowLootPage();
        end
    end
end
