#Rem
	This sample shows how to query a quadtree and return objects in a stack which you could use to perform various things.
#End

'Import the TimelineFX Module
#Import "<timelinefx>"

'We need the following namespaces (std and mojo are already imported in timelinefx module so that's why you don't need to import them above)
Using std..
Using mojo..
Using timelinefx..

Class Game Extends Window

	'Field to store the quadtree
	Field QTree:tlQuadTree
	'field for our box that will used to query the quad tree
	
	Field player:tlBox
	
	'Field to store our interface which are used to do something when objects are found in the quadtree
	Field DrawScreen:DrawScreenAction
	
	Field currentCanvas:Canvas

	Method New()
		'create the quadtree and make it the same size as the window. Here we're making it so that the maximum number of times it can
		'be subdivided is 5, and it will sub divide a when 10 objects are added to a quad. These numbers you can change To tweak performance
		'It will vary depending on how you use the quadtree
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 10)
		DrawScreen = New DrawScreenAction
		
		DrawScreen.thegame = Self
		
		'Populate the quadtree with a bunch of objects
		For Local c:Int = 1 To 1000
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
		
		player = New tlBox(0, 0, 50, 50)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
			
		canvas.BlendMode = BlendMode.Alpha
		
		'position the player box
		player.Position(Mouse.X, Mouse.Y)

		'when space is pressed, draw everything on the screen. We do this by calling "ForEachObjectInArea", and define the area as the screen size. We also
		'pass the DrawScreen interface which will be called by the quadtree if it finds something in the are. We also pass the layers that we want to check.
		If Keyboard.KeyDown(Key.Space) QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		
		'Check for objects within a box using "GetObjectsInBox", passing our player box. This will return all the objects it finds in that area stored in a stack.
		Local objects:=QTree.GetObjectsInBox(player, New Int[](0, 1, 2))
		
		player.Draw(canvas)
		
		'For each of the objects found draw them in a different colour:
		For Local o:=Eachin objects
			Local rect:tlBox = Cast<tlBox>(o)
			'Do a collision check and store the result
			Local collisionresult:tlCollisionResult = CheckCollision(player, rect)
			If collisionresult.Intersecting = True
				If rect.CollisionType = tlPOLY_COLLISION
					Cast<tlPolygon>(rect).RotateDegrees(1)
				
					Cast<tlPolygon>(rect).UpdateWithinQuadtree()
					
				End If
				canvas.Color = New Color(0, 1, 0)
				rect.Draw(canvas)
			End If
		Next
	
	End

End

'These are our interface objects which are used so that we can program what happens when the quadtree finds things in the area that we're checking.
'There are 2 versions of the doAction method that need to be overridden, depending on the query being run. See docs for a list of which queries need which 
'method
Class DrawScreenAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)
		Local rect:tlBox = Cast<tlBox>(o)
		thegame.currentCanvas.Color = New Color(0.5, 0.5, 0.5)
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
