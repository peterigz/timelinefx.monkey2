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

Using mojo..
Using std..
Using timelinefx..

'Create a simple Monky App Class
Class FXexample Extends Window


	'Create some fields to store an effects libray, effect, and a particle manager. 
	Field MyEffects:tlEffectsLibrary
	Field MyEffect:tlEffect
	Field MyParticleManager:tlParticleManager

	'In the OnCreate method you can load your effects 
	'library and set up the particle manager.
	Method New()

		'load the effects file. See the docs on LoadEffects on how to 
		'prepare an effects library for use in monkey.
		'MyEffects = LoadEffects("asset::test")
		MyEffects = LoadEffects("asset::explosions")
		
		'Use GetEffect, to retrieve an effect from the library.
		'MyEffect = MyEffects.GetEffect("test2")
		MyEffect = MyEffects.GetEffect("toon explosion arms &amp; trails")
		
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
			Local tempeffect:tlEffect = CopyEffect(MyEffect, MyParticleManager)
			
			'Position the effect where we want it
			tempeffect.SetPosition(Mouse.X, Mouse.Y)
			
			'Add the effect to the particle manager
			MyParticleManager.AddEffect(tempeffect)
				
		EndIf
		
		'Update the particle manager
		MyParticleManager.Update()
		
		App.RequestRender()
		canvas.Clear( New Color(0,0,0,1) )
		
		
		'draw the particles
		MyParticleManager.DrawParticles(canvas)
	End
End

Function Main()
	
	New AppInstance
	
	New FXexample
	
	App.Run()
	
End

