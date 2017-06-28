package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local threshold = 122

reaper.Undo_BeginBlock();
drmp.normaliseSelectedVelocities(threshold)
reaper.Undo_EndBlock("MIDI Normalise Velocity 122 fff",-1);