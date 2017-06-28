package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 1
local ccValue = 122

reaper.Undo_BeginBlock();
drmp.insertCCAtSelectedNotes(ccNum, ccValue)
reaper.Undo_EndBlock("MIDI Insert CC1 Value 122",-1);