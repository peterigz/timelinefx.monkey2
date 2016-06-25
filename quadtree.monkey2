Namespace timelinefx.collision

Using timelinefx.collision..
Using std.collections..
Using std.random

Const MAX_NODE_LEVELS:Int = 1
Const MAX_PER_NODE:Int = 2

Interface tlQuadTreeEvent
	Method doAction:Void(ReturnedObject:Object, Data:Object)
	Method doAction:Void(ReturnedObject:Object, Data:Object, Result:tlCollisionResult)
End

#rem
bbdoc: Quadtree type for managing a quadtree
about: <p>Rather then go on about what a quadtree is, here's some useful resources I used myself to find out about them:
http://en.wikipedia.org/wiki/Quadtree, http://www.kyleschouviller.com/wsuxna/quadtree-source-included/ and http://www.heroicvirtuecreations.com/QuadTree.html</p>
<p>Quadtrees vary with each implementation based on the users needs. I've tried to be flexible here with a emphasis on handling objects that will
move about a lot. If an object moves within a quadtree then it will generally have to be re-added to the quadtree, so I've implemented that possibility here.
Thankfully there's no need to rebuild the quadtree every time an object moves, the object just removes and adds itself back to the tree, and it will only do it if
it's moved outside of it's containing #tlQuadTreeNode.</p>
<p>When I say object, I mean a #tlBox, which is a simple axis aligned bounding box type that can be added to the quadtree, the more complex #tlCircle, #tlLine and
	#tlPolygon which extend #tlBox can also be added, but the quadtree will only concern itself with bounding boxes when a query is made on the
quadtree.</p>
<p>Using the quadtree is simple enough, create a new quadtree with whatever dimensions you want and then use #AddBox to add bounding boxes to it. In
your main loop you might want to put #RunQuadtreeMaintenance which tidies up the quadtree by finding empty partitions and deleting them. Of course
the whole point of a quadtree is to find out which objects are within a particular area so that you can do collision checking, rendering, updating or whatever. To do that,
	you can query the quadtree by simply calling either #QueryQuadtreeArea or #QueryQuadtreeBox which will run a callback function of your choice to perform your
specific tasks on them. There's also queries available to check for objects within a radius by using, #QueryQuadtreeRange and #QueryQuadtreeCircle, and also
for lines and rays using #QueryQuadtreeEdge, #QueryQuadtreeLine and #QueryQuadtreeRay.</p>
<p>Here is a list of the query functions you can use to query the quadtree, along with the type of callback function you'll need to create to handle the results
of each query:</p>
<table>
<tr>
<td> #QueryQuadtreeArea / #QueryQuadtreeBox </td>
<td>For querying the quadtree with a rectangular area. All objects within the area will be passed through to a callback function that needs the following
parameters: &{Callback(ObjectFoundInQuadtree:object, Data:object)} You don't have to use those exact variable names, just as long as the 2 variables are objects.</td>
</tr>
<tr>
<td> #QueryQuadtreeRange / #QueryQuadtreeCircle </td>
<td>For querying the quadtree with a specific radius. All objects within the radius will be passed through to the call back function:
	&{Callback(ObjectFoundInQuadtree:object, Data:object)}</td>
</tr>
<tr>
<td> #QueryQuadtreeRay </td>
<td>This is for casting a ray from any point and doing a callback on the first object that is hit. The callback differs slightly in that the results
of the ray collision are passed through to the callback aswell. This is because the collision check vs the ray has to be done during the query, so
there is no need to do any further ray checks in your callback. The callback should look like this: &{Callback(ObjectFoundInQuadtree:object, Data:object, Result:tlCollisionResult)}</td>
</tr>
<tr>
<td> #QueryQuadtreeEdge / #QueryQuadtreeLine </td>
<td>This is for querying the QuadTree with a line. Every object in the Quadtree that collides with the line is passed To the callback function, and like
the ray query, the collision result is also passed through too: &{Callback(ObjectFoundInQuadtree:object, Data:object, Result:tlCollisionResult)}
</td>
</tr>
</table>
<p>Implementing this quadtree within your game will probably involve including #tlBox, #tlCircle, #tlLine or #tlPolygon as a field within your entity/actor etc types.
When your actors move about, just make sure you update the position of the Box as well using #SetBoxPosition or #MoveBox. When this happens all the necessary updating
of the quadtree will happen automatically behind the scenes. Be aware that if an object moves outside of the quadtree bounds it will drop out of the quadtree.</p>
<p><b>FAQ:</b></p>
<p><b>What happens when a object overlaps more then one quadtreenode?</b></p>
<p>The object is added to each node it overlaps. No object will ever be added to a node that has children, they will be moved down the quadtree to the bottom level of that branch.</p>
<p><b>What happens when an object is found more then once because it is contained within more than 1 node?</b></p>
<p>tlBoxs are aware if they have already been found and a callback has been made within the same search, so a callback will never be made twice on
the same search query.</p>
<p><b>What happens if a node no longer contains more then the maximium allowed for a node, are it's objects moved back up the tree?</b></p>
<p>No, onced a node is partioned and objects moved down, they're there to stay, however if you #RunQuadtreeMaintenance then empty nodes will be unpartitioned. I
didn't think it was worth the overhead to worry about moving objects back up the tree again.</p>
<p><b>What collision checking is done when calling, for example, #QueryQuadtreeArea?</b></p>
<p>The quadtree will just concern itself with doing callbacks on objects it finds with rect->rect collision in the case of #QueryQuadtreeArea, and circle->rect
collision in the case of #QueryQuadtreeRange. Once you've found those objects you can then go on and do more complex collision checking such as poly->poly. If
however you only need to check for rect->rect then you can assume a hit straight away as the quadtree will only callback actual hits, potential hits are
already excluded automatically if their bounding box is outside the area being queried.</p>
<p><b>What are potential hits?</b></p>
<p>A potential hit would be an object in the same quadtree node that the area check overlaps. So if the area you're checking a collision for overlaps
2 quadnodes, all the objects in those 2 nodes would be considered potential hits. I decided that I may aswell cull any of those bounding boxes that
don't overlap the area being checked before doing the callback so that the amount of potential hits is reduced further, and to save wasting the time doing it in the callback function.
This applies to both #QueryQuadtreeArea and #QueryQuadtreeRange functions, but as mentioned before, it will only cull according to bounding boxes, you'll have
to do a further check in your callback to manage the more complex poly->poly, poly->rect etc., collisions.</p>
<p><b>If I have to use a callback function, how can I do stuff with an object without resorting to globals?</b></p>
<p>When you run a #QueryQuadtreeArea (of any type) you can pass an object that will be passed through to the callback function. So the call back function
you create should look like: &{Function MyCallBackFunction(ObjectFoundInQuadtree:Object, MyData:object)}So your data could be anything such as a bullet
or pLayer ship etc., and assuming that object has a tlBox field you can do further collision checks between the 2. If you don't need to pass any
data then just leave it null.</p>
<p><b>How do I know what kind of tlBox has been passed back from from the quadtree?</b></p>
<p>tlBoundaries have a field called collisiontype which you can find out by calling #GetCollisionType. This will return either tlBOX_COLLISION,
	tlCIRCLE_COLLISION, tlPOLY_COLLISION or tlLINE_COLLISION. The chances are though, that you won't need to know the type, as a call to #CheckCollision
will automatically determine the type and perform the appropriate collision check.</p>
<p><b>Can I have more then one quadtree</b></p>
<p>Yes you can create as many quadtrees as you want, however, bear in mind that a #tlBox can only ever exist in 1 quadtree at a time. I most cases, with
the use of Layers, 1 quadtree will probably be enough.</p>
<p><b>How do the Layers work?</b></p>
<p>You can put boxes onto different Layers of the quadtree to help organise your collisions and optimise too. Each Layer has it's own separate quadtree
which can be defined according to how you need it to be optimised. See #SetQuadtreeLayerConfig. So you could put a load of enemy objects onto one Layer
and the pLayer objects onto another. This will speed things up when an enemy might have to query the quadtree to see if the pLayer is nearby because
the Layer that the pLayer is on won't be so cluttered with other objects. If you need to check for collisions between many objects vs many other objects,
then you should try to put those objects onto the same Layer. This way when each object checks for a collision with an object on the same Layer it
can skip having to query the quadtree, because each tlbox already knows what quadtree nodes it exists in, so it can check against other objects in the same
node straight away without having to drill down into the quadtree each time.</p>
#end
Class tlQuadTree
	
	Field Box:tlBox
	Field rootnode:tlQuadTreeNode[]
	
	Field objectsfound:Int
	Field objectsupdated:Int
	Field totalobjectsintree:Int
	
	Field min_nodewidth:Float
	Field min_nodeheight:Float
	
	Field map:tlQuadTreeNode[]
	
	Field objectsprocessed:Int
	
	Field dimension:Int
	
	Field maxLayers:Int
	Field Layerconfigs:Int[]
	
	Field AreaCheckCount:=New Int[8]
	Field areacheckindex:Int = -1

	Field restack:Stack<tlBox>
	
	#rem
	bbdoc: Create a new tlQuadTree
	returns: A new quadtree
	about: Creates a new quad tree with the coordinates and dimensions given. _maxlevels determines how many times the quadtree can be sub divided. A
	quadtreenode is only subdivided when a certain amount of objects have been added, which is set by passing _maxpernode. There's no optimum values for
	these, it largely depends on your specific needs, so you will probably do well to experiment. Set maxLayers to determine exactly how many Layers
	your want the quadtree to have.
	#end
	Method New(x:Float, y:Float, w:Float, h:Float, maxlevels:Int = 4, maxpernode:Int = 4, _maxLayers:Int = 8)
		Box = New tlBox(x, y, w, h)
		maxLayers = _maxLayers
		rootnode = New tlQuadTreeNode[maxLayers]
		dimension = 2 Shl (maxlevels - 1)
		min_nodewidth = w / dimension
		min_nodeheight = h / dimension
		map = New tlQuadTreeNode[maxLayers * dimension * dimension]
		Layerconfigs = New Int[maxLayers*2]
		For Local l:Int = 0 To maxLayers - 1
			rootnode[l] = New tlQuadTreeNode(x, y, w, h, Self, l)
			For Local x:Int = 0 To dimension - 1
				For Local y:Int = 0 To dimension - 1
					map[x + dimension * (y + dimension * l)] = rootnode[l]
				Next
			Next
			rootnode[l].dimension = dimension
			Layerconfigs[l * MAX_NODE_LEVELS] = maxlevels
			Layerconfigs[l * MAX_PER_NODE] = maxpernode
		Next
		restack = New Stack<tlBox>
	End
	
	#rem
	bbdoc: Configure a Layer of the quadtree
	about: As the quadtree is broken up into Layers, this means you can configure each Layer to have a specific number of maximum levels
	and objects per node. This helps you to be more specific about how you optimise your quadtree. You should configure the Layers immediately
	after creating the quadtree and before anything is added to the tree. Layers can not be reconfigured once the quadtree has had objects added
	to it.
	#end
	Method SetLayerConfig(Layer:Int, maxlevels:Int, maxpernode:Int)
		If Layer < maxLayers And Layer >= 0
			Layerconfigs[Layer * MAX_NODE_LEVELS] = maxlevels
			Layerconfigs[Layer * MAX_PER_NODE] = maxpernode
		Else
			Print "Layer does not exist"
		End If
	End
	
	#rem
		bbdoc: Add a new bounding box to the Quadtree
		returns: False if the box doesn't overlap the qaudtree, otherwise True.
		about: A quadtree isn't much use without any objects. Use this to add a #tlBox to the quadtree. If the bounding box does not overlap the
		quadtree then null is returned.
	#end
	Method AddBox:Int(r:tlBox)
		If Box.BoundingBoxOverlap(r)
			r.quadtree = Self
			rootnode[r.CollisionLayer].AddBox(r)
			totalobjectsintree += 1
			Return True
		End
			
		Return False
	End

	Method ReAddBoxes()
		For Local r:=Eachin restack
			r.RemoveFromQuadTree()
			AddBox(r)
		Next
		restack.Clear()
	End

	#rem
	monkeydoc: Add a new bounding box to the restack
	#end
	Method AddBoxRestack(r:tlBox)
		restack.Add(r)
	End
		
	#rem
	bbdoc: Query the Quadtree to find objects with an area
	about: When you want to find objects within a particular area of the quadtree you can use this method.  Pass the area coordinates and dimensions
	that you want to check, an object that can be anything that you want to pass through to the callback function, and the function callback that you want
	to perform whatever tasks you need on the objects that are found within the area.
	The callback function you create needs to have 2 parameters: ReturnedObject:object which will be the tlBox/circle/poly, and Data:object which can be
	and object you want to pass through to the call back function.
	#end
	Method ForEachObjectInArea(x:Float, y:Float, w:Float, h:Float, Data:Object, onFoundObject:tlQuadTreeEvent, Layer:Int[])
		Local area:tlBox = New tlBox(x, y, w, h)
		areacheckindex += 1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		objectsfound = 0
		For Local c:Int = 0 To Layer.Length - 1
			rootnode[Layer[c]].ForEachInAreaDo(area, Data, onFoundObject, False)
		Next
		areacheckindex-=1
		ReAddBoxes()
	End
	
	#rem
	bbdoc: Query the quadtree to find objects within a #tlBox
	about: This does the same thing as #ForEachObjectInArea except you can pass a #tlBox instead to query the quadtree.
	#end
	Method ForEachObjectInBox(area:tlBox, Data:Object, onFoundObject:tlQuadTreeEvent, Layer:Int[])
		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		For Local c:Int = 0 To Layer.Length - 1
			rootnode[Layer[c]].ForEachInAreaDo(area, Data, onFoundObject, True)
		Next
		areacheckindex-=1
		ReAddBoxes()
	End
	
	#rem
	bbdoc: Query the quadtree to find objects within a #tlBox
	about: This does the same thing as #ForEachObjectInArea except you can pass a #tlBox instead to query the quadtree.
	#end
	Method GetObjectsInBox:Stack<tlBox>(area:tlBox, Layer:Int[], GetData:Int = False)
		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		Local list:Stack<tlBox> = New Stack<tlBox>
		For Local c:Int = 0 To Layer.Length - 1
			list = rootnode[Layer[c]].GetEachInArea(area, True, list, GetData)
		Next
		areacheckindex-=1
		Return list
	End
	
	#rem
	bbdoc: Query the quadtree to find objects within a certain radius
	about: This will query the quadtree and do a callback on any objects it finds within a given radius.
	#end
	Method ForEachObjectWithinRange(x:Float, y:Float, radius:Float, Data:Object, onFoundObject:tlQuadTreeEvent, Layer:Int[])
		Local range:tlCircle = New tlCircle(x, y, radius)
		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		For Local c:Int = 0 To Layer.Length - 1
			rootnode[Layer[c]].ForEachWithinRangeDo(range, Data, onFoundObject)
		Next
		areacheckindex-=1
	End
	
	#rem
	bbdoc: Query the quadtree to find objects within a #tlCircle
	about: This will query the quadtree and do a callback on any objects it finds within the given tlCircle
	#end
	Method ForEachObjectInCircle(circle:tlCircle, Data:Object, onFoundObject:tlQuadTreeEvent, Layer:Int[])
		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		For Local c:Int = 0 To Layer.Length - 1
			rootnode[Layer[c]].ForEachWithinRangeDo(circle, Data, onFoundObject)
		Next
		areacheckindex-=1
	End
	
	#rem
	bbdoc: Query the quadtree to find objects within a #tlCircle
	about: This does the same thing as #ForEachObjectWithinRange except you can pass a #tlCircle instead to query the quadtree.
	#end
	Method GetObjectsInCircle:Stack<Object>(circle:tlCircle, Layer:Int[], GetData:Int = False, Limit:Int = 0)
		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		Local list:= New Stack<Object>
		For Local c:Int = 0 To Layer.Length - 1
			rootnode[Layer[c]].GetEachInRange(circle, True, list, GetData, Limit)
		Next
		areacheckindex-=1
		Return list
	End
	
	#rem
	bbdoc: Query a quadtree with a #tlLine
	returns: False if the line did not touch anything, otherwise True
	about: This will query the quadtree with a line and perform a callback on all the objects the #tlLine intersects. Pass the quadtree to do the query on, the
	#tlLine to query with, an object you want to pass through to the callback, and the callback itself. It's worth noting that the callback also requires
	you have a #tlCollisionResult parameter which will be passed to the callback function with information about the results of the raycast.
	#end
	Method ForEachObjectAlongLine:Int(line:tlLine, data:Object, onFoundObject:tlQuadTreeEvent, Layer:Int[])
		Local d:tlVector2 = New tlVector2(line.TFormVertices[1].x - line.TFormVertices[0].x, line.TFormVertices[1].y - line.TFormVertices[0].y)
		Local maxdistance:Float = d.DotProduct(d)
		d.Normalise()
		
		If Not d.x And Not d.y
			Return False
		End If

		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		
		Local x1:Float = line.TFormVertices[0].x + line.World.x
		Local y1:Float = line.TFormVertices[0].y + line.World.y

		For Local c:Int = 0 To Layer.Length - 1
			Local tMaxX:Float = 0 
			Local tMaxY:Float = 0
			Local direction:Int
			
			Local StepX:Int = 0
			Local StepY:Int = 0
			
			Local DeltaX:Float = 0
			Local DeltaY:Float = 0

			Local x:Int = x1 / min_nodewidth
			Local y:Int = y1 / min_nodeheight

			Local wx:Float = x * min_nodewidth
			Local wy:Float = y * min_nodeheight
			
			If d.x < 0
				StepX = -1
				tMaxX = (wx - x1) / d.x
				DeltaX = (min_nodewidth) / -d.x
			ElseIf d.x > 0
				StepX = 1
				tMaxX = (wx - x1 + min_nodewidth) / d.x
				DeltaX = (min_nodewidth) / d.x
			Else
				StepX = 0
				direction = 1
				DeltaX = 0
			End If
			
			If d.y < 0
				StepY = -1
				tMaxY = (wy - y1) / d.y
				DeltaY = (min_nodeheight) / -d.y
			ElseIf d.y > 0
				StepY = 1
				tMaxY = (wy - y1 + min_nodeheight) / d.y
				DeltaY = (min_nodeheight) / d.y
			Else
				StepY = 0
				direction = 2
				DeltaY = 0
			End If
			
			Local lastquad:tlQuadTreeNode = Null
			
			Local dv:tlVector2 = New tlVector2(0, 0)
			Local endofline:Int
			
			'if line starts outside of quadtree
			If x < 0 Or x >= dimension Or y < 0 Or y >= dimension
				Local result:tlCollisionResult = rootnode[Layer[c]].Box.LineCollide(line)
				If result.NoCollision Return False
				If result.Intersecting
					Select direction
						Case 0
							While x < 0 Or x >= dimension Or y < 0 Or y >= dimension
								If tMaxX < tMaxY
									tMaxX+=DeltaX
									x = x + StepX
								Else
									tMaxY+=DeltaY
									y = y + StepY
								End If
							Wend
						Case 1
							While y < 0 Or y >= dimension
								tMaxY+=DeltaY
								y+=StepY
							Wend
						Case 2
							While x < 0 Or x >= dimension
								tMaxX+=DeltaX
								x+=StepX
							Wend
					End Select
				Else
					Return False
				End If
			End If
			
			Select direction
				Case 0
					While x >= 0 And x < dimension And y >= 0 And y < dimension
						If map[x + dimension * (y + dimension * Layer[c])] <> lastquad
							map[x + dimension * (y + dimension * Layer[c])].ForEachObjectAlongLine(line, data, onFoundObject)
						End If
						lastquad = map[x + dimension * (y + dimension * Layer[c])]
						
						dv = New tlVector2(map[x + dimension * (y + dimension * Layer[c])].Box.World.x - x1, map[x + dimension * (y + dimension * Layer[c])].Box.World.y - y1)
						If endofline Exit
						If dv.DotProduct(dv) > maxdistance endofline = True
						
						If tMaxX < tMaxY
							tMaxX+=DeltaX
							x = x + StepX
						Else
							tMaxY+=DeltaY
							y = y + StepY
						End If
					Wend
				Case 1	'vertically only
					While y >= 0 And y < dimension
						If map[x + dimension * (y + dimension * Layer[c])] <> lastquad
							map[x + dimension * (y + dimension * Layer[c])].ForEachObjectAlongLine(line, data, onFoundObject)
						End If
						lastquad = map[x + dimension * (y + dimension * Layer[c])]
						
						dv = New tlVector2(map[x + dimension * (y + dimension * Layer[c])].Box.World.x - x1, map[x + dimension * (y + dimension * Layer[c])].Box.World.y - y1)
						If endofline Exit
						If dv.DotProduct(dv) > maxdistance endofline = True
						
						tMaxY+=DeltaY
						y+=StepY
					Wend
				Case 2	'horizontally only
					While x >= 0 And x < dimension
						If map[x + dimension * (y + dimension * Layer[c])] <> lastquad
							map[x + dimension * (y + dimension * Layer[c])].ForEachObjectAlongLine(line, data, onFoundObject)
						End If
						lastquad = map[x + dimension * (y + dimension * Layer[c])]
						
						dv = New tlVector2(map[x + dimension * (y + dimension * Layer[c])].Box.World.x - x1, map[x + dimension * (y + dimension * Layer[c])].Box.World.y - y1)
						If endofline Exit
						If dv.DotProduct(dv) > maxdistance endofline = True
						
						tMaxX+=DeltaX
						x+=StepX
					Wend
			End Select
		Next
		
		areacheckindex-=1
		
		Return True
	End
	
	#rem
	bbdoc:
		about:
		#end
	Method RayCast:Int(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Float = 0, Data:Object, onFoundObject:tlQuadTreeEvent, Layer:Int[])

		objectsfound = 0
		areacheckindex+=1
		AreaCheckCount[areacheckindex] = GetUniqueNumber()
		
		Local d:tlVector2 = New tlVector2(dx, dy)
		d.Normalise()
		If Not d.x And Not d.y
			areacheckindex-=1
			Return False
		End If
		
		Local objectfound:Int
		
		For Local c:Int = 0 To Layer.Length - 1

			Local tMaxX:Float = 0 
			Local tMaxY:Float = 0
			Local direction:Int
			
			Local StepX:Int = 0
			Local StepY:Int = 0
			
			Local DeltaX:Float = 0
			Local DeltaY:Float = 0

			Local x:Int = px / min_nodewidth
			Local y:Int = py / min_nodeheight

			Local wx:Float = x * min_nodewidth
			Local wy:Float = y * min_nodeheight
			
			If d.x < 0
				StepX = -1
				tMaxX = (wx - px) / d.x
				DeltaX = (min_nodewidth) / -d.x
			ElseIf d.x > 0
				StepX = 1
				tMaxX = (wx - px + min_nodewidth) / d.x
				DeltaX = (min_nodewidth) / d.x
			Else
				StepX = 0
				direction = 1
				DeltaX = 0
			End If
			
			If d.y < 0
				StepY = -1
				tMaxY = (wy - py) / d.y
				DeltaY = (min_nodeheight) / -d.y
			ElseIf d.y > 0
				StepY = 1
				tMaxY = (wy - py + min_nodeheight) / d.y
				DeltaY = (min_nodeheight) / d.y
			Else
				StepY = 0
				direction = 2
				DeltaY = 0
			End If
			
			Local lastquad:tlQuadTreeNode = Null
			
			Select direction
				Case 0
					While x >= 0 And x < dimension And y >= 0 And y < dimension And Not objectfound
						If map[x + dimension * (y + dimension * Layer[c])] <> lastquad
							objectfound = map[x + dimension * (y + dimension * Layer[c])].RayCast(px, py, dx, dy, maxdistance, Data, onFoundObject)
						End If
						lastquad = map[x + dimension * (y + dimension * Layer[c])]
						If(tMaxX < tMaxY)
							tMaxX+=DeltaX
							x = x + StepX
						Else
							tMaxY = tMaxY + DeltaY
							y = y + StepY
						End If
					Wend
				Case 1	'vertically only
					While y >= 0 And y < dimension And Not objectfound
						If map[x + dimension * (y + dimension * Layer[c])] <> lastquad
							objectfound = map[x + dimension * (y + dimension * Layer[c])].RayCast(px, py, dx, dy, maxdistance, Data, onFoundObject)
						End If
						lastquad = map[x + dimension * (y + dimension * Layer[c])]
						tMaxY+=DeltaY
						y = y + StepY
					Wend
				Case 2	'horizontally only
					While x >= 0 And x < dimension And Not objectfound
						If map[x + dimension * (y + dimension * Layer[c])] <> lastquad
							objectfound = map[x + dimension * (y + dimension * Layer[c])].RayCast(px, py, dx, dy, maxdistance, Data, onFoundObject)
						End If
						lastquad = map[x + dimension * (y + dimension * Layer[c])]
						tMaxX+=DeltaX
						x = x + StepX
					Wend
			End Select
		Next
		
		areacheckindex-=1
				
		If objectfound
			objectsfound = 1
			Return True
		End
		
		Return False
		
	End
	
	#rem
	bbdoc: Find out how many objects were found on the last query
	returns: Number of objects found.
	about: Use this to retrieve the amount of object that were found when the last query was run.
	#end
	Method GetObjectsFound:Int()
		Return objectsfound
	End
	
	#rem
	bbdoc: Find out how many objects are currently in the quadtree
	returns: Number of Total Objects in Tree
	about: Use this to retrieve the total amount of objects that are stored in the quadtree.
	#end
	Method GetTotalObjects:Int()
		Return totalobjectsintree
	End
	
	#rem
	bbdoc: Get the width of the #tlQuadtree
	returns: Overal width of the quadtree
	#end
	Method GetWidth:Int()
		Return Box.Width
	End
	
	#rem
	bbdoc: Get the height of the #tlQuadtree
	returns: Overal height of the quadtree
	#end
	Method GetHeight:Int()
		Return Box.Height
	End
	
	#rem
	bbdoc: Perform some house keeping on the quadtree
	about: This will search the quadtree on the specified Layers for any empty #tlQuadTreeNodes and unpartition them if necessary.
	#end
	Method RunMaintenance(Layer:Int[])
		For Local c:Int = 0 To Layer.Length - 1
			rootnode[Layer[c]].UnpartitionEmptyQuads()
		Next
	End
	
	#rem
	bbdoc: Draw a Layer of the quadtree
	about: This can be used for debugging purposes. *Warning: This will be very slow if the quadtree has more then 6 or 7 levels!*
		#end
	Method Draw(canvas:Canvas, offsetx:Float = 0, offsety:Float = 0, Layer:Int)
		If Layer >= 0 And Layer < maxLayers
			rootnode[Layer].Draw(canvas, offsetx, offsety)
		Else
			Print "Can't draw quadtree, Layer spefied that doesn't exist"
		End If
	End

	Method CountAllObjects:Int()
		Local amount:int = 0
		For Local c:Int = 0 To rootnode.Length - 1
			amount += rootnode[c].CountObjects()
		Next

		Return amount
	End

	'Internal Stuff-----------------------------------
	Method UpdateRect(r:tlBox)
		'This is run automatically when a tlBox decides it needs to be moved within the quadtree
		'r.RemoveFromQuadTree()
		objectsupdated+=1
		restack.Add(r)
	End

	Method GetQuadNode:tlQuadTreeNode(x:Float, y:Float, Layer:Int)
		Local tx:Int = x / min_nodewidth
		Local ty:Int = y / min_nodeheight
		If tx >= 0 And tx < dimension And ty >= 0 And ty < dimension
			Return map[Layer*tx*ty]
		End If
		Return Null
	End

	Method GetUniqueNumber:Int()
		Return Rnd(-2147483647, 2147483647)
	End
End

#rem
bbdoc: tlQuadTreeNode Class for containing objects within the QuadTree
about: This Classis use internally by #tlQuadTree so you shouldn't have to worry about it.
#end
Class tlQuadTreeNode
	Field parenttree:tlQuadTree
	Field parent:tlQuadTreeNode
	'Node layout:
	'01
	'23
	Field childnode:=New tlQuadTreeNode[4]
	Field Box:tlBox
	Field objects:Stack<tlBox>
	Field numberofobjects:Int
	Field nodelevel:Int
	Field partitioned:Int
	Field gridx:Int
	Field gridy:Int
	Field dimension:Int
	Field Layer:Int
	
	'Internal Stuff------------------------------------
	'This whole type should be handled automatically by the quadtree it belongs to, so you don't have to worry about it.
	#rem
	bbdoc: Create a new tlQuadTreeNode
	about: This will create a new node within the quad tree. You shouldn't have to worry about this, as it's performed automatically as objects are
	added to the quadtree.
	#end
	Method New(x:Float, y:Float, w:Float, h:Float, _parenttree:tlQuadTree, _Layer:Int, parentnode:tlQuadTreeNode = Null, gridref:Int = -1)
		Box = New tlBox(x, y, w, h)
		parenttree = _parenttree
		Layer = _Layer
		If parentnode
			nodelevel = parentnode.nodelevel + 1
			parent = parentnode
		Else
			nodelevel = 1
		End If
		objects = New Stack<tlBox>
		If parentnode
			dimension = parentnode.dimension / 2
			Select gridref
				Case 0
					gridx = parentnode.gridx
					gridy = parentnode.gridy
				Case 1
					gridx = parentnode.gridx + dimension
					gridy = parentnode.gridy
				Case 2
					gridx = parentnode.gridx
					gridy = parentnode.gridy + dimension
				Case 3
					gridx = parentnode.gridx + dimension
					gridy = parentnode.gridy + dimension
			End Select
			For Local c:Int = 0 To parenttree.maxLayers - 1
				For Local x:Int = 0 To dimension - 1
					For Local y:Int = 0 To dimension - 1
						parenttree.map[(x + gridx) + parenttree.dimension * ((y + gridy) + parenttree.dimension * c)] = Self
					Next
				Next
			Next
		End If
	End

	Method CountObjects:Int()
		Local amount:Int = 0
		amount += objects.Length
		If (partitioned)
			For Local c:Int = 0 to 3
				amount += childnode[c].CountObjects()
			Next
		End
		Return amount
	End
	
	Method Partition()
		'When this quadtreenode contains more objects then parenttree.maxpernode it is partitioned
		childnode[0] = New tlQuadTreeNode(Box.tl_corner.x, Box.tl_corner.y, Box.Width / 2, Box.Height / 2, parenttree, Layer, Self, 0)
		childnode[1] = New tlQuadTreeNode(Box.tl_corner.x + Box.Width / 2, Box.tl_corner.y, Box.Width / 2, Box.Height / 2, parenttree, Layer, Self, 1)
		childnode[2] = New tlQuadTreeNode(Box.tl_corner.x, Box.tl_corner.y + Box.Height / 2, Box.Width / 2, Box.Height / 2, parenttree, Layer, Self, 2)
		childnode[3] = New tlQuadTreeNode(Box.tl_corner.x + Box.Width / 2, Box.tl_corner.y + Box.Height / 2, Box.Width / 2, Box.Height / 2, parenttree, Layer, Self, 3)
		partitioned = True
	End
	
	Method AddBox(r:tlBox)
		'Adds a new bounding box to the node, and partitions/moves objects down the tree as necessary.
		If partitioned
			MoveRectDown(r)
		Else
			objects.Add(r)
			numberofobjects+=1
			r.AddQuad(Self)
			If nodelevel < parenttree.Layerconfigs[Layer*MAX_NODE_LEVELS] And numberofobjects + 1 > parenttree.Layerconfigs[Layer*MAX_PER_NODE]
				If Not partitioned Partition()
				local rects:=objects.All()
				local box:tlBox
				while not rects.AtEnd
					box = rects.Current
					box.RemoveQuad(self)
					numberofobjects-=1
					MoveRectDown(box)
					rects.Erase()
				End
			End If
		End If
	End
	
	Method RemoveRect(r:tlBox, listRemove:Int = true)
		'Mark the Box for removal
		r.remove = true
		numberofobjects-=1
	End
	
	Method MoveRectDown(r:tlBox)
		'moves a bounding box down the quadtree to any children it overlaps
		If childnode[0].Box.BoundingBoxOverlap(r) childnode[0].AddBox(r)
		If childnode[1].Box.BoundingBoxOverlap(r) childnode[1].AddBox(r)
		If childnode[2].Box.BoundingBoxOverlap(r) childnode[2].AddBox(r)
		If childnode[3].Box.BoundingBoxOverlap(r) childnode[3].AddBox(r)
	End
	
	Method ForEachInAreaDo(area:tlBox, Data:Object, onFoundObject:tlQuadTreeEvent, velocitycheck:Int)
		'run a callback on objects found within the nodes that the area overlaps
		Local checkindex:Int = parenttree.areacheckindex
		If Box.BoundingBoxOverlap(area, velocitycheck)
			If partitioned
				If Not objects.Empty
					local rects:=objects.All()
					local r:tlBox
					While not rects.AtEnd
						r = rects.Current
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And r <> area
							If r.BoundingBoxOverlap(area, True)
								onFoundObject.doAction(r, Data)
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
						End If
						if r.remove
							r.remove = False
							rects.Erase()
						Else
							rects.Bump()
						End If
					Wend
				End If
				childnode[0].ForEachInAreaDo(area, Data, onFoundObject, velocitycheck)
				childnode[1].ForEachInAreaDo(area, Data, onFoundObject, velocitycheck)
				childnode[2].ForEachInAreaDo(area, Data, onFoundObject, velocitycheck)
				childnode[3].ForEachInAreaDo(area, Data, onFoundObject, velocitycheck)
			Else
				If Not objects.Empty
					local rects:=objects.All()
					local r:tlBox
					While not rects.AtEnd
						r = rects.Current
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And r <> area
							If r.BoundingBoxOverlap(area, True)
								onFoundObject.doAction(r, Data)
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
						End If
						if r.remove
							r.remove = False
							rects.Erase()
						Else
							rects.Bump()
						End If
					Wend
				End If
			End If
		End If
	End
	
	Method GetEachInArea:Stack<tlBox>(area:tlBox, velocitycheck:Int, list:Stack<tlBox>, GetData:Int)
		'run a callback on objects found within the nodes that the area overlaps
		Local checkindex:Int = parenttree.areacheckindex
		If Box.BoundingBoxOverlap(area, velocitycheck)
			If partitioned
				If Not objects.Empty
					Local last:Object = objects.Top
					For Local r:tlBox = EachIn objects
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And r <> area
							If r.BoundingBoxOverlap(area, True)
								Select GetData
									Case True
										list.Add(r)
									Case False
										list.Add(r)
								End Select
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
							If last = r Exit
						End If
					Next
				End If
				list = childnode[0].GetEachInArea(area, velocitycheck, list, GetData)
				list = childnode[1].GetEachInArea(area, velocitycheck, list, GetData)
				list = childnode[2].GetEachInArea(area, velocitycheck, list, GetData)
				list = childnode[3].GetEachInArea(area, velocitycheck, list, GetData)
			Else
				If Not objects.Empty
					Local last:Object = objects.Top
					For Local r:tlBox = EachIn objects
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And r <> area
							If r.BoundingBoxOverlap(area, True)
								Select GetData
									Case True
										list.Add(r)
									Case False
										list.Add(r)
								End Select
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
							If last = r Exit
						End If
					Next
				End If
			End If
		End If
		Return list
	End
	
	Method ForEachWithinRangeDo(Range:tlCircle, Data:Object, onFoundObject:tlQuadTreeEvent)
		'run a callback on objects found within the nodes that the circle overlaps
		Local checkindex:Int = parenttree.areacheckindex
		If Box.CircleOverlap(Range)
			If partitioned
				If Not objects.Empty
					local rects:=objects.All()
					local r:tlBox
					While not rects.AtEnd
						r = rects.Current
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And r <> Range
							If r.CircleOverlap(Range)
								onFoundObject.doAction(r, Data)
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
						End If
						if r.remove
							r.remove = False
							rects.Erase()
						Else
							rects.Bump()
						End If
					Wend
				End If
				childnode[0].ForEachWithinRangeDo(Range, Data, onFoundObject)
				childnode[1].ForEachWithinRangeDo(Range, Data, onFoundObject)
				childnode[2].ForEachWithinRangeDo(Range, Data, onFoundObject)
				childnode[3].ForEachWithinRangeDo(Range, Data, onFoundObject)
			Else
				If Not objects.Empty
					local rects:=objects.All()
					local r:tlBox
					While not rects.AtEnd
						r = rects.Current
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And r <> Range
							If r.CircleOverlap(Range)
								onFoundObject.doAction(r, Data)
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
						End If
						if r.remove
							r.remove = False
							rects.Erase()
						Else
							rects.Bump()
						End If
					Wend
				End If
			End If
		End If
	End
	
	Method GetEachInRange:Stack<Object>(Range:tlCircle, velocitycheck:Int, list:Stack<Object>, GetData:Int, Limit:Int)
		'run a callback on objects found within the nodes that the circle overlaps
		Local checkindex:Int = parenttree.areacheckindex
		If Limit > 0 And parenttree.objectsfound >= Limit
			Return list
		End If
		If Box.CircleOverlap(Range)
			If partitioned
				If Not objects.Empty
					Local last:Object = objects.Top
					For Local r:tlBox = EachIn objects
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And Range <> r
							If Range.BoundingBoxOverlap(r, True)
								Select GetData
									Case True
										list.Add(r.Data)
									Case False
										list.Add(r)
								End Select
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
							If Limit > 0 And parenttree.objectsfound >= Limit
								Return list
							End If
						End If
						If last = r Exit
					Next
				End If
				list = childnode[0].GetEachInRange(Range, velocitycheck, list, GetData, Limit)
				list = childnode[1].GetEachInRange(Range, velocitycheck, list, GetData, Limit)
				list = childnode[2].GetEachInRange(Range, velocitycheck, list, GetData, Limit)
				list = childnode[3].GetEachInRange(Range, velocitycheck, list, GetData, Limit)
			Else
				If Not objects.Empty
					Local last:Object = objects.Top
					For Local r:tlBox = EachIn objects
						If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And Range <> r
							If Range.BoundingBoxOverlap(r, True)
								Select GetData
									Case True
										list.Add(r.Data)
									Case False
										list.Add(r)
								End Select
							End If
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
							If Limit > 0 And parenttree.objectsfound >= Limit
								Return list
							End If
						End If
						If last = r Exit
					Next
				End If
			End If
		End If
		Return list
	End
	
	Method ForEachObjectAlongLine(Line:tlLine, Data:Object, onFoundObject:tlQuadTreeEvent)
		Local result:tlCollisionResult
		Local checkindex:Int = parenttree.areacheckindex
		if not objects.Empty
			local rects:=objects.All()
			local r:tlBox
			While not rects.AtEnd
				r = rects.Current
				If r.AreaCheckCount[checkindex] <> parenttree.AreaCheckCount[checkindex] And Line <> r
					result = r.LineCollide(Line)
					If not result.NoCollision
						If result.Intersecting Or result.WillIntersect
							onFoundObject.doAction(r, Data, result)
							r.AreaCheckCount[checkindex] = parenttree.AreaCheckCount[checkindex]
							parenttree.objectsfound+=1
							parenttree.objectsprocessed+=1
						End If
					End If
				End If
				if r.remove
					r.remove = False
					rects.Erase()
				Else
					rects.Bump()
				End If
			wend
		End
	End
	
	Method RayCast:Int(px:Float, py:Float, dx:Float, dy:Float, maxdistance:Int, Data:Object, onFoundObject:tlQuadTreeEvent)
		
		Local result:tlCollisionResult
		Local nearestobject:tlBox
		Local nearestresult:tlCollisionResult
		Local mindistance:Float = $7fffffff
		
		if not objects.Empty
			local rects:=objects.All()
			local r:tlBox
			While not rects.AtEnd
				r = rects.Current
				result = r.RayCollide(px, py, dx, dy, maxdistance)
				If result.RayOriginInside
					mindistance = result.RayDistance
					nearestresult = result
					nearestobject = r
					Exit
				End If
				If result.RayDistance < mindistance And result.HasIntersection
					mindistance = result.RayDistance
					nearestresult = result
					nearestobject = r
				End If
				if r.remove
					r.remove = False
					rects.Erase()
				Else
					rects.Bump()
				End If
			Wend
		End If
		
		If nearestobject
			onFoundObject.doAction(nearestobject, Data, nearestresult)
			Return True
		End If
		
		Return False
		
	End
	
	Method UnpartitionEmptyQuads()
		'This is run when RunMaintenance is run in the quadtree type.
		If partitioned
			If childnode[0] childnode[0].UnpartitionEmptyQuads()
			If childnode[1] childnode[1].UnpartitionEmptyQuads()
			If childnode[2] childnode[2].UnpartitionEmptyQuads()
			If childnode[3] childnode[3].UnpartitionEmptyQuads()
		Else
			If parent parent.DeleteEmptyPartitions()
		End If
	End
	
	Method DeleteEmptyPartitions()
		'deletes the partitions from this node
		If childnode[0].numberofobjects + childnode[1].numberofobjects + childnode[2].numberofobjects + childnode[3].numberofobjects = 0
			If Not childnode[0].partitioned And Not childnode[1].partitioned And Not childnode[2].partitioned And Not childnode[3].partitioned
				partitioned = False
				childnode[0] = Null
				childnode[1] = Null
				childnode[2] = Null
				childnode[3] = Null
			End If
		End If
	End
	
	Method Draw(canvas:Canvas, offsetx:Float = 0, offsety:Float = 0)
		'called when the draw method is called in tlQuadTreeNode
		Box.Draw(canvas, offsetx, offsety)
		If partitioned
			childnode[0].Draw(canvas, offsetx, offsety)
			childnode[1].Draw(canvas, offsetx, offsety)
			childnode[2].Draw(canvas, offsetx, offsety)
			childnode[3].Draw(canvas, offsetx, offsety)
		End If
	End

	Method ToString:string()
		return gridx + ", " + gridy
	End
End