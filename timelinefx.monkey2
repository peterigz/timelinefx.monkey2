#rem
	TimelineFX Module by Peter Rigby
	
	Copyright (c) 2017 Peter J Rigby
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

#end

Namespace timelinefx

#Import "<std>"
#Import "<mojo>"
#Import "math"
#Import "vector"
#Import "matrix"
#Import "collision"
#Import "quadtree"
#import "shape2"
#Import "gameobject"
#Import "particlemanager"
#Import "fxobject"
#Import "effect"
#Import "emitter"
#Import "particle"
#Import "components"
#Import "attributes"
#Import "effectattributes"
#Import "emitterattributes"
#Import "spawncomponents"
#Import "graphmath"
#Import "library"
#Import "xml"
#Import "loaders"

Using std..
Using mojo..

#Rem monkeydoc @hidden
#end
Global tp_UPDATE_FREQUENCY:Float = 30 ' times per second
#Rem monkeydoc @hidden
#end
Global tp_UPDATE_TIME:Float = 1000 / tp_UPDATE_FREQUENCY
#Rem monkeydoc @hidden
#end
Global tp_CURRENT_UPDATE_TIME:Float = tp_UPDATE_FREQUENCY
#Rem monkeydoc @hidden
#end
Global tp_LOOKUP_FREQUENCY:Float = 30
#Rem monkeydoc @hidden
#end
Global tp_LOOKUP_FREQUENCY_OVERTIME:Float = 1

'constants

#Rem monkeydoc @hidden
#end
Const tlPOINT_EFFECT:Int = 0
#Rem monkeydoc @hidden
#end
Const tlAREA_EFFECT:Int = 1
#Rem monkeydoc @hidden
#end
Const tlLINE_EFFECT:Int = 2
#Rem monkeydoc @hidden
#end
Const tlELLIPSE_EFFECT:Int = 3
#Rem monkeydoc @hidden
#end
Const tlCONTINUOUS:Int = 0
#Rem monkeydoc @hidden
#end
Const tlFINITE:Int = 1
#Rem monkeydoc @hidden
#end
Const tlANGLE_ALIGN:Int = 0
#Rem monkeydoc @hidden
#end
Const tlANGLE_RANDOM:Int = 1
#Rem monkeydoc @hidden
#end
Const tlANGLE_SPECIFY:Int = 2
#Rem monkeydoc @hidden
#end
Const tlEMISSION_INWARDS:Int = 0
#Rem monkeydoc @hidden
#end
Const tlEMISSION_OUTWARDS:Int = 1
#Rem monkeydoc @hidden
#end
Const tlEMISSION_SPECIFIED:Int = 2
#Rem monkeydoc @hidden
#end
Const tlEMISSION_IN_AND_OUT:Int = 3
#Rem monkeydoc @hidden
#end
Const tlEND_KILL:Int = 0
#Rem monkeydoc @hidden
#end
Const tlEND_LOOPAROUND:Int = 1
#Rem monkeydoc @hidden
#end
Const tlEND_LETFREE:Int = 2
#Rem monkeydoc @hidden
#end
Const tlAREA_EFFECT_TOP_EDGE:Int = 0
#Rem monkeydoc @hidden
#end
Const tlAREA_EFFECT_RIGHT_EDGE:Int = 1
#Rem monkeydoc @hidden
#end
Const tlAREA_EFFECT_BOTTOM_EDGE:Int = 2
#Rem monkeydoc @hidden
#end
Const tlAREA_EFFECT_LEFT_EDGE:Int = 3

#Rem monkeydoc @hidden
#end
Const tlGLOBAL_PERCENT_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlGLOBAL_PERCENT_MAX:Float = 20
#Rem monkeydoc @hidden
#end
Const tlGLOBAL_PERCENT_STEPS:Float = 100

#Rem monkeydoc @hidden
#end
Const tlGLOBAL_PERCENT_V_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlGLOBAL_PERCENT_V_MAX:Float = 10
#Rem monkeydoc @hidden
#end
Const tlGLOBAL_PERCENT_V_STEPS:Float = 200

#Rem monkeydoc @hidden
#end
Const tlANGLE_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlANGLE_MAX:Float = 1080
#Rem monkeydoc @hidden
#end
Const tlANGLE_STEPS:Float = 54

#Rem monkeydoc @hidden
#end
Const tlEMISSION_RANGE_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlEMISSION_RANGE_MAX:Float = 180
#Rem monkeydoc @hidden
#end
Const tlEMISSION_RANGE_STEPS:Float = 30

#Rem monkeydoc @hidden
#end
Const tlDIMENSIONS_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlDIMENSIONS_MAX:Float = 2000
#Rem monkeydoc @hidden
#end
Const tlDIMENSIONS_STEPS:Float = 40

#Rem monkeydoc @hidden
#end
Const tlLIFE_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlLIFE_MAX:Float = 100000
#Rem monkeydoc @hidden
#end
Const tlLIFE_STEPS:Float = 200

#Rem monkeydoc @hidden
#end
Const tlAMOUNT_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlAMOUNT_MAX:Float = 2000
#Rem monkeydoc @hidden
#end
Const tlAMOUNT_STEPS:Float = 100

#Rem monkeydoc @hidden
#end
Const tlVELOCITY_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlVELOCITY_MAX:Float = 10000
#Rem monkeydoc @hidden
#end
Const tlVELOCITY_STEPS:Float = 100

#Rem monkeydoc @hidden
#end
Const tlVELOCITY_OVERTIME_MIN:Float = -20
#Rem monkeydoc @hidden
#end
Const tlVELOCITY_OVERTIME_MAX:Float = 20
#Rem monkeydoc @hidden
#end
Const tlVELOCITY_OVERTIME_STEPS:Float = 200

#Rem monkeydoc @hidden
#end
Const tlWEIGHT_MIN:Float = -2500
#Rem monkeydoc @hidden
#end
Const tlWEIGHT_MAX:Float = 2500
#Rem monkeydoc @hidden
#end
Const tlWEIGHT_STEPS:Float = 200

#Rem monkeydoc @hidden
#end
Const tlWEIGHT_VARIATION_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlWEIGHT_VARIATION_MAX:Float = 2500
#Rem monkeydoc @hidden
#end
Const tlWEIGHT_VARIATION_STEPS:Float = 250

#Rem monkeydoc @hidden
#end
Const tlSPIN_MIN:Float = -2000
#Rem monkeydoc @hidden
#end
Const tlSPIN_MAX:Float = 2000
#Rem monkeydoc @hidden
#end
Const tlSPIN_STEPS:Float = 100

#Rem monkeydoc @hidden
#end
Const tlSPIN_VARIATION_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlSPIN_VARIATION_MAX:Float = 2000
#Rem monkeydoc @hidden
#end
Const tlSPIN_VARIATION_STEPS:Float = 100

#Rem monkeydoc @hidden
#end
Const tlSPIN_OVERTIME_MIN:Float = -20
#Rem monkeydoc @hidden
#end
Const tlSPIN_OVERTIME_MAX:Float = 20
#Rem monkeydoc @hidden
#end
Const tlSPIN_OVERTIME_STEPS:Float = 200

#Rem monkeydoc @hidden
#end
Const tlDIRECTION_OVERTIME_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlDIRECTION_OVERTIME_MAX:Float = 4320
#Rem monkeydoc @hidden
#end
Const tlDIRECTION_OVERTIME_STEPS:Float = 216

#Rem monkeydoc @hidden
#end
Const tlFRAMERATE_MIN:Float = 0
#Rem monkeydoc @hidden
#end
Const tlFRAMERATE_MAX:Float = 200
#Rem monkeydoc @hidden
#end
Const tlFRAMERATE_STEPS:Float = 100

#Rem monkeydoc @hidden
#end
Const tlMAX_DIRECTION_VARIATION:Float = 0.3926991
#Rem monkeydoc @hidden
#end
Const tlMAX_VELOCITY_VARIATION:Float = 30
#Rem monkeydoc @hidden
#end
Const tlMOTION_VARIATION_INTERVAL:Int = 30

#Rem monkeydoc @hidden
#end
Const tlPARTICLE_LIMIT:Int = 5000

#Rem monkeydoc @hidden
#end
Const tlUPDATE_MODE_COMPILED:Int = 0
#Rem monkeydoc @hidden
#end
Const tlUPDATE_MODE_INTERPOLATED:Int = 1

#Rem monkeydoc @hidden
#end
Const tlLOOKUP_FREQUENCY:Float = 30
#Rem monkeydoc @hidden
#end
Const tlLOOKUP_FREQUENCY_OVERTIME:Float = 1

#Rem monkeydoc @hidden
#end
Const tlNORMAL_GRAPH:Int = 0
#Rem monkeydoc @hidden
#end
Const tlOVERTIME_GRAPH:Int = 1

#Rem monkeydoc Set the update frequency of the particles
	It's important to set this to the correct value so that the particle effects playback at the correct rate. For example if you game runs at 60hz then set it to 60.
#end
Function SetUpdateFrequency(freq:float)
	tp_UPDATE_FREQUENCY = freq ' times per second
	tp_UPDATE_TIME = 1000 / tp_UPDATE_FREQUENCY
	tp_CURRENT_UPDATE_TIME = tp_UPDATE_FREQUENCY
End
