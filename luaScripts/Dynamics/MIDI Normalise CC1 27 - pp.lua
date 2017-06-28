package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 1
local threshold = 27

reaper.Undo_BeginBlock();
drmp.normaliseSelectedCCs(ccNum, threshold)
reaper.Undo_EndBlock("MIDI Normalise CC1 27 pp",-1);