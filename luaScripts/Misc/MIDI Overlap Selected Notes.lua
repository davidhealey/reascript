--[[ 
* ReaScript Name: MIDI Overlap Selected Notes
* Written: 29/05/2017
* Last Updated: 20/06/2017
* Author: David Healey.
--]] 

reaper.Undo_BeginBlock();

for i = 0, reaper.CountMediaItems(0), 1 do --Each media item

	local item = reaper.GetMediaItem(0, i) --Get item

	if reaper.ValidatePtr2(0, item, "MediaItem*") then --Double check that we got a valid item
		
		local take = reaper.GetActiveTake(item) --Get item's active take 

		if reaper.ValidatePtr2(0, take, "MediaItem_Take*") and reaper.TakeIsMIDI(take) then --Active take contains MIDI data
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take) --Count events

			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(take, n); --Get note data

				if n_selected == true then --If the note is selected
					
					nextNote = reaper.MIDI_EnumSelNotes(take, n); --Get the next selected note

					if nextNote ~= -1 then --If there is a next selected note
						retval, b_selected, b_muted, b_ppq, b_endppq, b_chan, b_pitch, b_vel = reaper.MIDI_GetNote(take, nextNote); --Get its note data		
						len = n_endppq - n_ppq; --Take start away from end to get length
						len = b_ppq + (len * 0.03); --Extend length up to next note + 3%
						reaper.MIDI_SetNote(take, n, NULL, NULL, NULL, len, NULL, NULL, NULL, true); --Extend note length
					end
				end

			end
			reaper.MIDI_Sort(take)
		end
	end
end

reaper.Undo_EndBlock("MIDI Overlap Selected Notes",-1);
reaper.UpdateArrange();