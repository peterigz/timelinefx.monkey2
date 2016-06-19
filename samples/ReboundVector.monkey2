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
	Field ball:tlCircle
	Field currentCanvas:Canvas
	Field poly:tlPolygon
	
	Private

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 20)
		
		DrawBox = New DrawBoxAction
		DrawScreen = New DrawScreenAction
		
		DrawBox.thegame = Self
		DrawScreen.thegame = Self
		
		'Add some obstacles to the quadtree
		QTree.AddBox(CreateBox(10, 0, Width - 20, 10))
		QTree.AddBox(CreateBox(10, Height - 10, Width - 20, 10))
		QTree.AddBox(CreateBox(0, 10, 10, Height - 20))
		QTree.AddBox(CreateBox(Width - 10, 10, 10, Height - 20))
		Local verts:=New Float[](- 50.0, -50.0, -70.0, 0.0, -50.0, 50.0, 50.0, 50.0, 100.0, 0.0, 50.0, -50.0)
		poly = CreatePolygon(100, 100, verts)
		QTree.AddBox(poly)
		QTree.AddBox(CreateCircle(500, 400, 100))
		QTree.AddBox(CreateBox(500, 200, 50, 50))
		QTree.AddBox(CreateLine(300, 300, 350, 590))
		
		'create a ball to bounce about
		ball = CreateCircle(250, 200, 10)
		ball.SetVelocity(3, 5)
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		currentCanvas = canvas
		
		poly.Rotate(0.01)
	
		App.RequestRender()
	
		canvas.Clear( New Color(0,0,0,1) )
			
		canvas.BlendMode = BlendMode.Alpha
		
		ball.UpdatePosition()

		Local QueryTime:Int = Millisecs()
		QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		QTree.ForEachObjectInBox(ball, ball, DrawBox, New Int[](0, 1, 2))
		
		ball.Draw(canvas)
		
	End

End

Class DrawBoxAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(o:Object, data:Object)
		Local ball:tlCircle = Cast<tlCircle>(data)
		Local wall:tlBox = Cast<tlBox>(o)
		
		'check for collisions between the ball and the obstacle found in the quadtree
		Local result:tlCollisionResult = CheckCollision(ball, wall)
		'prevent the 2 objects from overlapping
		PreventOverlap(result)
		'set the ball velocity to the appropriate rebound vector to make it bounce off the walls.
		ball.SetVelocityVector(result.GetReboundVector(ball.Velocity))
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
