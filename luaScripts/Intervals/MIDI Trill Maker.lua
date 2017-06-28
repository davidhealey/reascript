--[[ 
* ReaScript Name: MIDI Trill Maker
* Written: 02/06/2017
* Last Updated: 21/06/2017
* Author: David Healey.
--]] 

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

function main(interval, length)
	
	takes = drmp.getActiveMIDITakes() --Get all active MIDI takes
	
	reaper.Undo_BeginBlock();

	if takes ~= false then
		for i, t in pairs(takes) do
			
	        -- Weird, sometimes REAPER's PPQ is not 960. So first get PPQ of take - JulianSader.
	        local QNstart = reaper.MIDI_GetProjQNFromPPQPos(t, 0)
	        local RPPQ = reaper.MIDI_GetPPQPosFromProjQN(t, QNstart + 1) - reaper.MIDI_GetPPQPosFromProjQN(t, QNstart)
	        local len = (4.0*RPPQ)*(1/length) -- Desired length of trill notes in ticks
		
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			local noteData = {} --Store note data in an array so that new notes can be selected without iterating over them
			for n = 0, notes, 1 do 
				retval, selected, muted, ppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(t, n) --Get note data
				if selected == true then
					noteData[n] = {n_ppq=ppq, n_endppq=endppq, n_chan=chan, n_pitch=pitch, n_vel=vel}--Store data
				end
			end

			if noteData ~= nil then
				for n, d in pairs(noteData) do --Go through selected note data

					reaper.MIDI_DeleteNote(t, n) --Delete original note

					--The number of new notes to insert based on the length of selected note
					noteCount = (d.n_endppq - d.n_ppq) / len

					for i = 0, noteCount, 1 do 
						if i % 2 == 0 then --If i is even
							reaper.MIDI_InsertNote(t, true, false, d.n_ppq+i*len, d.n_ppq+(i*len)+len, d.n_chan, d.n_pitch, d.n_vel, true);
						else
							reaper.MIDI_InsertNote(t, true, false, d.n_ppq+i*len, d.n_ppq+(i*len)+len, d.n_chan, d.n_pitch+interval, d.n_vel, true);
						end
					end
				end
			end
			reaper.MIDI_Sort(t)
		end
	end
	reaper.UpdateArrange();
end

--RUN----------------
retval, input = reaper.GetUserInputs("Trill Maker", 2, "Interval,Note Length", "1,32")

local interval, length = input:match("([^,]+),([^,]+)"); --Split input into variables

if type(tonumber(interval)) == "number" and type(tonumber(length)) == "number" and tonumber(length) > 0 then --Validate input
	if retval ~= false then
		main(interval, length)
	end
end