package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local CC_NUM = 32;
local CC_VALUE = 40;

reaper.Undo_BeginBlock();
drmp.insertCCAtSelectedNotes(CC_NUM, CC_VALUE)
reaper.Undo_EndBlock("MIDI Insert CC32 Value 40",-1);