Namespace myapp

#Import "<std>"

Using std..

Enum ReadStatus
	None = 0
	OpenTag = 1
	CloseTag = 2
	Waiting = 3
	Def = 4
End

Enum DataType
	Discard = 0
	Node = 1
	Attribute = 2
	Data = 3
End

Class XMLParser
	
	Private 
	
	Field _file:Stream
	Field _buffer:String
	Field _last:ReadStatus = ReadStatus.None
	Field _this:ReadStatus = ReadStatus.None
	Field _next:String
	Field _data:DataType
	Field _root:Node
	Field _parsestack:Stack<Data>
	
	Method New()
		_parsestack = New Stack<Data>
	End
	
	Function ParseXML:XMLParser(path:String)
		Local parser:XMLParser = New XMLParser
		parser._file = Stream.Open(path, "r")
		
		parser.Parse()
		
		Return parser
	End
	
	Method Parse:XMLParser()
		If Not _file Return Null
		
		Local cs:String
		
		While Not _file.Eof
			cs = _file.ReadCString()
			
			If _last = ReadStatus.None And cs <> "<" Return Null
			
			Status(cs)
			
			Process(cs)
		Wend
		
		Return Self
	End
	
	Method Status(cs:String)
		_last = _this
		
		Select cs
			Case "<"
				If _last = ReadStatus.None
					_last = ReadStatus.OpenTag
				End if
				_this = ReadStatus.OpenTag
			Case ">"
				_this = ReadStatus.CloseTag
			Case "?"
				_this = ReadStatus.Def
			Default
				'No Change
		End
	End
	
	Method Process(cs:String)
		If _this = ReadStatus.Waiting And cs <> _next
			_buffer += cs
		End if
		If _last = ReadStatus.OpenTag And _this = ReadStatus.Def 
			_next = "?"
			_data = DataType.Discard
			_this = ReadStatus.Waiting
		End If
		If _last = ReadStatus.Waiting And _this = ReadStatus.Def 
			_next = ">"
			_data = DataType.Discard
			_this = ReadStatus.Waiting
		End If
		If _last = ReadStatus.Waiting And _this = ReadStatus.CloseTag 
			_next = ">"
			Build()
			_this = ReadStatus.Waiting
		End If
		If _last = ReadStatus.CloseTag And _this = ReadStatus.OpenTag 
			_next = ">"
			_data = DataType.Node
			_this = ReadStatus.Waiting
		End If
		If _last = ReadStatus.OpenTag And _this = ReadStatus.CloseTag 
			_next = ">"
			Build()
			_this = ReadStatus.Waiting
		End If
	End
	
	Method Build()
		Select _data
			Case DataType.Node
				Local node:= New Node(_buffer)
				Local data:= New Data(DataType.Node)
				data.Node = node
				_parsestack.Add(data)
				If Not _root Then _root = node
			Case DataType.Attribute
			
			Case DataType.Data
			
		End
		
		_buffer = ""
	End
	
End

Class Node
	Field _name:String
	Field _data:String
	Field _parent:Node
	Field _children:List<Node>
	Field _attributes:List<Attribute>
	
	Method New(name:String, parent:Node = Null)
		_name = name
		_parent = parent
	End
	
	Property Data:String()
		Return _data
	Setter(v:String)
		_data = v
	End
End

Class Attribute
	Field _name:String
	Field _data:String
	Field _node:Node
	
	Method New(name:String, node:Node)
		_name = name
		_node = node
	End
	
	Property Data:String()
		Return _data
	Setter(v:String)
		_data = v
	End
End

Class Data
	Field _node:Node
	Field _datatype:DataType
	
	Method New(type:DataType)
		_datatype = type
	End
	
	Property Node:Node()
		Return _node
	Setter(v:Node)
		_node = v
	End
End

Function Main()

	Local xml:=Stream.Open("c:/monkey2/modules/timelinefx/samples/assets/data.xml", "r")
	xml.Close()
End