Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class CollisionTest Extends Window

	Field poly:tlPolygon
	
	'create a box to move about
	Field box:tlBox
	
	'a local collision result to store the result of the collision test
	Field result:tlCollisionResult = New tlCollisionResult
	
	'some velocity vectors to move the box about
	Field VelVector:tlVector2 = New tlVector2(0, 0)
	Field VelMatrix:tlMatrix2 = New tlMatrix2
	Field Direction:Float
	Field speed:Float = 4
	
	Private
	
	Field _fps:Int
	Field _tick:Int
	Field _fpscount:Int

	Method New()
		Local verts:= New Float[](0.0, 0.0, -150.0, 100.0, 50.0, 150.0, 185.0, 100.0, 300.0, 0.0)
		poly = CreatePolygon(400, 200, verts)
		box = CreateBox(100, 100, 20, 20)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1))
		
		canvas.PushMatrix()
		
		poly.Rotate(0.01)
		
		'some basic movement controls for the box
		If Keyboard.KeyDown(Key.Up) Direction = DegRad(0)
		If Keyboard.KeyDown(Key.Right) Direction = DegRad(90)
		If Keyboard.KeyDown(Key.Down) Direction = DegRad(180)
		If Keyboard.KeyDown(Key.Left) Direction = DegRad(270)
		If Keyboard.KeyDown(Key.Right) And Keyboard.KeyDown(Key.Down) Direction = DegRad(135)
		If Keyboard.KeyDown(Key.Down) And Keyboard.KeyDown(Key.Left) Direction = DegRad(225)
		If Keyboard.KeyDown(Key.Up) And Keyboard.KeyDown(Key.Right) Direction = DegRad(45)
		If Keyboard.KeyDown(Key.Left) And Keyboard.KeyDown(Key.Up) Direction = DegRad(315)
		If Keyboard.KeyDown(Key.Up) Or Keyboard.KeyDown(Key.Down) Or Keyboard.KeyDown(Key.Left) Or Keyboard.KeyDown(Key.Right)
			VelVector = New tlVector2(0, -speed)
		Else
			VelVector = New tlVector2(0, 0)
		End If
		VelMatrix.Set(Cos(Direction), Sin(Direction), -Sin(Direction), Cos(Direction))
		VelVector = VelMatrix.TransformVector(VelVector).Unit()
		'set the box velocity so that the collision check can see whether the 2 objects will collide
		'the next frame. You don't *have* to do this, but it makes for more accurate collisions
		box.SetVelocityVector(VelVector.Scale(speed))
		
		'check for a collision with the poly
		result = CheckCollision(box, poly)
		
		'prevent the box from overlapping the poly
		PreventOverlap(result)
		
		'move the box. Important to do this after the collision check, but only if you're setting
		'the box velicity.
		box.UpdatePosition()
		
		box.Draw(canvas)
		poly.Draw(canvas)
		
		If Millisecs() - _tick > 1008
			_fps = _fpscount
			_tick = Millisecs()
			_fpscount=0
		Else
			_fpscount +=1
		End
		
		canvas.DrawText(_fps, 10, 10)
	
	End

End

Function DegRad:Float(degrees:Float)
	Return degrees * Pi / 180
End

Function Main()

	New AppInstance
	
	New CollisionTest
	
	App.Run()

End
