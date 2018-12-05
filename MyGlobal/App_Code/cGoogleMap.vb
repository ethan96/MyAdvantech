' Google Maps User Control for ASP.Net version 1.0: 
' ======================== 
' Copyright (C) 2008 Shabdar Ghata 
' Email : ghata2002@gmail.com 
' URL : http://www.shabdar.org 

' This program is free software: you can redistribute it and/or modify 
' it under the terms of the GNU General Public License as published by 
' the Free Software Foundation, either version 3 of the License, or 
' (at your option) any later version. 

' This program is distributed in the hope that it will be useful, 
' but WITHOUT ANY WARRANTY; without even the implied warranty of 
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
' GNU General Public License for more details. 

' You should have received a copy of the GNU General Public License 
' along with this program. If not, see <http://www.gnu.org/licenses/>. 

' This program comes with ABSOLUTELY NO WARRANTY. 

Imports System
Imports System.Data
Imports System.Configuration
Imports System.Web
Imports System.Web.Security
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.UI.WebControls.WebParts
Imports System.Web.UI.HtmlControls
Imports System.Collections
Imports System.Drawing
Imports System.IO
Imports System.Net
Imports System.Text

''' <summary> 
''' Summary description for cGoogleMap 
''' </summary> 
''' 
<Serializable()> _
Public Class GoogleObject
    Public Sub New()
    End Sub

    Public Sub New(ByVal prev As GoogleObject)
        Points = GooglePoints.CloneMe(prev.Points)
        Polylines = GooglePolylines.CloneMe(prev.Polylines)
        Polygons = GooglePolygons.CloneMe(prev.Polygons)
        ZoomLevel = prev.ZoomLevel
        ShowZoomControl = prev.ShowZoomControl
        ShowMapTypesControl = prev.ShowMapTypesControl
        Width = prev.Width
        Height = prev.Height
        MapType = prev.MapType
        APIKey = prev.APIKey
        ShowTraffic = prev.ShowTraffic
        RecenterMap = prev.RecenterMap
        AutomaticBoundaryAndZoom = prev.AutomaticBoundaryAndZoom
    End Sub

    Private _gpoints As New GooglePoints()
    Public Property Points() As GooglePoints
        Get
            Return _gpoints
        End Get
        Set(ByVal value As GooglePoints)
            _gpoints = value
        End Set
    End Property

    Private _gpolylines As New GooglePolylines()
    Public Property Polylines() As GooglePolylines
        Get
            Return _gpolylines
        End Get
        Set(ByVal value As GooglePolylines)
            _gpolylines = value
        End Set
    End Property

    Private _gpolygons As New GooglePolygons()
    Public Property Polygons() As GooglePolygons
        Get
            Return _gpolygons
        End Get
        Set(ByVal value As GooglePolygons)
            _gpolygons = value
        End Set
    End Property

    Private _centerpoint As New GooglePoint()
    Public Property CenterPoint() As GooglePoint
        Get
            Return _centerpoint
        End Get
        Set(ByVal value As GooglePoint)
            _centerpoint = value
        End Set
    End Property

    Private _zoomlevel As Integer = 3
    Public Property ZoomLevel() As Integer
        Get
            Return _zoomlevel
        End Get
        Set(ByVal value As Integer)
            _zoomlevel = value
        End Set
    End Property

    Private _showzoomcontrol As Boolean = True
    Public Property ShowZoomControl() As Boolean
        Get
            Return _showzoomcontrol
        End Get
        Set(ByVal value As Boolean)
            _showzoomcontrol = value
        End Set
    End Property

    Private _recentermap As Boolean = False
    Public Property RecenterMap() As Boolean
        Get
            Return _recentermap
        End Get
        Set(ByVal value As Boolean)
            _recentermap = value
        End Set
    End Property

    Private _automaticboundaryandzoom As Boolean = True
    Public Property AutomaticBoundaryAndZoom() As Boolean
        Get
            Return _automaticboundaryandzoom
        End Get
        Set(ByVal value As Boolean)
            _automaticboundaryandzoom = value
        End Set
    End Property

    Private _showtraffic As Boolean = False
    Public Property ShowTraffic() As Boolean
        Get
            Return _showtraffic
        End Get
        Set(ByVal value As Boolean)
            _showtraffic = value
        End Set
    End Property

    Private _showmaptypescontrol As Boolean = True
    Public Property ShowMapTypesControl() As Boolean
        Get
            Return _showmaptypescontrol
        End Get
        Set(ByVal value As Boolean)
            _showmaptypescontrol = value
        End Set
    End Property

    Private _width As String = "500px"
    Public Property Width() As String
        Get
            Return _width
        End Get
        Set(ByVal value As String)
            _width = value
        End Set
    End Property

    Private _height As String = "400px"
    Public Property Height() As String
        Get
            Return _height
        End Get
        Set(ByVal value As String)
            _height = value
        End Set
    End Property


    Private _maptype As String = ""
    Public Property MapType() As String
        Get
            Return _maptype
        End Get
        Set(ByVal value As String)
            _maptype = value
        End Set
    End Property

    Private _apikey As String = ""
    Public Property APIKey() As String
        Get
            Return _apikey
        End Get
        Set(ByVal value As String)
            _apikey = value
        End Set
    End Property

    Private _apiversion As String = "2"
    Public Property APIVersion() As String
        Get
            Return _apiversion
        End Get
        Set(ByVal value As String)
            _apiversion = value
        End Set
    End Property

End Class



Public Class GooglePoint
    Public Sub New()
    End Sub

    Private _pointstatus As String = ""
    'N-New, D-Deleted, C-Changed, ''-No Action 
    Public Property PointStatus() As String
        Get
            Return _pointstatus
        End Get
        Set(ByVal value As String)
            _pointstatus = value
        End Set
    End Property


    Private _address As String = ""
    Public Property Address() As String
        Get
            Return _address
        End Get
        Set(ByVal value As String)
            _address = value
        End Set
    End Property


    Public Sub New(ByVal pID As String, ByVal plat As Double, ByVal plon As Double, ByVal picon As String, ByVal pinfohtml As String)
        ID = pID
        Latitude = plat
        Longitude = plon
        IconImage = picon
        InfoHTML = pinfohtml
    End Sub

    Public Sub New(ByVal pID As String, ByVal plat As Double, ByVal plon As Double, ByVal picon As String, ByVal pinfohtml As String, ByVal pTooltipText As String, _
    ByVal pDraggable As Boolean)
        ID = pID
        Latitude = plat
        Longitude = plon
        IconImage = picon
        InfoHTML = pinfohtml
        ToolTip = pTooltipText
        Draggable = pDraggable
    End Sub

    Public Sub New(ByVal pID As String, ByVal plat As Double, ByVal plon As Double, ByVal picon As String)
        ID = pID
        Latitude = plat
        Longitude = plon
        IconImage = picon
    End Sub

    Public Sub New(ByVal pID As String, ByVal plat As Double, ByVal plon As Double)
        ID = pID
        Latitude = plat
        Longitude = plon
    End Sub

    Private _id As String = ""
    Public Property ID() As String
        Get
            Return _id
        End Get
        Set(ByVal value As String)
            _id = value
        End Set
    End Property

    Private _icon As String = ""
    Public Property IconImage() As String
        Get
            Return _icon
        End Get
        Set(ByVal value As String)

            'Get physical path of icon image. Necessary for Bitmap object. 
            Dim sIconImage As String = value
            If sIconImage = "" Then
                Return
            End If
            Dim ImageIconPhysicalPath As String = cCommon.GetLocalPath() + sIconImage.Replace("/", "\")
            'Find width and height of icon using Bitmap image. 


            Using img As System.Drawing.Image = System.Drawing.Image.FromFile(ImageIconPhysicalPath)
                IconImageWidth = img.Width
                IconImageHeight = img.Height

                IconAnchor_posX = img.Width / 2
                IconAnchor_posY = img.Height

                InfoWindowAnchor_posX = img.Width / 2
                InfoWindowAnchor_posY = img.Height / 3
            End Using
            _icon = cCommon.GetHttpURL() + sIconImage


            _icon = value
        End Set
    End Property

    Private _iconshadowimage As String = ""
    Public Property IconShadowImage() As String
        Get
            Return _iconshadowimage
        End Get
        Set(ByVal value As String)

            'Get physical path of icon image. Necessary for Bitmap object. 
            Dim sShadowImage As String = value
            If sShadowImage = "" Then
                Return
            End If
            Dim ShadowIconPhysicalPath As String = cCommon.GetLocalPath() + sShadowImage.Replace("/", "\")
            'Find width and height of icon using Bitmap image. 

            Using img As System.Drawing.Image = System.Drawing.Image.FromFile(ShadowIconPhysicalPath)
                IconShadowWidth = img.Width
                IconShadowHeight = img.Height
            End Using
            _iconshadowimage = cCommon.GetHttpURL() + sShadowImage

            _iconshadowimage = value
        End Set
    End Property

    Private _iconimagewidth As Integer = 32
    Public Property IconImageWidth() As Integer
        Get
            Return _iconimagewidth
        End Get
        Set(ByVal value As Integer)
            _iconimagewidth = value
        End Set
    End Property

    Private _iconshadowwidth As Integer = 0
    Public Property IconShadowWidth() As Integer
        Get
            Return _iconshadowwidth
        End Get
        Set(ByVal value As Integer)
            _iconshadowwidth = value
        End Set
    End Property

    Private _iconshadowheight As Integer = 0
    Public Property IconShadowHeight() As Integer
        Get
            Return _iconshadowheight
        End Get
        Set(ByVal value As Integer)
            _iconshadowheight = value
        End Set
    End Property

    Private _iconanchor_posx As Integer = 16
    Public Property IconAnchor_posX() As Integer
        Get
            Return _iconanchor_posx
        End Get
        Set(ByVal value As Integer)
            _iconanchor_posx = value
        End Set
    End Property
    Private _iconanchor_posy As Integer = 32
    Public Property IconAnchor_posY() As Integer
        Get
            Return _iconanchor_posy
        End Get
        Set(ByVal value As Integer)
            _iconanchor_posy = value
        End Set
    End Property

    Private _infowindowanchor_posx As Integer = 16
    Public Property InfoWindowAnchor_posX() As Integer
        Get
            Return _infowindowanchor_posx
        End Get
        Set(ByVal value As Integer)
            _infowindowanchor_posx = value
        End Set
    End Property

    Private _infowindowanchor_posy As Integer = 5
    Public Property InfoWindowAnchor_posY() As Integer
        Get
            Return _infowindowanchor_posy
        End Get
        Set(ByVal value As Integer)
            _infowindowanchor_posy = value
        End Set
    End Property

    Private _draggable As Boolean = False
    Public Property Draggable() As Boolean
        Get
            Return _draggable
        End Get
        Set(ByVal value As Boolean)
            _draggable = value
        End Set
    End Property

    Private _iconimageheight As Integer = 32
    Public Property IconImageHeight() As Integer
        Get
            Return _iconimageheight
        End Get
        Set(ByVal value As Integer)
            _iconimageheight = value
        End Set
    End Property

    Private _lat As Double = 0
    Public Property Latitude() As Double
        Get
            Return _lat
        End Get
        Set(ByVal value As Double)
            _lat = value
        End Set
    End Property

    Private _lon As Double = 0
    Public Property Longitude() As Double
        Get
            Return _lon
        End Get
        Set(ByVal value As Double)
            _lon = value
        End Set
    End Property

    Private _infohtml As String = ""
    Public Property InfoHTML() As String
        Get
            Return _infohtml
        End Get
        Set(ByVal value As String)
            _infohtml = value
        End Set
    End Property

    Private _tooltip As String = ""
    Public Property ToolTip() As String
        Get
            Return _tooltip
        End Get
        Set(ByVal value As String)
            _tooltip = value
        End Set
    End Property

    Public Overloads Overrides Function Equals(ByVal obj As Object) As Boolean
        ' If parameter is null return false. 
        If obj Is Nothing Then
            Return False
        End If

        ' If parameter cannot be cast to Point return false. 
        Dim p As GooglePoint = TryCast(obj, GooglePoint)
        If DirectCast(p, Object) Is Nothing Then
            Return False
        End If

        ' Return true if the fields match: 
        Return (InfoHTML = p.InfoHTML) AndAlso (IconImage = p.IconImage) AndAlso (p.ID = ID) AndAlso (p.Latitude = Latitude) AndAlso (p.Longitude = Longitude)
    End Function

    Public Function GeocodeAddress(ByVal sAPIKey As String) As Boolean
        Return cCommon.GeocodeAddress(Me, sAPIKey)
    End Function
End Class

Public Class GooglePoints
    Inherits CollectionBase

    Public Sub New()
    End Sub

    Public Shared Function CloneMe(ByVal prev As GooglePoints) As GooglePoints
        Dim p As New GooglePoints()
        For i As Integer = 0 To prev.Count - 1
            p.Add(New GooglePoint(prev(i).ID, prev(i).Latitude, prev(i).Longitude, prev(i).IconImage, prev(i).InfoHTML, prev(i).ToolTip, _
            prev(i).Draggable))
        Next
        Return p
    End Function


    Default Public Property Item(ByVal pIndex As Integer) As GooglePoint
        Get
            Return DirectCast(Me.List(pIndex), GooglePoint)
        End Get
        Set(ByVal value As GooglePoint)
            Me.List(pIndex) = value
        End Set
    End Property

    Default Public Property Item(ByVal pID As String) As GooglePoint
        Get
            For i As Integer = 0 To Count - 1
                If Me(i).ID = pID Then
                    Return DirectCast(Me.List(i), GooglePoint)
                End If
            Next
            Return Nothing
        End Get
        Set(ByVal value As GooglePoint)
            For i As Integer = 0 To Count - 1
                If Me(i).ID = pID Then
                    Me.List(i) = value
                End If
            Next
        End Set
    End Property


    Public Sub Add(ByVal pPoint As GooglePoint)
        Me.List.Add(pPoint)
    End Sub
    Public Sub Remove(ByVal pIndex As Integer)
        Me.RemoveAt(pIndex)
    End Sub
    Public Sub Remove(ByVal pID As String)
        For i As Integer = 0 To Count - 1
            If Me(i).ID = pID Then
                Me.List.RemoveAt(i)
                Return
            End If
        Next
    End Sub

    Public Overloads Overrides Function Equals(ByVal obj As Object) As Boolean
        ' If parameter is null return false. 
        If obj Is Nothing Then
            Return False
        End If

        ' If parameter cannot be cast to Point return false. 
        Dim p As GooglePoints = TryCast(obj, GooglePoints)
        If DirectCast(p, Object) Is Nothing Then
            Return False
        End If

        If p.Count <> Count Then
            Return False
        End If
        For i As Integer = 0 To p.Count - 1


            If Not Me(i).Equals(p(i)) Then
                Return False
            End If
        Next
        ' Return true if the fields match: 
        Return True
    End Function
End Class

Public Class GooglePolyline
    Private _linestatus As String = ""
    'N-New, D-Deleted, C-Changed, ''-No Action 
    Public Property LineStatus() As String
        Get
            Return _linestatus
        End Get
        Set(ByVal value As String)
            _linestatus = value
        End Set
    End Property

    Private _id As String = ""
    Public Property ID() As String
        Get
            Return _id
        End Get
        Set(ByVal value As String)
            _id = value
        End Set
    End Property

    Private _gpoints As New GooglePoints()
    Public Property Points() As GooglePoints
        Get
            Return _gpoints
        End Get
        Set(ByVal value As GooglePoints)
            _gpoints = value
        End Set
    End Property

    Private _colorcode As String = "#66FF00"
    Public Property ColorCode() As String
        Get
            Return _colorcode
        End Get
        Set(ByVal value As String)
            _colorcode = value
        End Set
    End Property

    Private _width As Integer = 10
    Public Property Width() As Integer
        Get
            Return _width
        End Get
        Set(ByVal value As Integer)
            _width = value
        End Set
    End Property

    Private _geodesic As Boolean = False
    Public Property Geodesic() As Boolean
        Get
            Return _geodesic
        End Get
        Set(ByVal value As Boolean)
            _geodesic = value
        End Set
    End Property

    Public Overloads Overrides Function Equals(ByVal obj As Object) As Boolean
        ' If parameter is null return false. 
        If obj Is Nothing Then
            Return False
        End If

        ' If parameter cannot be cast to Point return false. 
        Dim p As GooglePolyline = TryCast(obj, GooglePolyline)
        If DirectCast(p, Object) Is Nothing Then
            Return False
        End If

        ' Return true if the fields match: 
        Return (Geodesic = p.Geodesic) AndAlso (Width = p.Width) AndAlso (p.ID = ID) AndAlso (p.ColorCode = ColorCode) AndAlso (p.Points.Equals(Points))
    End Function

End Class

Public Class GooglePolylines
    Inherits CollectionBase

    Public Sub New()
    End Sub

    Public Shared Function CloneMe(ByVal prev As GooglePolylines) As GooglePolylines
        Dim p As New GooglePolylines()
        For i As Integer = 0 To prev.Count - 1
            Dim GPL As New GooglePolyline()
            GPL.ColorCode = prev(i).ColorCode
            GPL.Geodesic = prev(i).Geodesic
            GPL.ID = prev(i).ID
            GPL.Points = GooglePoints.CloneMe(prev(i).Points)
            GPL.Width = prev(i).Width
            p.Add(GPL)
        Next
        Return p
    End Function

    Default Public Property Item(ByVal pIndex As Integer) As GooglePolyline
        Get
            Return DirectCast(Me.List(pIndex), GooglePolyline)
        End Get
        Set(ByVal value As GooglePolyline)
            Me.List(pIndex) = value
        End Set
    End Property

    Default Public Property Item(ByVal pID As String) As GooglePolyline
        Get
            For i As Integer = 0 To Count - 1
                If Me(i).ID = pID Then
                    Return DirectCast(Me.List(i), GooglePolyline)
                End If
            Next
            Return Nothing
        End Get
        Set(ByVal value As GooglePolyline)
            For i As Integer = 0 To Count - 1
                If Me(i).ID = pID Then
                    Me.List(i) = value
                End If
            Next
        End Set
    End Property

    Public Sub Add(ByVal pPolyline As GooglePolyline)
        Me.List.Add(pPolyline)
    End Sub
    Public Sub Remove(ByVal pIndex As Integer)
        Me.RemoveAt(pIndex)
    End Sub
    Public Sub Remove(ByVal pID As String)
        For i As Integer = 0 To Count - 1
            If Me(i).ID = pID Then
                Me.List.RemoveAt(i)
                Return
            End If
        Next
    End Sub

End Class


Public NotInheritable Class GoogleMapType
    Public Const NORMAL_MAP As String = "G_NORMAL_MAP"
    Public Const SATELLITE_MAP As String = "G_SATELLITE_MAP"
    Public Const HYBRID_MAP As String = "G_HYBRID_MAP"
End Class

Public Class cCommon
    ' 
    ' TODO: Add constructor logic here 
    ' 
    Public Sub New()
    End Sub
    Public Shared random As New Random()
    Public Shared Function IsNumeric(ByVal s As Object) As Boolean
        Try
            Double.Parse(s.ToString())
        Catch
            Return False
        End Try
        Return True
    End Function


    Public Shared Function GetIntegerValue(ByVal pNumValue As Object) As Integer
        If (pNumValue Is Nothing) Then
            Return 0
        End If
        If IsNumeric(pNumValue) Then
            Return Integer.Parse((pNumValue.ToString()))
        Else
            Return 0
        End If
    End Function


    Public Shared Function GeocodeAddress(ByVal GP As GooglePoint, ByVal GoogleAPIKey As String) As Boolean
        Dim sURL As String = "http://maps.google.com/maps/geo?q=" + GP.Address + "&output=xml&key=" + GoogleAPIKey
        Dim request As WebRequest = WebRequest.Create(sURL)
        request.Proxy = New WebProxy("http://172.21.34.46:8080", True)
        request.Proxy.Credentials = New System.Net.NetworkCredential("ebiz.aeu", "@dvantech1", "AESC_NT")
        request.Timeout = 10000
        ' Set the Method property of the request to POST. 
        request.Method = "POST"
        ' Create POST data and convert it to a byte array. 
        Dim postData As String = "This is a test that posts this string to a Web server."
        Dim byteArray As Byte() = Encoding.UTF8.GetBytes(postData)
        ' Set the ContentType property of the WebRequest. 
        request.ContentType = "application/x-www-form-urlencoded"
        ' Set the ContentLength property of the WebRequest. 
        request.ContentLength = byteArray.Length
        ' Get the request stream. 
        Dim dataStream As Stream = request.GetRequestStream()

        ' Write the data to the request stream. 
        dataStream.Write(byteArray, 0, byteArray.Length)
        ' Close the Stream object. 
        dataStream.Close()
        ' Get the response. 
        Dim response As WebResponse = request.GetResponse()
        ' Display the status. 
        'Console.WriteLine(((HttpWebResponse)response).StatusDescription); 
        ' Get the stream containing content returned by the server. 
        dataStream = response.GetResponseStream()
        ' Open the stream using a StreamReader for easy access. 
        Dim reader As New StreamReader(dataStream)
        ' Read the content. 
        Dim responseFromServer As String = reader.ReadToEnd()

        Dim tx As New StringReader(responseFromServer)

        'return false; 
        'System.Xml.XmlReader xr = new System.Xml.XmlReader(); 

        'return false; 

        Dim DS As New DataSet()
        DS.ReadXml(tx)
        'DS.ReadXml(dataStream); 
        'DS.ReadXml(tx); 



        Dim StatusCode As Integer = cCommon.GetIntegerValue(DS.Tables("Status").Rows(0)("code"))
        If StatusCode = 200 Then
            Dim sLatLon As String = cCommon.GetStringValue(DS.Tables("Point").Rows(0)("coordinates"))
            Dim s As String() = sLatLon.Split(","c)
            If s.Length > 1 Then
                GP.Latitude = cCommon.GetNumericValue(s(1))
                GP.Longitude = cCommon.GetNumericValue(s(0))
            End If
            If DS.Tables("Placemark") IsNot Nothing Then
                GP.Address = cCommon.GetStringValue(DS.Tables("Placemark").Rows(0)("address"))
            End If
            If DS.Tables("PostalCode") IsNot Nothing Then
                GP.Address += " " + cCommon.GetStringValue(DS.Tables("PostalCode").Rows(0)("PostalCodeNumber"))
            End If
            Return True
        End If
        Return False

    End Function




    Public Shared Function GetNumericValue(ByVal pNumValue As Object) As Double
        If (pNumValue Is Nothing) Then
            Return 0
        End If
        If IsNumeric(pNumValue) Then
            Return Double.Parse((pNumValue.ToString()))
        Else
            Return 0
        End If
    End Function

    Public Shared Function GetStringValue(ByVal obj As Object) As String
        If obj Is Nothing Then
            Return ""
        End If
        If (obj Is Nothing) Then
            Return ""
        End If
        If Not (obj Is Nothing) Then
            Return obj.ToString()
        Else
            Return ""
        End If
    End Function
    Public Shared Function GetHttpURL() As String
        Dim s As String() = System.Web.HttpContext.Current.Request.Url.AbsoluteUri.Split(New Char() {"/"c})
        Dim path As String = s(0) + "/"
        For i As Integer = 1 To s.Length - 2
            path = path + s(i) + "/"
        Next
        Return path
    End Function

    Public Shared Function GetLocalPath() As String
        Dim s As String() = System.Web.HttpContext.Current.Request.Url.AbsoluteUri.Split(New Char() {"/"c})
        Dim PageName As String = s(s.Length - 1)
        s = System.Web.HttpContext.Current.Request.MapPath(PageName).Split(New Char() {"\"c})
        Dim path As String = s(0) + "\"
        For i As Integer = 1 To s.Length - 2
            path = path + s(i) + "\"
        Next
        Return path
    End Function

    Public Shared Function RandomNumber(ByVal min As Decimal, ByVal max As Decimal) As Decimal
        Dim Fractions As Decimal = 10000000
        Dim iMin As Integer = CInt(GetIntegerPart(min * Fractions))
        Dim iMax As Integer = CInt(GetIntegerPart(max * Fractions))
        Dim iRand As Integer = random.[Next](iMin, iMax)

        Dim dRand As Decimal = CDec(iRand)
        dRand = dRand / Fractions

        Return dRand
    End Function


    Public Shared Function GetFractional(ByVal source As Decimal) As Decimal
        Return source Mod 1D
    End Function

    Public Shared Function GetIntegerPart(ByVal source As Decimal) As Decimal
        Return Decimal.Parse(source.ToString("#.00"))
    End Function

End Class

Public Class GooglePolygon
    Private _status As String = ""
    'N-New, D-Deleted, C-Changed, ''-No Action 
    Public Property Status() As String
        Get
            Return _status
        End Get
        Set(ByVal value As String)
            _status = value
        End Set
    End Property

    Private _id As String = ""
    Public Property ID() As String
        Get
            Return _id
        End Get
        Set(ByVal value As String)
            _id = value
        End Set
    End Property

    Private _gpoints As New GooglePoints()
    Public Property Points() As GooglePoints
        Get
            Return _gpoints
        End Get
        Set(ByVal value As GooglePoints)
            _gpoints = value
        End Set
    End Property

    Private _strokecolor As String = "#0000FF"
    Public Property StrokeColor() As String
        Get
            Return _strokecolor
        End Get
        Set(ByVal value As String)
            _strokecolor = value
        End Set
    End Property

    Private _fillcolor As String = "#66FF00"
    Public Property FillColor() As String
        Get
            Return _fillcolor
        End Get
        Set(ByVal value As String)
            _fillcolor = value
        End Set
    End Property

    Private _strokeweight As Integer = 10
    Public Property StrokeWeight() As Integer
        Get
            Return _strokeweight
        End Get
        Set(ByVal value As Integer)
            _strokeweight = value
        End Set
    End Property

    Private _strokeopacity As Double = 1
    Public Property StrokeOpacity() As Double
        Get
            Return _strokeopacity
        End Get
        Set(ByVal value As Double)
            _strokeopacity = value
        End Set
    End Property

    Private _fillopacity As Double = 0.2
    Public Property FillOpacity() As Double
        Get
            Return _fillopacity
        End Get
        Set(ByVal value As Double)
            _fillopacity = value
        End Set
    End Property

    Public Overloads Overrides Function Equals(ByVal obj As Object) As Boolean
        ' If parameter is null return false. 
        If obj Is Nothing Then
            Return False
        End If

        ' If parameter cannot be cast to Point return false. 
        Dim p As GooglePolygon = TryCast(obj, GooglePolygon)
        If DirectCast(p, Object) Is Nothing Then
            Return False
        End If

        ' Return true if the fields match: 
        Return (FillColor = p.FillColor) AndAlso (FillOpacity = p.FillOpacity) AndAlso (p.ID = ID) AndAlso (p.Status = Status) AndAlso (p.StrokeColor = StrokeColor) AndAlso (p.StrokeOpacity = StrokeOpacity) AndAlso (p.StrokeWeight = StrokeWeight) AndAlso (p.Points.Equals(Points))
    End Function

End Class

Public Class GooglePolygons
    Inherits CollectionBase

    Public Sub New()
    End Sub

    Public Shared Function CloneMe(ByVal prev As GooglePolygons) As GooglePolygons
        Dim p As New GooglePolygons()
        For i As Integer = 0 To prev.Count - 1
            Dim GPL As New GooglePolygon()
            GPL.FillColor = prev(i).FillColor
            GPL.FillOpacity = prev(i).FillOpacity
            GPL.ID = prev(i).ID
            GPL.Status = prev(i).Status
            GPL.StrokeColor = prev(i).StrokeColor
            GPL.StrokeOpacity = prev(i).StrokeOpacity
            GPL.StrokeWeight = prev(i).StrokeWeight
            GPL.Points = GooglePoints.CloneMe(prev(i).Points)
            p.Add(GPL)
        Next
        Return p
    End Function

    Default Public Property Item(ByVal pIndex As Integer) As GooglePolygon
        Get
            Return DirectCast(Me.List(pIndex), GooglePolygon)
        End Get
        Set(ByVal value As GooglePolygon)
            Me.List(pIndex) = value
        End Set
    End Property

    Default Public Property Item(ByVal pID As String) As GooglePolygon
        Get
            For i As Integer = 0 To Count - 1
                If Me(i).ID = pID Then
                    Return DirectCast(Me.List(i), GooglePolygon)
                End If
            Next
            Return Nothing
        End Get
        Set(ByVal value As GooglePolygon)
            For i As Integer = 0 To Count - 1
                If Me(i).ID = pID Then
                    Me.List(i) = value
                End If
            Next
        End Set
    End Property

    Public Sub Add(ByVal pPolygon As GooglePolygon)
        Me.List.Add(pPolygon)
    End Sub
    Public Sub Remove(ByVal pIndex As Integer)
        Me.RemoveAt(pIndex)
    End Sub
    Public Sub Remove(ByVal pID As String)
        For i As Integer = 0 To Count - 1
            If Me(i).ID = pID Then
                Me.List.RemoveAt(i)
                Return
            End If
        Next
    End Sub

End Class