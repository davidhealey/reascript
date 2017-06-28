package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local value = 27

reaper.Undo_BeginBlock();
drmp.setVelocityForSelectedNotes(value)
reaper.Undo_EndBlock("MIDI Set Velocity For Selected Notes 27 pp",-1);