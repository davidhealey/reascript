package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local value = 75

reaper.Undo_BeginBlock();
drmp.setVelocityForSelectedNotes(value)
reaper.Undo_EndBlock("MIDI Set Velocity For Selected Notes 75 mf",-1);