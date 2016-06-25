Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class Game Extends Window

	Field QTree:tlQuadTree
	Field DrawRange:DrawRangeAction
	Field DrawScreen:DrawScreenAction
	Field currentCanvas:Canvas
	Field eventCount:int
	
	Private

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 10)
		DrawRange = New DrawRangeAction
		DrawScreen = New DrawScreenAction
		
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
			If Not QTree.AddBox(rect)
				Print "Didn't Add a Box " + x + ", " + y + " - Screen Size: " + Width + ", " + Height
			End If
		Next
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
		
		'canvas.PushMatrix()		
		canvas.BlendMode = BlendMode.Alpha

		If Keyboard.KeyDown(Key.Space) QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		QTree.ForEachObjectWithinRange(Mouse.X, Mouse.Y, 50, Null, DrawRange, New Int[](0, 1, 2))
		
		Local RenderTime:Int = Millisecs()
		
		canvas.Color = New Color(1,0,0,0.5)
		canvas.DrawOval(Mouse.X-50, Mouse.Y-50, 100, 100)
	
	End

End

Class DrawRangeAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)
		'Use casting to create a local rect of whatever boundary object the quad tree has found.
		'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
		Local rect:tlBox = Cast<tlBox>(o)
		thegame.currentCanvas.Color = New Color(0, 1, 0)
		rect.Draw(thegame.currentCanvas)
		thegame.eventCount+=1
	End
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		
	End
End

Class DrawScreenAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)
		Local rect:tlBox = Cast<tlBox>(o)
		thegame.currentCanvas.Color = New Color(0.5, 0.5, 0.5)
		rect.Draw(thegame.currentCanvas)
		thegame.eventCount+=1
	End
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		
	End
End

Function Main()

	New AppInstance
	
	New Game
	
	App.Run()

End
