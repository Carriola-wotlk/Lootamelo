local ns = _G[LOOTAMELO_NAME];
ns.Navigation = ns.Navigation or {};

local navButtonConfig, navButtonRaid, navButtonLoot, navButtonCreate;
local navButtonConfigTexture, navButtonRaidTexture, navButtonLootTexture;
local pressTexture, normalTexture;
local menuVoices = {"Config", "Raid", "Loot"};
local isFirstOpen = true;

local function CreateNavButtons()
    local navButton, buttonText;
    for index, voice in pairs(menuVoices) do
        navButton = CreateFrame("Button", "Lootamelo_NavButton" .. voice, _G["Lootamelo_MainFrame"], "Lootamelo_NavButtonTemplate");
        buttonText = _G[navButton:GetName() .. "Text"];
        if(buttonText) then
            buttonText:SetText(voice);
        end
        navButton:SetPoint("TOPLEFT", _G["Lootamelo_NavButtonCreate"], "TOPLEFT", 75 + ((index-1) * 128), -40);
    end

    navButtonCreate = CreateFrame("Button", "Lootamelo_NavButtonCreate", _G["Lootamelo_MainFrame"], "UIPanelButtonTemplate");

    navButtonCreate:SetPoint("TOPLEFT", 10, -44);
    navButtonCreate:SetSize(70, 25);
    navButtonCreate:SetText("New run");

end

local function ShowRaidPage()
    ns.State.currentPage = "Raid";
    if(navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(pressTexture);
        --navButtonConfigTexture:SetTexture(normalTexture);
        navButtonLootTexture:SetTexture(normalTexture);

        if(navButtonCreate and not navButtonCreate:IsShown()) then
            navButtonCreate:Show();
        end

        if(_G["Lootamelo_ConfigFrame"]) then
            _G["Lootamelo_ConfigFrame"]:Hide();
        end

        if(_G["Lootamelo_LootFrame"]) then
            _G["Lootamelo_LootFrame"]:Hide();
        end
        
        if(_G["Lootamelo_CreateFrame"]) then
            _G["Lootamelo_CreateFrame"]:Hide();
        end
        
        _G["Lootamelo_RaidFrame"]:Show();

        if(ns.State.raidItemSelected) then
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
    ns.State.currentPage = "Config";
    if(navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(normalTexture);
        --navButtonConfigTexture:SetTexture(pressTexture);
        navButtonLootTexture:SetTexture(normalTexture);

        if(navButtonCreate and not navButtonCreate:IsShown()) then
            navButtonCreate:Show();
        end

        if(_G["Lootamelo_RaidFrame"]) then
            _G["Lootamelo_RaidFrame"]:Hide();
        end

        if(_G["Lootamelo_CreateFrame"]) then
            _G["Lootamelo_CreateFrame"]:Hide();
        end
        
        if(_G["Lootamelo_LootFrame"]) then
            _G["Lootamelo_LootFrame"]:Hide();
        end

        _G["Lootamelo_ConfigFrame"]:Show();
    end
end

local function ShowLootPage()
    ns.State.currentPage = "Loot";
    if(navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(normalTexture);
        --navButtonConfigTexture:SetTexture(normalTexture);
        navButtonLootTexture:SetTexture(pressTexture);

        if(navButtonCreate and not navButtonCreate:IsShown()) then
            navButtonCreate:Show();
        end

        if(_G["Lootamelo_RaidFrame"]) then
            _G["Lootamelo_RaidFrame"]:Hide();
        end

        if(_G["Lootamelo_CreateFrame"]) then
            _G["Lootamelo_CreateFrame"]:Hide();
        end

        if(_G["Lootamelo_ConfigFrame"]) then
            _G["Lootamelo_ConfigFrame"]:Hide();
        end
        _G["Lootamelo_LootFrame"]:Show();
    end
end

local function ShowCreatePage()
    ns.State.currentPage = "Create";
    if(navButtonRaidTexture and navButtonLootTexture) then
        navButtonRaidTexture:SetTexture(normalTexture);
        --navButtonConfigTexture:SetTexture(normalTexture);
        navButtonLootTexture:SetTexture(pressTexture);

        if(navButtonCreate and navButtonCreate:IsShown()) then
            navButtonCreate:Hide();
        end

        if(_G["Lootamelo_RaidFrame"]) then
            _G["Lootamelo_RaidFrame"]:Hide();
        end

        if(_G["Lootamelo_LootFrame"]) then
            _G["Lootamelo_LootFrame"]:Hide();
        end

        if(_G["Lootamelo_ConfigFrame"]) then
            _G["Lootamelo_ConfigFrame"]:Hide();
        end

        _G["Lootamelo_CreateFrame"]:Show();
    end
end

local function PagesVariablesInit()
    CreateNavButtons();
    --navButtonConfig = _G["Lootamelo_NavButtonConfig"];
    navButtonRaid = _G["Lootamelo_NavButtonRaid"];
    navButtonLoot = _G["Lootamelo_NavButtonLoot"];

    pressTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-press]];
    normalTexture = [[Interface\AddOns\Lootamelo\Texture\buttons\nav-button-normal]];

    if(navButtonConfig) then
        navButtonConfigTexture = _G[navButtonConfig:GetName() .. "NormalTexture"];
    end

    if(navButtonRaid) then
        navButtonRaidTexture = _G[navButtonRaid:GetName() .. "NormalTexture"];
    end

    if(navButtonLoot) then
        navButtonLootTexture = _G[navButtonLoot:GetName() .. "NormalTexture"];
    end
end

local pagesSwitch = {
    --Config = ShowConfigPage,
    Raid = ShowRaidPage,
    Loot = ShowLootPage,
    Create = ShowCreatePage,
}

function ns.Navigation.CloseMainFrame()
    if _G["Lootamelo_MainFrame"] then
        _G["Lootamelo_MainFrame"]:Hide();
    end
end

function ns.Navigation.MainFrameToggle(page)
    if _G["Lootamelo_MainFrame"] and _G["Lootamelo_MainFrame"]:IsShown() then
        ns.Navigation.CloseMainFrame();
    else
        ns.Navigation.ToPage(page);
    end
end

function ns.Navigation.ToPage(page)
    ns.State.currentPage = page;
    if not _G["Lootamelo_MainFrame"]:IsShown() then
        _G["Lootamelo_MainFrame"]:Show();
    end
    if(isFirstOpen) then
        PagesVariablesInit();
        isFirstOpen = false;
    end

    if(navButtonRaidTexture and navButtonLootTexture) then
        if pagesSwitch[page] then
            pagesSwitch[page]();
        else
            print("Page not found");
        end
    end
end

-- globals wrapper for xml files --
function Lootamelo_CloseMainFrame()
    ns.Navigation.CloseMainFrame()
end