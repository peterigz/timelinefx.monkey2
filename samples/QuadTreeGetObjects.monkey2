Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class Game Extends Window

	Field QTree:tlQuadTree
	Field player:tlBox
	Field DrawBox:DrawBoxAction
	Field DrawScreen:DrawScreenAction
	Field currentCanvas:Canvas

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 10)
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
			If Not QTree.AddBox(rect)
				Print "Didn't Add a Box " + x + ", " + y + " - Screen Size: " + Width + ", " + Height
			End If
		Next
		
		player = New tlBox(0, 0, 50, 50)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
			
		canvas.BlendMode = BlendMode.Alpha
		
		player.Position(Mouse.X, Mouse.Y)

		If Keyboard.KeyDown(Key.Space) QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		Local objects:=QTree.GetObjectsInBox(player, New Int[](0, 1, 2))
		
		Local RenderTime:Int = Millisecs()
		player.Draw(canvas)

		canvas.Color = New Color(0.75, 0.75, 0.75)
		QTree.Draw(canvas, 0, 0, 0)
		
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
