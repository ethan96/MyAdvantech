﻿Imports Microsoft.VisualBasic

Public Class tbBase
    Dim _conn As String = ""
    Dim _tb As String = ""
    Public Property conn As String
        Set(ByVal value As String)
            _conn = value
        End Set
        Get
            Return _conn
        End Get
    End Property
    Public Property tb As String
        Set(ByVal value As String)
            _tb = value
        End Set
        Get
            Return _tb
        End Get
    End Property
    Public Function GetDTbySelectStr(ByVal selectStr As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable(_conn, selectStr)
        Return dt
    End Function
    Public Function GetDT(ByVal whereStr As String, ByVal orderStr As String) As DataTable
        Dim str As String = ""
        If whereStr <> "" Then
            whereStr = "where " & whereStr
        End If
        If orderStr <> "" Then
            orderStr = "order by " & orderStr
        End If
        str = String.Format("select * from {0} {1} {2}", _tb, whereStr, orderStr)
        Dim dt As DataTable = dbUtil.dbGetDataTable(_conn, str)
        Return dt
    End Function
    Public Function Delete(ByVal whereStr As String) As Integer
        Dim str As String = String.Format("delete from {1} where {0}", whereStr, _tb)
        dbUtil.dbExecuteNoQuery(_conn, str)
        Return 1
    End Function

    Public Function Update(ByVal whereStr As String, ByVal setStr As String) As Integer
        Dim str As String = String.Format("update {2} set {0} where {1}", setStr, whereStr, _tb)
        dbUtil.dbExecuteNoQuery(_conn, str)
        Return 1
    End Function
    Public Function UpdateShareConn(ByVal whereStr As String, ByVal setStr As String, ByVal conn As SqlClient.SqlConnection) As Integer
        Dim str As String = String.Format("update {2} set {0} where {1}", setStr, whereStr, _tb)
        dbUtil.dbExecuteNoQueryShareConn(conn, str)
        Return 1
    End Function
    Public Function IsExists(ByVal whereStr As String) As Integer
        Dim dt As DataTable = dbUtil.dbGetDataTable(_conn, String.Format("select top 1 * from {1} where {0}", whereStr, _tb))
        If dt.Rows.Count > 0 Then
            Return 1
        End If
        Return 0
    End Function

    Public Overloads Function Add() As Integer
        Return 1
    End Function

End Class