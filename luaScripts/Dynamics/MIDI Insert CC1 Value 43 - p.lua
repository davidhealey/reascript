package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local CC_NUM = 1;
local CC_VALUE = 43;

reaper.Undo_BeginBlock();
drmp.insertCCAtSelectedNotes(CC_NUM, CC_VALUE)
reaper.Undo_EndBlock("MIDI Insert CC1 Value 43",-1);