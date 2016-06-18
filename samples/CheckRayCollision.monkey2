Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class CollisionTest Extends Window

	Field box:tlBox
	Field poly:tlPolygon
	Field line:tlLine
	Field circle:tlCircle
	
	Field ray:tlVector2 = New tlVector2(0, 0)
	Field result:tlCollisionResult = New tlCollisionResult
	Field point:tlVector2 = New tlVector2(0, 0)
	
	Field shape:Int
	
	Private

	Method New()
		box = new tlBox(400, 300, 100, 100)
		Local verts:=New Float[](-100.0, 0.0, -150.0, 100.0, 50.0, 150.0, 185.0, 100.0, 300.0, 0.0)
		poly = New tlPolygon(400, 200, verts)
		line = New tlLine(200, 500, 800, 100)
		circle = New tlCircle(400, 300, 40)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1))
		
		canvas.PushMatrix()
		
		'set the ray vector based on the point->mouse vector
		If Mouse.ButtonDown(MouseButton.Left) point.SetPosition(Mouse.X, Mouse.Y)
		ray.SetPosition(Mouse.X - point.x, Mouse.Y - point.y)
		
		'normalise the ray so we can draw the laser a fixed length a bit more easily
		ray.Normalise()
		
		'iterate through shapes if space is pressed
		If Keyboard.KeyHit(Key.Space)
			shape+=1
			If shape > 3 shape = 0
		End If
		
		'do a ray collision checked on the selected shape and store the result
		Select shape
			Case 0
				result = CheckRayCollision(box, point.x, point.y, ray.x, ray.y)
			Case 1
				line.RotateDegrees(1)
				result = CheckRayCollision(line, point.x, point.y, ray.x, ray.y)
			Case 2
				result = CheckRayCollision(circle, point.x, point.y, ray.x, ray.y)
			Case 3
				poly.RotateDegrees(1)
				result = CheckRayCollision(poly, point.x, point.y, ray.x, ray.y)
		End Select
		
		Select shape
			Case 0
				box.Draw(canvas)
			Case 1
				line.Draw(canvas)
			Case 2
				circle.Draw(canvas)
			Case 3
				poly.Draw(canvas)
		End Select
		
		canvas.DrawRect(point.x - 5, point.y - 5, 10, 10)
		
		'if the result shows an intersection and it wasn't insise the shape
		If result.Intersecting And Not result.RayOriginInside
			'draw the ray upto the intersection point
			canvas.DrawLine(point.x, point.y, result.RayIntersection.x, result.RayIntersection.y)
			canvas.DrawOval(result.RayIntersection.x - 4, result.RayIntersection.y - 4, 8, 8)
			'find the rebound vector
			Local rebound:tlVector2 = result.GetReboundVector(ray)
			'draw the rebounded ray
			canvas.DrawLine (result.RayIntersection.x, result.RayIntersection.y,
					result.RayIntersection.x + rebound.x * 500, result.RayIntersection.y + rebound.y * 500)
		ElseIf result.RayOriginInside
			canvas.DrawText ("Ray starts inside object!", 10, 30)
		Else
			'no intersection, draw a line for the ray
			canvas.DrawLine (point.x, point.y, point.x + ray.x * 1000, point.y + ray.y * 1000)
		EndIf
		
		canvas.DrawText ("Press space to change shape", 10, 10)
		canvas.DrawText ("Click and drag to move the laser origin", 10, 20)
	
	End

End

Function Main()

	New AppInstance
	
	New CollisionTest
	
	App.Run()

End
