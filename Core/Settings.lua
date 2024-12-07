local ns = _G[LOOTAMELO_NAME];
ns.Settings = ns.Settings or {};

local settingsButton, cancelButton, settingsTextArea, scrollFrame, settingsTitle;

function ns.Settings.LoadFrame()
   local settingsFrame = _G["Lootamelo_SettingsFrame"];

   if not settingsTitle then
       settingsTitle = _G["Lootamelo_SettingsFrame"]:CreateFontString(nil, "ARTWORK", "GameFontNormal");
       settingsTitle:SetPoint("TOPLEFT", _G["Lootamelo_SettingsFrame"], "TOPLEFT", 55, -180);
       settingsTitle:SetText("Paste SoftRes \"WeakAura Data\" here:");
   end

   if not scrollFrame then
       scrollFrame = CreateFrame("ScrollFrame", "Lootamelo_SettingsFrameTextAreaScollFrame", settingsFrame, "UIPanelScrollFrameTemplate");
       settingsTextArea = CreateFrame("EditBox", "Lootamelo_SettingsFrameTextArea", scrollFrame);
       scrollFrame:SetSize(400, 160);
       scrollFrame:SetPoint("CENTER", settingsFrame, "CENTER", 0, -60);
       settingsTextArea:SetMultiLine(true);
       settingsTextArea:SetAutoFocus(true);
       settingsTextArea:SetSize(285, 230);
       settingsTextArea:SetFontObject(GameFontHighlight);
       scrollFrame:SetScrollChild(settingsTextArea);

       -- Imposta lo sfondo per lo ScrollFrame
       scrollFrame:SetBackdrop({
           bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
           insets = { left = -8, right = 0, top = -8, bottom = -8 }
       });
       
       settingsButton = CreateFrame("Button", "Lootamelo_SettingsFrameSettingsButton", settingsFrame, "UIPanelButtonTemplate");
       settingsButton:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -50, 30);
       settingsButton:SetSize(100, 30);
       settingsButton:SetText("Add");
       settingsButton:Disable();
   end

   settingsTextArea:SetScript("OnTextChanged", function(self)
       --UpdateSettingsButtonState();

       local scrollBar = _G[scrollFrame:GetName() .. "ScrollBar"];
       if scrollBar then
           local scrollMax = scrollBar:GetMinMaxValues();
           local currentScroll = scrollBar:GetValue();

           if currentScroll >= scrollMax then
               scrollFrame:SetVerticalScroll(scrollMax);
           end
       end
   end);

   settingsTextArea:SetScript("OnEscapePressed", function(self)
       self:ClearFocus();
   end);

   -- settingsButton:SetScript("OnClick", function()
   --     SettingsRun(settingsTextArea:GetText());
   -- end);
end


function Lootamelo_SettingsFrameInitDropDown()
   print("Lootamelo_SettingsFrameInitDropDown");
end