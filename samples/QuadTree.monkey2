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
	
	Private
	
	Field _fps:Int
	Field _tick:Int
	Field _fpscount:Int

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 5)
		DrawBox = New DrawBoxAction
		DrawScreen = New DrawScreenAction
		
		DrawBox.thegame = Self
		DrawScreen.thegame = Self
		
		'Populate the quadtree with a bunch of objects
		For Local c:Int = 1 To 10000
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
					rect = New tlCircle(x, y, 5, tlLAYER_1)
				Case 2
					'Create a polygon boundary
					Local verts:= New Float[](- 10.0, -10.0, -15.0, 0.0, -10.0, 10.0, 10.0, 10.0, 15.0, 0.0, 10.0, -10.0)
					rect = New tlPolygon(x, y, verts, tlLAYER_2)
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
		
		'canvas.PushMatrix()		
		
		player.SetPosition(Mouse.X, Mouse.Y)

		Local QueryTime:Int = Millisecs()
		If Keyboard.KeyDown(Key.Space) QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		QTree.ForEachObjectInBox(player, player, DrawBox,New Int[](0, 1, 2))
		QueryTime = Millisecs() - QueryTime
		
		Local RenderTime:Int = Millisecs()
		player.Draw(canvas)

		'canvas.Color = New Color(0.75, 0.75, 0.75)
		'QTree.Draw(canvas, 0, 0, 0)
		RenderTime = Millisecs() - RenderTime
		
		If Millisecs() - _tick > 1000
			_fps = _fpscount
			_tick = Millisecs()
			_fpscount=0
		Else
			_fpscount +=1
		End
		
		canvas.DrawText(_fps, 10, 10)
		canvas.DrawText(QTree.objectsupdated, 30, 10)
		canvas.DrawText(QTree.totalobjectsintree, 50, 10)
		canvas.DrawText("Process Time: " + QueryTime, 10, 35)
		QTree.objectsupdated = 0
	
	End

End

Class DrawBoxAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)
		'Use casting to create a local rect of whatever boundary object the quad tree has found.
		'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
		Local rect:tlBox = Cast<tlBox>(o)
		'We used the data variable to pass the poly we're using to move around the screen. This could be
		'any object, such as a game entity, which could have a field containing a tlBoundary representing
		'its bounding box/poly etc.
		Local player:tlBox = Cast<tlBox>(data)
		'Do a collision check and store the result
		Local collisionresult:tlCollisionResult = CheckCollision(player, rect)
		If collisionresult.intersecting = True
			If rect.CollisionType = tlPOLY_COLLISION
				Cast<tlPolygon>(rect).RotateDegrees(1)
			
				Cast<tlPolygon>(rect).UpdateWithinQuadtree()
				
			End If
			thegame.currentCanvas.Color = New Color(0, 1, 0)
			rect.Draw(thegame.currentCanvas)
		End If
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
	End
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
		
	End
End

Function Main()

	New AppInstance
	
	New Game
	
	App.Run()

End
