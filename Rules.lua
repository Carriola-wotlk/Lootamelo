local testo_regolamento = "REGOLA PRINCIPALE DELLA GILDA\nLa gilda segue un ideale di reciproco rispetto, quindi rispettate sempre i gildani, il loro modo di pensare e comportatevi in modo cordiale. Stessa cosa con i player esterni alla gilda (persone incontrate in pug, dungeon, world, ecc), quando vi relazionate con qualcuno siete responsabili dell'immagine della gilda. Tutti i membri che non rispetteranno questo modo di pensare potranno subire una sospensione temporanea o permanente, sia dalla gilda che dal discord ufficiale. È una gilda 18+, quindi sono autorizzati comportamenti e dialoghi maturi. Se questo può arrecare offesa, non puoi essere un membro della nostra gilda. Ci si esime da qualsivoglia responsabilità.\n\nPROGRESS ED OBIETTIVI\nGli obiettivi di gilda sono attualmente quelli di creare un gruppo coeso di giocatori che possa più avanti nel progress avere la possibilità di ottenere reward col minor sforzo possibile. Siamo prevalentemente una gilda soft-core PvE , ma sono presenti gruppi ed utenti che si dedicano con passione anche al PvP (Battleground e Arene).\n\nRANKS E RUOLI\nRicordiamo che l'iter di assegnazione dei Ruoli su Discord e in-Game diverge, a causa della necessità di poter taggare determinate categorie di giocatori nei thread del canale.\n\nDopo la gildatura iniziale ti sarà assegnato automaticamente il Rank di Recluta. Al fine di ottenere la promozione al Rank Membro, in game, è necessario raggiungere dell'attuale level cap senza alcun richiamo formale. Inoltre la permanenza in gilda deve essere almeno pari e non inferiore ai 15gg. Una volta raggiunto il grado di membro (in game e su discord) sarai ufficialmente parte della gilda e non più in prova.\nIl rank Raider è identificativo dei giocatori che partecipano con continuità ai raid e viene assegnato a coloro che hanno fatto richiesta tramite apply per partecipare ai raid. Chiunque dimostri interesse può compilare una apply (15 domande veloci a risposta multipla o aperta) tramite l'apposito canale su discord. Le risposte della tua apply saranno visionate dal reparto Officer, i quali decideranno se approvare la tua richiesta o meno, quindi occhio a ciò che scrivi. Se la tua richiesta sarà approvata, otterrai il rank Raider e potrai accedere liberamente a tutti gli eventi organizzati dalla gilda."


function Lootamelo_ShowRulesFrame()
    _G["Lootamelo_Button1_NormalTexture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\buttons\button-normal]]);
    _G["Lootamelo_Button2_NormalTexture"]:SetTexture([[Interface\AddOns\Lootamelo\texture\buttons\button-press]]);
    _G["Lootamelo_main_texture_bottom_right"]:SetTexture([[Interface\AddOns\Lootamelo\texture\frames\regolamento-bottom-right]]);
    _G["Lootamelo_main_texture_top_right"]:SetTexture([[Interface\AddOns\Lootamelo\texture\frames\regolamento-top-right]]);
    _G["Lootamelo_Main_Frame_Rules"]:Show();
    _G["Lootamelo_Main_Frame_Members"]:Hide();
end


function Lootamelo_RulesFrameInit()
    local rulesFrame = CreateFrame("Frame", "Lootamelo_Main_Frame_Rules", Lootamelo_main_frame)
    rulesFrame:SetSize(450, 400);
    rulesFrame:SetPoint("CENTER", -40, 0);
    rulesFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    });
    rulesFrame:EnableMouse(true);

    local scrollChild = CreateFrame("Frame", "Lootamelo_Main_Frame_Members_ScrollChild", rulesFrame);
    scrollChild:SetPoint("CENTER", rulesFrame, "CENTER", 0, 0);

    -- Creazione della texture per il testo
    local scrollText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal");
    scrollText:SetSize(400, 550); -- Imposta la dimensione in base alle tue esigenze
    scrollText:SetPoint("TOP", scrollChild, "TOP", 10, 0);
    scrollText:SetJustifyH("LEFT");
    scrollText:SetJustifyV("TOP");
    scrollText:SetText(testo_regolamento);

    -- Creazione del frame di scorrimento
    local scrollFrame = CreateFrame("ScrollFrame", "MyGuildScrollFrame", rulesFrame, "UIPanelScrollFrameTemplate");
    scrollFrame:SetPoint("TOPLEFT", rulesFrame, "TOPLEFT", 10, -10);
    scrollFrame:SetPoint("BOTTOMRIGHT", rulesFrame, "BOTTOMRIGHT", -30, 10);
    scrollFrame:SetScrollChild(scrollChild);

    -- Aggiorna la dimensione del scrollChild in base al testo
    scrollChild:SetSize(380, scrollText:GetStringHeight());
end

