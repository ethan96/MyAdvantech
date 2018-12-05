Imports Microsoft.VisualBasic

Public Class EnumSetting
    Enum USPrintOutFormat As Integer
        MAIN_ITEM_ONLY = 0
        SUB_ITEM_WITH_SUB_ITEM_PRICE = 1
        SUB_ITEM_WITHOUT_SUB_ITEM_PRICE = 2
        SUB_ITEM_WITHPARTNO_WITHOUT_SUB_ITEM_PRICE = 3
    End Enum

    Public Enum EarlyShipmentSetting As Integer
        Early_Shipment_Allowed = 1
        Early_Shipment_Not_Allowed = 2
    End Enum

End Class

''' <summary>
''' USer Type
''' </summary>
''' <remarks>目前需要辨識的user種類有內部使用者,加盟商及一般客戶</remarks>
Public Enum UserType

    ''' <summary>
    ''' Internal user
    ''' </summary>
    ''' <remarks></remarks>
    Internal

    ''' <summary>
    ''' franchiser 
    ''' </summary>
    ''' <remarks></remarks>
    Franchiser

    ''' <summary>
    ''' general Customer
    ''' </summary>
    ''' <remarks></remarks>
    Customer

End Enum


