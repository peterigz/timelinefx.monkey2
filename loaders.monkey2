#rem
	Copyright (c) 2010 Peter J Rigby
	
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

Using timeinefx..

#REM
	Summary: Load a TimelineFX Library
	In order to load in an effects library, you need to do a little preparation first. Monkey applications currently cannot unpack zip files, and TimelineFX .EFF files are essentially that.
	What you need to do first is unpack the .eff file into a folder of the same name inside tthe "data" folder of your monkey app. For example, if you have an EFF file called explosions, then unpack this
	into your data folder in a folder called explosions (You might find it easier to rename the extension to .zip). So the folder structure should be
	
	MyApp.Data/explosions/
	
	Inside this explosions folder you should see a DATA.XML file and a bunch of PNG files (tt will also have a thumbnails folder which you can delete if you want to save space as it's not needed). 
	It's import that your App is ready to accept files with an XML extension so you need to make sure your #TEXT_FILES (either set at the top of your app, or in your config file) variable looks something like:
	
	[code]
	#TEXT_FILES="*.txt|*.XML|*.json"
	[/code]
	
	Note that XML is in caps, this is because it is case sensitive and by default the timelineFX editor saves in caps. However monkey might change this to lower, I'm not sure, if in doubt, rename DATA.XML
	into lower case! 
	
	Once that is done you can load the effects with:
	
	[code]
	Local MyEffects:tlEffectsLibrary
	MyEffects = LoadEffects("explosions")
	[/code]
#END
Function LoadEffects:tlEffectsLibrary(filename:String)

	Local parser:XMLParser = new XMLParser
	local xmldoc:XMLDocument = parser.ParseFile(filename + "/data.xml")
	Local library:tlEffectsLibrary = new tlEffectsLibrary
	
	For Local xmleffect:XMLElement = eachin xmldoc.Root().Children
		if xmleffect.Name = "SHAPES"
			For Local xmlshape:XMLElement = eachin xmleffect.Children
				Local shape:tlShape
				Local url:String = StripDir(xmlshape.GetAttribute("URL").Replace("\", "/"))
				'url = url.Replace(".tpa", ".png")

				shape = LoadShape(filename + "/" + url, int(xmlshape.GetAttribute("WIDTH")), int(xmlshape.GetAttribute("HEIGHT")), int(xmlshape.GetAttribute("FRAMES")))
				
				If shape.getImage(0) = Null
					DebugLog url
				EndIf
				
				shape.LargeIndex = int(xmlshape.GetAttribute("INDEX"))
				
				library.AddShape(shape)
			Next
		End
	Next
	
	For Local xmleffect:XMLElement = eachin xmldoc.Root().Children
		Select xmleffect.Name
			Case "EFFECT"
				Local effect:tlEffect = LoadEffectXMLTree(xmleffect, library)
				library.AddEffect effect
				effect.Directory = New StringMap<tlGameObject>
				effect.AddEffectToDirectory(effect)
				effect.AddEffect(effect)
				effect.CompileAll()
			Case "FOLDER"
				LoadFolderXMLTree(xmleffect, library)
		End
	Next
	
	Return library
	
End

Private
Function LoadEffectXMLTree:tlEffect(effectschild:XMLElement, effectslib:tlEffectsLibrary, Parent:tlEmitter = Null, Folderpath:String = "")
	Local e:tlEffect = New tlEffect
	Local ec:tlAttributeNode
	
	e.EffectClass = Int(effectschild.GetAttribute("TYPE"))
	e.EmitatPoints = Int(effectschild.GetAttribute("EMITATPOINTS"))
	e.MaxGX = Int(effectschild.GetAttribute("MAXGX"))
	e.MaxGY = Int(effectschild.GetAttribute("MAXGY"))
	e.EmissionType = Int(effectschild.GetAttribute("EMISSION_TYPE"))
	e.EllipseArc = Float(effectschild.GetAttribute("ELLIPSE_ARC"))
	e.EffectLength = Int(effectschild.GetAttribute("EFFECT_LENGTH"))
	e.Uniform = Int(effectschild.GetAttribute("UNIFORM"))
	e.Name = effectschild.GetAttribute("NAME")
	e.HandleCenter = Int(effectschild.GetAttribute("HANDLE_CENTER"))
	e.SetHandle(Int(effectschild.GetAttribute("HANDLE_X")), Int(effectschild.GetAttribute("HANDLE_Y")))
	e.TraverseEdge = Int(effectschild.GetAttribute("TRAVERSE_EDGE"))
	e.EndBehaviour = Int(effectschild.GetAttribute("END_BEHAVIOUR"))
	e.DistanceSetByLife = Int(effectschild.GetAttribute("DISTANCE_SET_BY_LIFE"))
	e.ReverseSpawnDirection = Int(effectschild.GetAttribute("REVERSE_SPAWN_DIRECTION"))
	e.ParentEmitter = Parent
	If e.ParentEmitter
		e.Path = e.ParentEmitter.Path + "/" + e.Name
	Else
		e.Path = Folderpath + e.Name
	End If
	Local effectchildren:DiddyStack<XMLElement> = effectschild.Children()
	'Temp attribute node lists
	Local amount:List<tlAttributeNode> = New List<tlAttributeNode>
	Local life:List<tlAttributeNode> = New List<tlAttributeNode>
	Local sizex:List<tlAttributeNode> = New List<tlAttributeNode>
	Local sizey:List<tlAttributeNode> = New List<tlAttributeNode>
	Local velocity:List<tlAttributeNode> = New List<tlAttributeNode>
	Local weight:List<tlAttributeNode> = New List<tlAttributeNode>
	Local spin:List<tlAttributeNode> = New List<tlAttributeNode>
	Local alpha:List<tlAttributeNode> = New List<tlAttributeNode>
	Local emissionangle:List<tlAttributeNode> = New List<tlAttributeNode>
	Local emissionrange:List<tlAttributeNode> = New List<tlAttributeNode>
	Local areawidth:List<tlAttributeNode> = New List<tlAttributeNode>
	Local areaheight:List<tlAttributeNode> = New List<tlAttributeNode>
	Local angle:List<tlAttributeNode> = New List<tlAttributeNode>
	Local stretch:List<tlAttributeNode> = New List<tlAttributeNode>
	Local globalzoom:List<tlAttributeNode> = New List<tlAttributeNode>
	For Local effectchild:XMLElement = EachIn effectchildren
		Select effectchild.Name
			Case "ANIMATION_PROPERTIES"
				e.Frames = Int(effectchild.GetAttribute("FRAMES"))
				e.AnimWidth = Int(effectchild.GetAttribute("WIDTH"))
				e.AnimHeight = Int(effectchild.GetAttribute("HEIGHT"))
				e.AnimX = Int(effectchild.GetAttribute("X"))
				e.AnimY = Int(effectchild.GetAttribute("Y"))
				e.Seed = Int(effectchild.GetAttribute("SEED"))
				e.Looped = Int(effectchild.GetAttribute("LOOPED"))
				e.Zoom = Float(effectchild.GetAttribute("ZOOM"))
				e.FrameOffset = Int(effectchild.GetAttribute("FRAME_OFFSET"))
			Case "AMOUNT"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				amount.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "LIFE"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				life.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SIZEX"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				sizex.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SIZEY"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				sizey.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "VELOCITY"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				velocity.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "WEIGHT"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				weight.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SPIN"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				spin.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "ALPHA"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				alpha.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "EMISSIONANGLE"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				emissionangle.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "EMISSIONRANGE"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				emissionrange.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "AREA_WIDTH"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				areawidth.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "AREA_HEIGHT"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				areaheight.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "ANGLE"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				angle.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "STRETCH"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				stretch.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
								Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
								Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
								Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "GLOBAL_ZOOM"
				ec = New tlAttributeNode(Float(effectchild.GetAttribute("FRAME")), Float(effectchild.GetAttribute("VALUE")))
				globalzoom.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = effectchild.Children()
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),  
								Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),  
								Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),  
								Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
		End Select
	Next
	'create the necessary components
	If amount.Count > 1 Or e.ParentHasGraph("Amount")
		Local component:tlEffectComponent_Amount = New tlEffectComponent_Amount("Amount")
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, amount, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentAmount = tlAttributeNode(amount.First).value
	ElseIf amount.Count = 1
		e.CurrentAmount = tlAttributeNode(amount.First).value
		If e.ParentEmitter
			e.CurrentAmount *= e.ParentEmitter.ParentEffect.CurrentAmount
		End If
	End If
	If life.Count > 1 Or e.ParentHasGraph("Life")
		Local component:tlEffectComponent_Life = tlEffectComponent_Life(New tlEffectComponent_Life("Life"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, life, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentAmount = tlAttributeNode(life.First).value
	ElseIf life.Count = 1
		e.CurrentLife = tlAttributeNode(life.First).value
		If e.ParentEmitter
			e.CurrentLife*=e.ParentEmitter.ParentEffect.CurrentLife
		End If
	End If
	If sizex.Count > 1 Or e.ParentHasGraph("SizeX")
		Local component:tlEffectComponent_SizeX = tlEffectComponent_SizeX(New tlEffectComponent_SizeX("SizeX"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, sizex, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentSizeY = tlAttributeNode(sizex.First).value
	ElseIf sizex.Count = 1
		e.CurrentSizeX = tlAttributeNode(sizex.First).value
		If e.Uniform
			e.CurrentSizeY = e.CurrentSizeX
		End If
		If e.ParentEmitter
			e.CurrentSizeX*=e.ParentEmitter.ParentEffect.CurrentSizeX
		End If
	End If
	If Not e.Uniform Or e.ParentHasGraph("SizeX")
		If sizey.Count > 1
			Local component:tlEffectComponent_SizeY = tlEffectComponent_SizeY(New tlEffectComponent_SizeY("SizeX"))
			component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, sizey, tlNORMAL_GRAPH, e)
			e.AddComponent(component)
			e.CurrentSizeY = tlAttributeNode(sizey.First).value
		ElseIf sizey.Count = 1
			e.CurrentSizeY = tlAttributeNode(sizey.First).value
			If e.ParentEmitter
				e.CurrentSizeY*=e.ParentEmitter.ParentEffect.CurrentSizeY
			End If
		End If
	End If
	If velocity.Count > 1 Or e.ParentHasGraph("Velocity")
		Local component:tlEffectComponent_Velocity = tlEffectComponent_Velocity(New tlEffectComponent_Velocity("Velocity"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, velocity, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentVelocity = tlAttributeNode(velocity.First).value
	ElseIf velocity.Count = 1
		e.CurrentVelocity = tlAttributeNode(velocity.First).value
		If e.ParentEmitter
			e.CurrentVelocity*=e.ParentEmitter.ParentEffect.CurrentVelocity
		End If
	End If
	If weight.Count > 1 Or e.ParentHasGraph("Weight")
		Local component:tlEffectComponent_Weight = tlEffectComponent_Weight(New tlEffectComponent_Weight("Weight"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, weight, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentWeight = tlAttributeNode(weight.First).value
	ElseIf weight.Count = 1
		e.CurrentWeight = tlAttributeNode(weight.First).value
		If e.ParentEmitter
			e.CurrentWeight*=e.ParentEmitter.ParentEffect.CurrentWeight
		End If
	End If
	If spin.Count > 1 Or e.ParentHasGraph("Spin")
		Local component:tlEffectComponent_Spin = tlEffectComponent_Spin(New tlEffectComponent_Spin("Spin"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, spin, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentSpin = tlAttributeNode(spin.First).value
	ElseIf spin.Count = 1
		e.CurrentSpin = tlAttributeNode(spin.First).value
		If e.ParentEmitter
			e.CurrentSpin*=e.ParentEmitter.ParentEffect.CurrentSpin
		End If
	End If
	If alpha.Count > 1 Or e.ParentHasGraph("Alpha")
		Local component:tlEffectComponent_Alpha = tlEffectComponent_Alpha(New tlEffectComponent_Alpha("Alpha"))
		component.InitGraph(0, 1, alpha, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentAlpha = tlAttributeNode(alpha.First).value
	ElseIf alpha.Count = 1
		e.CurrentAlpha = tlAttributeNode(alpha.First).value
		If e.ParentEmitter
			e.CurrentAlpha*=e.ParentEmitter.ParentEffect.CurrentAlpha
		End If
	End If
	If emissionangle.Count > 1
		Local component:tlEffectComponent_EmissionAngle = tlEffectComponent_EmissionAngle(New tlEffectComponent_EmissionAngle("EmissionAngle"))
		component.InitGraph(tlANGLE_MIN, tlANGLE_MAX, emissionangle, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
	ElseIf emissionangle.Count = 1
		e.CurrentEmissionAngle = tlAttributeNode(emissionangle.First).value
	End If
	If emissionrange.Count > 1
		Local component:tlEffectComponent_EmissionRange = tlEffectComponent_EmissionRange(New tlEffectComponent_EmissionRange("EmissionRange"))
		component.InitGraph(tlEMISSION_RANGE_MIN, tlEMISSION_RANGE_MAX, emissionrange, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
	ElseIf emissionrange.Count = 1
		e.CurrentEmissionRange = tlAttributeNode(emissionrange.First).value 
	End If
	If areawidth.Count > 1
		Local component:tlEffectComponent_AreaWidth = New tlEffectComponent_AreaWidth("AreaWidth")
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, areawidth, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
	ElseIf areawidth.Count = 1
		e.CurrentAreaWidth = tlAttributeNode(areawidth.First).value
	End If
	If areaheight.Count > 1
		Local component:tlEffectComponent_AreaHeight = tlEffectComponent_AreaHeight(New tlEffectComponent_AreaHeight("AreaHeight"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, areaheight, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
	ElseIf areaheight.Count = 1
		e.CurrentAreaHeight = tlAttributeNode(areaheight.First).value
	End If
	If e.HandleCenter And e.EffectClass <> tlPOINT_EFFECT
		e.HandleVector.SetPosition(e.CurrentAreaWidth / 2, e.CurrentAreaHeight / 2)
	ElseIf e.HandleCenter
		e.HandleVector.SetPosition(0, 0)
	End If
	If angle.Count > 1
		Local component:tlEffectComponent_Angle = tlEffectComponent_Angle(New tlEffectComponent_Angle("Angle"))
		component.InitGraph(tlANGLE_MIN, tlANGLE_MAX, angle, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
	ElseIf angle.Count = 1
		e.LocalRotation = tlAttributeNode(angle.First).value
	End If
	If stretch.Count > 1 Or e.ParentHasGraph("Stretch")
		Local component:tlEffectComponent_Stretch = tlEffectComponent_Stretch(New tlEffectComponent_Stretch("Stretch"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, stretch, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentStretch = tlAttributeNode(stretch.First).value
	ElseIf stretch.Count = 1
		e.CurrentStretch = tlAttributeNode(stretch.First).value
		If e.ParentEmitter
			e.CurrentStretch*=e.ParentEmitter.ParentEffect.CurrentStretch
		End If
	End If
	If globalzoom.Count > 1 Or e.ParentHasGraph("GlobalZoom")
		Local component:tlEffectComponent_GlobalZoom = tlEffectComponent_GlobalZoom(New tlEffectComponent_GlobalZoom("GlobalZoom"))
		component.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, globalzoom, tlNORMAL_GRAPH, e)
		e.AddComponent(component)
		e.CurrentGlobalZoom = tlAttributeNode(globalzoom.First).value
	ElseIf globalzoom.Count = 1
		e.CurrentGlobalZoom = tlAttributeNode(globalzoom.First).value
		If e.ParentEmitter
			e.CurrentGlobalZoom*=e.ParentEmitter.ParentEffect.CurrentGlobalZoom
		End If
		e.Zoom = e.CurrentGlobalZoom
	Else
		e.CurrentGlobalZoom = 1
		If e.ParentEmitter
			e.CurrentGlobalZoom*=e.ParentEmitter.ParentEffect.CurrentGlobalZoom
		End If
		e.Zoom = e.CurrentGlobalZoom
	End If
	For Local effectchild:XMLElement = EachIn effectchildren
		Select effectchild.Name
			Case "PARTICLE"
				e.AddChild(LoadEmitterXMLTree(effectchild, effectslib, e))
		End Select
	Next
	Return e
End Function

Function LoadFolderXMLTree(folderchild:XMLElement, effectslib:tlEffectsLibrary)
	Local effectschildren:= folderchild.Children
	If effectschildren
		For Local effectchild:XMLElement = EachIn effectschildren
			Select effectchild.Name
				Case "EFFECT"
					Local e:tlEffect = LoadEffectXMLTree(effectchild, effectslib, Null, folderchild.GetAttribute("NAME") + "/")
					effectslib.AddEffect(e)
					e.Directory = New StringMap<tlGameObject>
					e.AddEffect(e)
					e.CompileAll()
			End Select
		Next
	End If
End Function

Function LoadEmitterXMLTree:tlEmitter(effectchild:XMLElement, effectslib:tlEffectsLibrary, e:tlEffect)
	Local particlechildren:= effectchild.Children
	Local p:tlEmitter = New tlEmitter
	Local ec:tlAttributeNode
	p.SetHandle(Int(effectchild.GetAttribute("HANDLE_X")), Int(effectchild.GetAttribute("HANDLE_Y")))
	p.blendMode = Int(effectchild.GetAttribute("BLENDMODE"))
	Select p.blendMode
		Case 3
			p.blendMode = BlendMode.Alpha
		Case 4
			p.blendMode = BlendMode.Additive
	End
	'Print p.blendMode
	p.ParticleRelative = Int(effectchild.GetAttribute("RELATIVE"))
	p.RandomColor = Int(effectchild.GetAttribute("RANDOM_COLOR"))
	p.Layer = Int(effectchild.GetAttribute("LAYER"))
	p.SingleParticle = Int(effectchild.GetAttribute("SINGLE_PARTICLE"))
	p.Name = effectchild.GetAttribute("NAME")
	p.Animating = Int(effectchild.GetAttribute("ANIMATE"))
	p.AnimateOnce = Int(effectchild.GetAttribute("ANIMATE_ONCE"))
	p.Frame = Int(effectchild.GetAttribute("FRAME"))
	p.RandomStartFrame = Int(effectchild.GetAttribute("RANDOM_START_FRAME"))
	p.AnimationDirection = Int(effectchild.GetAttribute("ANIMATION_DIRECTION"))
	p.Uniform = Int(effectchild.GetAttribute("UNIFORM"))
	p.AngleType = Int(effectchild.GetAttribute("ANGLE_TYPE"))
	p.AngleOffset = Int(effectchild.GetAttribute("ANGLE_OFFSET"))
	p.LockAngle = Int(effectchild.GetAttribute("LOCK_ANGLE"))
	p.AngleRelative = Int(effectchild.GetAttribute("ANGLE_RELATIVE"))
	p.UseEffectEmission = Int(effectchild.GetAttribute("USE_EFFECT_EMISSION"))
	p.ColorRepeat = Int(effectchild.GetAttribute("COLOR_REPEAT"))
	p.AlphaRepeat = Int(effectchild.GetAttribute("ALPHA_REPEAT"))
	p.OneShot = Int(effectchild.GetAttribute("ONE_SHOT"))
	p.HandleCenter = Int(effectchild.GetAttribute("HANDLE_CENTERED"))
	p.GroupParticles = Int(effectchild.GetAttribute("GROUP_PARTICLES"))
	If Not p.AnimationDirection
		p.AnimationDirection = 1
	End If
	p.ParentEffect = e
	p.Path = p.ParentEffect.Path + "/" + p.Name
	'Temp attribute node lists
	Local amount:= New List<tlAttributeNode>
	Local life:= New List<tlAttributeNode>
	Local basespeed:= New List<tlAttributeNode>
	Local baseweight:= New List<tlAttributeNode>
	Local basesizex:= New List<tlAttributeNode>
	Local basesizey:= New List<tlAttributeNode>
	Local basespin:= New List<tlAttributeNode>
	Local splatter:= New List<tlAttributeNode>
	Local lifevariation:= New List<tlAttributeNode>
	Local amountvariation:= New List<tlAttributeNode>
	Local velocityvariation:= New List<tlAttributeNode>
	Local weightvariation:= New List<tlAttributeNode>
	Local sizexvariation:= New List<tlAttributeNode>
	Local sizeyvariation:= New List<tlAttributeNode>
	Local spinvariation:= New List<tlAttributeNode>
	Local directionvariation:= New List<tlAttributeNode>
	Local alphaovertime:= New List<tlAttributeNode>
	Local velocityovertime:= New List<tlAttributeNode>
	Local weightovertime:= New List<tlAttributeNode>
	Local scalexovertime:= New List<tlAttributeNode>
	Local scaleyovertime:= New List<tlAttributeNode>
	Local spinovertime:= New List<tlAttributeNode>
	Local direction:= New List<tlAttributeNode>
	Local directionvariationot:= New List<tlAttributeNode>
	Local framerateovertime:= New List<tlAttributeNode>
	Local stretchovertime:= New List<tlAttributeNode>
	Local redovertime:= New List<tlAttributeNode>
	Local greenovertime:= New List<tlAttributeNode>
	Local blueovertime:= New List<tlAttributeNode>
	Local globalvelocity:= New List<tlAttributeNode>
	Local emissionangle:= New List<tlAttributeNode>
	Local emissionrange:= New List<tlAttributeNode>
	For Local particlechild:XMLElement = EachIn particlechildren
		Select particlechild.Name
			Case "ANGLE_TYPE"
				p.AngleType = Int(particlechild.GetAttribute("VALUE"))
			Case "ANGLE_OFFSET"
				p.AngleOffset = Int(particlechild.GetAttribute("VALUE"))
			Case "LOCK_ANGLE"
				p.LockAngle = Int(particlechild.GetAttribute("VALUE"))
			Case "ANGLE_RELATIVE"
				p.AngleRelative = Int(particlechild.GetAttribute("VALUE"))
			Case "USE_EFFECT_EMISSION"
				p.UseEffectEmission = Int(particlechild.GetAttribute("VALUE"))
			Case "COLOR_REPEAT"
				p.ColorRepeat = Int(particlechild.GetAttribute("VALUE"))
			Case "ALPHA_REPEAT"
				p.AlphaRepeat = Int(particlechild.GetAttribute("VALUE"))
			Case "ONE_SHOT"
				p.OneShot = Int(particlechild.GetAttribute("VALUE"))
			Case "HANDLE_CENTERED"
				p.HandleCenter = Int(particlechild.GetAttribute("VALUE"))
			Case "SHAPE_INDEX"
				p.Sprite = effectslib.GetShape(Int(particlechild.Value))
			Case "LIFE"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				life.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "AMOUNT"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				amount.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "BASE_SPEED"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				basespeed.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "BASE_WEIGHT"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				baseweight.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "BASE_SIZE_X"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				basesizex.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "BASE_SIZE_Y"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				basesizey.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "BASE_SPIN"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				basespin.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SPLATTER"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				splatter.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "LIFE_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				lifevariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "AMOUNT_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				amountvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "VELOCITY_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				velocityvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "WEIGHT_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				weightvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SIZE_X_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				sizexvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SIZE_Y_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				sizeyvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SPIN_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				spinvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "DIRECTION_VARIATION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				directionvariation.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "ALPHA_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				alphaovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "VELOCITY_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				velocityovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "WEIGHT_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				weightovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SCALE_X_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				scalexovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SCALE_Y_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				scaleyovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "SPIN_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				spinovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "DIRECTION"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				direction.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "DIRECTION_VARIATIONOT"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				directionvariationot.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "FRAMERATE_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				framerateovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "STRETCH_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				stretchovertime.AddLast(ec)
				Local attlist:DiddyStack<XMLElement> = particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
								Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
								Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
								Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "RED_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				redovertime.AddLast(ec)
			Case "GREEN_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				greenovertime.AddLast(ec)
			Case "BLUE_OVERTIME"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				blueovertime.AddLast(ec)
			Case "GLOBAL_VELOCITY"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				globalvelocity.AddLast(ec)
				Local attlist:= particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "EMISSION_ANGLE"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				emissionangle.AddLast(ec)
				Local attlist:= particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "EMISSION_RANGE"
				ec = New tlAttributeNode(Float(particlechild.GetAttribute("FRAME")), Float(particlechild.GetAttribute("VALUE")))
				emissionrange.AddLast(ec)
				Local attlist:= particlechild.Children
				If attlist
					For Local attchild:XMLElement = EachIn attlist
						Select attchild.Name
							Case "CURVE"
								ec.SetCurvePoints(Float(attchild.GetAttribute("LEFT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("LEFT_CURVE_POINT_Y")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_X")),
									Float(attchild.GetAttribute("RIGHT_CURVE_POINT_Y")))
						End Select
					Next
				End If
			Case "EFFECT"
				p.AddEffect(LoadEffectXMLTree(particlechild, effectslib, p))
		End Select
	Next
	'create the necessary components
	If amount.Count > 1
		Local component:tlEC_Amount = tlEC_Amount(New tlEC_Amount("Amount"))
		component.InitGraph(tlAMOUNT_MIN, tlAMOUNT_MAX, amount, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf amount.Count = 1
		p.CurrentAmount = tlAttributeNode(amount.First).value
	End If
	If amountvariation.Count > 1
		Local component:tlEC_AmountVariation = tlEC_AmountVariation(New tlEC_AmountVariation("AmountVariation"))
		component.InitGraph(tlAMOUNT_MIN, tlAMOUNT_MAX, amountvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf amountvariation.Count = 1
		p.currentamountvariation = tlAttributeNode(amountvariation.First).value
	End If
	If life.Count > 1
		Local component:tlEC_Life = tlEC_Life(New tlEC_Life("Life"))
		component.InitGraph(tlLIFE_MIN, tlLIFE_MAX, life, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf life.Count = 1
		p.currentlife = tlAttributeNode(life.First).value
	End If
	If lifevariation.Count > 1
		Local component:tlEC_LifeVariation = tlEC_LifeVariation(New tlEC_LifeVariation("LifeVariation"))
		component.InitGraph(tlLIFE_MIN, tlLIFE_MAX, lifevariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf lifevariation.Count = 1
		p.currentlifevariation = tlAttributeNode(lifevariation.First).value
	End If
	If basesizex.Count > 1
		Local component:tlEC_BaseSizeX = tlEC_BaseSizeX(New tlEC_BaseSizeX("BaseSizeX"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, basesizex, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf basesizex.Count = 1
		p.currentbasesizex = tlAttributeNode(basesizex.First).value
	End If
	If basesizey.Count > 1
		Local component:tlEC_BaseSizeY = tlEC_BaseSizeY(New tlEC_BaseSizeY("BaseSizeY"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, basesizey, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf basesizey.Count = 1
		p.currentbasesizey = tlAttributeNode(basesizey.First).value
	End If
	If basespeed.Count > 1
		Local component:tlEC_BaseSpeed = tlEC_BaseSpeed(New tlEC_BaseSpeed("BaseSpeed"))
		component.InitGraph(tlVELOCITY_MIN, tlVELOCITY_MAX, basespeed, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf basespeed.Count = 1
		p.currentbasespeed = tlAttributeNode(basespeed.First).value
	End If
	If basespin.Count > 1
		Local component:tlEC_BaseSpin = tlEC_BaseSpin(New tlEC_BaseSpin("BaseSpin"))
		component.InitGraph(tlSPIN_MIN, tlSPIN_MAX, basespin, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf basespin.Count = 1
		p.currentbasespin = tlAttributeNode(basespin.First).value
	End If
	If baseweight.Count > 1
		Local component:tlEC_BaseWeight = tlEC_BaseWeight(New tlEC_BaseWeight("BaseWeight"))
		component.InitGraph(tlWEIGHT_MIN, tlWEIGHT_MAX, baseweight, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf baseweight.Count = 1
		p.currentbaseweight = tlAttributeNode(baseweight.First).value
	End If
	If splatter.Count > 1
		Local component:tlEC_Splatter = tlEC_Splatter(New tlEC_Splatter("Splatter"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, splatter, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf splatter.Count = 1
		p.currentsplatter = tlAttributeNode(splatter.First).value
	End If
	If sizexvariation.Count > 1
		Local component:tlEC_SizeXVariation = tlEC_SizeXVariation(New tlEC_SizeXVariation("SizeXVariation"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, sizexvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf sizexvariation.Count = 1
		p.currentsizexvariation = tlAttributeNode(sizexvariation.First).value
	End If
	If sizeyvariation.Count > 1
		Local component:tlEC_SizeYVariation = tlEC_SizeYVariation(New tlEC_SizeYVariation("SizeYVariation"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, sizeyvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf sizeyvariation.Count = 1
		p.currentsizeyvariation = tlAttributeNode(sizeyvariation.First).value
	End If
	If directionvariation.Count > 1
		Local component:tlEC_DirectionVariation = tlEC_DirectionVariation(New tlEC_DirectionVariation("DirectionVariation"))
		component.InitGraph(tlDIMENSIONS_MIN, tlDIMENSIONS_MAX, directionvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf directionvariation.Count = 1
		p.currentdirectionvariation = tlAttributeNode(directionvariation.First).value
	End If
	If velocityvariation.Count > 1
		Local component:tlEC_VelocityVariation = tlEC_VelocityVariation(New tlEC_VelocityVariation("VelocityVariation"))
		component.InitGraph(tlVELOCITY_MIN, tlVELOCITY_MAX, velocityvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf velocityvariation.Count = 1
		p.currentvelocityvariation = tlAttributeNode(velocityvariation.First).value
	End If
	If spinvariation.Count > 1
		Local component:tlEC_SpinVariation = tlEC_SpinVariation(New tlEC_SpinVariation("SpinVariation"))
		component.InitGraph(tlSPIN_VARIATION_MIN, tlSPIN_VARIATION_MAX, spinvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf spinvariation.Count = 1
		p.currentspinvariation = tlAttributeNode(spinvariation.First).value
	End If
	If weightvariation.Count > 1
		Local component:tlEC_WeightVariation = tlEC_WeightVariation(New tlEC_WeightVariation("WeightVariation"))
		component.InitGraph(tlWEIGHT_VARIATION_MIN, tlWEIGHT_VARIATION_MAX, weightvariation, tlNORMAL_GRAPH, p.ParentEffect, p)
		p.AddComponent(component, False)
	ElseIf weightvariation.Count = 1
		p.currentweightvariation = tlAttributeNode(weightvariation.First).value
	End If
	If emissionangle.Count > 1
		Local component:tlEC_EmissionAngle = tlEC_EmissionAngle(New tlEC_EmissionAngle("EmissionAngle"))
		component.InitGraph(tlANGLE_MIN, tlANGLE_MAX, emissionangle, tlNORMAL_GRAPH, e)
		p.AddComponent(component)
	ElseIf emissionangle.Count = 1
		p.currentemissionangle = tlAttributeNode(emissionangle.First).value
	End If
	If emissionrange.Count > 1
		Local component:tlEC_EmissionRange = tlEC_EmissionRange(New tlEC_EmissionRange("EmissionRange"))
		component.InitGraph(tlEMISSION_RANGE_MIN, tlEMISSION_RANGE_MAX, emissionrange, tlNORMAL_GRAPH, e)
		p.AddComponent(component)
	ElseIf emissionrange.Count = 1
		p.currentemissionrange = tlAttributeNode(emissionrange.First).value
	End If
	Local scalexcomponent:tlEC_ScaleXOvertime = tlEC_ScaleXOvertime(New tlEC_ScaleXOvertime("ScaleXOvertime"))
	scalexcomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, scalexovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.scalex_component = scalexcomponent
	Local scaleycomponent:tlEC_ScaleYOvertime = tlEC_ScaleYOvertime(New tlEC_ScaleYOvertime("ScaleYOvertime"))
	scaleycomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, scaleyovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.scaley_component = scaleycomponent
	Local velocitycomponent:tlEC_VelocityOvertime = tlEC_VelocityOvertime(New tlEC_VelocityOvertime("VelocityOvertime"))
	velocitycomponent.InitGraph(tlVELOCITY_OVERTIME_MIN, tlVELOCITY_OVERTIME_MAX, velocityovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.velocity_component = velocitycomponent
	Local globalvelocitycomponent:tlEC_GlobalVelocity = tlEC_GlobalVelocity(New tlEC_GlobalVelocity("GlobalVelocity"))
	globalvelocitycomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, globalvelocity, tlNORMAL_GRAPH, p.ParentEffect, p)
	p.globalvelocity_component = globalvelocitycomponent
	Local stretchcomponent:tlEC_StretchOvertime = tlEC_StretchOvertime(New tlEC_StretchOvertime("StretchOvertime"))
	stretchcomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, stretchovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.stretch_component = stretchcomponent
	Local alphacomponent:tlEC_AlphaOvertime = tlEC_AlphaOvertime(New tlEC_AlphaOvertime("AlphaOvertime"))
	alphacomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, alphaovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.alpha_component = alphacomponent
	Local redcomponent:tlEC_RedOvertime = tlEC_RedOvertime(New tlEC_RedOvertime("RedOvertime"))
	redcomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, redovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.red_component = redcomponent
	Local greencomponent:tlEC_GreenOvertime = tlEC_GreenOvertime(New tlEC_GreenOvertime("GreenOvertime"))
	greencomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, greenovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.green_component = greencomponent
	Local bluecomponent:tlEC_BlueOvertime = tlEC_BlueOvertime(New tlEC_BlueOvertime("BlueOvertime"))
	bluecomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, blueovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.blue_component = bluecomponent
	Local directioncomponent:tlEC_DirectionOvertime = tlEC_DirectionOvertime(New tlEC_DirectionOvertime("DirectionOvertime"))
	directioncomponent.InitGraph(tlDIRECTION_OVERTIME_MIN, tlDIRECTION_OVERTIME_MIN, direction, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.direction_component = directioncomponent
	Local dvotcomponent:tlEC_DirectionVariationOvertime = tlEC_DirectionVariationOvertime(New tlEC_DirectionVariationOvertime("DirectionVariationOvertime"))
	dvotcomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, directionvariationot, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.dvovertime_component = dvotcomponent
	Local spincomponent:tlEC_SpinOvertime = tlEC_SpinOvertime(New tlEC_SpinOvertime("SpinOvertime"))
	spincomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, spinovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.spin_component = spincomponent
	Local weightcomponent:tlEC_WeightOvertime = tlEC_WeightOvertime(New tlEC_WeightOvertime("WeightOvertime"))
	weightcomponent.InitGraph(tlGLOBAL_PERCENT_MIN, tlGLOBAL_PERCENT_MAX, weightovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.weight_component = weightcomponent
	Local frameratecomponent:tlEC_FramerateOvertime = tlEC_FramerateOvertime(New tlEC_FramerateOvertime("FramerateOvertime"))
	frameratecomponent.InitGraph(tlFRAMERATE_MIN, tlFRAMERATE_MAX, framerateovertime, tlOVERTIME_GRAPH, p.ParentEffect, p)
	p.framerate_component = frameratecomponent
	Return p
End Function
