--[[ 
* ReaScript Name: MIDI Retrigger Trill Maker
* Written: 02/06/2017
* Updated: 21/06/2017
* Author: David Healey.
--]] 

--Inserts trilling note above/below the sustaining note for use with VSTs with a legato retrigger function
---------------------------
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

function main(interval, length)

	takes = drmp.getActiveMIDITakes() --Get all active MIDI takes
	
	reaper.Undo_BeginBlock();

	if takes ~= false then
		for i, t in pairs(takes) do

	        -- Weird, sometimes REAPER's PPQ is not 960.  So first get PPQ of take - JulianSader.
	        local QNstart = reaper.MIDI_GetProjQNFromPPQPos(t, 0)
	        local RPPQ = reaper.MIDI_GetPPQPosFromProjQN(t, QNstart + 1) - reaper.MIDI_GetPPQPosFromProjQN(t, QNstart)
	        local len = (4.0*RPPQ)*(1/length) -- Desired length of trill notes in ticks

			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count events

			local noteData = {} --Store note data in an array so that new notes an be selected without iterating over them
			for n = 0, notes, 1 do 
				retval, selected, muted, ppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(t, n) --Get note data
				if selected == true then
					noteData[n] = {n_ppq=ppq, n_endppq=endppq, n_chan=chan, n_pitch=pitch, n_vel=vel}--Store data
				end
			end

			if noteData ~= nil then
				for n, d in pairs(noteData) do --Go through selected note data

					noteCount = (d.n_endppq - d.n_ppq) / len --The number of new notes to insert based on the length of selected note

					for i = 0, noteCount, 1 do 
						if i % 2 ~= 0 then --If i is odd
							reaper.MIDI_InsertNote(t, true, false, d.n_ppq+i*len, d.n_ppq+(i*len)+len, d.n_chan, d.n_pitch+interval, d.n_vel, true);
						end
					end
				end
				reaper.MIDIEditor_OnCommand(e, 41614) --Call Reaper command to hide selected notes (new trill notes)
			end
			reaper.MIDI_Sort(t)
		end
	end
		reaper.Undo_EndBlock("MIDI Retrigger Trill Maker",-1);
		reaper.UpdateArrange();
end

--RUN----------------
retval, input = reaper.GetUserInputs("Trill Maker", 2, "interval,Note Length", "1,32")

local interval, length = input:match("([^,]+),([^,]+)"); --Split input into variables

if type(tonumber(interval)) == "number" and type(tonumber(length)) == "number" and tonumber(length) > 0 then --Validate input
	if retval ~= false then
		main(interval, length)
	end
end