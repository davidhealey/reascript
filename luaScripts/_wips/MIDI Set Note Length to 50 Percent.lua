--[[ 
* ReaScript Name: MIDI Set Note Length to 50%
* Version: 02/06/2017
* Author: David Healey.
--]] 

--[[
Halves the duration of selected notes.
If using this to create staccato notes - which is my purpose - create a custom action
load this script as the first step, then use JulianSader's js_Notation Set display length of selected notes to double script
to restore the displayed length of the note and add a staccato articulation marking.
---------------------------]]

function main()

	e = reaper.MIDIEditor_GetActive() --Get active editor
	take = reaper.MIDIEditor_GetTake(e) --Get active take

	if take ~= nil then

		reaper.Undo_BeginBlock();

		retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take) --Count events

		for n = 0, notes, 1 do 
			retval, selected, muted, ppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, n) --Get note data
			if selected == true then
 				reaper.MIDI_SetNote(take, n, NULL, NULL, NULL, ppq+(endppq-ppq)/2, NULL, NULL, NULL, true)
			end
		end

		reaper.MIDI_Sort(take)
		reaper.Undo_EndBlock("MIDI Set Note Length to 50%",-1);
		reaper.UpdateArrange();
	end
end

--RUN----------------
main()