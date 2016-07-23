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

Namespace timelinefx

Class tlShape
	
	Private

	Field width:Int
	Field height:Int
	Field url:String
	Field frames:Int
	Field smallindex:Int
	Field largeindex:Int
	Field maxradius:Float
	Field name:String
	
	Public
	
	Field image:Image[]
	
	Property Url:String()
		Return url
	Setter (value:String)
		url = value
	End
	
	Property Name:String() 
		Return name
	Setter (value:String)
		name = value
	End
	
	Method GetImage:Image(frame:int)
		Return image[frame]
	End
	
	Property Width:Int()
		Return width
	Setter (value:Int)
		width = value
	End
	
	Property Height:Int()
		Return height
	Setter (value:Int)
		height = value
	End
	
	Property MaxRadius:Float()
		Return maxradius
	Setter (value:Float)
		maxradius = value
	End
	
	Property LargeIndex:Int()
		Return largeindex
	Setter (value:Int)
		largeindex = value
	End
	
	Property Frames:Int()
		Return frames
	Setter (value:Int)
		frames = value
	End
	
	Function LoadFrames:Image[] (path:String, numFrames:Int, cellWidth:Int, cellHeight:Int, padded:Bool = False, flags:TextureFlags = TextureFlags.Filter|TextureFlags.Mipmap, shader:Shader = Null)
	
		Local material:=Image.Load( path,flags|TextureFlags.Filter, shader )
		If Not material Return New Image[0]
		
		If cellWidth * cellHeight * numFrames > material.Width * material.Height Return New Image[0]
		
		Local frames:= New Image[numFrames]
		
		If cellHeight = material.Height
			Local x:=0
			local width:=cellWidth
			If padded 
				x += 1
				width -= 2
			End if

			For Local i:=0 Until numFrames
				local rect:= New Recti(i * cellWidth + x, 0, i * cellWidth + x + width, cellHeight)
				frames[i] = New Image(material, rect)
			Next
		Else
			Local x:= 0, width:= cellWidth, y:= 0, height:= cellHeight
			Local columns:= material.Width / width
			If padded
				x += 1
				y += 1
				width -= 2
				height -= 2
			End If
			
			For Local i:=0 Until numFrames
				Local fx:Int = i Mod columns * cellWidth
				Local fy:Int = i / columns * cellHeight

				local rect:= New Recti(fx + x, fy + y, fx + x + width, fy + y + height)
				frames[i] = New Image(material, rect)
			Next
		End If
		
		Return frames
		
	End

End

Function LoadShape:tlShape(url:String, width:Int, height:Int, frames:Int)
	Local shape:tlShape = New tlShape
	If frames = 1
		shape.image = New Image[1]
		shape.image[0] = Image.Load(url)
	Else
		shape.image = tlShape.LoadFrames(url, frames, width, height)
	EndIf

	shape.Width = width
	shape.Height = height
	shape.Frames = frames
	shape.Url = url
	
	Return shape

End