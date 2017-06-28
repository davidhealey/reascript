--[[ 
* ReaScript Name: MIDI Increase CC1 For First CC of Each Selected Note By 15%
* Version: 29/05/2017
* Author: David Healey.
--]] 

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive()) --Get active take
local CC_NUM = 1;

if take ~= nil then
	reaper.Undo_BeginBlock();

	retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take) --Count note and cc evens

	for n = 0, notes, 1 do --Each note event

		retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(take, n); --Get note data

		if n_selected == true then --If this note is selected

			for c = 0, ccs, 1 do --Each CC event
				retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(take, c) --Get CC data

				--If the CC ppq is within the note's start and end ppq and the CC lane is CC_NUM
				if (c_ppq >= n_ppq and c_ppq < n_endppq) and msg2 == CC_NUM then
					CC_VALUE = msg3 + math.floor(msg3*.15) --Increase CC value
					if CC_VALUE >= 127 then CC_VALUE = 127 end --Don't let value go above max
					reaper.MIDI_SetCC(take, c, NULL, NULL, NULL, NULL, NULL, NULL, CC_VALUE, true);
					break; --Only process one CC per note
				end
			end

		end

	end
end

reaper.MIDI_Sort(take)
reaper.Undo_EndBlock("MIDI Increase CC1 For First CC of Each Selected Note",-1);
reaper.UpdateArrange();