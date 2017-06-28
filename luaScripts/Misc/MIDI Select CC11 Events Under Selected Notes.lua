package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 11;

reaper.Undo_BeginBlock();
drmp.selectCCEventsUnderSelectedNotes(ccNum)
reaper.Undo_EndBlock("MIDI Select CC11 Events Under Selected Notes",-1);