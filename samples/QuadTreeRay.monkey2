Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class Point
	Field x:Float
	Field y:Float
End

Class Game Extends Window

	Field QTree:tlQuadTree
	Field ray:tlVector2
	Field vpoint:tlVector2
	Field DrawRay:RayAction
	Field DrawScreen:DrawScreenAction
	Field currentCanvas:Canvas
	Field eventCount:Int
	Field point:Point
	
	Private

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 5)
		DrawRay = New RayAction
		DrawScreen = New DrawScreenAction
		
		point = New Point
		
		DrawRay.thegame = Self
		DrawScreen.thegame = Self
		
		'Populate the quadtree with a bunch of objects
		For Local c:Int = 1 To 100
			Local t:Int = Rnd(3)
			Local rect:tlBox
			Local x:Float = Rnd() * Width 
			Local y:Float = Rnd() * Height 
			Select t
				Case 0
					'Create a Basic bounding box boundary
					rect = New tlBox(x, y, 10, 10, tlLAYER_0)
				Case 1
					'Create a circle Boundary
					rect = New tlCircle(x, y, 5, tlLAYER_0)
				Case 2
					'Create a polygon boundary
					Local verts:= New Float[](- 10.0, -10.0, -15.0, 0.0, -10.0, 10.0, 10.0, 10.0, 15.0, 0.0, 10.0, -10.0)
					rect = New tlPolygon(x, y, verts, tlLAYER_0)
			End Select
			'Add the boundary to the quadtree
			QTree.AddBox(rect)
		Next
		
		ray = New tlVector2(0, 0)
		vpoint = New tlVector2(400, 400)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
		
		'canvas.PushMatrix()		
		canvas.BlendMode = BlendMode.Alpha
		
		If Mouse.ButtonDown(MouseButton.Left) vpoint = New tlVector2(Mouse.X, Mouse.Y)
		ray = New tlVector2(Mouse.X - point.x, Mouse.Y - point.y).Normalise()
		point.x = vpoint.x
		point.y = vpoint.y

		QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))

		'query the quadtree with the ray and run our call back if it hit. Otherwise draw the full length of the ray (300)
		'we're using the data variable here to pass through the Point to the callback function	
		If Not QTree.RayCast(point.x, point.y, ray.x, ray.y, 300.0, point, DrawRay, New Int[](0, 1, 2))
			canvas.Color = New Color( 255, 0, 0 )
			canvas.DrawLine (point.x, point.y, point.x + (ray.x * 300), point.y + (ray.y * 300))
		End If
	
	End

End

Class RayAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)

	End
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		'cast the objects to some local variables
		Local point:Point = Cast<Point>(Data)
		Local box:tlBox = Cast<tlBox>(ReturnedObject)
		
		If Cast<tlPolygon>(ReturnedObject)
			Cast<tlPolygon>(ReturnedObject).Rotate(0.01)
		End
		
		thegame.currentCanvas.Color = New Color( 255, 0, 0 )
		
		'if the ray does not originate inside an object then draw the ray and intersection point
		If Not Result.RayOriginInside
			thegame.currentCanvas.DrawLine(point.x, point.y, Result.RayIntersection.x, Result.RayIntersection.y)
			thegame.currentCanvas.DrawOval(Result.RayIntersection.x - 4, Result.RayIntersection.y - 4, 8, 8)
		End If
		
		'draw the box we collided with in a different colour
		box.Draw(thegame.currentCanvas)
	End
End

Class DrawScreenAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)
		'Use casting to create a local rect of whatever boundary object the quad tree has found.
		'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
		Local rect:tlBox = Cast<tlBox>(o)
		'We used the data variable to pass the poly we're using to move around the screen. This could be
		'any object, such as a game entity, which could have a field containing a tlBoundary representing
		'its bounding box/poly etc.
		Local line:tlBox = Cast<tlBox>(data)
		thegame.currentCanvas.Color = New Color(1, 1, 1)
		rect.Draw(thegame.currentCanvas)
	End
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)

	End
End

Function Main()

	New AppInstance
	
	New Game
	
	App.Run()

End
