local listLength = 0;
local scrollFrame;
local slider;
local scrollChild;
local previousSelection = "Online";
local previousSpecFilter = "All specs";
local previousProfessionFilter = "All professions";
local previousKeySort = "";
local direction = 'ASC';
local currentKeySort = "";
local playerName = UnitName("player");
local playerRank = "";

function Lootamelo_SplitString(inputString)
    local words = {};
    for word in string.gmatch(inputString, "[^%s/-]+") do
        table.insert(words, Lootamelo_ToLowerCase(word));
    end
    return words;
end

function Lootamelo_RefreshMembers() --lasciare così questa funzione
    GuildRoster();

    -- set a true della variabile config guildShowOffline (se è disattivata, getNumGuildMembers torna solo il numero di player online)
    SetCVar("guildShowOffline", 1); --questo oltre a mostrare anche i membri offline trigghera GUILD_ROSTER_UPDATE
    SetCVar("guildShowOffline", 0);
end

function Lootamelo_DecodeNote(elements, result, name)
    local indexProf = 1;
    local indexSpec = 1;

    for i, element in ipairs(elements) do

        if element == "main" then
            result.isAlt = false;
        elseif element == "alt" then
            result.isAlt = true;
        else
            if Lootamelo_prof_table[element] ~= nil then
                if indexProf == 1 then
                    result["prof"].main = Lootamelo_prof_table[element];
                    indexProf = 2;
                elseif indexProf == 2 then
                    result["prof"].off = Lootamelo_prof_table[element];
                end
            elseif Lootamelo_spec_table[element] ~= nil then
                if indexSpec == 1 then
                    result["spec"].main = Lootamelo_spec_table[element];
                    indexSpec = 2;
                elseif indexSpec == 2 then
                    result["spec"].off = Lootamelo_spec_table[element];
                end
            elseif Lootamelo_guild_roster_names[element] then
                result.altOf = Lootamelo_guild_roster_names[element];
            end
        end

    end
end

function Lootamelo_GetMemberProps(idx, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class)
    local result = { idx = idx, name = name, lvl = lvl, cl = cl, zone = zone, note = note, offNote = offNote, online = online, status = status, class = class,
            rank =  Lootamelo_ToLowerCase(Lootamelo_Trim(rank)),
            rankIndex = rankIndex,
            prof = {},
            spec = {},
            isAlt = false,
            altOf = '',
        };
        
        -- ALT ha uno spazio alla fine
        -- todo: stringa da trimmare
        if rank == "ALT " then
            result.isAlt = true;
        end

    local elements = Lootamelo_SplitString(note);
    Lootamelo_DecodeNote(elements, result, name);
    return result;
end

function Lootamelo_InitNoteFrame()
    Lootamelo_note_frame = CreateFrame("Frame", "Lootamelo_Note_Frame", Lootamelo_main_frame);
    Lootamelo_note_frame:SetSize(256, 256);
    Lootamelo_note_frame:SetPoint("LEFT", Lootamelo_main_frame, "BOTTOMRIGHT", -15, 160);
    Lootamelo_note_frame:SetBackdrop({
        bgFile = "Interface\\AddOns\\Lootamelo\\texture\\frames\\finestra-laterale.tga",
        tile = false,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    Lootamelo_note_frame:SetFrameLevel(Lootamelo_main_frame:GetFrameLevel()-1);

    Lootamelo_note_frame_title = Lootamelo_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    Lootamelo_note_frame_title:SetPoint("TOPLEFT", Lootamelo_note_frame, "TOPLEFT", 30, -30);
    Lootamelo_note_frame_title:SetText("");

    local personalNotesLabel = Lootamelo_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    personalNotesLabel:SetPoint("TOPLEFT", Lootamelo_note_frame_title, "BOTTOMLEFT", 0, -15);
    personalNotesLabel:SetText("Note personali: ");

    Lootamelo_note_frame_personal_note = CreateFrame("EditBox", "MioAddonEditBox", Lootamelo_note_frame);
    Lootamelo_note_frame_personal_note:SetMultiLine(true);
    Lootamelo_note_frame_personal_note:SetFontObject(GameFontNormal);
    Lootamelo_note_frame_personal_note:SetWidth(200);
    Lootamelo_note_frame_personal_note:SetPoint("TOPLEFT", personalNotesLabel, "BOTTOMLEFT", 0, -3);
    Lootamelo_note_frame_personal_note:SetText("");
    Lootamelo_note_frame_personal_note:HighlightText();
    Lootamelo_note_frame_personal_note:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    Lootamelo_note_frame_personal_note:SetTextInsets(8, 8, 8, 8);
    Lootamelo_note_frame_personal_note:SetMaxLetters(40);

    local officerNotesLabel = Lootamelo_note_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    officerNotesLabel:SetPoint("TOPLEFT",  Lootamelo_note_frame_personal_note, "BOTTOMLEFT", 0, -12);
    officerNotesLabel:SetText("Note officer: ");

    Lootamelo_note_frame_officer_note = CreateFrame("EditBox", "MioAddonEditBox", Lootamelo_note_frame);
    Lootamelo_note_frame_officer_note:SetMultiLine(true);
    Lootamelo_note_frame_officer_note:SetFontObject(GameFontNormal);
    Lootamelo_note_frame_officer_note:SetWidth(200);
    Lootamelo_note_frame_officer_note:SetPoint("TOPLEFT", officerNotesLabel, "BOTTOMLEFT", 0, -3);
    Lootamelo_note_frame_officer_note:SetText("");
    Lootamelo_note_frame_officer_note:HighlightText();
    Lootamelo_note_frame_officer_note:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    Lootamelo_note_frame_officer_note:SetTextInsets(8, 8, 8, 8);
    Lootamelo_note_frame_officer_note:SetMaxLetters(40);

    local closeButton = CreateFrame("Button", "SaveButton", Lootamelo_note_frame, "UIPanelButtonTemplate");
    closeButton:SetSize(80, 25);
    closeButton:SetText("Chiudi");
    closeButton:SetPoint("BOTTOMLEFT", Lootamelo_note_frame, "BOTTOMLEFT", 30, 25);

    closeButton:SetScript("OnClick", function()
        Lootamelo_note_frame_title:SetText("");
        Lootamelo_note_frame_personal_note:SetText("");
        Lootamelo_note_frame_officer_note:SetText("");
        Lootamelo_note_frame:Hide();
    end);

    Lootamelo_note_frame_save = CreateFrame("Button", "SaveButton", Lootamelo_note_frame, "UIPanelButtonTemplate");
    Lootamelo_note_frame_save:SetSize(80, 25);
    Lootamelo_note_frame_save:SetText("Salva");
    Lootamelo_note_frame_save:SetPoint("LEFT", closeButton, "RIGHT", 10, 0);

    Lootamelo_note_frame:Hide();
end

function Lootamelo_OpenEditNote(name, idx, note)
    Lootamelo_note_frame:Show();
    Lootamelo_note_frame_title:SetText(Lootamelo_ToUpperCase(name));

    if note:match("^(.-)\n\n(.+)$") then
        local personal, officer = note:match("^(.-)\n\n(.+)$");
        Lootamelo_note_frame_personal_note:SetText(personal);
        Lootamelo_note_frame_officer_note:SetText(string.sub(officer, 14));
    else 
        Lootamelo_note_frame_personal_note:SetText(note);
        Lootamelo_note_frame_officer_note:SetText("");
    end

    Lootamelo_note_frame_save:SetScript("OnClick", function()
        local personalNotes = Lootamelo_note_frame_personal_note:GetText();
        local officerNotes = Lootamelo_note_frame_personal_note:GetText();

        GuildRosterSetPublicNote(idx, personalNotes);
        GuildRosterSetOfficerNote(idx, officerNotes);

        Lootamelo_note_frame_title:SetText("");
        Lootamelo_note_frame_personal_note:SetText("");
        Lootamelo_note_frame_officer_note:SetText("");
        Lootamelo_note_frame:Hide();
        Lootamelo_RefreshMembers();
    end);

end

function Lootamelo_ClearMemberRow()
    for idx = 1, 13 do
        _G["Lootamelo_Member" .. idx .. "_ClassIcon_Texture"]:SetTexture(nil);
        _G["Lootamelo_Member" .. idx .. "_Name_Text"]:SetText(nil);
        _G["Lootamelo_Member" .. idx .. "_Level_Text"]:SetText(nil);
        _G["Lootamelo_Member" .. idx .. "_MainSpec_Texture"]:SetTexture(nil);
        _G["Lootamelo_Member" .. idx .. "_OffSpec_Texture"]:SetTexture(nil);
        _G["Lootamelo_Member" .. idx .. "_MainProf_Texture"]:SetTexture(nil);
        _G["Lootamelo_Member" .. idx .. "_OffProf_Texture"]:SetTexture(nil);
        _G["Lootamelo_Member" .. idx .. "_Zone_Text"]:SetText(nil);
        _G["Lootamelo_Member" .. idx .. "_Main_Text"]:SetText(nil);
        _G["Lootamelo_Member" .. idx .. "_Rank_Texture"]:SetTexture(nil);
        _G["Lootamelo_Member" .. idx .. "_Note"]:SetScript("OnEnter", nil);
        _G["Lootamelo_Member" .. idx .. "_Note"]:SetScript("OnLeave", nil);
        _G["Lootamelo_Member" .. idx .. "_Note"]:SetScript("OnClick", nil);
        _G["Lootamelo_Member" .. idx .. "_Note"]:Hide();
        _G["Lootamelo_Member" .. idx .. "_Invite"]:Hide();
        _G["Lootamelo_Member" .. idx .. "_Whisper"]:Hide();
    end
end


function Lootamelo_MemberListUpdate(index)
    Lootamelo_ClearMemberRow()
    local cycle = #Lootamelo_guild_roster_filtered;

    if cycle > 13 then
        cycle = 13;
    end

    for idx = 1, cycle do
        local memberFrame = _G["Lootamelo_Member" .. idx];

        if Lootamelo_section == 'offline' then
            memberFrame:SetAlpha(0.6);
        else
            memberFrame:SetAlpha(1);
        end

        local classIconTexture = _G[memberFrame:GetName() .. "_ClassIcon_Texture"];
        if Lootamelo_guild_roster_filtered[idx+index].name == 'Cipollino' then
            classIconTexture:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\Cipollino]]);
        else
            classIconTexture:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\]] .. Lootamelo_guild_roster_filtered[idx+index].class);
        end
        
        local name = _G[memberFrame:GetName() .. "_Name_Text"];
        name:SetText(Lootamelo_guild_roster_filtered[idx+index].name);

        local lvl = _G[memberFrame:GetName() .. "_Level_Text"];
        lvl:SetText(Lootamelo_guild_roster_filtered[idx+index].lvl);

        if(Lootamelo_guild_roster_filtered[idx+index].spec.main) then
            _G[memberFrame:GetName() .. "_MainSpec_Texture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\]] .. Lootamelo_guild_roster_filtered[idx+index].spec.main .. Lootamelo_guild_roster_filtered[idx+index].class);
        end

        if(Lootamelo_guild_roster_filtered[idx+index].spec.off) then
            _G[memberFrame:GetName() .. "_OffSpec_Texture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\]] .. Lootamelo_guild_roster_filtered[idx+index].spec.off .. Lootamelo_guild_roster_filtered[idx+index].class);
        end
        
        if(Lootamelo_guild_roster_filtered[idx+index].prof.main) then
            local mainProf = _G[memberFrame:GetName() .. "_MainProf"];
            local prof = Lootamelo_guild_roster_filtered[idx+index].prof.main
            _G[memberFrame:GetName() .. "_MainProf_Texture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\]] .. Lootamelo_guild_roster_filtered[idx+index].prof.main);

            mainProf:SetScript("OnClick", function()
                local msg = "Req:" .. prof;
                SendAddonMessage(Lootamelo_channel, msg, "WHISPER", Lootamelo_guild_roster_filtered[idx+index].name);
            end)
        end

        if(Lootamelo_guild_roster_filtered[idx+index].prof.off) then
            local offProf = _G[memberFrame:GetName() .. "_OffProf"];
            local prof = Lootamelo_guild_roster_filtered[idx+index].prof.off
            _G[memberFrame:GetName() .. "_OffProf_Texture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\]] .. Lootamelo_guild_roster_filtered[idx+index].prof.off);

            offProf:SetScript("OnClick", function()
                local msg = "Req:" .. prof;
                SendAddonMessage(Lootamelo_channel, msg, "WHISPER", Lootamelo_guild_roster_filtered[idx+index].name);
            end)
        end

        local zone = _G[memberFrame:GetName() .. "_Zone_Text"];

        local zoneText = Lootamelo_guild_roster_filtered[idx + index].zone;

        if string.len(zoneText) > 21 then
            zoneText = string.sub(zoneText, 1, 21) .. "...";
        end
        zone:SetText(zoneText);

        if Lootamelo_section == 'offline' then
                name:SetTextColor(0.5, 0.5, 0.5);
                lvl:SetTextColor(0.5, 0.5, 0.5);
                zone:SetTextColor(0.5, 0.5, 0.5);
        else
                name:SetTextColor(0.9, 0.9, 0.9);
                lvl:SetTextColor(0.9, 0.9, 0.9);
                zone:SetTextColor(0.9, 0.9, 0.9);
        end

        local invite = _G[memberFrame:GetName() .. "_Invite"];
        local whisper = _G[memberFrame:GetName() .. "_Whisper"];

        if Lootamelo_section == 'offline' then
            invite:Hide();
            whisper:Hide();
        else
            invite:Show();
            whisper:Show();

            invite:SetScript("OnClick", function()
                InviteUnit(Lootamelo_guild_roster_filtered[idx+index].name);
            end)

            whisper:SetScript("OnClick", function()
                ChatFrame_SendTell(Lootamelo_guild_roster_filtered[idx+index].name);
            end)
        end

        _G[memberFrame:GetName() .. "_Rank_Texture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\rank_]] .. Lootamelo_guild_roster_filtered[idx+index].rank);

        if(Lootamelo_guild_roster_filtered[idx+index].altOf) then
            local main = _G[memberFrame:GetName() .. "_Main_Text"];
            main:SetText(Lootamelo_guild_roster_filtered[idx+index].altOf);
            main:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE");
            main:SetTextColor(0.7, 0.7, 0.7);
        end
        
        local note = _G[memberFrame:GetName() .. "_Note"];
        note:Show();

        local textNote = Lootamelo_guild_roster_filtered[idx+index].note;
        if(Lootamelo_guild_roster_filtered[idx+index].offNote ~= "") then
            textNote = textNote .. "\n\nOfficer Note: " ..  Lootamelo_guild_roster_filtered[idx+index].offNote
        end
        note:SetScript("OnEnter", function(self)
           
            GameTooltip:SetOwner(self, "ANCHOR_TOP");
            GameTooltip:SetWidth(400);
            GameTooltip:SetText(textNote, 1, 1, 1, true);
            GameTooltip:Show();
        end)

        note:SetScript("OnLeave", function()
            GameTooltip:Hide();
        end)

        if(playerRank == "guild master" or Lootamelo_Rank_Edit_Note[playerRank])then
            note:SetScript("OnClick", function ()
                Lootamelo_OpenEditNote(Lootamelo_guild_roster_filtered[idx+index].name, Lootamelo_guild_roster_filtered[idx+index].note);
            end)
        end

    end
end


function Lootamelo_MemberListInit()
    for idx = 1, 13 do
        local item = CreateFrame("Frame", "Lootamelo_Member" .. idx, Lootamelo_members_frame, "Lootamelo_Member_Template");

        if idx == 1 then
            item:SetPoint("TOP", 0, -60);
        else
            item:SetPoint("TOP", _G["Lootamelo_Member" .. idx-1], "BOTTOM", 0, 0);
        end
    end
    Lootamelo_is_first_open = false;
    Lootamelo_MemberListUpdate(0);
end


function Lootamelo_MembersScrollBarInit()
    scrollFrame = CreateFrame("ScrollFrame", "Lootamelo_Main_Frame_Members_ScrollFrame", Lootamelo_members_frame, "UIPanelScrollFrameTemplate");
    slider = CreateFrame("Slider", "Lootamelo_Main_Frame_Members_Slider", scrollFrame, "OptionsSliderTemplate");
    scrollChild = CreateFrame("Frame", "Lootamelo_Main_Frame_Members_ScrollChild", scrollFrame);
    Lootamelo_members_frame.scrollFrame = scrollFrame;
    Lootamelo_members_frame.slider = slider;
    scrollFrame:SetPoint("CENTER", Lootamelo_members_frame, "CENTER", 0, -10);
    scrollFrame:SetSize(768, 430);
    scrollFrame:EnableMouseWheel(true);

    slider:SetSize(25, 445);
    slider:SetPoint("LEFT", Lootamelo_members_frame, "RIGHT", 0, -10);
    slider:SetBackdrop({
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 },
    });
    _G[slider:GetName() .. 'Low']:SetText('');
    _G[slider:GetName() .. 'High']:SetText('');
end


function Lootamelo_MembersScrollBarUpdate()
    local minValue = 1;
    local addValue = 0;
    if listLength > 13 and (listLength-13) % 5 ~= 0 then
        addValue = (5 - ((listLength - 13) % 5)) * 32;
    end
    local maxValue = (listLength*32) + addValue;
    scrollChild:SetSize(665, maxValue);
    scrollChild:SetPoint("RIGHT", Lootamelo_members_frame, "LEFT", 0, 0);
    scrollFrame:SetScrollChild(scrollChild);

    local stepSize = 5 * 32;

    scrollFrame:SetScript("OnVerticalScroll", function(self, value)
        local newValue = math.max(160, math.floor(value / stepSize + 0.5) * stepSize);
        newValue = math.min(maxValue, math.max(minValue, newValue));

        if(value == 0) then
            Lootamelo_MemberListUpdate(0);
        else
            Lootamelo_MemberListUpdate(newValue / 32);
        end
    end)
end

function Lootamelo_GuildRoster_Sorted()
        if(previousKeySort ~= currentKeySort) then
            direction = "ASC";
        elseif direction == "ASC" then
            direction = "DESC";
        else
            direction = "ASC";
        end

        table.sort(Lootamelo_guild_roster_filtered, function(a, b)
            if direction == "ASC" then
                return a[currentKeySort] < b[currentKeySort];
            else
                return a[currentKeySort] > b[currentKeySort];
            end
        end)

        previousKeySort = currentKeySort;
end

function Lootamelo_MembersFrameInit()
    Lootamelo_GuildRoster_Filtered();

    if currentKeySort ~= "" then
        Lootamelo_GuildRoster_Sorted();
    end

    listLength = #Lootamelo_guild_roster_filtered;

    if(Lootamelo_navBar_current_button == "membri") then
        Lootamelo_ShowMembersFrame();
    end

    if(Lootamelo_is_first_open) then
        Lootamelo_MembersScrollBarInit();
        Lootamelo_MemberListInit();
    end

    Lootamelo_MembersScrollBarUpdate();
    Lootamelo_MemberListUpdate(0);
end

function Lootamelo_BuildArrayOfName(maxMembers)
    for i = 1, maxMembers do
        local name = GetGuildRosterInfo(i);
        if name ~= nil then
            Lootamelo_guild_roster_names[string.lower(name)] = name;
        end
    end
end

function Lootamelo_RosterBuild()
    Lootamelo_rosterInProgress = true;

    SetCVar("guildShowOffline", 1);
    Lootamelo_guild_roster["online"] = {};
    Lootamelo_guild_roster["offline"] = {};
    local maxMembers = GetNumGuildMembers();
 
    if maxMembers ~= nil then
       Lootamelo_BuildArrayOfName(maxMembers)
        for i = 1, maxMembers do
            local name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class = GetGuildRosterInfo(i);
            if name ~= nil then
               if name == playerName then
                   playerRank = Lootamelo_ToLowerCase(Lootamelo_Trim(rank));
               end
               if online == 1 then
                   table.insert(Lootamelo_guild_roster["online"], Lootamelo_GetMemberProps(i, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class));
               else
                   table.insert(Lootamelo_guild_roster["offline"], Lootamelo_GetMemberProps(i, name, rank, rankIndex, lvl, cl, zone, note, offNote, online, status, class));
               end
            end
        end
        _G["Lootamelo_Main_Frame_Members_RosterStatus"]:SetText("Online: " .. #Lootamelo_guild_roster["online"] .. "/" .. #Lootamelo_guild_roster["online"]+#Lootamelo_guild_roster["offline"]);
        Lootamelo_MembersFrameInit();
    end
    SetCVar("guildShowOffline", 0);
    Lootamelo_rosterInProgress = false;
end
