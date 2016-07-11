#rem
	TimelineFX Module by Peter Rigby
	
	Copyright (c) 2012 Peter J Rigby
	
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
	summary: The effect class which is the main parent class for emitters
	Effect types are the main containers for emitters and has a set of global attributes that can effect any emitters it stores.
	The basic entity structure of an effect is: Effect -> Emitter(s) -> Particle(s)
#END
Class tlEffect Extends tlFXObject
	
	Private
	
	'Effect Settings:
	Field _class:Int
	Field emitatpoints:Int
	Field maxgx:Int
	Field maxgy:Int
	Field emission_type:Int
	Field ellipsearc:Float
	Field ellipseoffset:Int
	Field effectlength:Int
	Field uniform:Int
	Field traverseedge:Int
	Field endbehaviour:Int
	Field distancesetbylife:Int
	Field emissiontype:Int
	Field reversespawndirection:Int
	
	'Animation Properties
	Field animwidth:Int
	Field animheight:Int
	Field animx:Int
	Field animy:Int
	Field seed:Int
	Field looped:Int
	Field frameoffset:Int
	Field animzoom:Float
	
	'Overide flags
	Field overrideareasize:Int
	Field overrideemissionangle:Int
	Field overrideemissionrange:Int
	Field overrideangle:Int
	Field overridelife:Int
	Field overrideamount:Int
	Field overridevelocity:Int
	Field overridespin:Int
	Field overridesizex:Int
	Field overridesizey:Int
	Field overrideweight:Int
	Field overridealpha:Int
	Field overridestretch:Int
	Field overrideglobalzoom:Int
	
	'Other temp settings
	Field spawndirection:Int
	
	'Hierarchy
	Field parentemitter:tlEmitter
	
	'Map
	Field directory:StringMap<tlGameObject>
	
	'Particle Management
	Field pm:tlParticleManager
	Field particlecount:Int
	Field donottimeout:Int
	
	'Idle counter
	Field idletime:Int
	
	Field data:Object
	
	Field effectlayer:Int
	
	Public
	
	'Temp attribute values
	'There's no current angle becuase that sets the game object's local_rotation field
	Field currentsizex:Float
	Field currentsizey:Float
	Field currentvelocity:Float
	Field currentspin:Float
	Field currentweight:Float
	Field currentareawidth:Float
	Field currentareaheight:Float
	Field currentalpha:Float
	Field currentemissionangle:Float
	Field currentemissionrange:Float
	Field currentstretch:Float
	Field currentglobalzoom:Float
	
	Method New()
		Super.New()
		Local core:tlEffectCoreComponent = New tlEffectCoreComponent("Core")
		core.Effect = Self
		ImageBox = CreateBox(0, 0, 1, 1)
		AddComponent(core)
		DoNotRender = True
	End
	
	'properties	
	Property EffectLayer:Int()
		Return effectlayer
	Setter(v:Int)
		effectlayer = v
	End
	Property ParticleCount:Int() 
		Return particlecount
	Setter(v:Int)
		particlecount = v	
	End
	Property DoNotTimeOut:Int() 
		Return donottimeout
	Setter(v:Int)
		donottimeout = v	
	End
	Property IdleTime:Int() 
		Return idletime
	Setter(v:Int)
		idletime = v	
	End
	Property Directory:StringMap<tlGameObject>() 
		Return directory
	Setter(v:StringMap<tlGameObject>)
		directory = v	
	End
	Method AddEffectToDirectory(e:tlEffect)
		directory.Add(e.Path.ToUpper(), e)
		For Local em:tlGameObject = EachIn e.GetChildren()
			AddEmitterToDirectory(Cast<tlEmitter>(em))
		Next
	End
	Method AddEmitterToDirectory(e:tlEmitter)
		directory.Add(e.Path, e)
		For Local ef:tlGameObject = EachIn e.Effects
			AddEffectToDirectory(Cast<tlEffect>(ef))
		Next
	End
	Method AddEffect(e:tlEffect)
		directory.Add(e.Path.ToUpper(), e)
		For Local em:tlGameObject = EachIn e.GetChildren()
			AddEmitter(Cast<tlEmitter>(em))
		Next
	End
	Method AddEmitter(e:tlEmitter)
		directory.Add(e.Path.ToUpper(), e)
		For Local ef:tlGameObject = EachIn e.Effects
			AddEffect(Cast<tlEffect>(ef))
		Next
	End
	Property ParentEmitter:tlEmitter() 
		Return parentemitter
	Setter(v:tlEmitter)
		parentemitter = v
	End
	Property EffectClass:Int() 
		Return _class
	Setter(v:Int)
		_class = v
	End
	Property EmitatPoints:Int() 
		Return emitatpoints
	Setter(v:Int)
		emitatpoints = v
	End
	Property MaxGX:Int() 
		Return maxgx
	Setter(v:Int)
		maxgx = v
	End
	Property MaxGY:Int() 
		Return maxgy
	Setter(v:Int)
		maxgy = v
	End
	Property EmissionType:Int() 
		Return emissiontype
	Setter(v:Int)
		emissiontype = v
	End
	Property EllipseArc:Float() 
		Return ellipsearc
	Setter(v:Float)
		ellipsearc = v
	End
	Property EllipseOffset:Int() 
		Return ellipseoffset
	Setter(v:Int)
		ellipseoffset = v
	End
	Property EffectLength:Int() 
		Return effectlength
	Setter(v:Int)
		effectlength = v
	End
	Property Uniform:Int() 
		Return uniform
	Setter(v:Int)
		uniform = v
	End
	Property TraverseEdge:Int() 
		Return traverseedge
	Setter(v:Int)
		traverseedge = v
	End
	Property EndBehaviour:Int() 
		return endbehaviour
	Setter(v:Int)
		endbehaviour = v
	End
	Property DistanceSetByLife:Int() 
		Return distancesetbylife
	Setter(v:Int)
		distancesetbylife = v
	End
	Property ReverseSpawnDirection:Int() 
		Return reversespawndirection 
	Setter(v:Int)
		reversespawndirection = v
	End
	Property SpawnDirection:Int() 
		Return spawndirection
	Setter(v:Int)
		spawndirection = v
	End
	Property AnimWidth:Int() 
		Return animwidth
	Setter(v:Int)
		animwidth = v
	End
	Property AnimHeight:Int() 
		Return animheight
	Setter(v:Int)
		animheight = v
	End
	Property AnimX:Int() 
		Return animx
	Setter(v:Int)
		animx = v
	End
	Property AnimY:Int() 
		Return animy
	Setter(v:Int)
		animy = v
	End
	Property Seed:Int() 
		Return seed
	Setter(v:Int)
		seed = v
	End
	Property Looped:Int() 
		Return looped
	Setter(v:Int)
		looped = v
	End
	Property FrameOffset:Int() 
		Return frameoffset
	Setter(v:Int)
		frameoffset = v
	End
	Property AnimZoom:Float()
		Return animzoom
	Setter(v:Int)
		animzoom = v
	End
	Property CurrentSizeX:Float()
		Return currentsizex
	Setter(v:Float)
		currentsizex = v
	End
	Property CurrentSizeY:Float()
		Return currentsizey
	Setter(v:Float)
		currentsizey = v
	End
	Property CurrentVelocity:Float()
		Return currentvelocity
	Setter(v:Float)
		currentvelocity = v
	End
	Property CurrentSpin:Float()
		Return currentspin
	Setter(v:Float)
		currentspin = v
	End
	Property CurrentWeight:Float()
		Return currentweight
	Setter(v:Float)
		currentweight = v
	End
	Property CurrentAreaWidth:Float()
		Return currentareawidth
	Setter(v:Float)
		currentareawidth = v
	End
	Property CurrentAreaHeight:Float()
		Return currentareaheight
	Setter(v:Float)
		currentareaheight = v
	End
	Property CurrentAlpha:Float()
		Return currentalpha
	Setter(v:Float)
		currentalpha = v
	End
	Property CurrentEmissionAngle:Float()
		Return currentemissionangle
	Setter(v:Float)
		currentemissionangle = v
	End
	Property CurrentEmissionRange:Float()
		Return currentemissionrange
	Setter(v:Float)
		currentemissionrange = v
	End
	Property CurrentStretch:Float()
		Return currentstretch
	Setter(v:Float)
		currentstretch = v
	End
	Property CurrentGlobalZoom:Float()
		Return currentglobalzoom
	Setter(v:Float)
		currentglobalzoom = v
	End
	Property Data:Object()
		Return data
	Setter(v:Object)
		data = v
	End
	
	Property OverrideAreaSize:Int() 
		Return overrideareasize
	Setter(v:Int)
		overrideareasize = v
	End
	Property OverrideEmissionAngle:Int() 
		Return overrideemissionangle
	Setter(v:Int)
		overrideemissionangle = v
	End
	Property OverrideEmissionRange:Int() 
		Return overrideemissionrange
	Setter(v:Int)
		overrideemissionrange = v
	End
	Property OverrideAngle:Int() 
		Return overrideangle
	Setter(v:Int)
		overrideangle = v
	End
	Property OverrideLife:Int() 
		Return overridelife
	Setter(v:Int)
		overridelife = v
	End
	Property OverrideAmount:Int() 
		Return overrideamount
	Setter(v:Int)
		overrideamount = v
	End
	Property OverrideVelocity:Int() 
		Return overridevelocity
	Setter(v:Int)
		overridevelocity = v
	End
	Property OverrideSpin:Int() 
		Return overridespin
	Setter(v:Int)
		overridespin = v
	End
	Property OverrideSizeX:Int() 
		Return overridesizex
	Setter(v:Int)
		overridesizex = v
	End
	Property OverrideSizeY:Int() 
		Return overridesizey
	Setter(v:Int)
		overridesizey = v
	End
	Property OverrideWeight:Int() 
		Return overrideweight
	Setter(v:Int)
		overrideweight = v
	End
	Property OverrideAlpha:Int() 
		Return overridealpha
	Setter(v:Int)
		overridealpha = v
	End
	Property OverrideStretch:Int() 
		Return overridestretch
	Setter(v:Int)
		overridestretch = v
	End
	Property OverrideGlobalZoom:Int() 
		Return overrideglobalzoom
	Setter(v:Int)
		overrideglobalzoom = v
	End
	Property ParticleManager:tlParticleManager() 
		Return pm
	Setter(v:tlParticleManager)
		pm = v
	End
	
	'Main Effect Setters
	
	#REM
		summary: Set the area size of the effect
		If the effect is Area or Elipse then you can use this to change the dimensions of it.
	#END
	Method SetAreaSize(Width:Float, Height:Float)
		overrideareasize = True
		currentareawidth = Width
		currentareaheight = Height
	End
	
	#Rem
		summary: Set the line length of the effect
		For line effects, use this function to override the graph and set the length of the line to whatever you want.
	#END
	Method SetLineLength(Length:Float)
		overrideareasize = True
		currentareawidth = Length
	End
	#Rem
		summary: Set the Emission Angle of the effect
		This overides whatever angle is set on the graph and sets the emission angle of the effect. This won't effect emitters that have <i>UseEffectEmission</i> set
		to FALSE.
	#END
	Method SetEmissionAngle(angle:Float)
		overrideemissionangle = True
		currentemissionangle = angle
	End
	#Rem
		summary: Set the Angle of the effect
		This overides the whatever angle is set on the graph and sets the angle of the effect.
	#END
	Method SetEffectAngle(Angle:Float)
		If Angle < 0 Angle += 360
		overrideangle = True
		LocalRotation = Angle
	End
	#Rem
		summary: Set the Global attribute Life of the effect
		This overides the graph the effect uses to set the Global Attribute Life
	#END
	Method SetLife(life:Float)
		overridelife = True
		currentlife = life
	End
	#Rem
		summary: Set the Global attribute Amount of the effect
		This overides the graph the effect uses to set the Global Attribute Amount
	#END
	Method SetAmount(amount:Float)
		overrideamount = True
		currentamount = amount
	End
	#Rem
		summary: Set the Global attribute velocity of the effect
		This overides the graph the effect uses to set the Global Attribute velocity
	#END
	Method SetVelocity(velocity:Float)
		overridevelocity = True
		currentvelocity = velocity
	End
	#Rem
		summary: Set the Global attribute Spin of the effect
		This overides the graph the effect uses to set the Global Attribute Spin
	#END
	Method SetSpin(spin:Float)
		overridespin = True
		currentspin = spin
	End
	#Rem
	summary: Set the Global attribute Weight of the effect
	This overides the graph the effect uses to set the Global Attribute Weight
	#END
	Method SetWeight(Weight:Float)
		overrideweight = True
		currentweight = Weight
	End
	#Rem
		summary: Set the Global attribute Sizex of the effect
		This overides the graph the effect uses to set the Global Attribute Sizex and sizey
	#END
	Method SetEffectParticleSize(Sizex:Float, Sizey:Float)
		overridesizex = True
		overridesizey = True
		currentsizex = Sizex
		currentsizey = Sizey
	End
	#Rem
		summary: Set the Global attribute Sizex and Sizey of the effect
		This overides the graph the effect uses to set the Global Attribute Sizex and Sizey. You can use this method if your effect changes particle sizes uniformly. Although even if it doesn't you can still
		use this effect it will just change both sizex and size to the same values.
	#END
	Method SetSize(Size:Float)
		overridesizex = True
		overridesizey = True
		currentsizex = Size
		currentsizey = Size
	End
	#Rem
		summary: Set the Global attribute Sizex of the effect
		This overides the graph the effect uses to set the Global Attribute Sizex
	#END
	Method SetSizeX(Sizex:Float)
		overridesizex = True
		currentsizex = Sizex
	End
	#Rem
		summary: Set the Global attribute Sizey of the effect
		This overides the graph the effect uses to set the Global Attribute Sizey. Note that if 
	#END
	Method SetSizeY(Sizey:Float)
		overridesizey = True
		currentsizey = Sizey
	End
	#Rem
		summary: Set the Global attribute Alpha of the effect
		This overides the graph the effect uses to set the Global Attribute Alpha
	#END
	Method SetEffectAlpha(Alpha:Float)
		overridealpha = True
		currentalpha = Alpha
	End
	#Rem
		summary: Set the Global attribute EmissionRange of the effect
		This overides the graph the effect uses to set the Global Attribute EmissionRange
	#END
	Method SetEffectEmissionRange(EmissionRange:Float)
		overrideemissionrange = True
		currentemissionrange = EmissionRange
	End
	#Rem
			Set the current zoom level of the effect
			This overides the graph the effect uses to set the Global Attribute Global Zoom and can be used to scale the size of the whole effect.
	#END
	Method SetZ(v:Float)
		overrideglobalzoom = True
		Zoom = v
	End
	#Rem
			Set the current zoom level of the effect
			This overides the graph the effect uses to set the Global Attribute Global Zoom
	#END
	Method SetGlobalZoom(v:Float)
		overrideglobalzoom = True
		Zoom = v
	End
	#Rem
		summary: Set the Global attribute Stretch of the effect
		This overides the graph the effect uses to set the Global Attribute Stretch
	#END
	Method SetStretch(v:Float)
		overridestretch = True
		currentstretch = v
	End
	
	Method SetSpawnDirection()
		If reversespawndirection
			spawndirection = -1
		Else
			spawndirection = 1
		EndIf
	End
	
	Method SoftKill()
		Dying = True
	End
	
	Method HardKill()
		Destroy()
		pm.RemoveEffect(Self)
	End
	
	'Internal Methods
	
	Method CompileAll()
		For Local graph:tlComponent = EachIn Components
			If Cast<tlGraphComponent>(graph)
				Select Cast<tlGraphComponent>(graph).GraphType
					Case tlNORMAL_GRAPH
						Cast<tlGraphComponent>(graph).Compile()
					Case tlOVERTIME_GRAPH
						Cast<tlGraphComponent>(graph).Compile_Overtime()
				End Select
			End If
		Next
		For Local e:tlGameObject = EachIn GetChildren()
			Cast<tlEmitter>(e).CompileAll()
		Next
	End
	
	Method ParentHasGraph:Int(graph:String)
		If parentemitter
			If parentemitter.ParentEffect.GetComponent(graph)
				Return True
			EndIf
			Return parentemitter.ParentEffect.ParentHasGraph(graph)
		End If

		Return False
	End

End

#REM
	summary: Copy an effect
	You should use this command everytime you want to add an effect to the particle, otherwise you'll simply be referencing the effect directly from the library which simply won't work
	if you add more then one of the same effect.
	
	Pass the effect you wish to copy, the particle manager you want it assigned to and if you wish you can copy the directory which allows you to access individual emitters within the effect, in most
	cases though this will be unnecessary.
#END
Function CopyEffect:tlEffect(e:tlEffect, ParticleManager:tlParticleManager, CopyDirectory:Int = False)
	Local clone:tlEffect = New tlEffect
	clone.EffectClass = e.EffectClass
	clone.EmitatPoints = e.EmitatPoints
	clone.MaxGX = e.MaxGX
	clone.MaxGY = e.MaxGY
	clone.EmissionType = e.EmissionType
	clone.EllipseArc = e.EllipseArc
	clone.EffectLength = e.EffectLength
	clone.Uniform = e.Uniform
	clone.TraverseEdge = e.TraverseEdge
	clone.EndBehaviour = e.EndBehaviour
	clone.DistanceSetByLife = e.DistanceSetByLife
	clone.ReverseSpawnDirection = e.ReverseSpawnDirection
	clone.Name = e.Name
	clone.Path = e.Path
	clone.HandleCenter = e.HandleCenter
	clone.HandleVector = e.HandleVector.Clone()
	clone.DoB = ParticleManager.CurrentTime
	clone.ParticleManager = ParticleManager
	clone.SetSpawnDirection()
	
	'temps
	clone.currentamount = e.currentamount
	clone.currentlife = e.currentlife
	clone.currentsizex = e.currentsizex
	clone.currentsizey = e.currentsizey
	clone.currentvelocity = e.currentvelocity
	clone.LocalRotation = e.LocalRotation
	clone.currentspin = e.currentspin
	clone.currentweight = e.currentweight
	clone.currentareawidth = e.currentareawidth
	clone.currentareaheight = e.currentareaheight
	clone.currentalpha = e.currentalpha
	clone.currentemissionangle = e.currentemissionangle
	clone.currentemissionrange = e.currentemissionrange
	clone.currentstretch = e.currentstretch
	clone.currentglobalzoom = e.currentglobalzoom
	clone.SetGlobalZoom(clone.currentglobalzoom)
	
	For Local component:tlComponent = EachIn e.Components
		If Cast<tlGraphComponent>(component)
			If component.Name = "Angle"
				clone.AddComponent(Cast<tlGraphComponent>(component).Clone(clone, Null, True))
			Else
				clone.AddComponent(Cast<tlGraphComponent>(component).Clone(clone))
			End If
		End If
	Next
	
	For Local emitter:tlGameObject = EachIn e.GetChildren()
		Local emitterclone:tlEmitter = CopyEmitter(Cast<tlEmitter>(emitter), clone, ParticleManager)
		emitterclone.SetParentEffect(clone)
		Cast<tlEmitterCoreComponent>(emitterclone.GetComponent("Core")).InitSpawner(emitterclone)
		clone.AddChild(emitterclone)
	Next
	
	If CopyDirectory
		If Not clone.Directory clone.Directory = New StringMap<tlGameObject>
		clone.AddEffect(clone)
	EndIf
	
	Return clone
End Function

