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

Namespace timelinefx.matrix

Using timelinefx.vector..

Class tlMatrix2
	
	Private

	Field aa:Float, ab:Float
	Field ba:Float, bb:Float
	
	Public
	
	#rem
		bbdoc: Create a new matrix
		returns: New matrix type
	#end
	Method New(aa:Float = 1, ab:Float = 0, ba:Float = 0, bb:Float = 1)
		Self.aa = aa
		Self.ab = ab
		Self.ba = ba
		Self.bb = bb
	End
	
	#rem
		bbdoc: Set the matrix to a new set of values
		about: Use this to prepare the matrix for a new transform. For example if you wanted to to rotate a vector, then you could do 
		&{<matrix.set(cos(angle),sin(angle),-sin(angle),cos(angle))}
		and then transform the vector with 
		&{matrix.transformvector(vector)}
	#end
	Method Set(_aa:Float = 1, _ab:Float = 0, _ba:Float = 0, _bb:Float = 1)
		aa = _aa
		ab = _ab
		ba = _ba
		bb = _bb
	End
	
	#rem
		bbdoc: Transpose the matrix
	#end
	Method Transpose()
		Local abt:Float = ab
		ab = ba
		ba = abt
	End
	
	#rem
		bbdoc: Scale the matrix by a given amount
	#end
	Method Scale(s:Float)
		aa *= s
		ab *= s
		ba *= s
		bb *= s
	End
	
	#rem
		bbdoc: Transfrom the matrix
		about: Multiplies 2 matrices together
		returns: New transformed matrix
	#end
	Method Transform:tlMatrix2(m:tlMatrix2)
		Local r:tlMatrix2 = New tlMatrix2
		r.aa = aa * m.aa + ab * m.ba;r.ab = aa * m.ab + ab * m.bb
		r.ba = ba * m.aa + bb * m.ba;r.bb = ba * m.ab + bb * m.bb
		Return r
	End
	
	#rem
		bbdoc: Transfrom a vector with the matrix
		returns: New transformed vector
		about: You can use this to transfrom a vector, rotating it, scaling it etc.
	#end
	Method TransformVector:tlVector2(v:tlVector2)
		Local tv:tlVector2 = New tlVector2(0, 0)
		tv.x = v.x * aa + v.y * ba
		tv.y = v.x * ab + v.y * bb
		Return tv
	End
	
	#rem
		bbdoc: Transfrom a point
		returns: New coordinates for the tranformed point in p[0] and p[1]
		about: This will transform a point (x,y) and appply the new coordinates into p[0] and p[1].
	#end
	Method TransformPoint(x:Float, y:Float, p:Float[])
		p[0] = x * aa + y * ba
		p[1] = x * ab + y * bb
	End

End