--[[ 
* ReaScript Name: Dynamics Menu
* Written: 27/06/2017
* Last Updated: 27/06/2017
* Author: David Healey
--]] 

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

gfx.init("Dynamics", 1, 1)

gfx.x = gfx.mouse_x
gfx.y = gfx.mouse_y

input = gfx.showmenu(">Dynamic Marking|ppp|pp|p|mp|mf|f|ff|fff|sfz|fp")

--local dynamics = {"ppp", "pp", "p", "mp", "mf", "f", "ff", "fff", "0xE539", "0xE534"} --sfz, fp
local dynamics = {41120, 41121, 41122, 41123, 41125, 41126, 41127, 41128, "0xE539", "0xE534"} --sfz, fp

if input ~= 0 then

	takes = drmp.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		
		reaper.Undo_BeginBlock()

		for i, t in pairs(takes) do
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count note and cc events
			
			for n = 0, notes, 1 do --Each note event

				retval, n_selected, n_muted, n_ppq, n_end, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

				if n_selected == true then 

					if input < 9 then --Built in markings
						reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 40440) --Move edit cursor
						reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), dynamics[input])
						--reaper.MIDI_InsertTextSysexEvt(t, true, n_muted, n_ppq, 0xF, "TRAC dynamic " .. dynamics[input] .. " ypos 2.000")
					else --Custom symbols
						reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 40440) --Remove existing custom text
						drmp.insertCustomTextAtGivenNote(t, n, dynamics[input])
					end
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.Undo_EndBlock("MIDI Dynamics Menu",-1)
	end
	reaper.UpdateArrange();
end

gfx.quit()