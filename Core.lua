Lootamelo = CreateFrame("Frame");
Lootamelo_main_button = CreateFrame("Button", "LootameloInitialButton", UIParent, "UIPanelButtonTemplate");
Lootamelo_main_button:SetPoint("LEFT", 0, 0);
Lootamelo_main_button:SetSize(100, 30);
Lootamelo_main_button:SetText("Loot Drama Free");
Lootamelo_main_button:SetMovable(true);
Lootamelo_main_button:RegisterForDrag("LeftButton");
Lootamelo_main_button:SetScript("OnDragStart", Lootamelo_main_button.StartMoving);
Lootamelo_main_button:SetScript("OnDragStop", Lootamelo_main_button.StopMovingOrSizing);

local playerName = UnitName("player");

function Lootamelo_CloseMainFrame()
    Lootamelo_ShowMembersFrame();
    _G["Lootamelo_Main_Frame"]:Hide();
end

function Lootamelo_ShowMainFrame()
    _G["Lootamelo_Main_Frame"]:Show();
end

function Lootamelo_MainFrameToggle()
   if _G["Lootamelo_Main_Frame"]:IsShown() then
        Lootamelo_CloseMainFrame();
    else
        Lootamelo_ShowMainFrame();
    end
end

Lootamelo_main_button:SetScript("OnClick", function()
    Lootamelo_MainFrameToggle();
end)

-- Lootamelo:RegisterEvent("CHAT_MSG_ADDON");

-- Lootamelo:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)

--     if event == "CHAT_MSG_ADDON" and prefix == Lootamelo_channel then
--         local msgType = string.sub(message, 1, 3);
--         local prof = string.sub(message, 5);
--         if msgType == "Req" then
--             local jewelcraftingLink = select(2,  GetSpellLink(prof));
--             local msg = "Res:" .. "|cff00A2FF ------| " .. playerName .. ":|r " .. jewelcraftingLink .. "|cff00A2FF |------ |r";
--             SendAddonMessage(Lootamelo_channel, msg, "WHISPER", sender);
--         end
--     end

--     if event == "CHAT_MSG_ADDON" and prefix == Lootamelo_channel then
--         local msgType = string.sub(message, 1, 3);
--         local link = string.sub(message, 5);
--         if msgType == "Res" then
--            print(link);
--         end
--     end


-- end)

-- tinsert(UISpecialFrames, "Lootamelo_Main_Frame");