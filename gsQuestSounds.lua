--[[
gsQuestSounds
Created by ColbyWanShinobi
email: colbywanshinobi@gameshaman.com
web: gameshaman.com
repo: https://github.com/ColbyWanShinobi/gsQuestSounds.git
--]]

local sounds = {
  --questComplete is played whenever the quest is finally completed and ready to be turned in
  --"Sound/creature/Peon/PeonBuildingComplete1.ogg"
  questComplete = 558132,
  
  --ObjectiveComplete is played whenever a quest objective is removed from the quest log.
  --"Sound/Creature/Peon/PeonReady1.ogg"
  objectiveComplete = 558137,
  
  --ObjectiveProgress is played whenever an accumulation quest is incremented. ie. You've found 3/5 acorns
  --"Sound/creature/Peon/PeonWhat3.ogg"
  objectiveProgress = 558143
  
};

--Classic
if MainMenuBarLeftEndCap then
  --print("Found Classic UI...");
  sounds = {
    questComplete = "Sound/creature/Peon/PeonBuildingComplete1.ogg",
    objectiveComplete = "Sound/Creature/Peon/PeonReady1.ogg",
    objectiveProgress = "Sound/creature/Peon/PeonWhat3.ogg"
  };
end

<<<<<<< HEAD
local gsQuestSounds = CreateFrame("Frame");
local events = {};
=======
gsQuestSounds.currentQuestId = 0;
gsQuestSounds.currentQuestTitle = '';
gsQuestSounds.currentQuestLevel = 0;
gsQuestSounds.currentCompleteQuestObjectives = 0;
gsQuestSounds.currentQuestProgressCounter = 0;
gsQuestSounds.currentQuestProgressTable = {};
gsQuestSounds.currentQuestLink = "";

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
>>>>>>> 90212835bd81c296f812602678f25e416d6e9993

gsQuestSounds.questIndex = 0;
gsQuestSounds.questId = 0;
gsQuestSounds.completeCount = 0;

local function countCompleteObjectives(index)
  local n = 0;
  for i = 1, GetNumQuestLeaderBoards(index) do
    local _, _, finished = GetQuestLogLeaderBoard(i, index);
    if finished then
      n = n + 1;
    end
  end
  return n;
end

<<<<<<< HEAD
function gsQuestSounds:setQuest(index)
  self.questIndex = index;
  if index > 0 then
    --local _, _, _, _, _, _, _, _, id = GetQuestLogTitle(index)
    local q = {GetQuestLogTitle(index)};
    local id = q[8];
    self.questId = id;
    if id and id > 0 then
      self.completeCount = countCompleteObjectives(index);
    end
  end
end

function gsQuestSounds:checkQuest()
  if self.questIndex > 0 then
    local index = self.questIndex;
    self.questIndex = 0;
    --local title, level, _, _, _, _, complete, daily, id = GetQuestLogTitle(index);
    local q = {GetQuestLogTitle(index)};
    local title = q[1];
    local level = q[2];
    local complete = q[6];
    local daily = q[7];
    local id = q[8];
    local link = "";
    if MainMenuBarLeftEndCap then
      --print("Found Classic UI...");
      link = title;
    else
      link = GetQuestLink(id);
    end
    if link == nil or link == "" then
      link = "Dynamic Quest";
    end
    if id == self.questId then
      if id and id > 0 then
        local objectivesComplete = countCompleteObjectives(index);
        if complete then
          print("gsQuestSounds: ["..level.."] '"..link.."': complete");
          gsQuestSounds:Play(sounds.questComplete);
        elseif objectivesComplete>self.completeCount then
          print("gsQuestSounds: ["..level.."] '"..link.."': objective complete ("..objectivesComplete.."/"..GetNumQuestLeaderBoards(index)..")");
          gsQuestSounds:Play(sounds.objectiveComplete);
        else
          print("gsQuestSounds: ["..level.."] '"..link.."': updated");
          gsQuestSounds:Play(sounds.objectiveProgress);
        end
=======
local function createQuestLink(id, level, title)
  --https://wow.gamepedia.com/QuestLink
  --|cff808080|Hquest:99:15|h[Arugal's Folly]|h|r
  --|cffffffff|Hquest:QUESTID:QUESTLEVEL|h[QUESTTITLE]|h|r
  local link = "|cffffff00|Hquest:"..id..":"..level.."|h["..title.."]|h|r";
  return link;
end

function gsQuestSounds:setCurrentQuest(id)
  if id and id > 0 then
    self.currentQuestId = id;
    local index = C_QuestLog.GetLogIndexForQuestID(id);
    local info = C_QuestLog.GetInfo(index);
    local level = info.level;
    self.currentQuestLevel = level;
    local title = info.title;
    self.currentQuestTitle = title;
    local objectives = C_QuestLog.GetQuestObjectives(id);
    self.currentQuestProgressTable = objectives;
    self.currentCompleteQuestObjectives = getCompleteObjectiveCount(objectives);
    self.currentQuestProgressCounter = getQuestProgressCount(objectives);
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
      print("gsQS: ["..level.."] '"..link.."': Objective Complete ("..completeObjectives.."/"..totalObjectives..")");
      gsQuestSounds:Play(sounds.objectiveComplete);
    elseif questProgress > self.currentQuestProgressCounter then
      --Quest progress is made
      if (updatedText) then 
        print("gsQS: ["..level.."] '"..link.."': "..updatedText);
      else
        print("gsQS: ["..level.."] '"..link.."': Updated");
>>>>>>> 90212835bd81c296f812602678f25e416d6e9993
      end
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
    print("gsQuestSounds by gameshaman.com - Addon Loaded");
end

function gsQuestSounds:Play(sound)
   --print("Playing:", sound)
  if sound and sound~="" then
    PlaySoundFile(sound);
  end
end

function events:UNIT_QUEST_LOG_CHANGED(unit)
  if unit=="player" then
    gsQuestSounds:checkQuest();
  end
end

function events:QUEST_WATCH_UPDATE(index)
  -- This event triggers just *before* the changes are registered
  -- in the quest log, giving a great opportunity to quantify changes
  -- in the subsequent UNIT_QUEST_LOG_CHANGED
  gsQuestSounds:setQuest(index);
end


-- ................................................................
-- must be last line:
gsQuestSounds:init();
