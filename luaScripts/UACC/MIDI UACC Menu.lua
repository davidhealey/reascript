--[[ 
* ReaScript Name: UACC Menu
* Written: 27/06/2017
* Last Updated: 27/06/2017
* Author: David Healey
--]] 

package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."../?.lua;".. package.path
require('daves reaper midi package v1-0')

local ccNum = 32
local INSERT_BEFORE = 0; --Set to 1 if you want the CC data inserted before each selected note

gfx.init("UACC", 1, 1)

gfx.x = gfx.mouse_x
gfx.y = gfx.mouse_y

input = gfx.showmenu(">Long|1: Long Generic|2: Long Alternative|3: Long Octave|4: Long Octave muted|5: Long Small (half)|6: Long Small muted (half muted)|7: Long Muted (cs/stopped)|8: Long Soft (flautando/hollow)|9: Long Hard (cuivre/overblown/nasty)|10: Long Harmonic|11: Long Trem (tremolando/flutter)|12: Long Trem muted (tremolando/flutter cs/stopped)|13: Long Trem soft (trem sul pont)|14: Long Trem hard (flutter overblown)|15: Long Term sul|16: Long Vibrato (molto or vib. only)|17: Long Higher (bells up/sul asto)|18: Long Lower (sul pont)|<19: Undefined|>Legato|20: Legato Generic|21: Legato Alternative|22: Legato Octave|23: Legato Octave muted|24: Legato Small|25: Legato Small muted|26: Legato Muted|27: Legato Soft|28: Legato Hard|29: Legato Harmonic|30: Legato Trem|31: Legato Slow (portamento/glissandi)|32: Legato Fast|33: Legato Slurred (legato runs)|34: Legato Detaché|35: Legato Higher (sul tasto)|36: Legato Lower (sul pont)|37: Undefined|38: Undefined|<39: Undefined|>Short|40: Short Generic|41: Short Alternative|42: Short Staccatissimo/very short)|43: Short Spiccato/very short soft|44: Short Leisurely (longer staccato)|45: Short Octave|46: Short Octave muted|47: Short Muted (cs/stopped)|48: Short Soft (brushed/feathered)|49: Short Hard (dig)|50: Short Tenuto|51: Short Tenuto soft|52: Short Marcato|53: Short Marcato soft|54: Short Marcato hard (bells up)|55: Short Marcato longer|56: Short Plucked (pizzicato)|57: Short Plucked hard (Bartok)|58: Short Struck (Col legno)|59: Short Higher (bells up/sul tasto)|60: Short Lower (sul pont)|61: Short Harmonic|62: Undefined|63: Undefined|64: Undefined|65: Undefined|66: Undefined|67: Undefined|68: Undefined|<69: Undefined|>Decorative|70: Trill min 2nd|71: Trill maj 2nd|72: Trill min 3rd|73: Trill maj 3rd|74: Trill perf 4th|75: Multitongue|76: Multitongue muted|77: Undefined|78: Undefined|79: Undefined|80: Synced - 120bpm (trem/trill)|81: Synced - 150bpm (trem/trill)|82: Synced - 180bpm (trem/trill)|83: Undefined|84: Undefined|85: Undefined|86: Undefined|87: Undefined|88: Undefined|<89: Undefined|>Phrases and Dynamics|90: FX 1|91: FX 2|92: FX 3|93: FX 4|94: FX 5|95: FX 6|96: FX 7|97: FX 8|98: FX 9|99: FX 10|100: Upwards (rips and runs)|101: Downwards (falls and runs)|102: Crescendo|103: Diminuendo|104: Arc|105: Slides|106: Undefined|107: Undefined|108: Undefined|<109: Undefined|>Various|110: Disco upwards (rips)|111: Disco downwards (falls)|112: Undefined|113: Undefined|114: Undefined|115: Undefined|116: Undefined|117: Undefined|118: Undefined|119: Undefined|120: Undefined|121: Undefined|123: Undefined|124: Undefined|125: Undefined|126: Undefined|<127: Undefined||Select UACC For Selected Note|Delete UACC For Selected Notes")

if input ~= 0 then
	reaper.Undo_BeginBlock();

	if input < 127 then 
		drmp.deleteCCUnderSelectedNotes(ccNum) --Remove existing UACC data
		if INSERT_BEFORE == 1 then
			drmp.insertCCBeforeSelectedNotes(ccNum, input) --Insert selected UACC data
		else
			drmp.insertCCAtSelectedNotes(ccNum, input) --Insert selected UACC data
		end
		reaper.Undo_EndBlock("MIDI Insert UACC From Menu",-1)
	else
		if input == 127 then 
			drmp.selectCCEventsUnderSelectedNotes(ccNum)
			reaper.Undo_EndBlock("MIDI Select UACC Events Under Selected Notes",-1);
		end

		if input == 128 then 
			drmp.deleteCCUnderSelectedNotes(ccNum)
			reaper.Undo_EndBlock("MIDI Delete UACC Under Selected Notes",-1)
		end
	end
end

gfx.quit()