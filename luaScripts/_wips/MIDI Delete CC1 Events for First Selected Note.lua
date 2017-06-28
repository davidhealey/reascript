--[[ 
* ReaScript Name: MIDI Delete CC1 Events for first selected note
* Version: 29/05/2017
* Author: David Healey.
--]] 

local CC_NUM = 1; --Only events for this CC number will be removed

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) --Get active take

if take ~= nil then

	retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take) --Count note and cc evens

	for n = 0, notes, 1 do --Each note event

		retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(take, n); --Get note data

		if n_selected == true then --If this note is selected

			for c = 0, ccs, 1 do --Each CC event
				retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(take, c) --Get CC data

				--If the CC ppq is within the note's start and end ppq and the CC lane is CC_NUM
				if (c_ppq >= n_ppq and c_ppq < n_endppq) and msg2 == CC_NUM then
					reaper.MIDI_DeleteCC(take, c); --Delete CC Event
				end
			end
			break; --Exist after the first selected note's CCs have been processed
		end

	end
end

reaper.MIDI_Sort(take)