#rem
	Copyright (c) 2016 Peter J Rigby
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.

#END

Const tlCAPTURE_SELF:Int = 0
Const tlCAPTURE_ALL:Int = 1
Const tlCAPTURE_NONE:Int = 2

Class tlGameObject
	
	Private
	
	Field name:string
	
	'vectors
	Field local_vec:tlVector2
	Field world_vec:tlVector2
	Field tiedvector:tlVector2
	
	Field scale_vec:tlVector2
	Field world_scale_vec:tlVector2
	
	Field zoom:Float = 1
	
	'matrices
	Field matrix:tlMatrix2				'A matrix to calculate entity rotation relative to the parent
	Field scale_matrix:tlMatrix2
	
	'colour
	Field red:Float = 1
	Field green:Float = 1
	Field blue:Float = 1
	Field alpha:Float = 1
	
	'image
	Field image:tlShape
	Field currentframe:Float
	
	'Field currentanimseq:tlAnimationSequence
	Field framerate:Float
	Field animating:Int
	Field handle_vec:tlVector2
	Field autocenter:Int = True
	Field local_rotation:Float
	Field world_rotation:Float
	Field frames:Int
	Field iterations:Int
	Field iterationcount:Int
	Field blendmode:BlendMode
	Field donotrender:Int

	'hierarchy
	Field parent:tlGameObject
	Field rootparent:tlGameObject
	Field children:Stack<tlGameObject>
	Field childcount:Int
	Field runchildren:Int
	Field relative:Int = True
	Field attached:Int
	Field rotate_vec:tlVector2 			'Vector formed between the parent and the children
	
	'tween values
	Field oldworld_vec:tlVector2
	Field oldworldscale_vec:tlVector2
	Field oldlocal_rotation:Float
	Field oldworld_rotation:Float
	Field oldcurrentframe:Float
	Field updatetime:Float = 30
	Field oldzoom:Float
	Field capturemode:Float
	
	'collision
	Field imagebox:tlBox
	Field imageboxtype:Int = tlBOX_COLLISION
	Field collisionbox:tlBox
	Field collisionboxtype:Int = tlBOX_COLLISION
	Field containingbox:tlBox
	Field rendercollisionbox:Int = False
	Field listenlayers:Int[]
	Field isstatic:Int
	Field maxtlx:Float = $7fffffff
	Field maxtly:Float = $7fffffff
	Field maxbrx:Float = -$7fffffff
	Field maxbry:Float = -$7fffffff
	Field updatecontainingbox:Int

	
	'Age and status flags
	Field dob:Float
	Field age:Float
	Field dead:Int
	Field dying:Int
	Field destroyed:Int
	
	'components
	Field components:Stack<tlComponent> = New Stack<tlComponent>
	Field components_map:StringMap<tlComponent>
	
	Public
	
	'properties
	Property IsDestroyed:Int() 
		Return destroyed
	End
	
	Property Dying:Int() 
		Return dying
	Setter (v:Int)
		dying = v
	End
	
	Property Dead:Int() 
		Return dead
	Setter(v:Int)
		dead = v
	End
	
	Property DoB:Int() 
		Return dob
	Setter(v:Int)
		dob = v
	End
	
	Property Destroyed:Int() 
		Return destroyed
	Setter(v:Int)
		destroyed = v
	End
	
	Property RenderCollisionBox:Bool() 
		Return rendercollisionbox
	Setter(v:Bool)
		rendercollisionbox = v
	End
	
	Property Name:String() 
		Return name
	Setter(v:String)
		name = v
	End
	
	Property Zoom:Float() 
		Return zoom
	Setter(v:float)
		zoom = v
	End
	
	Property OldZoom:Float() 
		Return oldzoom
	Setter(v:float)
		oldzoom = v
	End
	
	Property Matrix:tlMatrix2() 
		Return matrix
	Setter(v:tlMatrix2)
		matrix = v
	End
	
	Property ScaleMatrix:tlMatrix2() 
		Return scale_matrix
	End
	
	Property LocalVector:tlVector2() 
		Return local_vec
	End
	
	Property WorldVector:tlVector2() 
		Return world_vec
	End
	
	Property OldWorldVector:tlVector2() 
		Return oldworld_vec
	End
	
	Property ScaleVector:tlVector2() 
		Return scale_vec
	End
	
	Property WorldScaleVector:tlVector2() 
		Return world_scale_vec
	End
	
	Property OldWorldScaleVector:tlVector2() 
		Return oldworldscale_vec
	End
	
	Property HandleVector:tlVector2() 
		Return handle_vec
	Setter(v:tlVector2)
		handle_vec = v
	End
	
	Property LocalRotation:Float() 
		Return local_rotation
	Setter(v:Float)
		local_rotation = v
	End
	
	Property Angle:Float() 
		Return local_rotation
	Setter(v:Float)
		local_rotation = v
	End
	
	Property WorldRotation:Float() 
		Return world_rotation
	Setter(v:Float)
		world_rotation = v
	End
	
	Property OldLocalRotation:Float() 
		Return oldlocal_rotation
	Setter(v:Float)
		oldlocal_rotation = v
	End
	
	Property OldWorldRotation:Float() 
		Return oldworld_rotation
	Setter(v:Float)
		oldworld_rotation = v
	End
	
	Property RotateVector:tlVector2() 
		Return rotate_vec
	Setter(v:tlVector2)
		rotate_vec = v
	End
	
	Property DoNotRender:Int() 
		Return donotrender
	Setter(v:Int)
		donotrender = v
	End
	
	Property UpdateContainerBox:Int() 
		Return updatecontainingbox
	Setter(v:Int)
		updatecontainingbox = v
	End
	
	Property Components:Stack<tlComponent>() 
		Return components
	End
	
	Property ImageBox:tlBox() 
		Return imagebox
	Setter(v:tlBox)
		imagebox = v
	End
	
	Property ContainingBox:tlBox() 
		Return containingbox
	Setter(v:tlBox)
		containingbox = v
	End
	
	Property Age:Int() 
		Return age
	Setter (v:Int)
		age = v
	End
	
	Property AutoCenter:Int() 
		Return autocenter
	Setter(v:Int)
		autocenter = v
	End
	
	Property BlendMode:BlendMode()
		Return blendmode
	Setter(v:BlendMode)
		blendmode = v
	End
	
	Property Red:Float() 
		Return red
	Setter(v:Float)
		red = v
	End
	
	Property Green:Float() 
		Return green
	Setter(v:Float)
		green = v
	End
	
	Property Blue:Float() 
		Return blue
	Setter(v:Float)
		blue = v
	End
	
	Property Alpha:Float() 
		Return alpha
	Setter (v:Float)
		alpha = v
	End
	
	Property Image:tlShape() 
		Return image
	Setter(v:tlShape)
		image = v
	End
	
	Property Frames:Int() 
		Return frames
	Setter(v:Int)
		frames = v
	End
	
	Property FrameRate:Float() 
		Return framerate
	Setter(v:Float)
		framerate = v
	End
	
	Property UpdateTime:Float() 
		Return updatetime
	Setter(v:Float)
		updatetime = v
	End
	
	Property Animating:Int() 
		Return animating
	Setter(v:Int)
		animating = v
	End
	
	Property CurrentFrame:Float() 
		Return currentframe
	Setter(v:Float)
		currentframe = v
	End
	
	Property OldCurrentFrame:Float() 
		Return oldcurrentframe
	Setter(v:Float)
		oldcurrentframe = v
	End
	
	Property Relative:Int() 
		Return relative
	Setter(v:Int)
		relative = v
	End
	
	Property Parent:tlGameObject() 
		Return parent
	Setter(v:tlGameObject)
		parent = v
	End
	
	Property RootParent:tlGameObject() 
		Return rootparent
	Setter(v:tlGameObject)
		rootparent = v
	End
	
	Property ChildCount:Int() 
		Return childcount
	Setter(v:Int)
		childcount = v
	End
	
	'methods
	Method New()
		local_vec = New tlVector2(0, 0)
		world_vec = New tlVector2(0, 0)
		
		oldworld_vec = New tlVector2(0, 0)
		oldworldscale_vec = New tlVector2(0, 0)
		
		scale_vec = New tlVector2(1, 1)
		world_scale_vec = New tlVector2(1, 1)
		
		handle_vec = New tlVector2(0, 0)
		
		children = New Stack<tlGameObject>

		tiedvector = New tlVector2(0, 0, true)
		
		'matrices
		matrix = New tlMatrix2
		scale_matrix = New tlMatrix2
		
		'compoents
		'components = New List<tlComponent>
		
		Capture()
		
	End
	
	'setters
	
	Method SetHandle(x:Int, y:Int)
		handle_vec = New tlVector2(x, y)
	End
	
	Method SetImage(image:tlShape, collisiontype:Int = tlBOX_COLLISION, layer:Int = 0)
		Self.image = image
		frames = Self.image.Frames
		Select collisiontype
			Case tlPOLY_COLLISION
				SetImagePoly(GetWorldX(), GetWorldX(),New Float[](Float(-Self.image.Width) / 2, Float(-Self.image.Height) / 2,
					Float(-Self.image.Width) / 2, Float(Self.image.Height) / 2,
					Float(Self.image.Width) / 2, Float(Self.image.Height) / 2,
					Float(Self.image.Width) / 2, Float(-Self.image.Height) / 2), layer)
			Case tlCIRCLE_COLLISION
				SetImageCircle(GetWorldX(), GetWorldX(), Max(Self.image.Width / 2, Self.image.Height / 2), layer)
			Default
				SetImageBox(GetWorldX(), GetWorldX(), Self.image.Width, Self.image.Height, layer)
		End Select
	End
	
	Method SetImageBox(x:Float, y:Float, w:Float, h:Float, layer:Int = 0)
		imagebox = CreateBox(x, y, w, h, layer)
		imagebox.Data = Self
		imageboxtype = tlBOX_COLLISION
	End

	Method SetImageCircle(x:Float, y:Float, r:Float, layer:Int = 0)
		imagebox = CreateCircle(x, y, r, layer)
		imagebox.Data = Self
		imageboxtype = tlCIRCLE_COLLISION
	End

	Method SetImagePoly(x:Float, y:Float, verts:Float[], layer:Int = 0)
		imagebox = CreatePolygon(x, y, verts, layer)
		imagebox.Data = Self
		imageboxtype = tlPOLY_COLLISION
	End
	
	Method SetPosition(x:Float, y:Float)
		local_vec = New tlVector2(x, y)
	End

	Method SetPositionVector(position:tlVector2)
		local_vec = New tlVector2(position.x, position.y)
	End
	
	Method Move(x:Float, y:Float)
		local_vec = local_vec.Move(x, y)
	End
	
	Method MoveVector(v:tlVector2)
		local_vec = local_vec.Move(v.x, v.y)
	End
	
	Method TieToVector(vector:tlVector2)
		tiedvector = vector
	End
	
	Method UnTie()
		tiedvector.Invalid = True
	End
	
	Method SetScale(x:Float, y:Float)
		scale_vec = New tlVector2(x, y)
	End

	Method SetScale( v:Float )
		scale_vec = New tlVector2(v, v)
	End

	Method Rotate(v:float)
		local_rotation += v
	End

	'getters

	Method GetWorldX:Float()
		Return world_vec.x
	End

	Method GetWorldY:Float()
		Return world_vec.y
	End
	
	Method Capture()
		oldworld_vec.x = world_vec.x
		oldworld_vec.y = world_vec.y
		oldworldscale_vec.x = world_scale_vec.x
		oldworldscale_vec.y = world_scale_vec.y
		oldworld_rotation = world_rotation
		oldlocal_rotation = local_rotation
		oldcurrentframe = currentframe
		oldzoom = zoom
	End
	
	Method CaptureAll()
		Capture()
		For Local o:tlGameObject = EachIn children
			o.CaptureAll()
		Next
	End
	
	Method AddChild(o:tlGameObject)
		If o.parent
			o.parent.RemoveChild(o)
		End If
		children.Add(o)
		o.parent = Self
		o.AssignRootParent(o)
		o.attached = False
'		If Not _containingbox
'			_containingbox = CreateBox(0, 0, 1, 1)
'			_containingbox._data = Self
'			AssignMainBox()
'		End If
		childcount += 1
	End
	
	Method AttachChild(o:tlGameObject)
		If o.parent
			o.parent.RemoveChild(o)
		End If
		children.Add(o)
		o.parent = Self
		o.AssignRootParent(o)
		o.attached = True
		childcount += 1
	End
	
	Method RemoveChild(o:tlGameObject)
		children.Remove(o)
		o.parent = Null
		o.rootparent = Null
		o.attached = False
		childcount -= 1
'		If Not childcount
'			containingbox = Null
'			AssignMainBox()
'		End If
	End
	
	Method Detatch()
		If parent parent.RemoveChild(Self)
	End
	
	Method ClearChildren()
		For Local o:tlGameObject = EachIn children
			o.Destroy()
		Next
		children.Clear()
		childcount = 0
	End
	
	Method GetChildCount:Int()
		Return childcount
	End

	Method GetChildren:Stack<tlGameObject>()
		Return children
	End
	
	Method KillChildren()
		For Local o:tlGameObject = EachIn children
			o.KillChildren()
			o.dead = True
		Next
	End
	
	Method Destroy()
		'debugstop
		parent = Null
		image = Null
		rootparent = Null
		If imagebox
			'imagebox.RemoveFromQuadTree()
			imagebox.Data = Null
			imagebox = Null
		End If
		If collisionbox
			'collisionbox.RemoveFromQuadTree()
			collisionbox.Data = Null
			collisionbox = Null
		End If
		If containingbox
			'containingbox.RemoveFromQuadTree()
			containingbox.Data = Null
			containingbox = Null
		End If
		For Local o:tlGameObject = EachIn children
			o.Destroy()
		Next
		If components
			For Local component:tlComponent = EachIn components
				component.Destroy()
			Next
		End If
		destroyed = True
	End
	
	Method AddComponent(component:tlComponent, last:Int = True)
		component.parent = Self
		If Not components components = New Stack<tlComponent>
		If Not components_map components_map = New StringMap<tlComponent>
		If last
			components.Add(component)
		Else
			components.Insert(0, component)
		End If
		components_map.Add(component.name.ToUpper(), component)
		component.Init()
	End
	
	Method GetComponent:tlComponent(name:String)
		Return Cast<tlComponent>(components_map.Get(name.ToUpper()))
	End
	
	Method Update()
	
		Select capturemode
			Case tlCAPTURE_SELF
				Capture()
			Case tlCAPTURE_ALL
				'capture all including children
				CaptureAll()
		End Select
						
		'update components
		UpdateComponents()
		
		If Not tiedvector.Invalid
			local_vec = local_vec.SetPositionByVector(tiedvector)
		EndIf
		
		'transform the object
		TForm()

		'update the children		
		UpdateChildren()
		
		'update the collision boxes
		If collisionbox UpdateCollisionBox()
		
		UpdateImageBox()
		
		If parent
			If containingbox
				parent.UpdateContainingBox(containingbox.tl_corner.x, containingbox.tl_corner.y, containingbox.br_corner.x, containingbox.br_corner.y)
			Else
				parent.UpdateContainingBox(imagebox.tl_corner.x, imagebox.tl_corner.y, imagebox.br_corner.x, imagebox.br_corner.y)
			End If
		End If
		If UpdateContainerBox ReSizeContainingBox()
		
		'animate the image
		Animate()
		
	End
	
	Method Render(canvas:Canvas, tween:Float, origin:tlVector2 = New tlVector2, renderchildren:Int = True, screenbox:tlBox = Null)
		If image And Not donotrender
			If screenbox And imagebox
				If containingbox
					If Not screenbox.BoundingBoxOverlap(containingbox) Return
					Else
						If Not screenbox.BoundingBoxOverlap(imagebox) Return
				End If
			End If
			If autocenter
				Image.GetImage(currentframe).Handle = New Vec2f( 0.5, 0.5)
			Else
				Image.GetImage(currentframe).Handle = New Vec2f(handle_vec.x, handle_vec.y)
			End If
			canvas.BlendMode = blendmode
			Local tv:Float
			If Abs(oldworld_rotation - world_rotation) > 180
				tv = TweenValues(Abs(oldworld_rotation - 360), world_rotation, tween)
			Else
				tv = oldworld_rotation + (world_rotation - oldworld_rotation) * tween
			End If
			local rv:float = tv
			Local tx:Float = oldworldscale_vec.x + (world_scale_vec.x - oldworldscale_vec.x) * tween
			Local ty:Float = oldworldscale_vec.y + (world_scale_vec.y - oldworldscale_vec.y) * tween
			tv = oldzoom + (zoom - oldzoom) * tween
			If tv <> 1
				tx *= tv
				ty *= tv
			End If
			canvas.Color = New Color(red, green, blue, alpha)
			tv = currentframe
			canvas.DrawImage (Image.GetImage(tv), (oldworld_vec.x + (world_vec.x - oldworld_vec.x) * tween) - origin.x, (oldworld_vec.y + (world_vec.y - oldworld_vec.y) * tween) - origin.y, rv, tx, ty)
			If rendercollisionbox
				canvas.Scale (1, 1)
				canvas.Rotate (0)
				canvas.Color = New Color(1, 0, 1, 0.5)
				If collisionbox collisionbox.Draw(canvas, origin.x, origin.y, False)
				If containingbox
					containingbox.Draw(canvas, origin.x, origin.y, False)
				End If
			End If
		End If
		If renderchildren
			For Local o:tlGameObject = EachIn children
				o.Render(canvas, tween, origin,, screenbox)
			Next
		End If
	End
	
	Method Animate()
		'update animation frame
'		If currentanimseq And _animating
			currentframe += framerate / updatetime
			if currentframe >= image.Frames
				currentframe = 0
			End if
'		End If
	End
	
	Method UpdateImageBox()
		If Not isstatic And imagebox
			imagebox.Position(world_vec.x, world_vec.y)
			If oldworldscale_vec.x <> world_scale_vec.x Or oldworldscale_vec.y <> world_scale_vec.y Or oldzoom <> zoom
				If zoom = 1
					imagebox.SetScale(world_scale_vec.x, world_scale_vec.y)
				Else
					imagebox.SetScale(world_scale_vec.x * zoom, world_scale_vec.y * zoom)
				End If
			End If
			If imageboxtype = tlPOLY_COLLISION
				Cast<tlPolygon>(imagebox).SetAngle(world_rotation)
			End If
			'imagebox.UpdateWithinQuadtree()
		End If
	End
	
	Method UpdateCollisionBox()
		If Not isstatic
			collisionbox.Position(world_vec.x, world_vec.y)
			If oldworldscale_vec.x <> world_scale_vec.x Or oldworldscale_vec.y <> world_scale_vec.y Or oldzoom <> zoom
				If zoom = 1
					collisionbox.SetScale(world_scale_vec.x, world_scale_vec.y)
				Else
					collisionbox.SetScale(world_scale_vec.x * zoom, world_scale_vec.y * zoom)
				End If
			End If
			If collisionboxtype = tlPOLY_COLLISION
				Cast<tlPolygon>(collisionbox).SetAngle(world_rotation)
			End If
			'collisionbox.UpdateWithinQuadtree()
		End If
	End
	
	Method UpdateContainingBox(MaxTLX:Float, MaxTLY:Float, MaxBRX:Float, MaxBRY:Float)
		If containingbox
			maxtlx = Min(maxtlx, MaxTLX)
			maxtly = Min(maxtly, MaxTLY)
			maxbrx = Max(maxbrx, MaxBRX)
			maxbry = Max(maxbry, MaxBRY)
			updatecontainingbox = True
		End If
	End
	
	Method ReSizeContainingBox()
		If Not containingbox Return
		
		If imagebox
			maxtlx = Min(maxtlx, imagebox.tl_corner.x)
			maxtly = Min(maxtly, imagebox.tl_corner.y)
			maxbrx = Max(maxbrx, imagebox.br_corner.x)
			maxbry = Max(maxbry, imagebox.br_corner.y)
		End If
		
		Local width:Float = maxbrx - maxtlx
		Local height:Float = maxbry - maxtly
		
		containingbox.ReDimension(maxbrx - width, maxbry - height, width, height)
		'containingbox.UpdateWithinQuadtree()
		updatecontainingbox = False
		
		maxtlx = $7fffffff
		maxtly = $7fffffff
		maxbrx = -$7fffffff
		maxbry = -$7fffffff
	End
	
	Method AssignRootParent(o:tlGameObject)
		If parent
			parent.AssignRootParent(o)
		Else
			o.rootparent = Self
		End If
	End
	
	Method TForm()
		'set the matrix if it is relative to the parent
		If relative
			matrix.Set(Cos(local_rotation), Sin(local_rotation), -Sin(local_rotation), Cos(local_rotation))
		End If
		
		'calculate where the entity is in the world
		If parent And relative And Not attached
			zoom = parent.zoom
			matrix = matrix.Transform(parent.matrix)
			rotate_vec = parent.matrix.TransformVector(local_vec.Multiply(parent.world_scale_vec))
			If zoom = 1
				world_vec = world_vec.SetPositionByVector(parent.world_vec.AddVector(rotate_vec))
			Else
				world_vec = world_vec.SetPositionByVector(parent.world_vec.AddVector(rotate_vec.Scale(zoom)))
			End If
			world_rotation = parent.world_rotation + local_rotation
			world_scale_vec = world_scale_vec.SetPositionByVector(scale_vec.Multiply(parent.world_scale_vec))
		ElseIf parent And attached
			world_rotation = local_rotation
			world_scale_vec = world_scale_vec.SetPositionByVector(scale_vec)
			world_vec = world_vec.SetPositionByVector(parent.world_vec)
		Else
			world_rotation = local_rotation
			world_scale_vec = world_scale_vec.SetPositionByVector(scale_vec)
			world_vec = world_vec.SetPositionByVector(local_vec)
		End If
	End
	
	Method UpdateChildren()
		For Local o:tlGameObject = EachIn children
			o.Update()
		Next
	End
	
	Method UpdateComponents()
		For Local c:tlComponent = EachIn components
			c.Update()
			If destroyed Return
		Next
	End


End

Class tlComponent Abstract
	'Private
	
	Field parent:tlGameObject
	Field name:String
	
	'Public
	
	Method New(name:String)
		Self.name = name
	End
	
	Property Name:String()
		Return name
	Setter(name:String) 
		Self.name = name
	End
	
	Method Update() Abstract
	
	#Rem
		Insert your Init code here. This is run when the component is added to a #tlGameObject
	#end 	
	Method Init()
		
	End
	
	Method Destroy()
		parent = Null
	End
	
	#Rem
	bbdocs: Get the parent of the component
	returns: #tlGameObject
	#end
	Method GetParent:tlGameObject()
		Return parent
	End
	
	Property Parent:tlGameObject() 
		Return parent
	Setter(v:tlGameObject)
		parent = v
	End
End