Namespace collisiontest

#Import "<std>"
#Import "<mojo>"
#Import "<timelinefx>"

Using std..
Using mojo..
Using timelinefx..

Class Game Extends Window

	'Field to store the quadtree
	Field QTree:tlQuadTree
	
	'Field to store our interfaces which are used to do something when objects are found in the quadtree
	Field DrawBox:DrawBallAction
	Field DrawScreen:DrawScreenAction
	
	Field ball:tlCircle
	Field currentCanvas:Canvas
	Field poly:tlPolygon
	
	Private

	Method New()
		QTree = New tlQuadTree(0, 0, Width, Height, 5, 20)
		
		DrawBox = New DrawBallAction
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

		'Draw everything on the screen. We do this by calling "ForEachObjectInArea", and define the area as the screen size. We also
		'pass the DrawScreen interface which will be called by the quadtree if it finds something in the are. We also pass the layers that we want to check.
		QTree.ForEachObjectInArea(0, 0, Width, Height, Null, DrawScreen, New Int[](0, 1, 2))
		
		'Check for objects within a box using "ForEachObjectWithinBox", passing our ball. We also pass the ball as "Data" which is forwarded on to the
		'DrawBallAction so we can use it to find out if it is actually colliding with anything. We pass the DrawBallAction interface
		'we created which will be called when the qaudtree finds something within quadtree nodes that collide with the box. We also pass the layers that we want to check.
		QTree.ForEachObjectInBox(ball, ball, DrawBox, New Int[](0, 1, 2))
		
		canvas.Color = New Color(1, 0, 0)
		ball.Draw(canvas)
		
	End

End

'These are our interface objects which are used so that we can program what happens when the quadtree finds things in the area that we're checking.
'There are 2 versions of the doAction method that need to be overridden, depending on the query being run. See docs for a list of which queries need which 
'method
Class DrawBallAction Implements tlQuadTreeEvent
	Field thegame:Game
	Method doAction:Void(foundobject:Object, data:Object)
		Local ball:tlCircle = Cast<tlCircle>(data)
		Local wall:tlBox = Cast<tlBox>(foundobject)
		
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
	Method doAction:Void(foundobject:Object, data:Object)
		'Use casting to create a local rect of whatever boundary object the quad tree has found.
		'This could be either a tlBoundary, tlBoundaryCircle, tlBoundaryLine or tlBoundaryPoly
		'Note that the Box object has a Data field that you could use to store another object, say your game entity.
		Local rect:tlBox = Cast<tlBox>(foundobject)
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
