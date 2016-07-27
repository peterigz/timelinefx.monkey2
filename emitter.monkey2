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

Class tlEmitter Extends tlFXObject
	'lists
	Private
	
	Field effects:List<tlEffect>
	
	'emitter settings
	Field particlerelative:Int
	Field randomcolor:Int
	Field layer:Int
	Field singleparticle:Int
	Field animate:Int
	Field animateonce:Int
	Field frame:Int
	Field randomstartframe:Int
	Field animationdirection:Int
	Field uniform:Int
	Field angletype:Int
	Field angleoffset:Float
	Field lockangle:Int
	Field anglerelative:Int
	Field useeffectemission:Int
	Field colorrepeat:Int
	Field alpharepeat:Int
	Field oneshot:Int
	Field groupparticles:Int
	
	'The particle sprite
	Field sprite:tlShape
	
	Field run_uniform:Int
	Field run_scalex:Int
	Field run_scaley:Int
	Field run_velocity:Int
	Field run_stretch:Int
	Field run_globalvelocity:Int
	Field run_alpha:Int
	Field run_colour:Int
	Field run_direction:Int
	Field run_dvovertime:Int
	Field run_spin:Int
	Field run_weight:Int
	Field run_framerate:Int
	
	'Components that setup a particle when it spawns
	Field spawncomponents:List<tlSpawnComponent>
	
	'editor settings
	Field visible:Int = True
	
	'Other Settings
	Field tweenspawns:Int
	
	'Hierarchy
	Field parenteffect:tlEffect
	
	Public
	
	'Temp variables
	Field currentbasespeed:Float
	Field currentbaseweight:Float
	Field currentbasesizex:Float
	Field currentbasesizey:Float
	Field currentbasespin:Float
	Field currentsplatter:Float
	Field currentlifevariation:Float
	Field currentamountvariation:Float
	Field currentvelocityvariation:Float
	Field currentweightvariation:Float
	Field currentsizexvariation:Float
	Field currentsizeyvariation:Float
	Field currentspinvariation:Float
	Field currentdirectionvariation:Float
	Field currentalphaovertime:Float
	Field currentvelocityovertime:Float
	Field currentweightovertime:Float
	Field currentscalexovertime:Float
	Field currentscaleyovertime:Float
	Field currentspinovertime:Float
	Field currentdirection:Float
	Field currentdirectionvariationot:Float
	Field currentframerateovertime:Float
	Field currentstretchovertime:Float
	Field currentredovertime:Float
	Field currentgreenovertime:Float
	Field currentblueovertime:Float
	Field currentglobalvelocity:Float
	Field currentemissionangle:Float
	Field currentemissionrange:Float
	
	'Quick acccess variables to graph components
	Field scalex_component:tlEC_ScaleXOvertime
	Field scaley_component:tlEC_ScaleYOvertime
	Field uscale_component:tlEC_UniformScale
	Field velocity_component:tlEC_VelocityOvertime
	Field stretch_component:tlEC_StretchOvertime
	Field globalvelocity_component:tlEC_GlobalVelocity
	Field alpha_component:tlEC_AlphaOvertime
	Field red_component:tlEC_RedOvertime
	Field green_component:tlEC_GreenOvertime
	Field blue_component:tlEC_BlueOvertime
	Field direction_component:tlEC_DirectionOvertime
	Field dvovertime_component:tlEC_DirectionVariationOvertime
	Field spin_component:tlEC_SpinOvertime
	Field weight_component:tlEC_WeightOvertime
	Field framerate_component:tlEC_FramerateOvertime
	
	'properties	
	Property ParentEffect:tlEffect()
		Return parenteffect
	Setter(v:tlEffect)
		parenteffect = v
	End
	Property RunVelocity:Int()
		Return run_velocity
	Setter(v:Int)
		run_velocity = v
	End
	Property Effects:List<tlEffect>()
		Return effects
	End
	Property Sprite:tlShape()
		Return sprite
	Setter(v:tlShape)
		sprite = v
	End
	Property TweenSpawns:Int()
		Return tweenspawns
	Setter(v:Int)
		tweenspawns = v
	End
	Property Visible:Int()
		Return visible
	Setter(v:Int)
		visible = v
	End
	Property SpawnComponents:List<tlSpawnComponent>()
		Return spawncomponents
	Setter(v:List<tlSpawnComponent>)
		spawncomponents = v
	End

	Method New()
		AddComponent(New tlEmitterCoreComponent("Core"))
		spawncomponents = New List<tlSpawnComponent>
		effects = New List<tlEffect>
		DoNotRender = True
	End
	
	Method Destroy()
		parenteffect = Null
		Image = Null
		Sprite = Null
		If effects
			For Local e:tlEffect = EachIn effects
				e.Destroy()
			Next
		End If
		effects = Null
		If spawncomponents
			For Local c:tlSpawnComponent = EachIn spawncomponents
				c.Destroy()
			Next
		End If
		spawncomponents = Null
		scalex_component.Destroy()
		scaley_component.Destroy()
		If uscale_component uscale_component.Destroy()
		stretch_component.Destroy()
		velocity_component.Destroy()
		globalvelocity_component.Destroy()
		alpha_component.Destroy()
		red_component.Destroy()
		green_component.Destroy()
		blue_component.Destroy()
		direction_component.Destroy()
		dvovertime_component.Destroy()
		spin_component.Destroy()
		weight_component.Destroy()
		framerate_component.Destroy()
		Super.Destroy()
	End
	
	'Emitter Settings Getters
	Property ParticleRelative:Int()
		Return particlerelative
	Setter (v:Int)
		particlerelative = v
	End
	Property RandomColor:Int()
		Return randomcolor
	Setter (v:Int)
		randomcolor = v
	End
	Property Layer:Int()
		Return layer
	Setter (v:Int)
		layer = v
	End
	Property SingleParticle:Int()
		Return singleparticle
	Setter (v:Int)
		singleparticle = v
	End
	Property Animating:Int()
		Return animate
	Setter (v:Int)
		animate = v
	End
	Property AnimateOnce:Int()
		Return animateonce
	Setter (v:Int)
		animateonce = v
	End
	Property Frame:Int()
		Return frame
	Setter (v:Int)
		frame = v
	End
	Property RandomStartFrame:Int()
		Return randomstartframe
	Setter (v:Int)
		randomstartframe = v
	End
	Property AnimationDirection:Int()
		Return animationdirection
	Setter (v:Int)
		animationdirection = v
	End
	Property Uniform:Int()
		Return uniform
	Setter (v:Int)
		uniform = v
	End
	Property AngleType:Int()
		Return angletype
	Setter (v:Int)
		angletype = v
	End
	Property AngleOffset:Float()
		Return angleoffset
	Setter (v:Float)
		angleoffset = v
	End
	Property LockAngle:Int()
		Return lockangle
	Setter (v:Int)
		lockangle = v
	End
	Property AngleRelative:Int()
		Return anglerelative
	Setter (v:Int)
		anglerelative = v
	End
	Property UseEffectEmission:Int()
		Return useeffectemission
	Setter (v:Int)
		useeffectemission = v
	End
	Property ColorRepeat:Int()
		Return colorrepeat
	Setter (v:Int)
		colorrepeat = v
	End
	Property AlphaRepeat:Int()
		Return alpharepeat
	Setter (v:Int)
		alpharepeat = v
	End
	Property OneShot:Int()
		Return oneshot
	Setter (v:Int)
		oneshot = v
	End
	Property GroupParticles:Int()
		Return groupparticles
	Setter (v:Int)
		groupparticles = v
	End
	
	'Base attribute setters
	Method SetBaseWidth(v:Float)
		currentbasesizex = v
	End
	Method SetBaseHeight(v:Float)
		currentbasesizey = v
	End
	Method SetBaseSize(v:Float)
		currentbasesizex = v
		currentbasesizey = v
	End
	Method SetBaseWidthVariation(v:Float)
		currentsizexvariation = v
	End
	Method SetBaseHeightVariation(v:Float)
		currentsizeyvariation = v
	End
	Method SetBaseSizeVariation(v:Float)
		currentsizexvariation = v
		currentsizeyvariation = v
	End
	
	#Rem
		bbdoc: Add an effect to the emitters list of effects.
		about: Effects that are in the effects list are basically sub effects that are added to any particles that this emitter spawns which in turn should
		contain their own emitters that spawn more particles and so on.</p>
	#END
	Method AddEffect(e:tlEffect)
		effects.AddLast(e)
	End
	#Rem
		bbdoc: Get the parenteffect value in this tlEmitter object.
	#END
	Method GetParentEffect:tlEffect()
		Return parenteffect
	End
	#Rem
		bbdoc: Set the parenteffect value for this tlEmitter object.
	#END
	Method SetParentEffect(v:tlEffect)
		parenteffect = v
	End
	#Rem
		bbdoc:Update the #tlGameObject
	#END
	Method Update()
		Capture()
		
		'transform the object
		TForm()
			
		'update the children		
		UpdateChildren()
					
		'update components
		UpdateComponents()
		
		If Parent
			If ContainingBox
				Parent.UpdateContainingBox(ContainingBox.tl_corner.x, ContainingBox.tl_corner.y, ContainingBox.br_corner.x, ContainingBox.br_corner.y)
			Else
				Parent.UpdateContainingBox(WorldVector.x, WorldVector.y, WorldVector.x, WorldVector.y)
			End If
		End If
		
		If UpdateContainerBox ReSizeContainingBox()

		UpdateImageBox()
	End
	'Compilers
	Method CompileAll()
		For Local graph:tlComponent = EachIn Components
			If Cast<tlGraphComponent>(graph)
				Select  Cast<tlGraphComponent>(graph).GraphType
					Case tlNORMAL_GRAPH
						 Cast<tlGraphComponent>(graph).Compile()
					Case tlOVERTIME_GRAPH
						 Cast<tlGraphComponent>(graph).Compile_Overtime()
				End Select
			End If
		Next
		
		scalex_component.Compile_Overtime()
		scaley_component.Compile_Overtime()
		stretch_component.Compile_Overtime()
		velocity_component.Compile_Overtime()
		globalvelocity_component.Compile()
		alpha_component.Compile_Overtime()
		red_component.Compile_Overtime()
		green_component.Compile_Overtime()
		blue_component.Compile_Overtime()
		direction_component.Compile_Overtime()
		dvovertime_component.Compile_Overtime()
		spin_component.Compile_Overtime()
		weight_component.Compile_Overtime()
		framerate_component.Compile_Overtime()
		
		'add the overtime graphs to the particle compenents as necessary, depending on whether there's more then one node on the graph
		If spin_component.c_nodes.lastframe And Not (lockangle And angletype = tlANGLE_ALIGN)
			run_spin = True
		End If
		If scalex_component.c_nodes.lastframe
			If uniform
				uscale_component = New tlEC_UniformScale()
				scalex_component.CopyToClone(uscale_component, parenteffect, Self)
				uscale_component.Name = "UniformScale"
				run_uniform = True
			Else
				run_scalex = True
			End If
		End If
		If scaley_component.c_nodes.lastframe And Not uniform
			run_scaley = True
		End If
		currentdirection = direction_component.c_nodes.changes[0]
		If direction_component.c_nodes.lastframe Or parenteffect.TraverseEdge And parenteffect.EffectClass = tlLINE_EFFECT
			run_direction = True
		End If
		Local isvelocitycomponent:Int
		If velocity_component.c_nodes.lastframe Or globalvelocity_component.c_nodes.lastframe Or globalvelocity_component.c_nodes.changes[0] <> 1
			isvelocitycomponent = True
			run_velocity = True
		End If
		If globalvelocity_component.c_nodes.lastframe Or globalvelocity_component.c_nodes.changes[0] <> 1
			run_globalvelocity = True
			run_velocity = True
		End If
		If GetComponent("DirectionVariation") Or currentdirectionvariation
			If dvovertime_component.c_nodes.lastframe Or dvovertime_component.c_nodes.changes[0]
				If Not direction_component.c_nodes.lastframe
					run_direction = True
				End If
				run_dvovertime = True
			End If
		End If
		If alpha_component.c_nodes.lastframe Or parenteffect.GetComponent("Alpha") Or parenteffect.ParentHasGraph("Alpha")
			run_alpha = True
		End If
		If red_component.c_nodes.lastframe And Not randomcolor
			run_colour = True
		End If
		If weight_component.c_nodes.lastframe
			run_weight = True
		End If
		If stretch_component.c_nodes.changes[0] Or stretch_component.c_nodes.lastframe
			run_stretch = True
		End If
		
		If framerate_component.c_nodes.lastframe
			run_framerate = True
		End If
		InitSpawnComponents()
		For Local e:tlEffect = EachIn effects
			e.CompileAll()
		Next
	End
	Method InitSpawnComponents()
		'life
		If GetComponent("LifeVariation") Or currentlifevariation
			spawncomponents.AddLast(New tlSpawnComponent_LifeVariation("LifeVariation", parenteffect, Self))
		Else
			spawncomponents.AddLast(New tlSpawnComponent_Life("Life", parenteffect, Self))
		End If
		'speed
		If GetComponent("VelocityVariation") Or currentvelocityvariation Or GetComponent("BaseSpeed") Or currentbasespeed
			spawncomponents.AddLast(New tlSpawnComponent_Speed("Speed", parenteffect, Self))
		End If
		'size
		If GetComponent("SizeXVariation") Or currentsizexvariation Or (Not uniform And GetComponent("SizeYVariation") Or currentsizeyvariation)
			spawncomponents.AddLast(New tlSpawnComponent_SizeVariation("SizeVariation", parenteffect, Self))
		Else
			spawncomponents.AddLast(New tlSpawnComponent_Size("Size", parenteffect, Self))
		End If
		'Splatter
		If GetComponent("Splatter") Or currentsplatter
			spawncomponents.AddLast(New tlSpawnComponent_Splatter("Splatter", parenteffect, Self))
		End If
		'Tform
		spawncomponents.AddLast(New tlSpawnComponent_TForm("TForm", parenteffect, Self))
		'emission
		If Not (parenteffect.TraverseEdge And parenteffect.EffectClass = tlLINE_EFFECT)
			spawncomponents.AddLast(New tlSpawnComponent_Emission("Emission", parenteffect, Self))
			If GetComponent("EmissionRange") Or parenteffect.GetComponent("EmissionRange") Or currentemissionrange Or parenteffect.currentemissionrange
				spawncomponents.AddLast(New tlSpawnComponent_EmissionRange("EmissionRange", parenteffect, Self))
			End If
		End If
		'direction
		If GetComponent("DirectionVariation") Or currentdirectionvariation And (dvovertime_component.c_nodes.changes[0] Or dvovertime_component.c_nodes.lastframe)
			If Not parenteffect.TraverseEdge Or Not parenteffect.EffectClass = tlLINE_EFFECT
				spawncomponents.AddLast(New tlSpawnComponent_DirectionVariation("DirectionVariation", parenteffect, Self))
			End If
		End If
		'locked angle
		If lockangle
			spawncomponents.AddLast(New tlSpawnComponent_LockedAngle("LockedAngle", parenteffect, Self))
		Else
			spawncomponents.AddLast(New tlSpawnComponent_Angle("Angle", parenteffect, Self))
		End If
		'weight
		If GetComponent("WeightVariation") Or currentweightvariation Or GetComponent("BaseWeight") Or currentbaseweight
			If weight_component.c_nodes.changes[0] Or weight_component.c_nodes.lastframe
				spawncomponents.AddLast(New tlSpawnComponent_Weight("Weight", parenteffect, Self))
			End If
		End If
		'spin
		If GetComponent("SpinVariation") Or currentspinvariation Or GetComponent("BaseSpin") Or currentbasespin
			spawncomponents.AddLast(New tlSpawnComponent_Spin("Spin", parenteffect, Self))
		End If
	End
	
	Method ControlParticle(p:tlParticle)
		If run_uniform
			uscale_component.ControlParticle(p)
		Else
			If run_scalex scalex_component.ControlParticle(p)
			If run_scaley scaley_component.ControlParticle(p)
		End If
		If run_velocity velocity_component.ControlParticle(p)
		If run_globalvelocity globalvelocity_component.ControlParticle(p)
		If run_alpha alpha_component.ControlParticle(p)
		If run_colour
			 red_component.ControlParticle(p)
			 green_component.ControlParticle(p)
			 blue_component.ControlParticle(p)
		End If
		If run_direction direction_component.ControlParticle(p)
		If run_dvovertime dvovertime_component.ControlParticle(p)
		If run_spin spin_component.ControlParticle(p)
		If run_weight weight_component.ControlParticle(p)
		If run_stretch stretch_component.ControlParticle(p)
		If run_framerate framerate_component.ControlParticle(p)
	End
End

Function CopyEmitter:tlEmitter(e:tlEmitter, ParentEffect:tlEffect, ParticleManager:tlParticleManager)
	Local clone:tlEmitter = New tlEmitter
	clone.DoB = ParticleManager.CurrentTime
	clone.UseEffectEmission = e.UseEffectEmission
	clone.Sprite = e.Sprite
	clone.AngleType = e.AngleType
	clone.AngleOffset = e.AngleOffset
	clone.LocalRotation = e.LocalRotation
	clone.BlendMode = e.BlendMode
	clone.ParticleRelative = e.ParticleRelative
	clone.Uniform = e.Uniform
	clone.LockAngle = e.LockAngle
	clone.AngleRelative = e.AngleRelative
	clone.HandleVector = e.HandleVector.Clone()
	clone.Name = e.Name
	clone.SingleParticle = e.SingleParticle
	clone.Visible = e.Visible
	clone.RandomColor = e.RandomColor
	clone.Layer = e.Layer
	clone.Animating = e.Animating
	clone.RandomStartFrame = e.RandomStartFrame
	clone.AnimationDirection = e.AnimationDirection
	clone.Frame = e.Frame
	clone.ColorRepeat = e.ColorRepeat
	clone.AlphaRepeat = e.AlphaRepeat
	clone.OneShot = e.OneShot
	clone.HandleCenter = e.HandleCenter
	clone.AnimateOnce = e.AnimateOnce
	clone.Path = e.Path
	'temps
	clone.currentamount = e.currentamount
	clone.currentlife = e.currentlife
	clone.currentbasespeed = e.currentbasespeed
	clone.currentbaseweight = e.currentbaseweight
	clone.currentbasesizex = e.currentbasesizex
	clone.currentbasesizey = e.currentbasesizey
	clone.currentbasespin = e.currentbasespin
	clone.currentsplatter = e.currentsplatter
	clone.currentlifevariation = e.currentlifevariation
	clone.currentamountvariation = e.currentamountvariation
	clone.currentvelocityvariation = e.currentvelocityvariation
	clone.currentweightvariation = e.currentweightvariation
	clone.currentsizexvariation = e.currentsizexvariation
	clone.currentsizeyvariation = e.currentsizeyvariation
	clone.currentspinvariation = e.currentspinvariation
	clone.currentdirectionvariation = e.currentdirectionvariation
	clone.currentalphaovertime = e.currentalphaovertime
	clone.currentvelocityovertime = e.currentvelocityovertime
	clone.currentweightovertime = e.currentweightovertime
	clone.currentscalexovertime = e.currentscalexovertime
	clone.currentscaleyovertime = e.currentscaleyovertime
	clone.currentspinovertime = e.currentspinovertime
	clone.currentdirection = e.currentdirection
	clone.currentdirectionvariationot = e.currentdirectionvariationot
	clone.currentframerateovertime = e.currentframerateovertime
	clone.currentstretchovertime = e.currentstretchovertime
	clone.currentredovertime = e.currentredovertime
	clone.currentgreenovertime = e.currentgreenovertime
	clone.currentblueovertime = e.currentblueovertime
	clone.currentglobalvelocity = e.currentglobalvelocity
	clone.currentemissionangle = e.currentemissionangle
	clone.currentemissionrange = e.currentemissionrange

	'Quick access components
	clone.scalex_component = Cast<tlEC_ScaleXOvertime>(e.scalex_component.Clone(ParentEffect, clone))
	clone.scaley_component = Cast<tlEC_ScaleYOvertime>(e.scaley_component.Clone(ParentEffect, clone))
	If e.uscale_component clone.uscale_component = Cast<tlEC_UniformScale>(e.uscale_component.Clone(ParentEffect, clone))
	clone.stretch_component = Cast<tlEC_StretchOvertime>(e.stretch_component.Clone(ParentEffect, clone))
	clone.velocity_component = Cast<tlEC_VelocityOvertime>(e.velocity_component.Clone(ParentEffect, clone))
	clone.globalvelocity_component = Cast<tlEC_GlobalVelocity>(e.globalvelocity_component.Clone(ParentEffect, clone))
	clone.alpha_component = Cast<tlEC_AlphaOvertime>(e.alpha_component.Clone(ParentEffect, clone))
	clone.red_component = Cast<tlEC_RedOvertime>(e.red_component.Clone(ParentEffect, clone))
	clone.green_component = Cast<tlEC_GreenOvertime>(e.green_component.Clone(ParentEffect, clone))
	clone.blue_component = Cast<tlEC_BlueOvertime>(e.blue_component.Clone(ParentEffect, clone))
	clone.direction_component = Cast<tlEC_DirectionOvertime>(e.direction_component.Clone(ParentEffect, clone))
	clone.dvovertime_component = Cast<tlEC_DirectionVariationOvertime>(e.dvovertime_component.Clone(ParentEffect, clone))
	clone.spin_component = Cast<tlEC_SpinOvertime>(e.spin_component.Clone(ParentEffect, clone))
	clone.weight_component = Cast<tlEC_WeightOvertime>(e.weight_component.Clone(ParentEffect, clone))
	clone.framerate_component = Cast<tlEC_FramerateOvertime>(e.framerate_component.Clone(ParentEffect, clone))
	
	clone.run_uniform = e.run_uniform
	clone.run_scalex = e.run_scalex
	clone.run_scaley = e.run_scaley
	clone.run_velocity = e.run_velocity
	clone.run_stretch = e.run_stretch
	clone.run_globalvelocity = e.run_globalvelocity
	clone.run_alpha = e.run_alpha
	clone.run_colour = e.run_colour
	clone.run_direction = e.run_direction
	clone.run_dvovertime = e.run_dvovertime
	clone.run_spin = e.run_spin
	clone.run_weight = e.run_weight
	clone.run_framerate = e.run_framerate
	
	For Local component:tlComponent = EachIn e.Components
		If Cast<tlGraphComponent>(component)
			clone.AddComponent(Cast<tlGraphComponent>(component).Clone(ParentEffect, clone), False)
		EndIf
	Next
	For Local component:tlSpawnComponent = EachIn e.SpawnComponents
		clone.SpawnComponents.AddLast(component.Clone(ParentEffect, clone))
	Next
	For Local effect:tlEffect = EachIn e.Effects
		clone.AddEffect(CopyEffect(effect, ParticleManager))
	Next
	Return clone
End Function
