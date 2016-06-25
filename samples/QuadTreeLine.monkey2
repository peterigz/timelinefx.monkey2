Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class Game Extends Window

	Field QTree:tlQuadTree
	Field line:tlLine
	Field DrawBox:DrawBoxAction
	Field DrawScreen:DrawScreenAction
	Field currentCanvas:Canvas
	Field eventCount:int
	
	Private

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 5)
		DrawBox = New DrawBoxAction
		DrawScreen = New DrawScreenAction
		
		DrawBox.thegame = Self
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
		
		line = New tlLine(200, 200, 500, 500)
		line.Rotate(DegRad(180))
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
		
		'canvas.PushMatrix()		
		canvas.BlendMode = BlendMode.Alpha
		
		line.Position(Mouse.X, Mouse.Y)
		If Mouse.ButtonDown(MouseButton.Left) line.Rotate(0.05)

		QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		QTree.ForEachObjectAlongLine(line, line, DrawBox, New Int[](0, 1, 2))
		
		line.Draw(canvas)

		canvas.Color = New Color(0.75, 0.75, 0.75)
		QTree.Draw(canvas, 0, 0, 0)	
	
	End

End

Class DrawBoxAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)

	End
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		Local line:=Cast<tlLine>(Data)
		Local box:=Cast<tlBox>(ReturnedObject)
		thegame.currentCanvas.Color = New Color(0, 1, 0)
		line.Draw(thegame.currentCanvas)
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
