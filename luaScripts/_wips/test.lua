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

local commands = {41120, 41121, 41122, 41123, 41125, 41126, 41127, 41128, 41118, 41119} --ppp - fff - cresc, dim
local dynamics = {11, 27, 43, 59, 75, 91, 107, 122}

input = gfx.showmenu(">Velocity|>Insert|ppp|pp|p|mp|mf|f|ff|<fff|>Normalise|ppp|pp|p|mp|mf|f|ff|<fff|<Accent|>CC1|>Insert|ppp|pp|p|mp|mf|f|ff|<fff|>Normalise|ppp|pp|p|mp|mf|f|ff|<<fff||Accent|Select CC1|<Delete CC1|>Markings|ppp|pp|p|mp|mf|f|ff|fff||Cresc|<Dim")

if input ~= 0 then

  takes = drmp.getActiveMIDITakes() --Get all active MIDI takes

  if takes ~= false then
    
    reaper.Undo_BeginBlock()

    for i, t in pairs(takes) do
      retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t) --Count note and cc events
      
      for n = 0, notes, 1 do --Each note event

        retval, n_selected, n_muted, n_ppq, n_end, n_chan, pitch, vel = reaper.MIDI_GetNote(t, n); --Get note data

        if n_selected == true then

          if input > 0 and input < 9 then --Velocity >> Insert
            drmp.setVelocityForSelectedNotes(dynamics[input])
          end

          if input > 8 and input < 17 then --Velocity >> Normalise
            drmp.normaliseSelectedVelocities(dynamics[input-8])
          end

          if input == 17 then --Velocity >> Accent
            drmp.increaseVelocityOfSelectedNotesByAmount(5)
          end

          if input > 17 and input < 26 then --CC1 >> Insert
            drmp.deleteCCUnderSelectedNotes(1)
            drmp.insertCCAtSelectedNotes(1, dynamics[input-17])
          end

          if input > 25 and input < 34 then --CC1 >> Normalise
            drmp.normaliseSelectedCCs(1, dynamics[input-25])
          end

          if input == 34 then --CC1 >> Accent
            drmp.increaseCCAtSelectedNotesByAmount(1, 5)
          end

          if input == 35 then --CC1 >> Select CC
            drmp.selectCCEventsUnderSelectedNotes(1)
          end

          if input == 36 then --CC1 >> Delete CC
            drmp.deleteCCUnderSelectedNotes(1)
          end

          if input > 36 then --Dynamic marking commands
            reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), 40440) --Move cursor to start of events
            reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), commands[input-36])
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
