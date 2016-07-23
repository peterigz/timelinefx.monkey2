#Rem
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
	summary: The particle manager class for TimelinFX. This class manages all effects you create and is used to update and render all particles.
	The particle manger is the main type you can use to easily manage all of the effects you want to use in your application. It will automatically update 
	all of the effects and draw the particles with a simple call to #Update and #DrawParticles.
	
	The process of using the particle manager class is to, create it, add an effect to it and then update and draw in the OnCreate, OnUpdate and OnRender methods in a monkey App class:
	
	[code]
	Import mojo
	Import timelinefx
	
	Class FXexample Extends App
	
		Field MyEffects:tlEffectsLibrary
		Field MyEffect:tlEffect
		Field MyParticleManager:tlParticleManager
	
		Method OnCreate()
	
			MyEffects = LoadEffects("explosions")
			MyEffect = MyEffects.GetEffect("a big explosion")
			MyParticleManager = CreateParticleManager(5000)
			
			MyParticleManager.SetScreenSize(DeviceWidth(), DeviceHeight())
			MyParticleManager.SetOrigin(DeviceWidth() / 2, DeviceHeight() / 2)
			
			SetUpdateFrequency(30)
			SetUpdateRate 30
		End
		
		Method OnUpdate()
			If MouseHit
				Local tempeffect:tlEffect = CopyEffect(MyEffect, MyParticleManager)
				tempeffect.SetPosition(MouseX, MouseY)
				MyParticleManager.AddEffect(tempeffect)			
			EndIf
			MyParticleManager.Update()
		End
		
		Method OnRender()
			Cls
			
			MyParticleManager.DrawParticles()
		End
	End
	
	Function Main()
		
		New FXexample
		
	End
	[/code]
	
	The particle manager maintains 2 lists of particles, an Inuse list for particles currently in the rendering pipeline and an UnUsed list for a pool of particles
	that can be used by emitters at any time. You can control the maximum number of particles a particle manager can use when you create it:
	
	[code]
	local MaximumParticles:int=2500
	local MyParticleManager:tlParticleManager=CreateParticleManager(MaximumParticles)
	[/code]
	
	When emitters need to spawn new particles they will try and grab the next available particle in the Unused list.
	
	The command SetScreenSize tells the particle manager the size of the viewport currently being rendered to. With this information it locates the center of the
	screen. This is important because the effects do not locate themselves using screen coordinates, they instead use an abritrary set of world coordinates. So if you 
	place an effect at the coordinates 0,0 it will be drawn at the center of the screen. But don't worry, if you want to use screen coordinates to place your
	effects you can use the #SetOrigin command to offset the world coordinates to screen space:
	
	[code]
	MyParticleManager.SetScreenSize(GraphicsWidth(),GraphicsHeight())
	MyParticleManager.SetOrigin(GraphicsWidth()/2,GraphicsHeight()/2)
	[/code]
	
	This will place the origin at the top-left of the viewport so effects placed at 0,0 now will be drawn in the top-left corner of the screen in the same way DrawImage
	would. If however your application uses it's own world coordinate system to postion entities then it should be easy to use #SetOrigin to syncronise the location of any 
	effects with your app.
#END
Class tlParticleManager

	Private

	Field InUse:List<tlParticle>[,]
	Field UnUsed:List<tlParticle>
	field _layers:int
	
	Field unusedcount:Int
	Field inusecount:Int
	
	Field effects:List<tlEffect>[]
	
	Field current_time:Float
	
	Field paused:Int
	
	Field idletimelimit:Int = 100
	
	Field center:tlVector2
	Field camvec:tlVector2
	Field camzoom:Float
	Field px:Float
	Field py:Float
	
	Field screenbox:tlBox
	
	Field globalamountscale:Float = 1
	
	Field origin:tlVector2
	Field oldorigin:tlVector2
	Field zoom:Float = 1
	Field oldzoom:Float = 1
	
	Field usesetcolor:Int
	
	Public
	
	#REM
		Summary: The Global amount scale is used to control the overal number of particles that will be spawned.
		The default value is 1, meaning that the particle manage will spawn the same number of particles as designed in the editor. To spawn half the amount of particles, set to 0.5.
		This feature is useful for giving users the option to tone down the number of particles if their device is running slowly.
		
		[code]
		MyParticleManager.GlobalAmountScale(0.5)
		[/code]
	#END
	Property GlobalAmountScale:Float()
		return globalamountscale
	Setter(v:Float)
		globalamountscale = v
	End
	
	#REM
		Summary: The current time in millisecs since the particle manager has been updated.
	#END
	Property CurrentTime:Float()
		Return current_time
	Setter(v:Float)
		current_time = v
	End

	#REM
		Summary: Set the idle time limit to control how long before an idle effect is removed from the particle manager's list of effects
		An effect is considered idle if it currently has no particles active within it. You may have effects that have moments where they do not spawn any particles, so you can tweak this
		property to stop effects being prematurely removed from the particle manager.
		
		The default value is 100 (measured in game updates)
		
		If you want an effect to never be removed from the particle manager then you can use 
		
		[code]
		effect.DoNotTimeOut(True)
		[/code]
	#END
	Property IdleTimeLimit:Int()
		Return idletimelimit
	Setter(v:Int)
		idletimelimit = v
	End
	
	#REM
		Summary: Returns the number of particles currently in use by the particle manager.
	#END
	Property ParticlesInUse:Int()
		Return inusecount
	Setter(v:Int)
		inusecount = v
	End
	
	#REM
		Summary: Disable the particles from rendering using set colour. Useful if you running in HTML5which is very slow when using this command.
	#END
	Method DisableSetColor()
		usesetcolor = False
	End
	
	#REM
		Summary: Enable the use of set colour for rendering particles.
	#END
	Method EnableSetColor()
		usesetcolor = True
	End
	
	#REM
		Summary: Create a new instance of tlParticleManager
		See also [a #CreateParticleManager]CreateParticleManager[/a]
	#END
	Method New(particles:Int = tlPARTICLE_LIMIT, layers:Int = 1)
		origin = New tlVector2(0, 0)
		oldorigin = New tlVector2(0, 0)
		screenbox = New tlBox(0, 0, 1, 1)
		center = New tlVector2(0, 0)
		camvec = New tlVector2(0, 0)
		InUse = New List<tlParticle>[layers,9]
		effects = New List<tlEffect>[layers]
		_layers = layers
		For Local el:Int = 0 To _layers - 1
			effects[el] = New List<tlEffect>
			For Local l:Int = 0 To 8
				InUse[el, l] = New List<tlParticle>
			Next
		Next
		UnUsed = New List<tlParticle>
		For Local c:Int = 1 To particles
			Local p:tlParticle = New tlParticle
			p.ParticleManager = Self
			Local core:tlParticleCoreComponent = New tlParticleCoreComponent
			core.particle = p
			p.corecomponent = core
			p.AddComponent(core)
			UnUsed.AddLast(p)
			p.link = UnUsed.LastNode()
		Next
		unusedcount = particles
		EnableSetColor()
	End Method
	Field second:Float
	Field particlesspawned:int
	#Rem
	summary: Update the Particle Manager
	Run this method in the OnUpdate method to update all particle effects.
	#END
	Method Update()
		If Not paused
			CurrentTime += 16.6666667
			second += 16.6666667
			If second > 1000
				second = 0
				particlesspawned = 0
			EndIf
			For Local el:Int = 0 To _layers - 1
				Local ei:= effects[el].All()
				Local e:tlEffect
				While not ei.AtEnd
					'e.ParticleManager=Self
					e = ei.Current
					e.Update()
					If e.IsDestroyed
						ei.Erase()
					else
						ei.Bump()
					End If
				Wend
			Next
			oldorigin += origin
			oldzoom = zoom
		End If
	End Method
	#Rem
		summary: Adds a new effect to the particle manager
		Use this method to add new effects to the particle manager which will be updated automatically
	#END
	Method AddEffect(e:tlEffect, layer:Int = 0)
		If layer >= 9 layer = 0
		e.EffectLayer = layer
		effects[layer].AddLast(e)
	End Method
	#Rem
		summary: Removes an effect from the particle manager
		Use this method to #Remove effects from the particle manager. It's best to destroy the effect as well to avoid memory leaks
	#END
	Method RemoveEffect(e:tlEffect)
		effects[e.EffectLayer].Remove (e)
	End Method
	#Rem
		summary: Pause and unpause the particle manager
		Pauses the drawing and updating of all effects within the particle manager.
	#END
	Method Togglepause()
		paused = Not paused
	End Method
	#Rem
		summary: Set the Origin of the particle Manager.
		An origin at 0,0 represents the center of the screen assuming you have called #SetScreenSize. Passing a z value will zoom in or out. Values above 1
		will zoom out whilst values from 1 - 0 will zoom in. Values less then 0 will flip the particles being drawn.
	#END
	Method SetOrigin(x:Float, y:Float, z:Float = 1)
		oldorigin.SetPositionByVector(origin)
		oldzoom = zoom
		zoom = z
		origin = New tlVector2(x, y)
	End Method
	#Rem
		summary: Set the x origin
		See SetOrigin
	#END
	Method SetOrigin_X(v:Float)
		oldorigin.x = origin.x
		origin.x = v
	End Method
	#Rem
		summary: Set the y origin
		See SetOrigin
	#END
	Method SetOrigin_Y(v:Float)
		oldorigin.y = origin.y
		origin.y = v
	End Method
	#Rem
		summary: Set the level of zoom
		Values above 1 will zoom out whilst values from 1 - 0 will zoom in. Values less then 0 will flip the particles being drawn.
	#END
	Method SetZoom(v:Float)
		oldzoom = zoom
		zoom = v
	End Method
	#Rem
		summary: Set the current screen size
		Tells the particle manager the current size of the view port
	#END
	Method SetScreenSize(w:Int, h:Int)
		screenbox.ReDimension(0, 0, w, h)
		center = New tlVector2(w / 2, h / 2)
		screenbox.Position(0, 0)
		screenbox.SetHandlePosition(center.x, center.y)
	End Method
	#Rem
		summary: Set the current screen position
		If you're rendering to a particular section of the screen then you can set the position of the viewport's coordinates using
				this command. Thanks to Imphy for the suggestion!
	#END
	Method SetScreenPosition(x:Int, y:Int)
	   screenbox.Position(x, y)
	End Method
	#Rem
		summary: Set the amount of time before idle effects are deleted from the particle manager
		Any effects that have no active particles being drawn on the screen will be automatically #Removed from the particle manager after a given time set by this function.
	#END
	Method SetIdleTimeLimit(v:Int)
		idletimelimit = v
	End Method
	#Rem
		summary: Draw all particles currently in use
		Draws all pariticles in use and uses the tween value you pass to use render tween in order to smooth out the movement of effects assuming you
		use some kind of tweening code in your app.
	#END
	Method DrawParticles(canvas:Canvas, tween:Float = 1)
		camvec.x = -TweenValues(oldorigin.x, origin.x, tween)
		camvec.y = -TweenValues(oldorigin.y, origin.y, tween)
		camzoom = TweenValues(oldzoom, zoom, tween)
		For Local el:Int = 0 To _layers -1
			For Local l:Int = 0 To 8
				For Local e:tlParticle = EachIn InUse[el, l]
					DrawParticle(canvas, e, tween)
				Next
			Next
		Next
	End Method
	#Rem
		summary: Get the globalamountscale value of the particle manager
		see [a #SetGlobalAmountScale]SetGlobalAmountScale[/a] for info about setting this value
	#End
	Method GetGlobalAmountScale:Float()
		Return globalamountscale
	End Method
	#Rem
		summary: Set the globalamountscale value of the particle manager
		Setting this value will scale the amount of the particles spawned by all emitters contained within the particle manager, making it a handy way
		to control globally, the amount of particles that are spawned. This can help improve performance on lower end hardware that struggle to draw
		lots of particles. A value of 1 (the default value) will spawn the default amount for each effect. A value of 0.5 though for example, will spawn
		half the amount of particles of each effect.
	#End
	Method SetGlobalAmountScale(Value:Float)
		globalamountscale = Value
	End Method
	
	Method GrabParticle:tlParticle(effect:tlEffect, layer:Int = 0)
		If unusedcount
			Local p:tlParticle = Cast<tlParticle>(UnUsed.First)
			If p
				p.layer = layer
				InUse[effect.EffectLayer, layer].AddLast(p)
				'_UnUsed.Remove p
				p.link.Remove()
				p.link = InUse[effect.EffectLayer, layer].LastNode()
				unusedcount -= 1
				inusecount += 1
				p.Removed = false
				Return p
			End If
		End If

		Return Null
	End Method
	
	Method ReleaseParticle(p:tlParticle)
		unusedcount += 1
		inusecount -= 1
		UnUsed.AddLast(p)
		'_InUse[p._layer].Remove p
		p.link.Remove()
		p.link = UnUsed.LastNode()
	End Method
	Private
	Method DrawParticle(canvas:Canvas, e:tlParticle, tween:Float)
		If e.Age Or e.emitter.SingleParticle
			px = TweenValues(e.OldWorldVector.x, e.WorldVector.x, tween)
			py = TweenValues(e.OldWorldVector.y, e.WorldVector.y, tween)
			If camzoom <> 1
				px = (px * camzoom) + center.x + (camzoom * camvec.x)
				py = (py * camzoom) + center.y + (camzoom * camvec.y)
			Else
				px = px + center.x + camvec.x
				py = py + center.y + camvec.y
			End If
			If px > screenbox.tl_corner.x - e.ImageBox.Width And px < screenbox.br_corner.x + e.ImageBox.Width And py > screenbox.tl_corner.y - e.ImageBox.Height And py < screenbox.br_corner.y + e.ImageBox.Height
				canvas.BlendMode = e.BlendMode
				Local tv:Float
				Local ta:Float
				If e.emitter.AngleRelative
					If Abs( (e.OldWorldRotation) - (e.WorldRotation)) > 180
						ta = -TweenValues(Abs(e.OldWorldRotation - 360), e.WorldRotation, tween)
					Else
						ta = -TweenValues(e.OldWorldRotation, e.WorldRotation, tween)
					End If
				Else
					If Abs(e.OldLocalRotation - e.LocalRotation) > 180
						ta = TweenValues(Abs(e.OldLocalRotation - 360), e.LocalRotation, tween)
					Else
						ta = TweenValues(e.OldLocalRotation, e.LocalRotation, tween)
					End If
				End If
				Local tx:Float = TweenValues(e.OldWorldScaleVector.x, e.WorldScaleVector.x, tween)
				Local ty:Float = TweenValues(e.OldWorldScaleVector.y, e.WorldScaleVector.y, tween)

				tv = TweenValues(e.OldZoom, e.Zoom, tween)
				If tv = 1
					tx *= camzoom
					ty *= camzoom
				Else
					tx *= camzoom * tv
					ty *= camzoom * tv
				End If
				If usesetcolor canvas.Color = New Color(e.Red, e.Green, e.Blue, e.Alpha)
				If e.Animating
					tv = TweenValues(e.OldCurrentFrame, e.CurrentFrame, tween)
					If tv < 0
						tv = e.Sprite.Frames + tv Mod e.Sprite.Frames
						If tv = e.Sprite.Frames
							tv = 0
						End If
					Else
						tv = tv Mod e.Sprite.Frames
					End If
				Else
					tv = e.CurrentFrame
				End If
				If e.AutoCenter
					e.Sprite.image[tv].Handle = New Vec2f( 0.5, 0.5)
				Else
					e.Sprite.image[tv].Handle = New Vec2f( float(e.HandleVector.x) / e.sprite.Width, float(e.HandleVector.y) / e.sprite.Height )
				End If
				canvas.DrawImage (e.Sprite.image[tv], px, py, ta, tx, ty)
			End If
		End If
	End Method
End

#REM
	Summary: Create a new particle manager
	Creates a new particle manager that you can use to create and update new effects. Pass the maximum number of particles that you wish to update at any one time.
#END
Function CreateParticleManager:tlParticleManager(particles:Int = tlPARTICLE_LIMIT)
	Return New tlParticleManager(particles)
End Function
