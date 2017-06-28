package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 1;

reaper.Undo_BeginBlock();
drmp.deleteCCUnderSelectedNotes(ccNum)
reaper.Undo_EndBlock("MIDI Delete CC1 Events Under Selected Notes",-1);