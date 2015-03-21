-- realmName = GetRealmName()
-- ponranks functions (converted)
-- Update below line when you're about to upload this:
updateTime = 'Version: 3/6/14 8:04PM PT for Patch 5.4.7'

function isMatchingName(name1, name2)
	return (string.upper(name1) == string.upper(name2) or 
		string.upper(name1) == string.upper(name2 .. '-' .. GetRealmName()) or 
		string.upper(name1 .. '-' .. GetRealmName()) == string.upper(name2))
end

function PO_RanksPromote()
	if (UnitIsGroupLeader("player")) and CanGuildPromote() then
		-- go thru raid members
		for rIndex=1,GetNumGroupMembers() do
			local rName = GetRaidRosterInfo(rIndex);
			-- see if they are in guild
			if (PO_IsInGuild(rName)) then
				
				for gIndex=1,GetNumGuildMembers() do
					-- get their current rank
					
					local gName, _, rankIndex, _, _, _, _, officerNote = GetGuildRosterInfo(gIndex)
					rankIndex = rankIndex + 1; -- adjust to 1-based
					
					if (string.upper(rName .. '-' .. GetRealmName()) == string.upper(gName)) then
						if (rankIndex > 4) then -- rank 4 is "guild repair" rank
							-- set guild note
							local newNote = 'R['..rankIndex..']' .. officerNote;
							GuildRosterSetOfficerNote(gIndex, newNote);
							-- promote
							SetGuildMemberRank(gIndex, 4);
						end
					end
				end
			end
		end
	else
		PO_Msg('You must be raid leader with guild promote privileges in order to promote.');
	end
end

function PO_RanksDemote()
	if (UnitIsGroupLeader("player")) and CanGuildDemote() then
		-- go thru raid members
		for rIndex=1,GetNumGroupMembers() do
			local rName = GetRaidRosterInfo(rIndex);
			-- see if they are in guild
			if (PO_IsInGuild(rName)) then
				for gIndex=1,GetNumGuildMembers() do
					-- get their previous rank
					local gName, _, rankIndex, _, _, _, _, officerNote = GetGuildRosterInfo(gIndex);
					if (isMatchingName(gname, rname)) and (string.match(officerNote, 'R%[%d+%]')) then
						local oldRank = string.match(officerNote, 'R%[(%d+)%]');
						local old = 'R%[%d+%]';
						local newNote = string.gsub(officerNote, old, '');
						
						--local oldRank = tonumber(oldRank) + 1;
						
						GuildRosterSetOfficerNote(gIndex, newNote);
						SetGuildMemberRank(gIndex, oldRank);
					end
				end
			end
		end
	else
		PO_Msg('You must be raid leader with guild demote privileges in order to demote.');
	end
end

function PO_RanksDemoteAll()
    if CanGuildDemote() then
        for gIndex=1,GetNumGuildMembers() do
            -- get their previous rank
            local gName, _, rankIndex, _, _, _, _, officerNote = GetGuildRosterInfo(gIndex);
            if (string.match(officerNote, 'R%[%d+%]')) then
                local oldRank = string.match(officerNote, 'R%[(%d+)%]');
                local old = 'R%[%d+%]';
                local newNote = string.gsub(officerNote, old, '');
                --local oldRank = tonumber(oldRank) + 1;
                GuildRosterSetOfficerNote(gIndex, newNote);
                SetGuildMemberRank(gIndex, oldRank);
            end
        end
    else
        PO_Msg('You must have guild demote privileges in order to demote.');
    end
end

-- end ponranks

function PO_GetMasterLooter()
	for i=1,40 do
		name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (isML) then
			return name;
		end
	end
	return nil;
end

function PO_IsOfficer(player)
	if (player) then
		local numTotal = GetNumGuildMembers(true);
		for i=1,numTotal do
			local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
			if (isMatchingName(name, player)) then
				if (rankIndex <= 2) then
					return true;
				else
					return nil;
				end
			end
		end
	end
end

function PO_FilterMsg(frame, event, msg)
	if string.sub(msg, 0, 5) == '[PoN]' then
		return true;
	else
		return false;
	end
end

function PO_StartRoll()
	PO_Announce('NOW ROLLING: ' .. PO_CurrentRollItem.itemLink);
	SendAddonMessage('PON', 'START_ROLL/' .. PO_CurrentRollItem.itemLink, 'RAID');
end

function PO_GetClass(player)
	local numTotal = GetNumGuildMembers(true);
	for i=1,numTotal do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if (isMatchingName(name, player)) then
			return class;
		end
	end
end

function PO_GetGuildieInfo(player)
	local numTotal = GetNumGuildMembers(true);
	for i=1,numTotal do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if (isMatchingName(name, player)) then
			return rankIndex, officernote;
		end
	end
	return nil;
end

function PO_IsInGuild(player)
	local numTotal = GetNumGuildMembers(true);
	for i=1,numTotal do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if (isMatchingName(name, player)) then
			return true;
		end
	end
	return nil;
end

function PO_IsInRaid(player)
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (isMatchingName(name, player)) then
			return true;
		end
	end
	return nil;
end

function PO_GetRaidGroupNum()
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (isMatchingName(name, UnitName('player'))) then
			return tonumber(subgroup);
		end
	end
	
	return 0;
end

function PO_ClassColor(class)
	class = string.upper(class);
	local val = '';
	if (class == 'DRUID') then
		val = 'FF7D0A';
	elseif (class == 'HUNTER') then
		val = 'ABD473';
	elseif (class == 'MAGE') then
		val = '69CCF0';
	elseif (class == 'PALADIN') then
		val = 'F58CBA';
	elseif (class == 'PRIEST') then
		val = 'FFFFFF';
	elseif (class == 'ROGUE') then
		val = 'FFF569';
	elseif (class == 'SHAMAN') then
		val = '2459FF';
	elseif (class == 'WARLOCK') then
		val = '9482CA';
	elseif (class == 'WARRIOR') then
		val = 'C79C6E';
	else
		val = 'C41F3B';
		-- DK
	end
	
	return "|cff" .. val;
end

function PO_IncreaseAttendance()
	local numTotal = GetNumGuildMembers(true);
	for i=1,numTotal do
		local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i);
		if (string.match(officerNote, 'P%[[%d%-]+%]')) then
			local currentPoints = string.match(officerNote, 'P%[([%d%-]+)%]');
			if (string.len(currentPoints) < 10) then
				currentPoints = '----------';
			end
			
			local newAttendance = '';
			if (PO_IsInRaid(name)) then
				newAttendance = '0' .. string.sub(currentPoints, 1, 9);
			else
				newAttendance = '-' .. string.sub(currentPoints, 1, 9);
			end
			--PO_Msg('New Attendance: ' .. name .. '/' .. currentPoints .. '/' .. newAttendance);
			
			local new = 'P[' .. newAttendance .. ']';
			
			local old = 'P%[[%d%-]+%]';
			local newnote = string.gsub(officerNote, old, new);
			GuildRosterSetOfficerNote(i, newnote);
		end
	end
	PO_Msg('Attendance Updated');
end

function PO_Slash_Handler(msg)
	argv = {};
	
	for arg in string.gmatch(string.lower(msg), '[^%s]+') do
		table.insert(argv, arg);
	end
	
	if (argv[1] == 'setde') or (argv[1] == 'de') then
		SendAddonMessage('PON', 'NEW_DE/'..argv[2], 'RAID');
		PO_UpdateGreeds();
	elseif (argv[1] == 'getde') then
		PO_Msg('Current Disenchanter is: ' .. PoNDB['disenchanter']);
	elseif (argv[1] == 'import') then
		PonImport:Show();
	elseif (argv[1] == 'attendance') then
		PO_IncreaseAttendance();
		elseif (argv[1] == 'ranks') then
		PO_AnnounceRanks();
	elseif (argv[1] == 'version') then
		--SendAddonMessage('PON', 'VERSION_CHECK', 'RAID');
        PO_Msg(updateTime)
	elseif (argv[1] == 'promote') then
		PO_RanksPromote();
	elseif (argv[1] == 'demote') then
		PO_RanksDemote();
	elseif (argv[1] == 'demoteall') then
		PO_RanksDemoteAll();
	else
		PO_Msg('PoN Officer Mod');
		PO_Msg('--------------------------------');
		PO_Msg('/pon de NAME - sets the current disenchanter');
		PO_Msg('/pon getde - output the current disenchanter');
		PO_Msg('/pon ranks - announces the current raid ranks');
		PO_Msg('/pon attendance - logs attendance for the night');
		PO_Msg('/pon version - gets everyones version for the mod');
		PO_Msg('/pon promote - promotes everyone in the raid to repair rank');
		PO_Msg('/pon demote - returns everyone in the raid to their proper ranks');
		PO_Msg('/pon demoteall - returns everyone in the GUILD to their proper ranks');
	end
end

function PO_Msg(msg)
	if (msg) then
		if (string.len(msg) > 0) then
			if(DEFAULT_CHAT_FRAME) then
				DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. msg);
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. 'No Message');
		end
	end
end

function PO_ClickLootButton(self)
	local looticon = self;
	local index = string.sub(looticon:GetName(), -1);
	
	local itemNumber = tonumber(index) + (PO_CurrentLootPage * 3);
	PO_CurrentRollItemNumber = itemNumber;
	local itemLink = GetLootSlotLink(PO_CurrentRollItemNumber);
	
	if (itemLink) then
		PO_CurrentRollItem = {};
		
		local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
			itemEquipLoc, itemTexture = GetItemInfo(itemLink);
		
		if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
			-- show the menu
			PO_CurrentRollItem.itemLink = itemLink;
			PO_CurrentRollItem.itemType = itemType;
			PO_CurrentRollItem.itemSubType = itemSubType;
			PO_CurrentRollItem.itemName = itemName;
			PO_CurrentRollItem.itemIndex = PO_CurrentRollItemNumber;
			PO_CurrentRollItem.itemWinner = '';
		end
		
		if (looticon.oldClickScript) then
			looticon.oldClickScript()
		end
	end
end

function PO_LootPrevious()
	if (PO_CurrentLootPage > 0) then
		PO_CurrentLootPage = PO_CurrentLootPage - 1
	end
	
	if (LootFrameUpButton.old_click) then
		LootFrameUpButton.old_click();
	end
end

function PO_LootNext()
	PO_CurrentLootPage = PO_CurrentLootPage + 1;
	if (LootFrameDownButton.old_click) then
		LootFrameDownButton.old_click();
	end
end

function PO_Announce(msg)
	if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
		SendChatMessage(msg, "RAID");
		SendChatMessage(msg, "RAID_WARNING");
	end
end

function PO_EndLoot()
	local MasterLooter = PO_GetMasterLooter();
	if (MasterLooter == UnitName("player")) then
		SendAddonMessage('PON', 'END_ROLL', 'RAID');
	else
		PonLoot:Hide();
	end
end

function PO_GetRanks()
	PO_Raiders = {}
	PO_FnF = {}
	PO_Other = {}
	
	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if (PO_IsInGuild(name)) then
			-- see what rank they are
			local rankIndex, officerNote = PO_GetGuildieInfo(name);
			rankIndex = rankIndex + 1; -- adjust to 1-based
			
			if (string.match(officerNote, 'P%[[%d%-]+%]')) then
				local currentPoints = string.match(officerNote, 'P%[([%d%-]+)%]');
				
				local numLoot   = 0;
				local numNights = 0;
				
				for i=1,10 do
					local char = string.sub(currentPoints, i, i);
					if (char ~= '-') then
						local digit = tonumber(char);
						if (digit) then
							numNights = numNights + 1;
							numLoot = numLoot + digit;
						end
					end
				end
				
				local lootIndex = pon_round(numLoot / numNights, 2);
				
				if (rankIndex == 4) then
					-- they are temp promoted, get actual rank
					local actualRank = string.match(officerNote, 'R%[(%d+)%]');
					actualRank = tonumber(actualRank);
					rankIndex = actualRank;
				end
				
				--PO_Msg(name .. ": " .. lootIndex .. " (" .. numLoot .. "/" .. numNights .. ")");
				
				if (rankIndex < 7) then
					local index = table.getn(PO_Raiders) + 1;
					PO_Raiders[index] = { name=name, class=class, lootIndex=lootIndex, numNights=numNights }
				else
					local index = table.getn(PO_FnF) + 1;
					PO_FnF[index] = { name=name, class=class, lootIndex=lootIndex, numNights=numNights }
				end
			else
				local index = table.getn(PO_Other) + 1;
				PO_Other[index] = { name=name, class=class };
			end
		else
			local index = table.getn(PO_Other) + 1;
			PO_Other[index] = { name=name, class=class };
		end
	end
	
	if (table.getn(PO_Raiders) > 1) then
		table.sort(PO_Raiders, function(a,b)
				return a.lootIndex < b.lootIndex;
			end
		)
	end
	
	if (table.getn(PO_FnF) > 1) then
		table.sort(PO_FnF, function(a,b)
				return a.lootIndex < b.lootIndex;
			end
		)
	end
	
	return PO_Raiders, PO_FnF, PO_Other;
end

function PO_ShowLootWindow(item)
	-- get everyone in the raid, sort by best rank, 
	PO_Raiders, PO_FnF, PO_Other = PO_GetRanks();
	PO_Greed = {}
	
	-- open the loot list
	-- now we have our data, display it
	
	local ml = PO_GetMasterLooter();
	
	for x=1,27 do
		local button = getglobal('PonLoot'..x);
		button:Show();
		button:SetNormalFontObject(PO_MainFont);
		button:SetDisabledFontObject(PO_MainFont);
		button.recipient = '';
		button:Disable();
	end
	
	-- put it full of people
	
	local counter = 1;
	if (table.getn(PO_Raiders) > 0) then
		for i=1,table.getn(PO_Raiders) do
			local info = PO_Raiders[i];
			local button = getglobal('PonLoot'..counter);
			if (button) then
				button:SetText(info.name .. ': ' .. info.lootIndex .. ' - ' .. info.numNights);
				--if (ml == UnitName('player')) then button:Enable(); else button:Disable(); end
				button.recipient = info.name;
			end
			counter = counter + 1;
		end
	end
	
	if (table.getn(PO_FnF) > 0) then
		local button = getglobal('PonLoot'..counter);
		button:SetText('FnF');
		button:SetDisabledFontObject(PO_BlueFont);
		button:Disable();
		
		counter = counter + 1;

		for i=1,table.getn(PO_FnF) do
			local info = PO_FnF[i];
			local button = getglobal('PonLoot'..counter);
			if (button) then
				button:SetText(info.name .. ': ' .. info.lootIndex .. ' - ' .. info.numNights);
				--if (ml == UnitName('player')) then button:Enable(); else button:Disable(); end
				button.recipient = info.name;
			end
			counter = counter + 1;
			
		end
	end
	
	if (table.getn(PO_Other) > 0) then
		local button = getglobal('PonLoot'..counter);
		button:SetText('Other');
		button:Disable();
		button:SetDisabledFontObject(PO_BlueFont);
		counter = counter + 1;

		for i=1,table.getn(PO_Other) do
			local info = PO_Other[i];
			local button = getglobal('PonLoot'..counter);
			if (button) then
				button:SetText(info.name);
				--if (ml == UnitName('player')) then button:Enable(); else button:Disable(); end
				button.recipient = info.name;
			end
			counter = counter + 1;
			
		end
	end
	
	--local newHeight = 10 + ((counter-1)*15);
	--PonLoot:SetHeight(newHeight);
	
	for i=counter,27 do
		local button = getglobal('PonLoot'..i);
		button:Hide();
	end
	
	PO_UpdateGreeds();
	PonLoot:Show();
end

function PO_WhisperRank(player)
	PO_Raiders, PO_FnF, PO_Other = PO_GetRanks();
	
	local counter = 1;
	if (table.getn(PO_Raiders) > 0) then
		for i=1,table.getn(PO_Raiders) do
			local info = PO_Raiders[i];
			if (isMatchingName(player, info.name)) then
				SendChatMessage("Your current rank for this raid is: "..counter, "WHISPER", nil, player);
				return;
			end
			counter = counter + 1;
		end
	end
	
	if (table.getn(PO_FnF) > 0) then
		for i=1,table.getn(PO_FnF) do
			local info = PO_FnF[i];
			if (isMatchingName(player, info.name)) then
				SendChatMessage("Your current rank for this raid is: "..counter, "WHISPER", nil, player);
				return;
			end
			counter = counter + 1;
		end
	end
	
	SendChatMessage("You have no rank for this raid.", "WHISPER", nil, player);
end

function PO_AnnounceRanks()
	PO_Raiders, PO_FnF, PO_Other = PO_GetRanks();
	
	SendChatMessage('Loot Ranks', "RAID");
	
	local counter = 1;
	if (table.getn(PO_Raiders) > 0) then
		for i=1,table.getn(PO_Raiders) do
			local info = PO_Raiders[i];
			SendChatMessage(counter .. '. ' .. info.name .. ', Loot Index: '.. info.lootIndex ..', Tiebreaker: ' .. info.numNights, 'RAID');
			counter = counter + 1;
		end
	end
	
	if (table.getn(PO_FnF) > 0) then
		for i=1,table.getn(PO_FnF) do
			local info = PO_FnF[i];
			SendChatMessage(counter .. '. ' .. info.name .. ', Loot Index: '.. info.lootIndex ..', Tiebreaker: ' .. info.numNights, 'RAID');
			counter = counter + 1;
		end
	end
	
	if (table.getn(PO_Other) > 0) then
		for i=1,table.getn(PO_Other) do
			local info = PO_Other[i];
			SendChatMessage(info.name .. ': /roll', 'RAID');
			counter = counter + 1;
		end
	end
end

function PO_GiveLoot(self)
	local winner = self.recipient;
	
	for i = 1, GetNumGroupMembers() do
		if (GetMasterLootCandidate(PO_CurrentRollItemNumber, i) == winner) then
			-- give loot
			GiveMasterLoot(PO_CurrentRollItemNumber, i);
			-- update officer note
			PO_UpdateNote(winner);
			-- update guild roster
			GuildRoster();
			-- end roll
			
			PO_EndLoot();
			--SendAddonMessage('PON', 'END_ROLL', 'RAID');
		end
	end
end

function PO_GreedLoot(self)
	local winner = self.recipient;
	for i = 1, GetNumGroupMembers() do
		if (GetMasterLootCandidate(PO_CurrentRollItemNumber, i) == winner) then
			-- give loot
			GiveMasterLoot(PO_CurrentRollItemNumber, i);
			-- end loot
			PO_EndLoot();
		end
	end
end

function PO_DELoot(self)
	for i = 1, GetNumGroupMembers() do
		if (string.lower(GetMasterLootCandidate(PO_CurrentRollItemNumber, i)) == string.lower(PoNDB['disenchanter'])) then
			-- give loot
			GiveMasterLoot(PO_CurrentRollItemNumber, i);
			-- end loot
			PO_EndLoot();
		end
	end
end

function PO_UpdateNote(winner)
	local numTotal = GetNumGuildMembers(true);
	for i=1,numTotal do
		local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i);
		if (isMatchingName(name, winner)) then
			if (string.match(officerNote, 'P%[[%d%-]+%]')) then
				local currentPoints = string.match(officerNote, 'P%[([%d%-]+)%]');
				local tonight = string.sub(currentPoints, 1, 1);
				if (tonight == '-') then 
					tonight = 0
				else
					tonight = tonumber(tonight);
				end
				
				tonight = tonight + 1;
				
				if (tonight > 9) then
					tonight = 9 -- max 9 items per night
				end
				
				local new = 'P[' .. tostring(tonight) .. string.sub(currentPoints, 2, 10) .. ']';
				local old = 'P%[[%d%-]+%]';
				local newnote = string.gsub(officerNote, old, new);
				GuildRosterSetOfficerNote(i, newnote);
			else
				PO_Msg('Bad officer note: ' .. name);
				--[[
				local currentPoints = string.match(officerNote, 'P%[(%d+%/%d+)%]');
				local info      = pon_split(currentPoints, '/');
				local numLoot   = tonumber(info[1]);
				local numNights = tonumber(info[2]);
				local numLoot = numLoot + 1;
				
				local old = 'P%[%d+%/%d+%]';
				local new = 'P%['..numLoot..'%/'..numNights..'%]';
				
				local newnote = string.gsub(officerNote, old, new);
				GuildRosterSetOfficerNote(i, newnote);]]
			end
		end
	end
end

function PO_Import(self)
	local text = PonImportData:GetText();
	if (string.len(text) > 0) then
		local info = pon_split(text, ';');
		
		local newPoints = {}
		
		-- go through new list and set new points
		for i=1,table.getn(info) do
			local entry = info[i];
			local data  = pon_split(entry, ',');
			
			local player = data[1];
			newPoints[player] = data[2];
		end
		
		-- go thru everyone in the guild and update points
		
		local numTotal = GetNumGuildMembers(true);
		for i=1,numTotal do
			local name, rank, rankIndex, level, class, zone, note, officerNote, online, status = GetGuildRosterInfo(i);
			--[[
			if (string.match(officerNote, 'P%[%d+%/%d+%]')) then
				local old = 'P%[%d+%/%d+%]';
				local new = '';
				
				if (newPoints[name]) then
					local data      = newPoints[name];
					new = 'P%['..data..']';
				end
				
				local newnote = string.gsub(officerNote, old, new);
				--GuildRosterSetOfficerNote(i, newnote);
			else
				if (newPoints[name]) then
					local data      = newPoints[name];
					new = 'P['..data..']';
					local newnote = new;
					--GuildRosterSetOfficerNote(i, newnote);
				end
			end]]
			
			if (newPoints[name .. '-' .. GetRealmName()]) then
				local data = newPoints[name .. '-' .. GetRealmName()];
				new = 'P['..data..']';
				GuildRosterSetOfficerNote(i, new);
			end
		end
	end
	PonImport:Hide();
end

function PO_OnEvent(self, event, ...)
	local args = { select(1, ...) }
	if (event == 'LOOT_OPENED') then
		PO_CurrentLootPage = 0;
		
		if (PO_LootClicksEnabled == 0) then
			for i=1,4 do
				local looticon = getglobal('LootButton'..i);
				looticon.oldClickScript = looticon:GetScript('OnMouseUp');
				looticon:SetScript('OnMouseUp', PO_ClickLootButton)
			end
			
			LootFrameUpButton.old_click = LootFrameUpButton:GetScript('OnClick');
			LootFrameUpButton:SetScript('OnClick', PO_LootPrevious);
			
			LootFrameDownButton.old_click = LootFrameDownButton:GetScript('OnClick');
			LootFrameDownButton:SetScript('OnClick', PO_LootNext);
			
			PO_LootClicksEnabled = 1;
		end
		
	elseif (event == 'OPEN_MASTER_LOOT_LIST') then
		-- add buttons to master loot list
		local info = UIDropDownMenu_CreateInfo();
		info.text = '\124cFF00FF00PoN Officer\124r';
		info.r = 0;
		info.g = 1;
		info.b = 0;
		info.notClickable = 1;
		UIDropDownMenu_AddButton(info, 1);
		-- next button
		local info = UIDropDownMenu_CreateInfo();
		info.text = '\124cFF00FF00Loot Check\124r';
		info.func = function() PO_StartRoll(); end;
		UIDropDownMenu_AddButton(info, 1);
	elseif (event == 'CHAT_MSG_ADDON') then
		if (args[1] == 'PON') then
			local sender  = args[4];
			local message = args[2];
			local info    = pon_split(message, '/');
			local action  = info[1];
			if (action == 'START_ROLL') then
				--PO_Msg('Called: ' .. sender .. '/' .. message);
				local item = info[2];
				PO_ShowLootWindow(item);
			elseif (action == 'END_ROLL') then
				PonLoot:Hide();
			elseif (action == 'NEW_DE') then
				PoNDB['disenchanter'] = info[2];
				PO_Msg('[PoN] Disenchanter set to: ' .. info[2] .. ' by ' .. sender);
				PO_UpdateGreeds();
			elseif (action == 'VERSION_CHECK') then
				if (sender ~= UnitName('player')) then
					SendChatMessage(PONOFFICERVERSION, "WHISPER", nil, sender);
				end
			end
		end
	elseif (event == 'CHAT_MSG_RAID') or (event == 'CHAT_MSG_RAID_LEADER') then
		if (PonLoot:IsShown()) then
			PO_Raiders, PO_FnF, PO_Other = PO_GetRanks();
			local sender = args[2];
			local counter = 1;
			if (table.getn(PO_Raiders) > 0) then
				for i=1,table.getn(PO_Raiders) do
					local info = PO_Raiders[i];
					if (isMatchingName(sender, info.name)) then
                        sender = info.name -- binding sender to info.name without realm name
						j = i;
						lootIndex = info.lootIndex
						numNights = info.numNights
						counter2 = counter;
						break;
					end
					counter = counter + 1;
				end
			end
			if (table.getn(PO_FnF) > 0) then
				for i=1,table.getn(PO_FnF) do
					local info = PO_FnF[i];
					if (isMatchingName(sender, info.name)) then
                        sender = info.name
						j = i;
						lootIndex = info.lootIndex
						numNights = info.numNights
						counter2 = counter;
						break;
					end
					counter = counter + 1;
				end
			end
			if (string.lower(args[1]) == 'need') then
				for i=1,27 do
					local button = getglobal('PonLoot'..i);
					if (button.recipient == sender) then
						button:SetNormalFontObject(PO_GreenFont);
						button:SetDisabledFontObject(PO_GreenFont);
						
						local ml = PO_GetMasterLooter();
						if (ml == UnitName('player')) then button:Enable(); end
						SendChatMessage(counter2 .. '. ' .. sender .. ', Loot Index: '.. lootIndex ..', Tiebreaker: ' .. numNights, 'RAID');
					end
				end
			elseif (args[1] == 'pass') then
				for i=1,27 do
					local button = getglobal('PonLoot'..i);
					if (button.recipient == sender) then
						button:SetNormalFontObject(PO_RedFont);
						button:SetDisabledFontObject(PO_RedFont);
						button:Disable();
					end
				end
			end
		end
	elseif (event == 'CHAT_MSG_WHISPER' or event == 'CHAT_MSG_BN_WHISPER') then
		if(event == 'CHAT_MSG_BN_WHISPER') then
			hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime, canSoR, toonID = BNGetToonInfo(args[13]);
			args[2] = toonName;
		end
		
		if (args[1] == 'rank') then
			if ( (GetNumGroupMembers() > 0) and (PO_GetMasterLooter() == UnitName('player')) ) then
				local name = args[2];
				--SendChatMessage("mmmm gravy", "WHISPER", nil, name);
				-- get their rank!
				if (PO_IsInRaid(name)) then
					PO_WhisperRank(name);
				else
					SendChatMessage("You are not in the raid!", "WHISPER", nil, name);
				end
			end
		end
		
		if (GetNumGroupMembers() > 0) then -- in a raid
			if (UnitIsGroupAssistant("player")) or (UnitIsGroupLeader("player")) then -- can invite
				if strfind(args[1],"^invite") or (args[1] == "inv") or strfind(args[1],"^inv pl") then
					-- make sure this player is in the guild
					if (PO_IsInGuild(args[2])) then
						if GetNumGroupMembers() ~= 40 then
							InviteUnit(args[2])
						else
							SendChatMessage("Autoreply: The raid is currently full", "WHISPER", nil, name)
						end
					end
				else
					return
				end
			end
		end
	elseif (event == 'GROUP_ROSTER_UPDATE') then
		local num_raiders = GetNumGroupMembers();
		if (num_raiders and IsInRaid()) then
			for i = 1, num_raiders do
				local name, raid_rank = GetRaidRosterInfo(i);
				if (PO_IsOfficer(name)) then 
					if (raid_rank == 0) and (UnitIsGroupLeader("player")) then
						PromoteToAssistant(name);
					end
				end
			end
		end
	elseif (event == 'CHAT_MSG_SYSTEM') then
		for name, roll, low, high in string.gmatch(args[1], "([^%s]+) " .. "rolls" .. " (%d+) %((%d+)%-(%d+)%)$") do
			roll = tonumber(roll);
			name = tostring(name);
			low  = tonumber(low);
			high = tonumber(high);
			
			if (low == 1) and (high == 100) and (PonLoot:IsShown()) then
				if (PO_HasGreed(name) == nil) then
					local info = {}
					info.player = name;
					info.roll = roll;
					
					local index = table.getn(PO_Greed) + 1;
					PO_Greed[index] = info;
					
					PO_UpdateGreeds()
				end
			end
		end
	end
end

function PO_HasGreed(player)
	for i=1,table.getn(PO_Greed) do
		local info = PO_Greed[i];
		if (info.player == player) then
			return true
		end
	end
	return nil
end

function PO_UpdateGreeds()
	if (table.getn(PO_Greed) > 1) then
		table.sort(PO_Greed, function(a,b)
				return a.roll > b.roll;
			end
		)
	end
	
	for i=1,25 do
		local info = PO_Greed[i];
		local button = getglobal('PonLootGreed'..i);
		if (info) then
			button.recipient = info.player;
			button:SetText(info.player .. ': ' .. info.roll);
			button:Enable();
		else
			button:SetText('');
			button:Disable();
		end
	end
	
	local de_button = getglobal('PonLootGreed26');
	if (PoNDB['disenchanter']) then
		de_button:SetText('DE: ' .. PoNDB['disenchanter']);
		de_button:Enable();
	else
		de_button:SetText('Set a disenchanter');
		de_button:Disable();
	end
end

function pon_round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function pon_split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

