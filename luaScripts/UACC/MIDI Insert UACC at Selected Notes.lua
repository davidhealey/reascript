package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local retval, input = reaper.GetUserInputs("Insert UACC", 1, "UACC Value", "");

if (retval == false) then return end;

if type(tonumber(input)) == "number" then --Validate input
	reaper.Undo_BeginBlock();
	drmp.insertCCAtSelectedNotes(32, input)
	reaper.Undo_EndBlock("MIDI Insert UACC At Selected Notes",-1);
end