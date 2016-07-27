#rem
	TimelineFX Module by Peter Rigby
	
	Copyright (c) 2010 Peter J Rigby
	
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

Global tp_UPDATE_FREQUENCY:Float = 30 ' times per second
Global tp_UPDATE_TIME:Float = 1000 / tp_UPDATE_FREQUENCY
Global tp_CURRENT_UPDATE_TIME:Float = tp_UPDATE_FREQUENCY
Global tp_LOOKUP_FREQUENCY:Float = 30
Global tp_LOOKUP_FREQUENCY_OVERTIME:Float = 1

'constants
Const tlPOINT_EFFECT:Int = 0
Const tlAREA_EFFECT:Int = 1
Const tlLINE_EFFECT:Int = 2
Const tlELLIPSE_EFFECT:Int = 3
Const tlCONTINUOUS:Int = 0
Const tlFINITE:Int = 1
Const tlANGLE_ALIGN:Int = 0
Const tlANGLE_RANDOM:Int = 1
Const tlANGLE_SPECIFY:Int = 2
Const tlEMISSION_INWARDS:Int = 0
Const tlEMISSION_OUTWARDS:Int = 1
Const tlEMISSION_SPECIFIED:Int = 2
Const tlEMISSION_IN_AND_OUT:Int = 3
Const tlEND_KILL:Int = 0
Const tlEND_LOOPAROUND:Int = 1
Const tlEND_LETFREE:Int = 2
Const tlAREA_EFFECT_TOP_EDGE:Int = 0
Const tlAREA_EFFECT_RIGHT_EDGE:Int = 1
Const tlAREA_EFFECT_BOTTOM_EDGE:Int = 2
Const tlAREA_EFFECT_LEFT_EDGE:Int = 3

Const tlGLOBAL_PERCENT_MIN:Float = 0
Const tlGLOBAL_PERCENT_MAX:Float = 20
Const tlGLOBAL_PERCENT_STEPS:Float = 100

Const tlGLOBAL_PERCENT_V_MIN:Float = 0
Const tlGLOBAL_PERCENT_V_MAX:Float = 10
Const tlGLOBAL_PERCENT_V_STEPS:Float = 200

Const tlANGLE_MIN:Float = 0
Const tlANGLE_MAX:Float = 1080
Const tlANGLE_STEPS:Float = 54

Const tlEMISSION_RANGE_MIN:Float = 0
Const tlEMISSION_RANGE_MAX:Float = 180
Const tlEMISSION_RANGE_STEPS:Float = 30

Const tlDIMENSIONS_MIN:Float = 0
Const tlDIMENSIONS_MAX:Float = 2000
Const tlDIMENSIONS_STEPS:Float = 40

Const tlLIFE_MIN:Float = 0
Const tlLIFE_MAX:Float = 100000
Const tlLIFE_STEPS:Float = 200

Const tlAMOUNT_MIN:Float = 0
Const tlAMOUNT_MAX:Float = 2000
Const tlAMOUNT_STEPS:Float = 100

Const tlVELOCITY_MIN:Float = 0
Const tlVELOCITY_MAX:Float = 10000
Const tlVELOCITY_STEPS:Float = 100

Const tlVELOCITY_OVERTIME_MIN:Float = -20
Const tlVELOCITY_OVERTIME_MAX:Float = 20
Const tlVELOCITY_OVERTIME_STEPS:Float = 200

Const tlWEIGHT_MIN:Float = -2500
Const tlWEIGHT_MAX:Float = 2500
Const tlWEIGHT_STEPS:Float = 200

Const tlWEIGHT_VARIATION_MIN:Float = 0
Const tlWEIGHT_VARIATION_MAX:Float = 2500
Const tlWEIGHT_VARIATION_STEPS:Float = 250

Const tlSPIN_MIN:Float = -2000
Const tlSPIN_MAX:Float = 2000
Const tlSPIN_STEPS:Float = 100

Const tlSPIN_VARIATION_MIN:Float = 0
Const tlSPIN_VARIATION_MAX:Float = 2000
Const tlSPIN_VARIATION_STEPS:Float = 100

Const tlSPIN_OVERTIME_MIN:Float = -20
Const tlSPIN_OVERTIME_MAX:Float = 20
Const tlSPIN_OVERTIME_STEPS:Float = 200

Const tlDIRECTION_OVERTIME_MIN:Float = 0
Const tlDIRECTION_OVERTIME_MAX:Float = 4320
Const tlDIRECTION_OVERTIME_STEPS:Float = 216

Const tlFRAMERATE_MIN:Float = 0
Const tlFRAMERATE_MAX:Float = 200
Const tlFRAMERATE_STEPS:Float = 100

Const tlMAX_DIRECTION_VARIATION:Float = 0.3926991
Const tlMAX_VELOCITY_VARIATION:Float = 30
Const tlMOTION_VARIATION_INTERVAL:Int = 30

Const tlPARTICLE_LIMIT:Int = 5000

Const tlUPDATE_MODE_COMPILED:Int = 0
Const tlUPDATE_MODE_INTERPOLATED:Int = 1

Const tlLOOKUP_FREQUENCY:Float = 30
Const tlLOOKUP_FREQUENCY_OVERTIME:Float = 1

Const tlNORMAL_GRAPH:Int = 0
Const tlOVERTIME_GRAPH:Int = 1

Function SetUpdateFrequency(freq:float)
	tp_UPDATE_FREQUENCY = freq ' times per second
	tp_UPDATE_TIME = 1000 / tp_UPDATE_FREQUENCY
	tp_CURRENT_UPDATE_TIME = tp_UPDATE_FREQUENCY
End
