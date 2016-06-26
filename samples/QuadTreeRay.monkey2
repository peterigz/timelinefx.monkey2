#Rem
	This sample shows how to use a quadtree to check for objects using a ray cast. It uses an interface which you can use to create a callback to 
	decide what happens when a collision is found.
#End

'Import the TimelineFX Module
#Import "<timelinefx>"

'We need the following namespaces (std and mojo are already imported in timelinefx module so that's why you don't need to import them above)
Using std..
Using mojo..
Using timelinefx..

'Create a point class to store the origin of the ray we'll be casting. The reason I don't use a vector for this is because we need to pass it through
'the event einterface as an object, we can't do that if we use a struct (which is what a tlVector2 is).
Class Point
	Field x:Float
	Field y:Float
End

Class Game Extends Window

	'Field to store the quadtree
	Field QTree:tlQuadTree
	
	'A vector to store the direction of the ray
	Field ray:tlVector2
	
	'The origin of the ray
	Field vpoint:tlVector2
	
	'Field to store our interfaces which are used to do something when objects are found in the quadtree
	Field DrawRay:RayAction
	Field DrawScreen:DrawScreenAction
	
	Field currentCanvas:Canvas
	Field point:Point

	Method New()
		'create the quadtree and make it the same size as the window. Here we're making it so that the maximum number of times it can
		'be subdivided is 5, and it will sub divide a when 10 objects are added to a quad. These numbers you can change To tweak performance
		'It will vary depending on how you use the quadtree
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 10)
		
		'Create the event objects, see below for more details
		DrawRay = New RayAction
		DrawScreen = New DrawScreenAction
		
		point = New Point
		
		'Create a reference in the interfaces pointing to this object
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
		
		'Create the ray
		ray = New tlVector2(0, 0)
		vpoint = New tlVector2(400, 400)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
			
		canvas.BlendMode = BlendMode.Alpha
		
		If Mouse.ButtonDown(MouseButton.Left) vpoint = New tlVector2(Mouse.X, Mouse.Y)
		ray = New tlVector2(Mouse.X - point.x, Mouse.Y - point.y).Normalise()
		
		'Set our point coordinates. We'll pass this trhough the quadtree query
		point.x = vpoint.x
		point.y = vpoint.y

		'Draw everything on the screen. We do this by calling "ForEachObjectInArea", and define the area as the screen size. We also
		'pass the DrawScreen interface which will be called by the quadtree if it finds something in the are. We also pass the layers that we want to check.
		QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))

		'query the quadtree with the ray and run our call back if it hit. Otherwise draw the full length of the ray (300)
		'we're using the data variable here to pass through the Point to the interface	
		If Not QTree.RayCast(point.x, point.y, ray, 300.0, point, DrawRay, New Int[](0, 1, 2))
			canvas.Color = New Color( 255, 0, 0 )
			canvas.DrawLine (point.x, point.y, point.x + (ray.x * 300), point.y + (ray.y * 300))
		End If
	
	End

End

'These are our interface objects which are used so that we can program what happens when the quadtree finds things in the area that we're checking. In this case
'we're doing a raycast on the quadtree so it will pass the first object that is hit by the ray.
'There are 2 versions of the doAction method that need to be overridden, depending on the query being run. See docs for a list of which queries need which 
'method. Basically if the query will find multiple objects then the doAction method with 2 parameters will be called, if it's a raycast like this which will find one object
'then the result of the collision will also be passed as well.
Class RayAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)

	End
	Method doAction:Void(ObjectTheRayHit:Object, Data:Object, Result:tlCollisionResult)
		'cast the objects to some local variables
		Local point:Point = Cast<Point>(Data)
		Local box:tlBox = Cast<tlBox>(ObjectTheRayHit)
		
		'If it hits a polygon then rotate it.
		If Cast<tlPolygon>(ObjectTheRayHit)
			Cast<tlPolygon>(ObjectTheRayHit).Rotate(0.01)
		End
		
		thegame.currentCanvas.Color = New Color( 255, 0, 0 )
		
		'if the ray does not originate inside an object then draw the ray and intersection point
		If Not Result.RayOriginInside
			thegame.currentCanvas.DrawLine(point.x, point.y, Result.RayIntersection.x, Result.RayIntersection.y)
			thegame.currentCanvas.DrawOval(Result.RayIntersection.x - 4, Result.RayIntersection.y - 4, 8, 8)
		End If
		
		'draw the box the ray hit
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
