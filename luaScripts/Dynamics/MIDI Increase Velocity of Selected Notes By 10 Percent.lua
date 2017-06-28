package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local percentage = 4;

reaper.Undo_BeginBlock();
drmp.increaseVelocityOfSelectedNotesByPercentage(percentage)
reaper.Undo_EndBlock("MIDI Increase Velocity Of Selected Notes By 10%",-1);