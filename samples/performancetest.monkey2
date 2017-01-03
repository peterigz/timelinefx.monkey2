
Namespace timelinefxtest

#Import "<mojo>"
#Import "<std>"
#Import "<timelinefx>"

Using mojo..
Using std..
Using timelinefx..

#import "assets/pixels/Circle.png@/pixels"
#import "assets/pixels/pixel.png@/pixels"
#Import "assets/pixels/data.xml@/pixels"

Using std..

Function Main()
	New AppInstance

	Local pm:=CreateParticleManager(5000)
	Local MyEffects:= LoadEffects("asset::pixels")
	Local MyEffect:= MyEffects.GetEffect("vortex 2")
	
	Local tmp:=CopyEffect(MyEffect, pm)
	pm.AddEffect(tmp)
	
	SetUpdateFrequency(60)
	
	Local time:=App.Millisecs
	Local updates:Int
	
	Print "Starting Test:"
	
	While App.Millisecs - time <= 2000
		pm.Update()
		updates += 1
	Wend
	
	Print updates + ", " + (2000.0 / updates) + "ms"
	updates = 0
	time = App.Millisecs
	
	While App.Millisecs - time <= 2000
		pm.Update()
		updates += 1
	Wend
	
	Print updates + ", " + (2000.0 / updates) + "ms"
	updates = 0
	time = App.Millisecs
	
	While App.Millisecs - time <= 2000
		pm.Update()
		updates += 1
	Wend
	
	Print updates + ", " + (2000.0 / updates) + "ms"
	updates = 0
	time = App.Millisecs
	
	While App.Millisecs - time <= 2000
		pm.Update()
		updates += 1
	Wend
	
	Print updates + ", " + (2000.0 / updates) + "ms"
	updates = 0
	time = App.Millisecs
	
	While App.Millisecs - time <= 2000
		pm.Update()
		updates += 1
	Wend
	
	Print updates + ", " + (2000.0 / updates) + "ms"
	
End