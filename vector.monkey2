#rem
	Copyright (c) 2012 Peter J Rigby
	
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

#end

Namespace timelinefx.vector

Struct tlVector2
	
	Public
	
	Field x:Float
	Field y:Float
	Field invalid:Int

	Method New(x:Float = 0, y:Float = 0, invalid:int = false)
		self.x = x
		self.y = y
		self.invalid = invalid
	End

	Property Invalid:int()
		return invalid
	End
	
	Method Clone:tlVector2()
		Return New tlVector2(x, y)
	End
	
	Method Move(distance_x:Float, distance_y:Float)
		x += distance_x
		y += distance_y
	End
	
	Method MoveByVector(distance:tlVector2)
		x += distance.x
		y += distance.y
	End

	Method SetPosition(x:Float, y:Float)
		self.x = x
		self.y = y
	End

	Method Zero()
		x = 0
		y = 0
	End

	Method SetPositionByVector(v:tlVector2)
		x = v.x
		y = v.y
	End

	Method SubtractVector:tlVector2(v:tlVector2)
		Return New tlVector2(x - v.x, y - v.y)
	End
	
   Operator-:tlVector2( v:tlVector2 )
      Return New tlVector2( x - v.x,y - v.y )
   End

	Method AddVector:tlVector2(v:tlVector2)
		Return New tlVector2(x + v.x, y + v.y)
	End
	
   Operator+:tlVector2( v:tlVector2 )
      Return New tlVector2( x + v.x, y + v.y )
   End

	Method AddVectorSelf(v:tlVector2)
		x += v.x
		y += v.y
	End

	Method SubtractVectorSelf(v:tlVector2)
		x -= v.x
		y -= v.y
	End

	Method Multiply:tlVector2(v:tlVector2)
		Return New tlVector2(x * v.x, y * v.y)
	End

	Method Divide:tlVector2(factor:Float)
		Return New tlVector2(x / factor, y / factor)
	End

	Method Scale:tlVector2(scale:Float)
		Return New tlVector2(x * scale, y * scale)
	End

	Method ScaleSelf(scale:Float)
		x *= scale
		y *= scale
	End

	Method Limit(limit:Float)
		Local l:Float = Length()
		If l > limit
			Normalise()
			x *= limit
			y *= limit
		End If
	End

	Method Mirror:tlVector2()
		Return New tlVector2(-x, -y)
	End

	Method Length:Float()
		Return Sqrt(x * x + y * y)
	End

	Method HasLength:Int()
		Return x > 0 And y > 0
	End

	Method Unit:tlVector2()
		Local length:Float = Length()
		Local v:tlVector2 = Clone()
		If length
			v.x = x / length
			v.y = y / length
		End If
		Return v
	End

	Method Normal:tlVector2()
		Return New tlVector2(-y, x)
	End
	
	Method LeftNormal:tlVector2()
		Return New tlVector2(y, -x)
	End

	Method Normalise()
		Local length:Float = Length()
		If length
			x /= length
			y /= length
		End If
	End

	Method NormaliseTo(v:Float = 1)
		Local length:Float = Length()
		If length
			x /= (length * v)
			y /= (length * v)
		End If
	End

	Method DotProduct:Float(v:tlVector2)
		Return x * v.x + y * v.y
	End

	Method Angle:Float()
		Return (ATan2(y, x) + 450) Mod 360
	End
	
	Method toString:String()
		Return x + ", " + y
	End
	
End
