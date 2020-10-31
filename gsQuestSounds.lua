--[[
gsQuestSounds
Created by ColbyWanShinobi
email: colbywanshinobi@gameshaman.com
web: gameshaman.com
repo: https://github.com/ColbyWanShinobi/gsQuestSounds.git
--]]

local gsQuestSounds = CreateFrame("Frame");
local events = {};
local sounds = {
  --questComplete is played whenever the quest is finally completed and ready to be turned in
  --"Sound/Creature/Peon/PeonBuildingComplete1.ogg"
  questComplete = 558132,
  
  --ObjectiveComplete is played whenever a quest objective is removed from the quest log.
  --"Sound/Creature/Peon/PeonReady1.ogg"
  objectiveComplete = 558137,
  
  --ObjectiveProgress is played whenever an accumulation quest is incremented. ie. You've found 3/5 acorns
  --"Sound/Creature/Peon/PeonWhat3.ogg"
  objectiveProgress = 558143  
};

--Classic
if MainMenuBarLeftEndCap then
  --print("Found Classic UI...");
  sounds = {
    questComplete = "Sound/Creature/Peon/PeonBuildingComplete1.ogg",
    objectiveComplete = "Sound/Creature/Peon/PeonReady1.ogg",
    objectiveProgress = "Sound/Creature/Peon/PeonWhat3.ogg"
  };
end

gsQuestSounds.currentQuestId = 0;
gsQuestSounds.currentQuestTitle = '';
gsQuestSounds.currentQuestLevel = 0;
gsQuestSounds.currentCompleteQuestObjectives = 0;
gsQuestSounds.currentQuestProgressCounter = 0;
gsQuestSounds.currentQuestProgressTable = {};
gsQuestSounds.currentQuestLink = "";

local function printTable(table)
	if type(table) == "table" then
		for k, v in pairs(table) do
			local value;
			if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
				value = v;
			else
				value = type(v);
			end
			print("["..k.."]".."[", value, "]");
		end
	else
		print("NOT A TABLE", type(table), table);
	end
end

local function getCompleteObjectiveCount(objectives)
  local completeObjectives = 0;
  for objIndex, objInfo in ipairs(objectives) do
    --print(objIndex,objInfo.type,objInfo.text,objInfo.numRequired,objInfo.numFulfilled, objInfo.finished);
    if (objInfo.finished) then
      completeObjectives = completeObjectives + 1;
    end
  end
  return completeObjectives;
end

local function getQuestProgressCount(objectives)
  local updateCount = 0;
  for objIndex, objInfo in ipairs(objectives) do
    --print(objIndex,objInfo.type,objInfo.text,objInfo.numRequired,objInfo.numFulfilled, objInfo.finished);
    updateCount = updateCount + objInfo.numFulfilled;
  end
  return updateCount;
end

local function getUpdatedQuestObjectiveString(id, oldObjectives, freshObjectives)
  local questText = "";
  for objIndex, objInfo in ipairs(oldObjectives) do
    --printTable(objInfo)
    --print("===")
    --printTable(freshObjectives[objIndex])
    if objInfo ~= nil and freshObjectives ~= nil then
      if (objInfo.numFulfilled ~= freshObjectives[objIndex].numFulfilled) then
        questText = freshObjectives[objIndex].text;
      end
    end
  end
  return questText;
end

local function createQuestLink(id, level, title)
  --https://wow.gamepedia.com/QuestLink
  --|cff808080|Hquest:99:15|h[Arugal's Folly]|h|r
  --|cffffffff|Hquest:QUESTID:QUESTLEVEL|h[QUESTTITLE]|h|r
  local link = "|cffffff00|Hquest:"..id..":"..level.."|h["..title.."]|h|r";
  return link;
end

function gsQuestSounds:setCurrentQuest(id)
  if id and id > 0 then
    local objectives = C_QuestLog.GetQuestObjectives(id);
    local progressCount = getQuestProgressCount(objectives);
    
    if id == self.currentQuestId and progressCount <= self.currentQuestProgressCounter  then
      --There seems to be a delay in gettting quest progress which is triggering notifications of previous progress. Check to make sure this is not the case
      --DON'T UPDATE ANYTHING!
      --print('NO FLAPPING!!!!!!!!!')
      return
    end
     
    self.currentQuestId = id;
    local index = C_QuestLog.GetLogIndexForQuestID(id);
    local info = C_QuestLog.GetInfo(index);
    local level = info.level;
    self.currentQuestLevel = level;
    local title = info.title;
    self.currentQuestTitle = title;
    self.currentQuestProgressTable = objectives;
    self.currentCompleteQuestObjectives = getCompleteObjectiveCount(objectives);
    self.currentQuestProgressCounter = progressCount;
    local link = createQuestLink(id, level, title);
    self.currentQuestLink = link;
  end
end

function gsQuestSounds:checkCurrentQuest()
  local id = gsQuestSounds.currentQuestId;
  if id and id > 0 then
    local title = gsQuestSounds.currentQuestTitle;
    local level = self.currentQuestLevel;
    local title = self.currentQuestTitle;
    local link = self.currentQuestLink;
    local complete = C_QuestLog.ReadyForTurnIn(id);
    local totalObjectives = C_QuestLog.GetNumQuestObjectives(id);
    local objectives = C_QuestLog.GetQuestObjectives(id);
    local completeObjectives = getCompleteObjectiveCount(objectives);
    local questProgress = getQuestProgressCount(objectives);
    local updatedText = getUpdatedQuestObjectiveString(id, self.currentQuestProgressTable, objectives);
    
    if complete then
      --Quest is complete
      print("gsQS: ["..level.."] '"..link.."': "..updatedText);
      print("gsQS: ["..level.."] '"..link.."': Quest Complete");
      gsQuestSounds:Play(sounds.questComplete);
    elseif completeObjectives > self.currentCompleteQuestObjectives then
      --An objective is complete
      print("gsQS: ["..level.."] '"..link.."': "..updatedText);
      print("gsQ2: ["..level.."] '"..link.."': Objective Complete ("..completeObjectives.."/"..totalObjectives..")");
      gsQuestSounds:Play(sounds.objectiveComplete);
    elseif questProgress > self.currentQuestProgressCounter then
      --print("LMAO", questProgress, self.currentQuestProgressCounter)
      --Quest progress is made
      if (updatedText) then 
        print("gsQS: ["..level.."] '"..link.."': "..updatedText);
      else
        print("gsQS: ["..level.."] '"..link.."': Updated");
      end
      gsQuestSounds:Play(sounds.objectiveProgress);
    end
  end
end

function gsQuestSounds:init()
  self:SetScript("OnEvent", function(frame, event, ...)
    local handler = events[event];
    if handler then
      -- dispatch events that were auto-registered by naming convention
      handler(frame, ...);
    end
  end)
  for k,v in pairs(events) do
    self:RegisterEvent(k);
  end
    print("gsQuestSounds [gsQS] by gameshaman.com - Addon Loaded");
end

function gsQuestSounds:Play(sound)
  if sound and sound~="" then
    PlaySoundFile(sound);
  end
end

function events:UNIT_QUEST_LOG_CHANGED(unit)
  -- This event triggers whenevr the quest log is updated.
  if unit=="player" then
    gsQuestSounds:checkCurrentQuest();
  end
end

function events:QUEST_WATCH_UPDATE(questId)
  -- This event triggers just *before* the changes are registered
  -- in the quest log, giving a great opportunity to quantify changes
  -- in the subsequent UNIT_QUEST_LOG_CHANGED
  gsQuestSounds:setCurrentQuest(questId);
end

-- ................................................................
-- must be last line:
gsQuestSounds:init();
