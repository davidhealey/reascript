package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local retval, input = reaper.GetUserInputs("Insert CC1", 1, "CC1 Value", "");

if (retval == false) then return end;

if type(tonumber(input)) == "number" then --Validate input
	reaper.Undo_BeginBlock();
	drmp.insertCCAtSelectedNotes(1, input)
	reaper.Undo_EndBlock("MIDI Insert CC1 At Selected Notes",-1);
end
