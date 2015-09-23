--[[
gsQuestSounds
Created by ColbyWanShinobi
email: colbywanshinobi@gameshaman.com
web: gameshaman.com
repo: https://github.com/ColbyWanShinobi/gsQuestSounds.git
--]]

local sounds = {
  questComplete = "Sound/creature/Peon/PeonBuildingComplete1.ogg",
  -- questComplete is played whenever the quest is finally completed and ready to be turned in
  objectiveComplete = "Sound/Creature/Peon/PeonReady1.ogg",
  -- ObjectiveComplete is played whenever a quest objective is removed from the quest log. ie. Cross the Pool of Reflection
  objectiveProgress = "Sound/creature/Peon/PeonWhat3.ogg"
  -- ObjectiveProgress is played whenever an accumulation quest is incremented. ie. You've found 3/5 acorns
};

local QuestShampoo = CreateFrame("Frame");
local events = {};

QuestShampoo.questIndex = 0;
QuestShampoo.questId = 0;
QuestShampoo.completeCount = 0;

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

function QuestShampoo:setQuest(index)
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

function QuestShampoo:checkQuest()
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
    local link = GetQuestLink(index);
    if id == self.questId then
      if id and id > 0 then
        local objectivesComplete = countCompleteObjectives(index);
        if complete then
          print("["..level.."] '"..link.."': complete");
          QuestShampoo:Play(sounds.questComplete);
        elseif objectivesComplete>self.completeCount then
          print("["..level.."] '"..link.."': objective complete ("..objectivesComplete.."/"..GetNumQuestLeaderBoards(index)..")");
          QuestShampoo:Play(sounds.objectiveComplete);
        else
          print("["..level.."] '"..link.."': updated");
          QuestShampoo:Play(sounds.objectiveProgress);
        end
      end
    end
  end
end

function QuestShampoo:init()
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
    print("gsQuestSounds Loaded!")
end

function QuestShampoo:Play(sound)
   --print("Playing:", sound)
  if sound and sound~="" then
    PlaySoundFile(sound);
  end
end

function events:UNIT_QUEST_LOG_CHANGED(unit)
  if unit=="player" then
    QuestShampoo:checkQuest();
  end
end

function events:QUEST_WATCH_UPDATE(index)
  -- This event triggers just *before* the changes are registered
  -- in the quest log, giving a great opportunity to quantify changes
  -- in the subsequent UNIT_QUEST_LOG_CHANGED
  QuestShampoo:setQuest(index);
end


-- ................................................................
-- must be last line:
QuestShampoo:init();
