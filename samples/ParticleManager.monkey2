'The minimum we need to import is mojo and of course timelinefx!
#Import "<mojo>"
#Import "<std>"
#Import "<timelinefx>"
#Import "assets/explosions/data.xml@/explosions"
#Import "assets/explosions/Flare7.png@/explosions"
#Import "assets/explosions/Flare10.png@/explosions"
#Import "assets/explosions/Fog-Group.png@/explosions"
#Import "assets/explosions/Plume1.png@/explosions"
#Import "assets/explosions/toonCloud.png@/explosions"
#Import "assets/explosions/tooncollumn.png@/explosions"
#Import "assets/test/data.xml@/test"
#Import "assets/test/smoketoon2.png@/test"
#import "assets/examples/6starfilled.png@/examples"
#import "assets/examples/8starfilled.png@/examples"
#import "assets/examples/8starhollow.png@/examples"
#import "assets/examples/Circle.png@/examples"
#import "assets/examples/circlesymbol1.png@/examples"
#import "assets/examples/ElectricGroup1.png@/examples"
#import "assets/examples/fire7Copy.png@/examples"
#import "assets/examples/FlameArc8.png@/examples"
#import "assets/examples/Flare1.png@/examples"
#import "assets/examples/Flare10.png@/examples"
#import "assets/examples/Flare3.png@/examples"
#import "assets/examples/Flare5.png@/examples"
#import "assets/examples/FogGroup.png@/examples"
#import "assets/examples/Gradient.png@/examples"
#import "assets/examples/Halo1.png@/examples"
#import "assets/examples/Halo3.png@/examples"
#import "assets/examples/lines.png@/examples"
#import "assets/examples/numbersverdana.png@/examples"
#import "assets/examples/pixel.png@/examples"
#import "assets/examples/Plume2.png@/examples"
#import "assets/examples/smokeball.png@/examples"
#import "assets/examples/Snow1.png@/examples"
#import "assets/examples/sparkleflare.png@/examples"
#import "assets/examples/sparkleflare2.png@/examples"
#import "assets/examples/Splash3.png@/examples"
#import "assets/examples/Splash4.png@/examples"
#import "assets/examples/thinlines.png@/examples"
#import "assets/examples/triangle.png@/examples"
#Import "assets/examples/data.xml@/examples"

Using mojo..
Using std..
Using timelinefx..

'Create a simple Monky App Class
Class FXexample Extends Window


	'Create some fields to store an effects libray, effect, and a particle manager. 
	Field MyEffects:tlEffectsLibrary
	Field MyEffect:tlEffect
	Field MyEffect2:tlEffect
	Field MyEffect3:tlEffect
	Field MyEffect4:tlEffect
	Field MyParticleManager:tlParticleManager
	Field Paused:int

	'In the OnCreate method you can load your effects 
	'library and set up the particle manager.
	Method New(title:String,width:Int,height:Int)
		Super.New( title, width, height )
		'load the effects file. See the docs on LoadEffects on how to 
		'prepare an effects library for use in monkey.
		'MyEffects = LoadEffects("asset::test")
		MyEffects = LoadEffects("asset::examples")
		
		'Use GetEffect, to retrieve an effect from the library.
		'MyEffect = MyEffects.GetEffect("dv")
		'MyEffect = MyEffects.GetEffect("toon explosion arms &amp; trails")
		'MyEffect2 = MyEffects.GetEffect("toon explosion arms")
		'MyEffect3 = MyEffects.GetEffect("toon explosion 2")
		'MyEffect4 = MyEffects.GetEffect("toon smoke puff ring")
		MyEffect = MyEffects.GetEffect("smokey explosion")
		
		'create a particle manager to manage all the effects and particles
		MyParticleManager = CreateParticleManager(5000)
		
		'Set the number of times per second that you want the particles to 
		'be updated. Best to set this to the UpdateRate
		SetUpdateFrequency(60)
		
		'Let the Particle manager know the screen size
		MyParticleManager.SetScreenSize(Width, Height)
		
		'Set the origin so that we can use mouse coords to place effects on screen
		MyParticleManager.SetOrigin(Width / 2, Height / 2)
		
	End
	
	'Use the OnRender method to render all particles
	Method OnRender(canvas:Canvas) Override
		'lets create an effect everytime the mouse is clicked
		If Mouse.ButtonHit(MouseButton.Left)
			'Copy the effect *Important! Dont just add an effect directly from the 
			'library, make a copy of it first*
			Local rndeffect:Int=Rnd(4)
			Local tempeffect:tlEffect
			'Select rndeffect
			'	Case 0
			'		tempeffect = CopyEffect(MyEffect, MyParticleManager)
			'	Case 1
			'		tempeffect = CopyEffect(MyEffect2, MyParticleManager)
			'	Case 2
			'		tempeffect = CopyEffect(MyEffect3, MyParticleManager)
			'	Case 3
			'		tempeffect = CopyEffect(MyEffect4, MyParticleManager)
			'End Select
			tempeffect = CopyEffect(MyEffect, MyParticleManager)
			
			
			'Position the effect where we want it
			tempeffect.SetPosition(Mouse.X, Mouse.Y)
			
			'Add the effect to the particle manager
			MyParticleManager.AddEffect(tempeffect)
				
		EndIf
		
		If Keyboard.KeyHit(Key.P)
			Paused = ~Paused
		End If
		
		Local updatetime:= Millisecs()
		If Not Paused
			'Update the particle manager
			MyParticleManager.Update()
		End If
		updatetime = Millisecs() - updatetime

		App.RequestRender()
		canvas.Clear( New Color(0,0,0,1) )
		'canvas.TextureFilteringEnabled = false
		
		'draw the particles
		MyParticleManager.DrawParticles(canvas)
		
		canvas.DrawText (updatetime, 10, 10)
		
	End
End

Function Main()
	
	New AppInstance
	
	New FXexample("Particle Manager", 1024, 768)
	
	App.Run()
	
End

