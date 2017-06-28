package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local amount = 5;

reaper.Undo_BeginBlock();
drmp.increaseVelocityOfSelectedNotesByAmount(amount)
reaper.Undo_EndBlock("MIDI Accent - Increase Velocity Of Selected Notes By 5",-1);