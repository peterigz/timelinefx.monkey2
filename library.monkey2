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

#END

Namespace timelinefx

Using timelinefx..

#REM
	summary: Effects library for storing a list of effects and particle images/animations
	When using LoadEffects, all the effects and images that go with them are stored in this type.
#END
Class tlEffectsLibrary
	Private
	
	Field effects:StringMap<tlEffect> = New StringMap<tlEffect>
	Field emitters:StringMap<tlEmitter> = New StringMap<tlEmitter>
	Field name:String
	Field shapelist:IntMap<tlShape> = New IntMap<tlShape> 
	
	Public
	
	'summary: add a shape to the library
	Method AddShape:Bool(shape:tlShape)
		Local key:int = shape.LargeIndex
		return shapelist.Add(key, shape)
	End
	
	'summary: add an effect to the library
	Method AddEffect:Void(e:tlEffect)
		effects.Add(e.Path.ToUpper(), e)
		For Local em:tlGameObject = EachIn e.GetChildren()
			AddEmitter(Cast<tlEmitter>(em))
		Next
	End
	#REM
		summary: Add a new emitter to the library. 
		Emitters are stored using a map and can be retrieved using #GetEmitter. Generally you don't want to call this at all unless you're building your effects manually, 
		just use [a #AddEffect]AddEffect[/a] and all its emitters will be added also.
	#END
	Method AddEmitter:Void(e:tlEmitter)
		emitters.Add(e.Path.ToUpper(), e)
		For Local ef:tlEffect = EachIn e.Effects
			AddEffect(ef)
		Next
	End
	#REM
	summary: Clear all effects in the library
	Use this to empty the library of all effects and shapes.
	#END
	Method ClearAll:Void()
		Self.name = ""
		For Local e:tlEffect = EachIn effects.Values
			e.Destroy()
		Next
		Self.effects.Clear()
		Self.effects = Null
		Self.shapelist.Clear()
		Self.shapelist = Null
	End
	#REM
	summary: Retrieve an effect from the library
	Use this to get an effect from the library by passing the name of the effect you want. Example:
	
	[code]
	local explosion:tlEffect=MyEffectsLibrary.GetEffect("explosion")
	[/code]
	
	All effects and emitters are stored using a directory like path structure so to get at sub effects you can do:</p>
	
	[code]
	local explosion:tlEffect=MyEffectsLibrary.GetEffect("Effect/Emitter/Sub Effect/Another Emitter/A deeper sub effect")}
	[/code]
	
	Note that you should always use forward slashes.
	#END
	Method GetEffect:tlEffect(name:String)
		If Cast<tlEffect>(effects.Get(name.ToUpper()))
			Return Cast<tlEffect>(effects.Get(name.ToUpper()))
		End If
		return Null
	End
	#REM
	summary: Retrieve an emitter from the library
	Use this To get an emitter from the library by passing the name of the emitter you want. All effects And emitters are
	stored using a map with a directory like path structure. So retrieving an emitter called blast wave inside an effect called explosion
	would be done like so:
	
	[code]
	local blastwave:tlemitter=MyEffectsLibrary.GetEmitter("explosion/blast wave")
	[/code]
	
	Note that you should always use forward slashes.
	#END
	Method GetEmitter:tlEmitter(name:String)
		Return Cast<tlEmitter>(emitters.Get(name.ToUpper()))
	End
	#REM
		summary: Get a Shape (#tlResource) from the library
	#END
	Method GetShape:tlShape(index:Int)
		Return Cast<tlShape>(shapelist.Get(index))
	End
	
	#REM
		summary: Get the name of the effects library
	#END
	Property Name:String() 
		Return name
	End
	
	#REM
		summary: Return the list of effects stored in the library
	#END	
	Property Effects:StringMap<tlEffect>() 
		Return effects
	End

	
End