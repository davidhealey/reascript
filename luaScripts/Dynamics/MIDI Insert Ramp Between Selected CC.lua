--[[
 * ReaScript Name: MIDI Insert Ramp Between Selected CC
 * Description: Interpolate multiple CC events by creating new ones. Works on a single CC lane.	Built on X-Raym's original script.
 * Author of this version: David Healey
 * Original Author: X-Raym - http://extremraym.com
 * Licence: GPL v3
--]]

--[[
 * Changelog:
 * v1.2.1 (27/06/2017) - David Healey's branch.
 * v1.2 (2017-05-29)
	# Works with multiple CCS.
 * v1.1.1 (2016-12-10)
	# Text
 * v1.1 (2016-12-10)
	# Bug fix
 * v1.0 (2016-01-04)
	+ Initial Release
--]]

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 1
local interval = 16

function GetCC(take, cc)
	return cc.selected, cc.muted, cc.ppqpos, cc.chanmsg, cc.chan, cc.msg2, cc.msg3
end

function main()

	takes = drmp.getActiveMIDITakes() --Get all active MIDI takes

	if takes ~= false then
		for i, t in pairs(takes) do
		
			retval, notes, ccs, sysex = reaper.MIDI_CountEvts(t)	

			if ccs == 0 then return end

			-- Store CC by types
			midi_cc = {}
			for j = 0, ccs - 1 do
				cc = {}
				retval, cc.selected, cc.muted, cc.ppqpos, cc.chanmsg, cc.chan, cc.msg2, cc.msg3 = reaper.MIDI_GetCC(t, j)
				if not midi_cc[cc.msg2] then midi_cc[cc.msg2] = {} end
				table.insert(midi_cc[cc.msg2], cc)
			end

			-- Look for consecutive CC
			cc_events = {}
			cc_events_len = 0

			for key, val in pairs(midi_cc) do

				-- GET SELECTED NOTES (from 0 index)
				for k = 1, #val - 1 do

					a_selected, a_muted, a_ppqpos, a_chanmsg, a_chan, a_msg2, a_msg3 = GetCC(t, val[k])
					b_selected, b_muted, b_ppqpos, b_chanmsg, b_chan, b_msg2, b_msg3 = GetCC(t, val[k+1])

					if a_selected == true and b_selected == true then

						-- INSERT NEW CCs
						time_interval = (b_ppqpos - a_ppqpos) / interval

						for z = 1, interval - 1 do

							cc_events_len = cc_events_len + 1
							cc_events[cc_events_len] = {}

							c_ppqpos = a_ppqpos + time_interval * z
							c_msg3 = math.floor( ( (b_msg3 - a_msg3) / interval * z + a_msg3 )+ 0.5 )

							cc_events[cc_events_len].ppqpos = c_ppqpos
							cc_events[cc_events_len].chanmsg = a_chanmsg
							cc_events[cc_events_len].chan = a_chan
							cc_events[cc_events_len].msg3 = c_msg3
						end
					end
				end

				-- Insert Events
				for x, cc in ipairs(cc_events) do
					reaper.MIDI_InsertCC(t, false, false, cc.ppqpos, cc.chanmsg, cc.chan, ccNum, cc.msg3)
				end
			end
			reaper.MIDI_Sort(t)
		end
		reaper.UpdateArrange();
	end
end

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
main() -- Execute your main function
reaper.Undo_EndBlock("Insert CC linear ramp events between selected ones if consecutive", -1) -- End of the undo block. Leave it at the bottom of your main function.