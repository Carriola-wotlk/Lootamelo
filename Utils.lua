function Lootamelo_Trim(s)
    return s:match'^%s*(.*%S)' or '';
end

function Lootamelo_ToLowerCase(s)
    return s:lower();
end

function Lootamelo_ToUpperCase(s)
    return s:upper();
end

function Lootamelo_GetItemByIdAndRaid(itemId)
    local raidData = Lootamelo_Items_Data[Lootamelo_Current_Raid];
    if not raidData then
        return nil;
    end

    for bossName, items in pairs(raidData) do
        for _, item in ipairs(items) do
            if item.id == itemId then
                return item;
            end
        end
    end

    return nil;
end