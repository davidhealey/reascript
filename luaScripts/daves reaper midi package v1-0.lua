--[[ 
* ReaScript Name: daves reaper midi package v1.0.0
* Written: 20/06/2017
* Last Updated: 20/06/2017
* Author: David Healey
--]] 

local P = {}
drmp = P --Package name

function P.getActiveMIDITakes()
	
	local activeTakes = {}

	for i = 0, reaper.CountMediaItems(0), 1 do --Each media item

		local item = reaper.GetMediaItem(0, i) --Get item

		if reaper.ValidatePtr2(0, item, "MediaItem*") then --Check that we got a valid item
			
			local take = reaper.GetActiveTake(item) --Get item's active take 

			if reaper.ValidatePtr2(0, take, "MediaItem_Take*") and reaper.TakeIsMIDI(take) then --Active take is MIDI
				activeTakes[i] = take		
			end
		end
	end

	if next(activeTakes) ~= nil then --Active takes were found
		return activeTakes
	else 
		return false
	end
end

function P.insertCCAtSelectedNotes(ccNum, ccValue)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do

			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

				--If the note is selected insert CC data
				if n_selected == true then
					reaper.MIDI_InsertCC(t, false, false, n_ppq, 176, n_chan, ccNum, math.floor(ccValue));
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.insertCCBeforeSelectedNotes(ccNum, ccValue)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do

			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

				--If the note is selected insert CC data
				if n_selected == true then
					reaper.MIDI_InsertCC(t, false, false, n_ppq-15, 176, n_chan, ccNum, math.floor(ccValue));
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.setVelocityForSelectedNotes(value)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do

			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

				if n_selected == true then --If this note is selected
					reaper.MIDI_SetNote(t, n, NULL, NULL, NULL, NULL, NULL, NULL, value, true);
				end

			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.deleteCCUnderSelectedNotes(ccNum)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do

			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

				if n_selected == true then --If this note is selected

					if n < notes then --There are more notes after this
						retval, nn_selected, nn_muted, nn_ppq, nn_endppq, nn_chan, nn_pitch, nn_vel = reaper.MIDI_GetNote(t, n+1); --Get next note
					end

					for c = 0, ccs, 1 do --Each CC event

						retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(t, c) --Get CC data

						--If the CC ppq is within the note's start and end ppq and before the next
						--note's start or there is no next note
						if (c_ppq >= n_ppq and c_ppq < n_endppq) and (c_ppq < nn_ppq or n+1 == notes) then 
							if msg2 == ccNum then
								reaper.MIDI_DeleteCC(t, c); --Delete CC Event
							end
						end
					end

				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.selectCCEventsUnderSelectedNotes(ccNum)
	
	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events
			
			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data
				
				if n_selected == true then --If the note is selected
					for c = 0, ccs, 1 do --Each CC event
						retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(t, c) --Get CC data

						if c_ppq >= n_ppq and c_ppq < n_endppq then --CC ppq is within the note's start and end
							if msg2 == ccNum then --If it's on the correct CC
								reaper.MIDI_SetCC(t, c, true, NULL, NULL, NULL, NULL, NULL, NULL, true); --Set CC as selected
							else
								reaper.MIDI_SetCC(t, c, false, NULL, NULL, NULL, NULL, NULL, NULL, true); --Set CC as deselected
							end 
						end
					end
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.addIntervalToSelectedNotes(interval)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			local noteData = {} --Store note data so that new notes can be selected without iterating over them again
			for n = 0, notes, 1 do 
				retval, selected, muted, ppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(t, n) --Get note data
				if selected == true then
					noteData[n] = {n_ppq=ppq, n_endppq=endppq, n_chan=chan, n_pitch=pitch, n_vel=vel} --Store data
				end
			end

			if noteData ~= nil then
				for n, d in pairs(noteData) do --Go through selected note data
					--Add new note
					reaper.MIDI_InsertNote(t, false, false, d.n_ppq, d.n_endppq, d.n_chan, d.n_pitch+interval, d.n_vel, true)
				end
			end

			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.increaseCCAtSelectedNotesByPercentage(ccNum, percentage)
	
	takes = P.getActiveMIDITakes() --Get all active MIDI takes
	
	if takes ~= false then
		for i, t in pairs(takes) do
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events
			
			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data
				
				if n_selected == true then --If the note is selected

					if n < notes then --There are more notes after this
						retval, nn_selected, nn_muted, nn_ppq, nn_endppq, nn_chan, nn_pitch, nn_vel = reaper.MIDI_GetNote(t, n+1); --Get next note data
					end

					for c = 0, ccs, 1 do --Each CC event

						retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(t, c) --Get CC data

						if msg2 == ccNum then --It's the correct CC Number
							--If the CC ppq is within the note's start and end ppq and before the next
							--note's start or there is no next note
							if (c_ppq >= n_ppq and c_ppq < n_endppq) and (c_ppq < nn_ppq or n+1 == notes) then 
								
								ccValue = msg3 + math.floor(msg3*(percentage/100)) --Increase CC value
						
								if ccValue >= 127 then ccValue = 127 end --Don't let value go above max

								reaper.MIDI_SetCC(t, c, NULL, NULL, NULL, NULL, NULL, NULL, ccValue, true);
							end
						end
					end
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.increaseVelocityOfSelectedNotesByPercentage(percentage)
	
	takes = P.getActiveMIDITakes() --Get all active MIDI takes
	
	if takes ~= false then
		for i, t in pairs(takes) do
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			for n = 0, notes, 1 do --Each note event
				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data
				
				if n_selected == true then --If this note is selected
					velocity = vel + math.floor(vel*(percentage/100)) --Increase velocity by percentage
					if velocity >= 127 then velocity = 127 end --Don't let velocity go above max
					reaper.MIDI_SetNote(t, n, NULL, NULL, NULL, NULL, NULL, NULL, velocity, true);
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.increaseCCAtSelectedNotesByAmount(ccNum, amount)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes
	
	if takes ~= false then
		for i, t in pairs(takes) do
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events
			
			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

				if n_selected == true then --If the note is selected

					if n < notes then --There are more notes after this
						retval, nn_selected, nn_muted, nn_ppq, nn_endppq, nn_chan, nn_pitch, nn_vel = reaper.MIDI_GetNote(t, n+1); --Get next note data
					end

					for c = 0, ccs, 1 do --Each CC event

						retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(t, c) --Get CC data

						if msg2 == ccNum then --It's the correct CC Number
							--If the CC ppq is within the note's start and end ppq and before the next
							--note's start or there is no next note
							if (c_ppq >= n_ppq and c_ppq < n_endppq) and (c_ppq < nn_ppq or n+1 == notes) then 
								
								ccValue = msg3 + amount --Increase CC value
								if ccValue >= 127 then ccValue = 127 end --Don't let value go above max
								reaper.MIDI_SetCC(t, c, NULL, NULL, NULL, NULL, NULL, NULL, ccValue, true);
							end
						end
					end
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.increaseVelocityOfSelectedNotesByAmount(amount)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes
	
	if takes ~= false then
		for i, t in pairs(takes) do
			
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events
			
			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_endppq, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data
				
				if n_selected == true then --If this note is selected
					velocity = vel + amount --Increase velocity
					if velocity >= 127 then velocity = 127 end --Don't let velocity go above max
					reaper.MIDI_SetNote(t, n, NULL, NULL, NULL, NULL, NULL, NULL, velocity, true);
				end
			end

			reaper.MIDI_Sort(t)
		end 
		reaper.UpdateArrange();
	end 

end

function P.normaliseSelectedCCs(ccNum, threshold)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then

		for i, t in pairs(takes) do
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count note and cc events

			highest = 0; --The highest CC value
			ccData = {}; --Store value for all selected CCs (of ccNum) so don't need to use GetCC again
			for c = 0, ccs, 1 do --Each CC
				retval, c_selected, c_muted, c_ppq, c_chanmsg, c_chan, msg2, msg3 = reaper.MIDI_GetCC(t, c) --Get CC data

				if c_selected == true and msg2 == ccNum then
					if msg3 > highest then
						highest = msg3
					end
					ccData[c] = msg3
				end
			end
			
			perc = math.abs(highest - threshold) / highest * 100 --Get height difference as a positive percentage

			--Each selected CC value
			for j, v in pairs(ccData) do

				--If the highest CC found is higher than the threshold use a negative value to pull the CC value down
				if (highest > threshold) then
					newCCValue = v - math.ceil(v / 100 * perc)
				else
					newCCValue = v + math.ceil(v / 100 * perc)
				end

				--Lock min/max to full range
				if newCCValue <= 0 then newCCValue = 1 end
				if newCCValue > 127 then newCCValue = 127 end

				reaper.MIDI_SetCC(t, j, NULL, NULL, NULL, NULL, NULL, NULL, newCCValue, true)
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

function P.normaliseSelectedVelocities(threshold)

	takes = P.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then

		for i, t in pairs(takes) do
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count note and cc events

			highest = 0; --The highest velocity value
			noteData = {}; --Store velocity for all selected notes
			for n = 0, notes, 1 do --Each note
				retval, selected, muted, ppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(t, n) --Get note data

				if selected == true then
					if vel > highest then
						highest = vel
					end
					noteData[n] = vel
				end
			end
			
			perc = math.abs(highest - threshold) / highest * 100 --Get difference as a positive percentage

			--Each selected note's velocity
			for j, v in pairs(noteData) do

				--If the highest velocity found is higher than the threshold use a negative value to pull the velocity down
				if (highest > threshold) then
					newVel = v - math.floor(v / 100 * perc)
				else
					newVel = v + math.floor(v / 100 * perc)
				end

				--Lock min/max to full range
				if newVel <= 0 then newVel = 1 end
				if newVel > 127 then newVel = 127 end

				reaper.MIDI_SetNote(t, j, NULL, NULL, NULL, NULL, NULL, NULL, newVel, true)
			end

			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

--[[
Author: juliansader
Website: http://forum.cockos.com/showthread.php?t=172782&page=25
-- Returns the textsysex index of a given note's notation info.
-- If no notation info is found, returns -1]]--
function P.getTextIndexForNote(take, notePPQ, noteChannel, notePitch)

    reaper.MIDI_Sort(take)
    _, _, _, countTextSysex = reaper.MIDI_CountEvts(take)
    if countTextSysex > 0 then 
    
        -- Use binary search to find text event closest to the left of note's PPQ        
        local rightIndex = countTextSysex-1
        local leftIndex = 0
        local middleIndex
        while (rightIndex-leftIndex)>1 do
            middleIndex = math.ceil((rightIndex+leftIndex)/2)
            local textOK, _, _, textPPQ, _, _ = reaper.MIDI_GetTextSysexEvt(take, middleIndex, true, false, 0, 0, "")
            if textPPQ >= notePPQ then
                rightIndex = middleIndex
            else
                leftIndex = middleIndex
            end     
        end -- while (rightIndex-leftIndex)>1
        
        -- Now search through text events one by one
        for i = leftIndex, countTextSysex-1 do
            local textOK, _, _, textPPQ, type, msg = reaper.MIDI_GetTextSysexEvt(take, i, true, false, 0, 0, "")
            -- Assume that text events are order by PPQ position, so if beyond, no need to search further
            if textPPQ > notePPQ then 
                break
            elseif textPPQ == notePPQ and type == 15 then
                textChannel, textPitch = msg:match("NOTE ([%d]+) ([%d]+)")
                if noteChannel == tonumber(textChannel) and notePitch == tonumber(textPitch) then
                    return i, msg
                end
            end   
        end
    end    
    -- Nothing was found
    return(-1)
end

function P.insertCustomTextAtGivenNote(t, nIdx, text)

	retval, n_selected, n_muted, n_ppq, n_end, n_chan, pitch, vel = reaper.MIDI_GetNote(t, nIdx); --Get note data

	textToInsert = "NOTE 0 " .. pitch .. " custom " .. text
	reaper.MIDI_InsertTextSysexEvt(t, n_selected, n_muted, n_ppq, 0x0F, textToInsert)
end

return P --Not neccessary but considered good practice apparently