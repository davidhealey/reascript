--[[ 
* ReaScript Name: MIDI Select All CC Events Under Selected Notes
* Version: 04/06/2017
* Author: David Healey.
--]] 

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) --Get active take

if take ~= nil then
	
	reaper.Undo_BeginBlock();

	retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take) --Count note and cc evens

	for n = 0, notes, 1 do --Each note event

		retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(take, n); --Get note data

		if n_selected == true then --If this note is selected

			for c = 0, ccs, 1 do --Each CC event
				retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(take, c) --Get CC data

				--If the CC ppq is within the note's start and end ppq
				if c_ppq >= n_ppq and c_ppq < n_endppq then
					reaper.MIDI_SetCC(take, c, true, NULL, NULL, NULL, NULL, NULL, NULL, true); --Set CC as selected
				end
			end

		end

	end
end

reaper.MIDI_Sort(take)
reaper.Undo_EndBlock("MIDI Select All CC Events Under Selected Notes",-1);
reaper.UpdateArrange();