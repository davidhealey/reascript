package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local text = 'Bartok';

reaper.Undo_BeginBlock();
drmp.insertCustomTextAtSelectedNotes(text);
reaper.Undo_EndBlock("MIDI Accent - Insert Custom Text " .. text,-1);