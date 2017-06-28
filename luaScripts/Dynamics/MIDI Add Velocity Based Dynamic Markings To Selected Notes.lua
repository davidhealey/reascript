--[[ 
* ReaScript Name: MIDI Add Velocity Based Dynamic Markings To Selected Notes
* Version: 20/06/2017
* Author: David Healey.
--]] 

--USER SETTINGS
DYNAMICS = {16, 32, 48, 64, 80, 96, 112, 127} --ppp to fff
MARKINGS = {"ppp", "pp", "p", "mp", "mf", "f", "ff", "fff"} --ppp to fff
---------------------------

for i = 0, reaper.CountMediaItems(0), 1 do --Each media item

	local item = reaper.GetMediaItem(0, i) --Get item

	if reaper.ValidatePtr2(0, item, "MediaItem*") then --Double check that we got a valid item
		
		local take = reaper.GetActiveTake(item) --Get item's active take 

		if reaper.ValidatePtr2(0, take, "MediaItem_Take*") and reaper.TakeIsMIDI(take) then --Active take contains MIDI data
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take) --Count events

			for n = 0, notes, 1 do --Each note event

				retval, selected, muted, ppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, n) --Get note data

				--Find which dynamic range the velocity value fits to determine which dynamic marking to use
				if selected == true then
					reaper.MIDIEditor_OnCommand(e, 42173) --Remove any existing note text

					for i in pairs(DYNAMICS) do
						if vel <= DYNAMICS[i] then
							reaper.MIDI_InsertTextSysexEvt(take, true, false, ppq, 0xF, "TRAC dynamic " .. MARKINGS[i] .. " ypos 2.000")
							break;
						end
					end
				end

			end
			reaper.MIDI_Sort(take)
		end
	end
end

reaper.Undo_EndBlock("MIDI Add Velocity Based Dynamics To Selected Notes",-1);
reaper.UpdateArrange();