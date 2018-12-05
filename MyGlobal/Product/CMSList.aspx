<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CMSList.aspx.vb" Inherits="Product_CMSList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="/JS/angular.js"></script>
    <script type="text/javascript" src="/product/CMSList.aspx?json=1"></script>
    <script type="text/javascript" src="/JS/CMS.js"></script>
    <div ng-app="CMSApp">
        <table id="CMSList" width="100%" border="1" ng-controller="CMSCtrl as CMS">          
            <thead>
                <tr>                    
                    <th ng-class="{sort : true, sortASC : CMS.Sort.NameAsc, sortDESC: CMS.Sort.NameDesc}" ng-click ="CMS.sortByName()" style="width: 75%">CMS Name</th>
                    <th ng-class="{sort : true, sortASC : CMS.Sort.DateAsc, sortDESC: CMS.Sort.DateDesc}" ng-click ="CMS.sortByDate()" style="width: 15%">Released Date</th>
                    <th style="10%">Video Link</th>
                </tr>
            </thead>
            <tr ng-repeat="value in CMS.DataList | orderBy: CMS.Sort.SortColumn : CMS.Sort.DESC" ng-class="{trEven : $even}">
                <td>{{value.NAME}}</td>
                <td align="center">{{value.RELEASEDATE}}</td>
                <td align="center">
                    <a title="Play Vedio" href="{{value.URL}}" target="_blank">
                        <img src="/Images/play.png" width="50" />
                    </a>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

