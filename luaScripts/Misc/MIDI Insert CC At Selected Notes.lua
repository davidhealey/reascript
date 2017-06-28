package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local retval, userInput = reaper.GetUserInputs("CC Number & Value", 2, "CC Number,CC Value", "");

if (retval == false) then return end;

ccNum, ccValue = userInput:match("([^,]+),([^,]+)"); --Split user's input to variables

if type(tonumber(ccNum)) == "number" and type(tonumber(ccValue)) == "number" then --Validate input
	reaper.Undo_BeginBlock();
	drmp.insertCCAtSelectedNotes(ccNum, ccValue)
	reaper.Undo_EndBlock("MIDI Insert CC At Selected Notes",-1);
end