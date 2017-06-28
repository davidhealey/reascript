package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local CC_NUM = 1;

reaper.Undo_BeginBlock();
drmp.selectCCEventsUnderSelectedNotes(CC_NUM)
reaper.Undo_EndBlock("MIDI Select CC1 Events Under Selected Notes",-1);