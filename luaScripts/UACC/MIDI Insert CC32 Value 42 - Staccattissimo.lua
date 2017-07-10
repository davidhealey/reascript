package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local CC_NUM = 32;
local CC_VALUE = 42;
local INSERT_BEFORE = 0;

reaper.Undo_BeginBlock();
if (INSERT_BEFORE == 1) then
	drmp.insertCCBeforeSelectedNotes(CC_NUM, CC_VALUE)
else 
	drmp.insertCCAtSelectedNotes(CC_NUM, CC_VALUE)
end
reaper.Undo_EndBlock("MIDI Insert CC32 Value 42",-1);