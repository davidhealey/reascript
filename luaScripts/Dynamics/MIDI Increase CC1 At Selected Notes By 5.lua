package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 1;
local amount = 10;

reaper.Undo_BeginBlock();
drmp.increaseCCAtSelectedNotesByAmount(ccNum, amount)
reaper.Undo_EndBlock("MIDI Accent - Increase CC1 At Selected Notes 5",-1);