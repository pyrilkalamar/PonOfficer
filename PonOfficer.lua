
SlashCmdList["PONOFFICER"] = PO_Slash_Handler;
SLASH_PONOFFICER1 = "/po";
SLASH_PONOFFICER1 = "/pon";

local font = CreateFont('PO_MainFont');
font:SetFont("Fonts\\ARIALN.TTF", 12);
font:SetJustifyH('LEFT');
font:SetTextColor(1, 1, 1);

local bluefont = CreateFont('PO_BlueFont');
bluefont:SetFont("Fonts\\ARIALN.TTF", 15);
bluefont:SetJustifyH('CENTER');
bluefont:SetTextColor(0, 0, 1);


local greenfont = CreateFont('PO_GreenFont');
greenfont:SetFont("Fonts\\ARIALN.TTF", 12);
greenfont:SetJustifyH('LEFT');
greenfont:SetTextColor(0, 1, 0);

local redfont = CreateFont('PO_RedFont');
redfont:SetFont("Fonts\\ARIALN.TTF", 12);
redfont:SetJustifyH('LEFT');
redfont:SetTextColor(1, 0, 0);

local frame = CreateFrame("Frame","PonOfficer",UIParent);
frame:SetScript('OnEvent', PO_OnEvent);
frame:RegisterEvent('LOOT_OPENED');
frame:RegisterEvent('OPEN_MASTER_LOOT_LIST');
frame:RegisterEvent('CHAT_MSG_ADDON');
--frame:RegisterEvent('RAID_ROSTER_UPDATE');
frame:RegisterEvent('CHAT_MSG_WHISPER');
frame:RegisterEvent('CHAT_MSG_RAID');
frame:RegisterEvent('CHAT_MSG_RAID_LEADER');
frame:RegisterEvent('GROUP_ROSTER_UPDATE');
frame:RegisterEvent('CHAT_MSG_SYSTEM');
frame:RegisterEvent('CHAT_MSG_BN_WHISPER');

PO_LootClicksEnabled = 0;

--[[
local lootframe = CreateFrame("Frame", "PonLoot", UIParent)
lootframe:Hide();
lootframe:SetWidth(120);
lootframe:SetHeight(310);
lootframe:SetFrameStrata('HIGH');
lootframe:SetPoint("CENTER", 0, 0);

lootframe:SetBackdrop({bgFile="Interface\\AddOns\\PonOfficer\\white.tga", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", "yes", tileSize=16, edgeSize=16, insets = { left = 3, right = 3, top = 3, bottom = 3}})
lootframe:SetBackdropColor(0,0,0,.85)

local closebutton = CreateFrame("Button", "$parentClose", lootframe, 'UIPanelCloseButton');
closebutton:SetWidth(32);
closebutton:SetHeight(32);
closebutton:SetPoint('TOPRIGHT', lootframe, 'TOPRIGHT', 0, 0);
closebutton:SetScript('OnClick', function(self) PO_EndLoot(); end);

local i = 0;

for y=1,25 do
	local nb = CreateFrame("Button","$parent" .. y, lootframe);
	nb:SetWidth(110);
	nb:SetHeight(12);
	nb:SetFrameStrata("HIGH");
	nb:EnableMouse(true);
	nb:SetNormalFontObject(font);
	nb:SetScript('OnClick', function(self) PO_GiveLoot(self); end);
	--nb:SetText(y);
	nb:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight");
	
	local xOffset = 5;
	local yOffset = (5 + (12 * (y-1))) * -1;
	
	nb:SetPoint("TOPLEFT", lootframe, "TOPLEFT", xOffset, yOffset);
	
	i = i + 1;
end]]

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", PO_FilterMsg);

local rollframe = CreateFrame("Frame", "PonLoot", UIParent)
rollframe:Hide();
rollframe:SetWidth(230);
rollframe:SetHeight(450);
rollframe:SetFrameStrata('HIGH');
rollframe:SetPoint("CENTER", UIParent, 'CENTER', 300, 0);
rollframe:EnableMouse(1);
rollframe:SetMovable(1);
rollframe:SetScript('OnMouseDown', function(self) self:StartMoving(); end);
rollframe:SetScript('OnMouseUp', function(self) self:StopMovingOrSizing(); end);


--rollframe:SetBackdrop({bgFile="Interface\\AddOns\\PonOfficer\\white.tga", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", "yes", tileSize=16, edgeSize=16, insets = { left = 3, right = 3, top = 3, bottom = 3}})
rollframe:SetBackdrop({bgFile="Interface\\AddOns\\PonOfficer\\white.tga", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", "yes", tileSize=16, edgeSize=32, insets = { left = 3, right = 3, top = 3, bottom = 3}})
rollframe:SetBackdropColor(0,0,0,.85)

local closebutton = CreateFrame("Button", "$parentClose", rollframe, 'UIPanelCloseButton');
closebutton:SetWidth(32);
closebutton:SetHeight(32);
closebutton:SetPoint('TOPRIGHT', rollframe, 'TOPRIGHT', 0, 0);
closebutton:SetScript('OnClick', function(self) self:GetParent():Hide(); PO_EndLoot(); end);

for y=1,27 do
	local nb = CreateFrame("Button","$parent" .. y, rollframe);
	nb:SetWidth(110);
	nb:SetHeight(15);
	nb:SetFrameStrata("HIGH");
	nb:EnableMouse(true);
	nb:SetNormalFontObject(PO_MainFont);
	nb:SetScript('OnClick', function(self) PO_GiveLoot(self); end);
	nb:SetText(y);
	nb:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight");
	
	local xOffset = 15;
	local yOffset = (15 + (15 * (y-1))) * -1;
	
	nb:SetPoint("TOPLEFT", rollframe, "TOPLEFT", xOffset, yOffset);
end

for y=1,26 do
	local nb2 = CreateFrame("Button","$parentGreed" .. y, rollframe);
	nb2:SetWidth(110);
	nb2:SetHeight(15);
	nb2:SetFrameStrata("HIGH");
	nb2:EnableMouse(true);
	nb2:SetNormalFontObject(PO_MainFont);
	
	if (y < 26) then
		nb2:SetScript('OnClick', function(self) PO_GreedLoot(self); end);
	else
		nb2:SetScript('OnClick', function(self) PO_DELoot(self); end);
	end
	nb2:SetText(y);
	nb2:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight");
	
	local xOffset = -15;
	local yOffset = (15 + (15 * (y-1))) * -1;
	nb2:SetPoint("TOPRIGHT", rollframe, "TOPRIGHT", xOffset, yOffset);
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", PO_FilterMsg);

local importframe = CreateFrame("Frame", "PonImport", UIParent)
importframe:Hide();
importframe:SetWidth(400);
importframe:SetHeight(300);
importframe:SetFrameStrata('HIGH');
importframe:SetPoint("CENTER", 0, 0);
importframe:SetBackdrop({bgFile="Interface\\AddOns\\PonOfficer\\white.tga", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", "yes", tileSize=16, edgeSize=16, insets = { left = 3, right = 3, top = 3, bottom = 3}})
importframe:SetBackdropColor(0,0,0,.85)

local closebutton = CreateFrame("Button", "$parentClose", importframe, 'UIPanelCloseButton');
closebutton:SetWidth(32);
closebutton:SetHeight(32);
closebutton:SetPoint('TOPRIGHT', importframe, 'TOPRIGHT', 0, 0);
closebutton:SetScript('OnClick', function(self) self:GetParent():Hide(); end);

local editbox = CreateFrame("Editbox", "$parentData", importframe);
editbox:SetPoint('TOPLEFT', importframe, 'TOPLEFT', 5, -5);
editbox:SetPoint('BOTTOMRIGHT', importframe, 'BOTTOMRIGHT', -5, 30);
editbox:SetFontObject(PO_MainFont);
editbox:SetMultiLine(1);

local importbutton = CreateFrame("Button", "$parentImport", importframe, 'UIPanelButtonTemplate');
importbutton:SetWidth(100);
importbutton:SetHeight(22);
importbutton:SetPoint('BOTTOMRIGHT', importframe, 'BOTTOMRIGHT', -5, 5);
importbutton:SetText('Import');
importbutton:SetScript('OnClick', PO_Import);

PO_Raiders = {}
PO_FnF     = {}
PO_Other   = {}
PO_Greed   = {}

if (PoNDB == nil) then
	PoNDB = {}
end

PONOFFICERVERSION = 1.1;