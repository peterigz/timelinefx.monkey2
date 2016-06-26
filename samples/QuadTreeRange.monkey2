#Rem
	This sample shows how to use a quadtree to check for objects within a certain range. It uses an interface which you can use to create a callback to 
	decide what happens when a collision is found.
#End

'Import the TimelineFX Module
#Import "<timelinefx>"

'We need the following namespaces (std and mojo are already imported in timelinefx module so that's why you don't need to import them above)
Using std..
Using mojo..
Using timelinefx..

'Create a class that extends mojo Window where we can set the test
Class Game Extends Window

	'Field to store the quadtree	
	Field QTree:tlQuadTree
	
	'Field to store our interfaces which are used to do something when objects are found in the quadtree
	Field DrawRange:DrawRangeAction
	Field DrawScreen:DrawScreenAction
	
	'A Field to store the canvas
	Field currentCanvas:Canvas

	Method New()
		'create the quadtree and make it the same size as the window. Here we're making it so that the maximum number of times it can
		'be subdivided is 5, and it will sub divide a when 10 objects are added to a quad. These numbers you can change To tweak performance
		'It will vary depending on how you use the quadtree
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 10)
		
		'Create the event objects, see below for more details
		DrawRange = New DrawRangeAction
		DrawScreen = New DrawScreenAction
		
		'Create a reference in the interfaces pointing to this object
		DrawRange.thegame = Self
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
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
		
		canvas.BlendMode = BlendMode.Alpha

		'when space is pressed, draw everything on the screen. We do this by calling "ForEachObjectInArea", and define the area as the screen size. We also
		'pass the DrawScreen interface which will be called by the quadtree if it finds something in the are. We also pass the layers that we want to check.
		If Keyboard.KeyDown(Key.Space) QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		
		'Check for objects within a certain range using "ForEachObjectWithinRange", defining the point and the radius of the check. We pass the DrawRange interface
		'we created which will be called when the qaudtree finds something within that range. We also pass the layers that we want to check.
		QTree.ForEachObjectWithinRange(Mouse.X, Mouse.Y, 50, Null, DrawRange, New Int[](0, 1, 2))
		
		'draw a visual representation of the range being checked		
		canvas.Color = New Color(1,0,0,0.5)
		canvas.DrawOval(Mouse.X-50, Mouse.Y-50, 100, 100)
	
	End

End

'These are our interface objects which are used so that we can program what happens when the quadtree finds things in the area that we're checking.
'There are 2 versions of the doAction method that need to be overridden, depending on the query being run. See docs for a list of which queries need which 
'method
Class DrawRangeAction Implements tlQuadTreeEvent
	'A field to store our game object
	Field thegame:Game
	Method doAction(foundobject:Object, data:Object)
		'Use casting to create a local rect of whatever boundary object the quad tree has found.
		'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
		'Note that the Box object has a Data field that you could use to store another object, say your game entity.
		Local box:tlBox = Cast<tlBox>(foundobject)
		thegame.currentCanvas.Color = New Color(0, 1, 0)
		
		'Draw the box that was found
		box.Draw(thegame.currentCanvas)
	End
	Method doAction(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		
	End
End

Class DrawScreenAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction(foundobject:Object, data:Object)
		'Use casting to create a local rect of whatever boundary object the quad tree has found.
		'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
		'Note that the Box object has a Data field that you could use to store another object, say your game entity.
		Local box:tlBox = Cast<tlBox>(foundobject)
		thegame.currentCanvas.Color = New Color(0.5, 0.5, 0.5)
		
		'Draw the box that was found
		box.Draw(thegame.currentCanvas)
	End
	Method doAction(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		
	End
End

Function Main()

	New AppInstance
	
	New Game
	
	App.Run()

End
