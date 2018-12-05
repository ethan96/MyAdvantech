//var data = [
//    { "Url": "test.com", "Title": "testTitle" },
//    { "Url": "tes2.com", "Title": "testTitlh" }
//];

var app = angular.module('CMSApp', []).value('data', data);

app.controller({
    'CMSCtrl': [
                    '$scope', 'data', function CMSCtrl($scope, data) {
                        var me = this;
                        me.DataList = data.CMSList;
                        me.SortConfig = [
                            { "Name": "CMS Name", "Width": "75%", "Sort": true },
                            { "Name": "Released Date", "Width": "15%", "Sort": true },
                            { "Name": "Video Link", "Width": "10%", "Sort": false }
                        ];

                        me.Sort = data.Sort;                     

                        me.sortByName = function () {
                            if (me.Sort.SortColumn == "NAME") {
                                me.Sort.NameAsc = !me.Sort.NameAsc;
                                me.Sort.NameDesc = !me.Sort.NameDesc;
                            }

                            if (me.Sort.NameAsc) {
                                me.Sort.DESC = false;
                            }
                            else if (me.Sort.NameDesc) {
                                me.Sort.DESC = true
                            }
                            else {
                                me.Sort.DESC = false;
                                me.Sort.NameAsc = true;
                                me.Sort.NameDesc = false;
                            }

                            me.Sort.SortColumn = "NAME";
                            me.Sort.DateAsc = false;
                            me.Sort.DateDesc = false;
                        }

                        me.sortByDate = function () {
                            if (me.Sort.SortColumn == "RELEASEDATE") {
                                me.Sort.DateAsc = !me.Sort.DateAsc;
                                me.Sort.DateDesc = !me.Sort.DateDesc;
                            }

                            if (me.Sort.DateAsc) {
                                me.Sort.DESC = false;
                            }
                            else if (me.Sort.DateDesc) {
                                me.Sort.DESC = true;
                            }
                            else {
                                me.Sort.DESC = false;
                                me.Sort.DateAsc = true;
                                me.Sort.DateDesc = false;
                            }

                            me.Sort.SortColumn = "RELEASEDATE";
                            me.Sort.NameAsc = false;
                            me.Sort.NameDesc = false;
                        }

                        

                    }
    ]
});