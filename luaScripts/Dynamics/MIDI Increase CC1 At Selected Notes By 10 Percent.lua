package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 1;
local percentage = 10;

reaper.Undo_BeginBlock();
drmp.increaseCCAtSelectedNotesByPercentage(ccNum, percentage)
reaper.Undo_EndBlock("MIDI Increase CC1 At Selected Notes By 10%",-1);