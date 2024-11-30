function Lootamelo_Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function Lootamelo_ToLowerCase(s)
    return s:lower();
end

function Lootamelo_ToUpperCase(s)
    return s:upper();
end

function Lootamelo_OnLoad(self)
    self.items = {};
    for idx, value in ipairs(Lootamelo_navBar) do
        local item = CreateFrame("Button", "Lootamelo_Button" .. idx, self, "LootameloMenuButtonTemplate");
        self.items[idx] = item;
        _G["Lootamelo_Button" .. idx .. "_Voice"]:SetText(value);
        _G["Lootamelo_Button" .. idx .. "_Voice"]:SetTextColor(0.2, 0.2, 0.2);
        _G["Lootamelo_Button" .. idx .. "_IconTexture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\icons\]] .. value .. "_icon");

        if idx == 1 then
            item:SetPoint("LEFT", 23, -40);
            _G["Lootamelo_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\buttons\button-press]]);
        else
            item:SetPoint("TOPLEFT", self.items[idx-1], "BOTTOMLEFT", 0, -8);
        end
    end
end

