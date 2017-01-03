'The minimum we need to import is mojo, std and of course timelinefx!
#Import "<mojo>"
#Import "<std>"
#Import "<timelinefx>"
#import "assets/effects/"

Using mojo..
Using std..
Using timelinefx..

'Create a simple Monky App Class
Class FXexample Extends Window


	'Create some fields to store an effects libray, effect, and a particle manager. 
	Field MyEffects:tlEffectsLibrary
	Field MyEffect:tlEffect
	Field MyParticleManager:tlParticleManager
	Field Paused:Int
	Field EffectNames:String[]
	Field CurrentEffect:Int
	Field stop:int

	'In the OnCreate method you can load your effects 
	'library and set up the particle manager.
	Method New(title:String,width:Int,height:Int)
		Super.New( title, width, height )
		'load the effects file. See the docs on LoadEffects on how to 
		'prepare an effects library for use in monkey.
		MyEffects = LoadEffects("asset::explosions")
		
		'Use GetEffect, to retrieve an effect from the library.
		MyEffect = MyEffects.GetEffect("glowing explosion")
		
		'create a particle manager to manage all the effects and particles
		MyParticleManager = CreateParticleManager(5000)
		
		'Set the number of times per second that you want the particles to 
		'be updated. Best to set this to the UpdateRate
		SetUpdateFrequency(60)
		
		'Let the Particle manager know the screen size
		MyParticleManager.SetScreenSize(Width, Height)
		
		'Set the origin so that we can use mouse coords to place effects on screen
		MyParticleManager.SetOrigin(Width / 2, Height / 2)
		
		Local effects:=MyEffects.Effects
		
		'Get the effect names in the library so we can loop through them
		EffectNames = New String[effects.Count()]
		Local i:int
		For Local name:=Eachin effects.Keys
			If Not name.Contains("/")
				EffectNames[i] = name
				i+=1
			End If
		Next
		EffectNames = EffectNames.Slice(0, i-1)
		Print EffectNames.Length
	End
	
	'Use the OnRender method to render all particles
	Method OnRender(canvas:Canvas) Override
		'lets create an effect everytime the mouse is clicked
		If Keyboard.KeyHit(Key.Z) 
			CurrentEffect-=1
			If CurrentEffect < 0 CurrentEffect = EffectNames.Length-1
		End If
		If Keyboard.KeyHit(Key.X) 
			CurrentEffect+=1
			If CurrentEffect > EffectNames.Length-1 CurrentEffect = 0
		End If
		If stop
			'DebugStop()
			stop = False
		End If
		If Mouse.ButtonHit(MouseButton.Left)
			'Copy the effect *Important! Dont just add an effect directly from the 
			'library, make a copy of it first*
			Local tempeffect:tlEffect

			MyEffect = MyEffects.GetEffect(EffectNames[CurrentEffect])
			tempeffect = CopyEffect(MyEffect, MyParticleManager)

			'Position the effect where we want it
			tempeffect.SetPosition(Mouse.X, Mouse.Y)
			
			'Add the effect to the particle manager
			MyParticleManager.AddEffect(tempeffect)
			
			stop = True
		EndIf
		
		If Keyboard.KeyHit(Key.P)
			Paused = ~Paused
		End If
		
		If Keyboard.KeyHit(Key.Space)
			MyParticleManager.ClearAll()
		End If
		
		Local updatetime:= Millisecs()
		If Not Paused
			'Update the particle manager
			MyParticleManager.Update()
		End If
		updatetime = Millisecs() - updatetime

		App.RequestRender()
		canvas.Clear( New Color(0,0,0,1) )
		
		'draw the particles
		Local rendertime:= Millisecs()
		MyParticleManager.DrawParticles(canvas)
		rendertime = Millisecs() - rendertime
		
		canvas.Color = New Color(1,1,1,1)
		canvas.DrawText ("Press space to clear particles", 10, 10)
		canvas.DrawText ("Current Effect (use z & x to change): " + EffectNames[CurrentEffect], 10, 30)
		canvas.DrawText ( App.FPS, 10, 50)
		
	End
End

Function Main()
	
	New AppInstance
	
	New FXexample("Particle Manager", 1024, 768)
	
	App.Run()
	
End

