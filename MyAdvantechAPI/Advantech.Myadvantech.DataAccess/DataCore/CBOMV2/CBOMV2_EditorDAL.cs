﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Reflection;
using System.Data.SqlClient;
using System.Configuration;


namespace Advantech.Myadvantech.DataAccess
{
    public static class CBOMV2_EditorDAL
    {
        public static String InitializeTree(String rootid, String orgid)
        {
            List<EasyUITreeNode> TreeNodes = new List<EasyUITreeNode>();
            List<CBOM_CATEGORY_RECORD> CBOMCategoryRecords = GetCBOMCategoryTreeByRootId(rootid, orgid);
            List<CBOM_CATEGORY_RECORD> RootRecord = (from q in CBOMCategoryRecords where q.LEVEL == 2 select q).ToList();

            if (RootRecord.Count == 1)
            {
                CheckSharedCategory(new List<String>(), ref CBOMCategoryRecords);
                EasyUITreeNode RootTreeNode = new EasyUITreeNode(RootRecord.First().ID, RootRecord.First().ID, RootRecord.First().CATEGORY_ID, "", RootRecord.First().HIE_ID, "", 0, 0, 1, 0, 0, 0, 0);
                RootTreeNode.csstype = NodeCssType.Tree_Node_Root;
                CBOMCategoryRecordsToEasyUITreeNode(CBOMCategoryRecords, RootTreeNode);
                TreeNodes.Add(RootTreeNode);
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(TreeNodes);
        }

        public static List<CBOM_CATEGORY_RECORD> GetCBOMCategoryTreeByRootId(string RootId, string OrgId)
        {
            String str = " DECLARE @ID  hierarchyid " +
                         " SELECT @ID  = HIE_ID " +
                         " FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + RootId + "' AND ORG = '" + OrgId + "' " +
                         " SELECT IsNull(cast(HIE_ID.GetAncestor(1) as nvarchar(100)),'') as PAR_HIE_ID, " +
                         " HIE_ID.GetLevel() AS [LEVEL], ID AS [ID], ID AS [VIRTUAL_ID], " +
                         " HIE_ID.ToString() AS [HIE_ID],CATEGORY_ID, CATEGORY_TYPE, " +
                         " CATEGORY_NOTE,SEQ_NO,CONFIGURATION_RULE as CONFIGURATION_RULE, ORG, " +
                         " DEFAULT_FLAG as isDefault, REQUIRED_FLAG as isRequired, EXPAND_FLAG as isExpand, " +
                         " SHARED_CATEGORY_ID AS [SHARED_CATEGORY_GUID], MAX_QTY AS [QTY] " +
                         " FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1 " +
                         " ORDER BY HIE_ID.GetLevel() ";

            DataTable dtCategoryTree = SqlProvider.dbGetDataTable("CBOMV2", str);
            List<CBOM_CATEGORY_RECORD> CBOMCategoryRecords = dtCategoryTree.DataTableToList<CBOM_CATEGORY_RECORD>();
            return CBOMCategoryRecords;
        }

        public static void CBOMCategoryRecordsToEasyUITreeNode(List<CBOM_CATEGORY_RECORD> CBOMCategoryRecords, EasyUITreeNode CurrentNode)
        {
            String CurrentNodeHieId = CurrentNode.hieid;
            List<CBOM_CATEGORY_RECORD> SubRecord = (from q in CBOMCategoryRecords where q.PAR_HIE_ID == CurrentNodeHieId orderby q.SEQ_NO, q.CATEGORY_ID select q).ToList();

            if (SubRecord.Count == 0)
                return;


            //Find out if all values in an enumerable are unique :
            var allUnique = SubRecord.GroupBy(x => x.SEQ_NO).All(g => g.Count() == 1);
            if (!allUnique)
            {
                //請大大幫我寫一個update照目前seq與字母排序然後更新seq的指令吧
                int i = 0;
                StringBuilder sql = new StringBuilder();
                foreach (CBOM_CATEGORY_RECORD SubRecord_loopVariable in SubRecord)
                {
                    if (SubRecord_loopVariable.SEQ_NO != i)
                    {
                        sql.AppendFormat("Update CBOM_CATALOG_CATEGORY_V2 SET SEQ_NO = {0} WHERE ID = '{1}'; ", i, SubRecord_loopVariable.ID);
                        SubRecord_loopVariable.SEQ_NO = i;
                    }
                    i += 1;
                }
                if (!string.IsNullOrEmpty(sql.ToString()))
                    SqlProvider.dbExecuteNoQuery("CBOMV2", sql.ToString());
            }


            foreach (CBOM_CATEGORY_RECORD SubRecord_loopVariable in SubRecord)
            {
                EasyUITreeNode SubTreeNode = new EasyUITreeNode(SubRecord_loopVariable.ID, System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 5) + SubRecord_loopVariable.VIRTUAL_ID, SubRecord_loopVariable.CATEGORY_ID, CurrentNode.id, SubRecord_loopVariable.HIE_ID, SubRecord_loopVariable.CATEGORY_NOTE, (int)SubRecord_loopVariable.CATEGORY_TYPE, SubRecord_loopVariable.SEQ_NO, SubRecord_loopVariable.QTY
                    , SubRecord_loopVariable.isExpand, SubRecord_loopVariable.isRequired, SubRecord_loopVariable.isDefault, SubRecord_loopVariable.CONFIGURATION_RULE);

                switch (SubRecord_loopVariable.CATEGORY_TYPE)
                {
                    case CategoryTypes.Category:
                        SubTreeNode.csstype = NodeCssType.Tree_Node_Category;
                        break;
                    case CategoryTypes.Component:
                        SubTreeNode.csstype = NodeCssType.Tree_Node_Component;
                        break;
                    case CategoryTypes.SharedCategory:
                        SubTreeNode.csstype = NodeCssType.Tree_Node_Shared_Category;
                        break;
                    case CategoryTypes.SharedComponent:
                        SubTreeNode.csstype = NodeCssType.Tree_Node_Shared_Component;
                        break;
                    case CategoryTypes.Root:
                        SubTreeNode.csstype = NodeCssType.Tree_Node_Root;
                        break;
                    default:
                        break;
                }

                CurrentNode.children.Add(SubTreeNode);
                CBOMCategoryRecordsToEasyUITreeNode(CBOMCategoryRecords, SubTreeNode);
            }
        }

        public static void CheckSharedCategory(List<String> list, ref List<CBOM_CATEGORY_RECORD> CBOMCategoryRecords)
        {
            List<CBOM_CATEGORY_RECORD> copy = new List<CBOM_CATEGORY_RECORD>();
            copy.AddRange(CBOMCategoryRecords);

            foreach (CBOM_CATEGORY_RECORD c in copy)
            {
                if ((c.CATEGORY_TYPE == CategoryTypes.SharedCategory || c.CATEGORY_TYPE == CategoryTypes.SharedComponent) && !list.Contains(c.VIRTUAL_ID))
                {
                    list.Add(c.VIRTUAL_ID);
                    GetSharedCategory(ref CBOMCategoryRecords, c.ID.Substring(0, 5), c.HIE_ID, c.SHARED_CATEGORY_GUID);
                }
            }

            copy.RemoveAll(d => d.ID != String.Empty);
            copy.AddRange(CBOMCategoryRecords);
            if (copy.Where(d => (d.CATEGORY_TYPE == CategoryTypes.SharedCategory || d.CATEGORY_TYPE == CategoryTypes.SharedComponent) && !list.Contains(d.VIRTUAL_ID)).Any())
            {
                CheckSharedCategory(list, ref CBOMCategoryRecords);
            }
        }

        public static void GetSharedCategory(ref List<CBOM_CATEGORY_RECORD> CBOMCategoryRecords, String VirtualID, String HIEID, String SharedGUID)
        {
            String str = " DECLARE @ID  hierarchyid " +
                         " SELECT @ID  = HIE_ID " +
                         " FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + SharedGUID + "' " +
                         " SELECT IsNull('" + VirtualID + "_' + cast(HIE_ID.GetAncestor(1) as nvarchar(100)),'') as PAR_HIE_ID, " +
                         " HIE_ID.GetLevel() AS [LEVEL], ID AS [ID], '" + VirtualID + "_' + ID AS [VIRTUAL_ID], " +
                         " '" + VirtualID + "_' + HIE_ID.ToString() AS [HIE_ID], CATEGORY_ID, CATEGORY_TYPE, " +
                         " CATEGORY_NOTE, SEQ_NO, CONFIGURATION_RULE, ORG, " +
                         " DEFAULT_FLAG as [isDefault], REQUIRED_FLAG as [isRequired], EXPAND_FLAG as [isExpand], " +
                         " SHARED_CATEGORY_ID AS [SHARED_CATEGORY_GUID], MAX_QTY AS [QTY] " +
                         " FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1 " +
                         " ORDER BY HIE_ID.GetLevel() ";

            DataTable dtCategoryTree = SqlProvider.dbGetDataTable("CBOMV2", str);
            List<CBOM_CATEGORY_RECORD> SharedRecords = DataTableToList<CBOM_CATEGORY_RECORD>(dtCategoryTree) as List<CBOM_CATEGORY_RECORD>;

            SharedRecords.Remove(SharedRecords.Where(c => c.LEVEL == 2).FirstOrDefault());
            SharedRecords.Where(c => c.LEVEL == 3).ToList().ForEach(c => c.PAR_HIE_ID = HIEID);

            CBOMCategoryRecords.AddRange(SharedRecords);
        }

        public static int GetSeqNo(String _parentguid)
        {
            String str = "DECLARE @Child hierarchyid " +
                            " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                            " WHERE ID = '" + _parentguid + "'" +
                            " SELECT ISNULL(MAX(SEQ_NO),0) AS [SEQ_NO] " +
                            " FROM CBOM_CATALOG_CATEGORY_V2 " +
                            " WHERE HIE_ID.GetAncestor(1) = @Child ";

            return Convert.ToInt32(SqlProvider.dbExecuteScalar("CBOMV2", str)) + 1;
        }

        public static Boolean HasRepeatBrother(String _parentguid, String _categoryid)
        {
            String str = "DECLARE @Child hierarchyid " +
                         " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                         " WHERE ID = '" + _parentguid + "' " +
                         " SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 " +
                         " WHERE HIE_ID.GetAncestor(1) = @Child " +
                         " AND CATEGORY_ID = N'" + _categoryid + "'";
            int count = Convert.ToInt32(SqlProvider.dbExecuteScalar("CBOMV2", str));
            return (count > 0) ? true : false;
        }


        // Deprecated, due to shared node's parent will changed, below is useless in shared situation.
        public static Boolean HasRepeatAncestor(String _parentguid, String _sharedguid)
        {
            String str = " DECLARE @h hierarchyid " +
                         " SELECT @h = HIE_ID " +
                         " FROM CBOM_CATALOG_CATEGORY_V2  " +
                         " WHERE ID='" + _parentguid + "' " +
                         " SELECT CATEGORY_ID, ID, SHARED_CATEGORY_ID " +
                         " FROM CBOM_CATALOG_CATEGORY_V2 AS ED " +
                         " JOIN ListAncestors(@h) AS la " +
                         " ON ED.HIE_ID = la.Node ";
            DataTable dt = SqlProvider.dbGetDataTable("CBOMV2", str);

            if (dt != null && dt.Rows.Count > 0)
            {
                foreach (DataRow d in dt.Rows)
                {
                    if (d["SHARED_CATEGORY_ID"].ToString().Equals(_sharedguid, StringComparison.OrdinalIgnoreCase))
                        return true;
                }
                return false;
            }
            else
                return false;
        }

        public static List<T> DataTableToList<T>(this DataTable dt)
        {
            const BindingFlags flags = BindingFlags.Public | BindingFlags.Instance;
            var columnNames = dt.Columns.Cast<DataColumn>()
                .Select(c => c.ColumnName)
                .ToList();
            var objectProperties = typeof(T).GetProperties(flags);
            var targetList = dt.AsEnumerable().Select(dataRow =>
            {
                var instanceOfT = Activator.CreateInstance<T>();

                foreach (var properties in objectProperties.Where(properties => columnNames.Contains(properties.Name) && dataRow[properties.Name] != DBNull.Value))
                {
                    properties.SetValue(instanceOfT, dataRow[properties.Name], null);
                }
                return instanceOfT;
            }).ToList();

            return targetList;
        }


        #region Method
        public static string AddComponent(string ParentGUID, string CategoryID, string CategoryNote, string CategoryType, string IsExpand, string IsDefault, string OrgID, string ConfigurationRule)
        {
            Boolean is_expand = IsExpand.Equals("0") ? false : true;
            Boolean is_default = IsDefault.Equals("0") ? false : true;
            Boolean is_ParentShared = (CategoryType.Equals("3") || CategoryType.Equals("4")) ? true : false;

            UpdateDBResult res = new UpdateDBResult();

            try
            {
                string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                int seq = 0;

                if (is_ParentShared)
                {
                    // 若要在shared category節點下新增node, 則要去找出真正的parent id
                    String RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();

                    if (!HasRepeatBrother(RealParentGUID, CategoryID))
                    {
                        seq = GetSeqNo(RealParentGUID);
                        Tuple<bool, string> result = CreateNew(RealParentGUID, guid, CategoryID, (int)CategoryTypes.Component, CategoryNote, seq, Convert.ToInt32(ConfigurationRule), OrgID, "", 1, Convert.ToInt32(is_expand), 0, Convert.ToInt32(is_default));

                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Component is already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
                else
                {
                    if (!HasRepeatBrother(ParentGUID, CategoryID))
                    {
                        seq = GetSeqNo(ParentGUID);
                        Tuple<bool, string> result = CreateNew(ParentGUID, guid, CategoryID, (int)CategoryTypes.Component, CategoryNote, seq, Convert.ToInt32(ConfigurationRule), OrgID, "", 1, Convert.ToInt32(is_expand), 0, Convert.ToInt32(is_default));

                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Component is already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string AddSharedComponent(string ParentGUID, string CategoryID, string CategoryNote, string CategoryType, string IsExpand, string IsDefault, string OrgID, string ConfigurationRule)
        {
            Boolean is_expand = IsExpand.Equals("0") ? false : true;
            Boolean is_default = IsDefault.Equals("0") ? false : true;
            Boolean is_ParentShared = (CategoryType.Equals("3") || CategoryType.Equals("4")) ? true : false;
            String sharedRoot = OrgID + "_Shared";

            UpdateDBResult res = new UpdateDBResult();

            try
            {
                // Check input component name is already set as a shared component or not.
                String CheckNameAvailable = "DECLARE @Child hierarchyid " +
                             " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE ID = '" + sharedRoot + "' " +
                             " SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE HIE_ID.GetAncestor(1) = @Child " +
                             " AND CATEGORY_ID = N'" + CategoryID + "' AND CATEGORY_TYPE = '2'";
                if (Convert.ToInt32(SqlProvider.dbExecuteScalar("CBOMV2", CheckNameAvailable)) > 0)
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "This component is already set as a shared component, please check again.";
                    return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                }

                string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                string sharedguid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                int seq = 0;

                if (is_ParentShared)
                {
                    // 若要在shared category節點下新增node, 則要去找出真正的parent id
                    String RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();

                    if (!HasRepeatBrother(RealParentGUID, CategoryID))
                    {
                        // to create a new node under "Shared_Category"                
                        Tuple<bool, string> result0 = CreateNew(sharedRoot, sharedguid, CategoryID, (int)CategoryTypes.Component, CategoryNote, 0, Convert.ToInt32(ConfigurationRule), OrgID, "", 1, Convert.ToInt32(IsExpand), 0, Convert.ToInt32(IsDefault));
                        // if create new node to database failed, return false
                        if (!result0.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }

                        // to create node in its own tree side
                        seq = GetSeqNo(RealParentGUID);
                        Tuple<bool, string> result = CreateNew(RealParentGUID, guid, CategoryID, (int)CategoryTypes.SharedComponent, CategoryNote, seq, Convert.ToInt32(ConfigurationRule), OrgID, sharedguid, 1, Convert.ToInt32(is_expand), 0, Convert.ToInt32(is_default));
                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Component is already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
                else
                {
                    if (!HasRepeatBrother(ParentGUID, CategoryID))
                    {
                        // to create a new node under "Shared_Category"                
                        Tuple<bool, string> result0 = CreateNew(sharedRoot, sharedguid, CategoryID, (int)CategoryTypes.Component, CategoryNote, 0, Convert.ToInt32(ConfigurationRule), OrgID, "", 1, Convert.ToInt32(IsExpand), 0, Convert.ToInt32(IsDefault));
                        // if create new node to database failed, return false
                        if (!result0.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }

                        // to create node in its own tree side
                        seq = GetSeqNo(ParentGUID);
                        Tuple<bool, string> result = CreateNew(ParentGUID, guid, CategoryID, (int)CategoryTypes.SharedComponent, CategoryNote, GetSeqNo(ParentGUID), Convert.ToInt32(ConfigurationRule), OrgID, sharedguid, 1, Convert.ToInt32(is_expand), 0, Convert.ToInt32(is_default));
                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Component is already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string CopySharedComponent(string ParentGUID, string CategoryID, string CategoryNote, string CategoryType, string IsExpand, string IsDefault, string SharedGUID, string OrgID, string ConfigurationRule)
        {
            Boolean is_expand = IsExpand.Equals("0") ? false : true;
            Boolean is_default = IsDefault.Equals("0") ? false : true;
            Boolean is_ParentShared = (CategoryType.Equals("3") || CategoryType.Equals("4")) ? true : false;

            UpdateDBResult res = new UpdateDBResult();

            try
            {
                // To prevent "user choose shared component then remove the auto complete tag and add normal component"'s bug.
                if (!CategoryID.Equals(SqlProvider.dbExecuteScalar("CBOMV2", "select CATEGORY_ID from CBOM_CATALOG_CATEGORY_V2 where ID = '" + SharedGUID + "'").ToString()))
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Component name is different with copied one.";
                    return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                }

                string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                int seq = 0;

                if (is_ParentShared)
                {
                    // 若要在shared category節點下新增node, 則要去找出真正的parent id
                    String RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();

                    if (!HasRepeatBrother(RealParentGUID, CategoryID))
                    {
                        // to create node in its own tree side
                        seq = GetSeqNo(RealParentGUID);
                        Tuple<bool, string> result = CreateNew(RealParentGUID, guid, CategoryID, (int)CategoryTypes.SharedComponent, CategoryNote, seq, Convert.ToInt32(ConfigurationRule), OrgID, SharedGUID, 1, Convert.ToInt32(is_expand), 0, Convert.ToInt32(is_default));
                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Component is already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
                else
                {
                    if (!HasRepeatBrother(ParentGUID, CategoryID))
                    {
                        // to create node in its own tree side
                        seq = GetSeqNo(ParentGUID);
                        Tuple<bool, string> result = CreateNew(ParentGUID, guid, CategoryID, (int)CategoryTypes.SharedComponent, CategoryNote, GetSeqNo(ParentGUID), Convert.ToInt32(ConfigurationRule), OrgID, SharedGUID, 1, Convert.ToInt32(is_expand), 0, Convert.ToInt32(is_default));
                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Component is already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string AddCategory(string ParentGUID, string CategoryID, string CategoryNote, string CategoryType, string CategoryQty, string IsExpand, string IsRequired, string OrgID)
        {
            Boolean is_expand = IsExpand.Equals("0") ? false : true;
            Boolean is_required = IsRequired.Equals("0") ? false : true;
            Boolean is_ParentShared = (CategoryType.Equals("3") || CategoryType.Equals("4")) ? true : false;
            String sharedRoot = OrgID + "_Shared";

            UpdateDBResult res = new UpdateDBResult();

            try
            {
                // Check input category name is already used in shared category or not.
                String CheckNameAvailable = "DECLARE @Child hierarchyid " +
                             " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE ID = '" + sharedRoot + "' " +
                             " SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE HIE_ID.GetAncestor(1) = @Child " +
                             " AND CATEGORY_ID = N'" + CategoryID + "'";
                if (Convert.ToInt32(SqlProvider.dbExecuteScalar("CBOMV2", CheckNameAvailable)) > 0)
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Category name is already used by a shared category, please try another one.";
                    return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                }

                string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                int seq = 0;

                if (is_ParentShared)
                {
                    // 若要在shared component節點下新增category, 則要去找出真正的parent id
                    String RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();

                    if (!HasRepeatBrother(RealParentGUID, CategoryID))
                    {
                        seq = GetSeqNo(RealParentGUID);
                        Tuple<bool, string> result = CreateNew(RealParentGUID, guid, CategoryID, (int)CategoryTypes.Category, CategoryNote, seq, 0, OrgID, "", 1, Convert.ToInt32(is_expand), Convert.ToInt32(IsRequired), 0);

                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Category name already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
                else
                {
                    if (!HasRepeatBrother(ParentGUID, CategoryID))
                    {
                        seq = GetSeqNo(ParentGUID);
                        Tuple<bool, string> result = CreateNew(ParentGUID, guid, CategoryID, (int)CategoryTypes.Category, CategoryNote, seq, 0, OrgID, "", Convert.ToInt32(CategoryQty), Convert.ToInt32(IsExpand), Convert.ToInt32(IsRequired), 0);

                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Category name already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string AddSharedCategory(string ParentGUID, string CategoryID, string CategoryNote, string CategoryType, string CategoryQty, string IsExpand, string IsRequired, string OrgID)
        {
            Boolean is_expand = IsExpand.Equals("0") ? false : true;
            Boolean is_required = IsRequired.Equals("0") ? false : true;
            Boolean is_ParentShared = (CategoryType.Equals("3") || CategoryType.Equals("4")) ? true : false;
            String sharedRoot = OrgID + "_Shared";

            UpdateDBResult res = new UpdateDBResult();

            try
            {
                // if input category name is already used, return add failed.
                if (Convert.ToInt32(SqlProvider.dbExecuteScalar("CBOMV2", "SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 WHERE CATEGORY_ID = '" + CategoryID + "' AND ORG = '" + OrgID + "'")) > 0)
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Category name is not available, please try another one.";
                    return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                }


                string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                string sharedguid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                int seq = 0;

                if (is_ParentShared)
                {
                    // 若要在shared component節點下新增category, 則要去找出真正的parent id
                    String RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();

                    if (!HasRepeatBrother(RealParentGUID, CategoryID))
                    {
                        // to create a new node under "Shared_Category"                
                        Tuple<bool, string> result0 = CreateNew(sharedRoot, sharedguid, CategoryID, (int)CategoryTypes.Category, CategoryNote, 0, 0, OrgID, "", Convert.ToInt32(CategoryQty), Convert.ToInt32(IsExpand), Convert.ToInt32(IsRequired), 0);
                        // if create new node to database failed, return false
                        if (!result0.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }

                        // to create node in its own tree side
                        seq = GetSeqNo(RealParentGUID);
                        Tuple<bool, string> result = CreateNew(RealParentGUID, guid, CategoryID, (int)CategoryTypes.SharedCategory, CategoryNote, seq, 0, OrgID, sharedguid, 1, Convert.ToInt32(is_expand), Convert.ToInt32(IsRequired), 0);
                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Category name already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }

                }
                else
                {
                    if (!HasRepeatBrother(ParentGUID, CategoryID))
                    {
                        // to create a new node under "Shared_Category"                
                        Tuple<bool, string> result0 = CreateNew(sharedRoot, sharedguid, CategoryID, (int)CategoryTypes.Category, CategoryNote, 0, 0, OrgID, "", Convert.ToInt32(CategoryQty), Convert.ToInt32(IsExpand), Convert.ToInt32(IsRequired), 0);
                        // if create new node to database failed, return false
                        if (!result0.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }

                        // to create node in its own tree side
                        seq = GetSeqNo(ParentGUID);
                        Tuple<bool, string> result = CreateNew(ParentGUID, guid, CategoryID, (int)CategoryTypes.SharedCategory, CategoryNote, seq, 0, OrgID, sharedguid, Convert.ToInt32(CategoryQty), Convert.ToInt32(IsExpand), Convert.ToInt32(IsRequired), 0);
                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Category name already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }

                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string CopySharedCategory(string ParentGUID, string CategoryID, string CategoryNote, string CategoryType, string CategoryQty, string IsExpand, string IsRequired, string SharedGUID, string OrgID)
        {
            Boolean is_expand = IsExpand.Equals("0") ? false : true;
            Boolean is_required = IsRequired.Equals("0") ? false : true;
            Boolean is_ParentShared = (CategoryType.Equals("3") || CategoryType.Equals("4")) ? true : false;

            UpdateDBResult res = new UpdateDBResult();

            try
            {
                string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                int seq = 0;

                if (is_ParentShared)
                {
                    // 若要在shared component節點下新增category, 則要去找出真正的parent id
                    String RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();

                    if (!HasRepeatBrother(RealParentGUID, CategoryID))
                    {
                        seq = GetSeqNo(RealParentGUID);
                        Tuple<bool, string> result = CreateNew(RealParentGUID, guid, CategoryID, (int)CategoryTypes.SharedCategory, CategoryNote, seq, 0, OrgID, SharedGUID, Convert.ToInt32(CategoryQty), Convert.ToInt32(is_expand), Convert.ToInt32(IsRequired), 0);

                        // if create new node to database failed, return false
                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating data to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Category name already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
                else
                {
                    if (!HasRepeatBrother(ParentGUID, CategoryID))
                    {
                        seq = GetSeqNo(ParentGUID);
                        Tuple<bool, string> result = CreateNew(ParentGUID, guid, CategoryID, (int)CategoryTypes.SharedCategory, CategoryNote, seq, 0, OrgID, SharedGUID, Convert.ToInt32(CategoryQty), Convert.ToInt32(IsExpand), Convert.ToInt32(IsRequired), 0);

                        if (!result.Item1)
                        {
                            res.IsUpdated = false;
                            res.ServerMessage = "Error occurs while creating to database.";
                            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                        }
                    }
                    else
                    {
                        res.IsUpdated = false;
                        res.ServerMessage = "Category name already existed in same level.";
                        return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                    }
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string UpdateSelectedNode(string GUID, string CategoryID, string Desc, string Type, string Qty, string isExpand, string isRequired, string isDefault, string ConfigurationRule)
        {
            UpdateDBResult res = new UpdateDBResult();
            Boolean is_NodeShared = (Type.Equals("3") || Type.Equals("4")) ? true : false;

            try
            {
                // if node is shared, need to update both tree side and shared side.
                if (is_NodeShared)
                {
                    String RealGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + GUID + "'").ToString();

                    String str = "update CBOM_CATALOG_CATEGORY_V2 " +
                                " set Category_ID = N'" + CategoryID + "', CATEGORY_NOTE = N'" + Desc + "', MAX_QTY = '" + Qty + "', " +
                                " EXPAND_FLAG = '" + isExpand + "', REQUIRED_FLAG = '" + isRequired + "', DEFAULT_FLAG = '" + isDefault + "', CONFIGURATION_RULE = '" + ConfigurationRule + "' " +
                                " where ID = N'" + RealGUID + "' OR SHARED_CATEGORY_ID = '" + RealGUID + "'";

                    SqlProvider.dbExecuteNoQuery("CBOMV2", str);
                }
                else
                {
                    String str = "update CBOM_CATALOG_CATEGORY_V2 " +
                                " set Category_ID = N'" + CategoryID + "', CATEGORY_NOTE = N'" + Desc + "', MAX_QTY = '" + Qty + "', " +
                                " EXPAND_FLAG = '" + isExpand + "', REQUIRED_FLAG = '" + isRequired + "', DEFAULT_FLAG = '" + isDefault + "', CONFIGURATION_RULE = '" + ConfigurationRule + "' " +
                                " where ID = N'" + GUID + "'";

                    SqlProvider.dbExecuteNoQuery("CBOMV2", str);
                }

                res.IsUpdated = true;
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string DeleteNode(string GUID, string NodeType)
        {
            UpdateDBResult res = new UpdateDBResult();

            try
            {
                CategoryTypes type = CategoryTypes.Root;
                if (Enum.TryParse<CategoryTypes>(NodeType, out type) == true)
                {
                    switch (type)
                    {
                        case CategoryTypes.Category:
                        case CategoryTypes.Component:
                        case CategoryTypes.SharedComponent:
                        case CategoryTypes.SharedCategory:
                            SqlProvider.dbExecuteNoQuery("CBOMV2", "delete from CBOM_CATALOG_CATEGORY_V2 where ID = '" + GUID + "'");
                            break;
                        case CategoryTypes.Root:
                        default:
                            break;
                    }
                }
                res.IsUpdated = true;
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string DropTreeNode(string parentid, string parenttype, string currentid, string currentseq, string targetid, string targetseq, string point)
        {
            UpdateDBResult res = new UpdateDBResult();
            int FinalSeq = 0;

            try
            {
                // if parent is shared, get real parent id.
                if (parenttype.Equals("3") || parenttype.Equals("4"))
                    parentid = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + parentid + "'").ToString();

                if (Convert.ToInt32(targetseq) < Convert.ToInt32(currentseq))
                    FinalSeq = point.Equals("top", StringComparison.OrdinalIgnoreCase) ? Convert.ToInt32(targetseq) : Convert.ToInt32(targetseq) + 1;
                else if (Convert.ToInt32(targetseq) > Convert.ToInt32(currentseq))
                    FinalSeq = point.Equals("top", StringComparison.OrdinalIgnoreCase) ? Convert.ToInt32(targetseq) - 1 : Convert.ToInt32(targetseq);
                else
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Invalid operation, please try again.";
                    return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                }

                // final seq = itself, no need to do anything, return false.
                if (FinalSeq == Convert.ToInt32(currentseq))
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Invalid operation - moving to current sequence.";
                    return Newtonsoft.Json.JsonConvert.SerializeObject(res);
                }

                String str = " DECLARE @ID  hierarchyid " +
                             " SELECT @ID  = HIE_ID " +
                             " FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + parentid + "' " +
                             " update CBOM_CATALOG_CATEGORY_V2 SET SEQ_NO = SEQ_NO " + (FinalSeq > Convert.ToInt32(currentseq) ? " -1 " : " +1 ") +
                             " WHERE HIE_ID.GetAncestor(1) = @ID " +
                             " AND SEQ_NO >= '" + (FinalSeq > Convert.ToInt32(currentseq) ? Convert.ToInt32(currentseq) : FinalSeq) + "'" +
                             " AND SEQ_NO <= '" + (FinalSeq > Convert.ToInt32(currentseq) ? FinalSeq : Convert.ToInt32(currentseq)) + "' ";
                SqlProvider.dbExecuteNoQuery("CBOMV2", str);
                SqlProvider.dbExecuteNoQuery("CBOMV2", String.Format(" update  CBOM_CATALOG_CATEGORY_V2 SET SEQ_NO = " + FinalSeq + " where ID = '" + currentid + "' "));

                res.IsUpdated = true;
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string ReOrderByAlphabetical(string GUID, string NodeType)
        {
            Boolean is_ParentShared = (NodeType.Equals("3") || NodeType.Equals("4")) ? true : false;
            UpdateDBResult res = new UpdateDBResult();
            String select_str = String.Empty, RealParentGUID = GUID;

            try
            {
                if (is_ParentShared)
                {
                    // 若要reorder shared category/component, 則要去找出真正的parent id
                    RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + GUID + "'").ToString();
                }

                select_str = " DECLARE @Child hierarchyid " +
                             " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE ID = '" + RealParentGUID + "' " +
                             " SELECT * FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE HIE_ID.GetAncestor(1) = @Child " +
                             " order by category_id ";
                DataTable dt = SqlProvider.dbGetDataTable("CBOMV2", select_str);

                if (dt != null && dt.Rows.Count > 0)
                {
                    int seq = 0;
                    String str1 = String.Empty;
                    List<String> str2 = new List<string>();

                    foreach (DataRow d in dt.Rows)
                    {
                        str1 += " WHEN '" + d["CATEGORY_ID"].ToString() + "' THEN '" + seq.ToString() + "' ";
                        str2.Add("'" + d["CATEGORY_ID"].ToString() + "'");
                        seq++;
                    }

                    String update_str = " UPDATE CBOM_CATALOG_CATEGORY_V2 " +
                             " SET SEQ_NO = CASE CATEGORY_ID " +
                             str1 +
                             " ELSE SEQ_NO " +
                             " END " +
                             " WHERE CATEGORY_ID IN " + "(" + String.Join(", ", str2.ToArray()) + ")" + "; ";
                    SqlProvider.dbExecuteNoQuery("CBOMV2", update_str);

                    res.IsUpdated = true;
                }
                else
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Children nodes not found.";
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        public static string ReOrderBySeq(string ParentGUID, string ParentNodeType)
        {
            Boolean is_ParentShared = (ParentNodeType.Equals("3") || ParentNodeType.Equals("4")) ? true : false;
            UpdateDBResult res = new UpdateDBResult();
            String select_str = String.Empty, RealParentGUID = ParentGUID;

            try
            {
                if (is_ParentShared)
                {
                    // 若要reorder shared category/component, 則要去找出真正的parent id
                    RealParentGUID = SqlProvider.dbExecuteScalar("CBOMV2", "select ISNULL(SHARED_CATEGORY_ID,'') from CBOM_CATALOG_CATEGORY_V2 where ID = '" + ParentGUID + "'").ToString();
                }

                select_str = " DECLARE @Child hierarchyid " +
                             " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE ID = '" + RealParentGUID + "' " +
                             " SELECT * FROM CBOM_CATALOG_CATEGORY_V2 " +
                             " WHERE HIE_ID.GetAncestor(1) = @Child " +
                             " ORDER BY SEQ_NO ";
                DataTable dt = SqlProvider.dbGetDataTable("CBOMV2", select_str);

                if (dt != null && dt.Rows.Count > 0)
                {
                    int seq = 0;
                    String str1 = String.Empty;
                    List<String> str2 = new List<string>();

                    foreach (DataRow d in dt.Rows)
                    {
                        str1 += " WHEN N'" + d["CATEGORY_ID"].ToString() + "' THEN '" + seq.ToString() + "' ";
                        str2.Add("'" + d["ID"].ToString() + "'");
                        seq++;
                    }

                    String update_str = " UPDATE CBOM_CATALOG_CATEGORY_V2 " +
                             " SET SEQ_NO = CASE CATEGORY_ID " +
                             str1 +
                             " ELSE SEQ_NO " +
                             " END " +
                             " WHERE ID IN " + "(" + String.Join(", ", str2.ToArray()) + ")" + "; ";
                    SqlProvider.dbExecuteNoQuery("CBOMV2", update_str);

                    res.IsUpdated = true;
                }
                else
                {
                    res.IsUpdated = false;
                    res.ServerMessage = "Children nodes not found.";
                }
            }
            catch (Exception ex)
            {
                res.IsUpdated = false;
                res.ServerMessage = ex.Message;
            }
            return Newtonsoft.Json.JsonConvert.SerializeObject(res);
        }

        #endregion

        public static Tuple<bool, string> CreateNew(String _parentid, String _guid, String _categoryid, int _categorytype,
          String _categorynote, int _seq, int _rule, String _org, String _sharedcategoryid, int _maxqty = 1,
          int _expflag = 0, int _reqflag = 0, int _deflag = 0)
        {
            SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["CBOMV2"].ConnectionString);
            SqlCommand cmd = new SqlCommand("SP_Insert_CBOM_Category_V2", conn);

            cmd.CommandType = System.Data.CommandType.StoredProcedure;

            cmd.Parameters.Add("@parentID", System.Data.SqlDbType.NVarChar, 30);
            cmd.Parameters["@parentID"].Value = _parentid;

            cmd.Parameters.Add("@guid", System.Data.SqlDbType.NVarChar, 30);
            cmd.Parameters["@guid"].Value = _guid;

            cmd.Parameters.Add("@categoryID", System.Data.SqlDbType.NVarChar, 200);
            cmd.Parameters["@categoryID"].Value = _categoryid;

            cmd.Parameters.Add("@categoryType", System.Data.SqlDbType.Int);
            cmd.Parameters["@categoryType"].Value = _categorytype;

            cmd.Parameters.Add("@categoryNote", System.Data.SqlDbType.NVarChar, 200);
            cmd.Parameters["@categoryNote"].Value = _categorynote;

            cmd.Parameters.Add("@seq", System.Data.SqlDbType.Int);
            cmd.Parameters["@seq"].Value = _seq;

            cmd.Parameters.Add("@rule", System.Data.SqlDbType.Int);
            cmd.Parameters["@rule"].Value = _rule;

            cmd.Parameters.Add("@ORG", System.Data.SqlDbType.NVarChar, 10);
            cmd.Parameters["@ORG"].Value = _org;

            cmd.Parameters.Add("@Share", System.Data.SqlDbType.NVarChar, 200);
            cmd.Parameters["@Share"].Value = _sharedcategoryid;

            cmd.Parameters.Add("@MaxQty", System.Data.SqlDbType.Int);
            cmd.Parameters["@MaxQty"].Value = _maxqty;

            cmd.Parameters.Add("@expflag", System.Data.SqlDbType.TinyInt);
            cmd.Parameters["@expflag"].Value = _expflag;

            cmd.Parameters.Add("@reqflag", System.Data.SqlDbType.TinyInt);
            cmd.Parameters["@reqflag"].Value = _reqflag;

            cmd.Parameters.Add("@deflag", System.Data.SqlDbType.TinyInt);
            cmd.Parameters["@deflag"].Value = _deflag;

            SqlParameter returnData = cmd.Parameters.Add("@OutputID", SqlDbType.NVarChar, 200);
            returnData.Direction = ParameterDirection.Output;

            try
            {
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.Message);
            }
            finally
            {
                conn.Close();
                conn.Dispose();
            }
            return new Tuple<bool, string>(true, returnData.Value.ToString());
        }

        public static Tuple<bool, string> CreateProductCompatibility(string partNo1, string partNo2, string relation, string reason, string userID)
        {
            Compatibility status = Compatibility.Incompatible;
            if (Enum.TryParse<Compatibility>(relation, out status) == false)
                return new Tuple<bool, string>(false, "Compatibility status is wrong.");

            List<string> pn1List = new List<string>();
            List<string> pn2List = new List<string>();

            foreach (var pn in partNo1.Split('|'))
            {
                if (pn1List.Contains(pn.Trim()))
                    return new Tuple<bool, string>(false, string.Format("This part No - {0} is duplicate in textbox 1.", pn));
                else
                    pn1List.Add(pn.Trim());
            }
            pn1List = pn1List.OrderBy(p => p).ToList();

            foreach (var pn in partNo2.Split('|'))
            {
                if (pn2List.Contains(pn.Trim()) || pn1List.Contains(pn.Trim()))
                    return new Tuple<bool, string>(false, string.Format("This part No - {0} is duplicate in textbox 2.", pn));
                else
                    pn2List.Add(pn.Trim());
            }
            pn2List = pn2List.OrderBy(p => p).ToList();

            try
            {
                object count = SqlProvider.dbExecuteScalar("MY", string.Format("SELECT COUNT(*) FROM PRODUCT_COMPATIBILITY WHERE PART_NO1 = '{0}' AND PART_NO2 = '{1}'", string.Join("|", pn1List), string.Join("|", pn2List)));
                if (count != null && ((int)count) > 0)
                    return new Tuple<bool, string>(false, "Duplicate combination data in database.");

                //ICC 2017/10/25 Change to SQL parameter to save chinese text
                //StringBuilder sql = new StringBuilder();
                //sql.AppendFormat("INSERT INTO PRODUCT_COMPATIBILITY VALUES(N'{0}', N'{1}', {2}, '{3}', '{4}', GETDATE()); ", string.Join("|", pn1List), string.Join("|", pn2List), (int)status, reason.Trim(), userID.Trim());
                //sql.AppendFormat("INSERT INTO PRODUCT_COMPATIBILITY VALUES(N'{0}', N'{1}', {2}, '{3}', '{4}', GETDATE()); ", string.Join("|", pn2List), string.Join("|", pn1List), (int)status, reason.Trim(), userID.Trim());
                //SqlProvider.dbExecuteNoQuery("MY", sql.ToString());

                SqlParameter p1 = new SqlParameter("@pn1", SqlDbType.NVarChar, 1000);
                p1.Value = string.Join("|", pn1List);

                SqlParameter p2 = new SqlParameter("@pn2", SqlDbType.NVarChar, 1000);
                p2.Value = string.Join("|", pn2List);

                SqlParameter p3 = new SqlParameter("@relation", SqlDbType.Int);
                p3.Value = (int)status;

                SqlParameter p4 = new SqlParameter("@reason", SqlDbType.NVarChar, 1500);
                p4.Value = reason.Trim();

                SqlParameter p5 = new SqlParameter("@user", SqlDbType.NVarChar, 100);
                p5.Value = userID.Trim();

                List<SqlParameter> ps = new List<SqlParameter>() { p1, p2, p3, p4, p5 };

                SqlProvider.dbExecuteNoQuery2("MY", "INSERT INTO PRODUCT_COMPATIBILITY VALUES(@pn1, @pn2, @relation, @reason, @user, GETDATE()); INSERT INTO PRODUCT_COMPATIBILITY VALUES(@pn2, @pn1, @relation, @reason, @user, GETDATE());", ps.ToArray());

                return new Tuple<bool, string>(true, "Success");
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.ToString());
            }
        }

        public static DataTable GetProductCompatibility()
        {
            try
            {
                return SqlProvider.dbGetDataTable("MY", "SELECT ID, REPLACE(PART_NO1, '|', ', ') AS [PART_NO1], REPLACE(PART_NO2, '|', ', ') AS [PART_NO2], CASE RELATION WHEN 1 THEN 'Compatible' ELSE 'Incompatible' END  AS [RELATION], Reason AS [REASON], UPDATE_ID AS [UPDATE_ID] FROM PRODUCT_COMPATIBILITY where ID % 2 = 1 ORDER BY ID DESC");
            }
            catch
            {
                return new DataTable();
            }
        }

        public static Tuple<bool, string> DeleteProductCompatibility(int ID)
        {
            try
            {
                SqlProvider.dbExecuteNoQuery("MY", string.Format("DELETE FROM PRODUCT_COMPATIBILITY WHERE ID IN ({0}, {1})", ID, (ID + 1)));
                return new Tuple<bool, string>(true, string.Empty);
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.ToString());
            }
        }

        public static Tuple<bool, string> AddProjectCatelogCategory(string companyID, string partNo, string memo, string userID)
        {
            try
            {
                int count = 0;
                //var obj = SqlProvider.dbExecuteScalar("MY", string.Format("DECLARE @Child HIERARCHYID SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{2}_Project' SELECT COUNT(*) FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child AND CATEGORY_ID = '{0}' AND SHARED_CATEGORY_ID = '{1}'", partNo, companyID, org));
                var obj = SqlProvider.dbExecuteScalar("MY", string.Format("SELECT COUNT(*) FROM PROJECT_CATALOG_CATEGORY WHERE COMPANY_ID='{0}' AND PART_NO ='{1}'", companyID, partNo));
                if (obj != null) int.TryParse(obj.ToString(), out count);
                if (count > 0)
                    return new Tuple<bool, string>(false, string.Format("This parent No. {0} already exists.", partNo));

                //DataTable dt = OracleProvider.GetDataTable("SAP_PRD", string.Format("select distinct mast.matnr as Parent_item, stpo.idnrk as child_item, stpo.potx1 as memo from saprdp.mast inner join saprdp.stas  on stas.stlal = mast.stlal AND stas.stlnr = mast.stlnr INNER JOIN saprdp.stpo on stpo.stlkn = stas.stlkn AND stpo.stlnr = stas.stlnr AND stpo.stlty = stas.stlty where stas.LKENZ<>'X' and mast.matnr='{0}'", partNo));
                //if (dt == null || dt.Rows.Count == 0)
                //    return new Tuple<bool, string>(false, "This parent item can not be expanded from SAP");

                DataTable dt = DataCore.CBOMV2_ConfiguratorDAL.ExpandBOM(partNo, "TWH1");
                if (dt == null || dt.Rows.Count == 0)
                    return new Tuple<bool, string>(false, string.Format("This parent No. {0} can not be expanded from SAP!", partNo));

                //DataTable dt2 = OracleProvider.GetDataTable("SAP_PRD", string.Format("select distinct mast.matnr as Parent_item, stpo.idnrk as child_item, stpo.potx1 as memo from saprdp.mast inner join saprdp.stas  on stas.stlal = mast.stlal AND stas.stlnr = mast.stlnr INNER JOIN saprdp.stpo on stpo.stlkn = stas.stlkn AND stpo.stlnr = stas.stlnr AND stpo.stlty = stas.stlty where stas.LKENZ<>'X' and mast.matnr='{0}'", partNo));
                //List<string> exclude = new List<string>();
                //if (dt2 != null && dt2.Rows.Count > 0)
                //{
                //    foreach (DataRow dr in dt2.Rows)
                //    {
                //        string pn = dr["child_item"].ToString().Trim();
                //        string m = dr["memo"].ToString();
                //        if ((m.IndexOf("耗材") > -1 || m.IndexOf("客供") > -1) && !exclude.Contains(pn))
                //            exclude.Add(pn);
                //    }
                //}

                //Add parent
                //string guid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                //Tuple<bool, string> result = CreateNew(org + "_Project", guid, partNo, (int)CategoryTypes.Category, memo, 1, 0, org, companyID, 1, 0, 0, 0);
                //if (result.Item1 == false)
                //    return result;

                //Add child
                //foreach (DataRow dr in dt.Rows)
                //{
                //    string pn = FormatSAPPartNoToNormal(dr["IDNRK"].ToString().Trim());
                //    if (!exclude.Contains(pn))
                //    {
                //        double qty = 1;
                //        double.TryParse(dr["MENGE"].ToString().Trim(), out qty);//Save qty in Max_Qty column, and get this column as default qty in cart.
                //        string myid = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
                //        result = CreateNew(guid, myid, pn, (int)CategoryTypes.Component, dr["OJTXP"].ToString().Trim(), 1, 0, org, companyID, Convert.ToInt32(Math.Floor(qty)), 0, 0, 0);
                //        if (result.Item1 == false)
                //            return result;
                //    }
                //}
                //SqlProvider.dbExecuteNoQuery("MY", string.Format("INSERT INTO PROJECT_CATALOG_CATEGORY VALUES (N'{0}', N'{1}', N'{2}', '{3}', GETDATE())", companyID, partNo, memo, userID));
                SqlProvider.dbExecuteNoQuery("MY", string.Format("INSERT INTO PROJECT_CATALOG_CATEGORY VALUES ('{0}','{1}','{2}','{3}', GETDATE())", companyID, partNo, memo, userID));
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.Message);
            }
            return new Tuple<bool, string>(true, string.Empty);
        }

        public static List<ProjectCatalogCategory> InitialProjectCatalogCategory(string companyID)
        {
            List<ProjectCatalogCategory> list = new List<ProjectCatalogCategory>();
            try
            {
                //DataTable dt = SqlProvider.dbGetDataTable("CBOMV2", string.Format("DECLARE @Child HIERARCHYID SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}_Project' SELECT ID, CATEGORY_ID, CATEGORY_NOTE, SHARED_CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child AND SHARED_CATEGORY_ID = '{1}'", org, companyID));
                //if (dt != null && dt.Rows.Count > 0)
                //{
                //    foreach (DataRow dr in dt.Rows)
                //    {
                //        ProjectCatalogCategory p = new ProjectCatalogCategory();
                //        p.ID = dr["ID"].ToString();
                //        p.COMPANY_ID = dr["SHARED_CATEGORY_ID"].ToString();
                //        p.PART_NO = dr["CATEGORY_ID"].ToString();
                //        p.MEMO = dr["CATEGORY_NOTE"].ToString();
                //        list.Add(p);
                //    }
                //}
                DataTable dt = SqlProvider.dbGetDataTable("MY", string.Format("SELECT ID, COMPANY_ID, PART_NO, MEMO FROM PROJECT_CATALOG_CATEGORY WHERE COMPANY_ID = '{0}'", companyID));
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (DataRow dr in dt.Rows)
                    {
                        ProjectCatalogCategory p = new ProjectCatalogCategory();
                        p.ID = dr["ID"].ToString();
                        p.COMPANY_ID = companyID;
                        p.PART_NO = dr["PART_NO"].ToString();
                        p.MEMO = dr["MEMO"].ToString();
                        list.Add(p);
                    }
                }
            }
            catch
            {

            }
            return list;
        }

        public static Tuple<bool, string> DeleterProjectCatalogCategory(string ID)
        {
            try
            {
                int cid = 0;
                int.TryParse(ID, out cid);
                if (cid > 0)
                    SqlProvider.dbExecuteNoQuery("MY", string.Format("DELETE FROM PROJECT_CATALOG_CATEGORY WHERE ID = {0}", cid));

                //SqlProvider.dbExecuteNoQuery("CBOMV2", string.Format("DECLARE @ID HIERARCHYID SELECT @ID = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}' DELETE FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1", ID));
                return new Tuple<bool, string>(true, string.Empty);
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.Message);
            }
        }

        public static string FormatSAPPartNoToNormal(string partNo)
        {
            double d = 0d;
            if (double.TryParse(partNo, out d) == false)
                return partNo;
            else
            {
                for (int i = 0; i <= partNo.Length - 1; i++)
                {
                    if (!partNo.Substring(i, 1).Equals("0"))
                    {
                        return partNo.Substring(i);
                    }
                }
                return partNo;
            }
        }

        //This region is just for TW temporarily use
        public static Tuple<bool, string> CreateProductCompatibilityTW(string partNo1, string partNo2, string relation, string reason, string userID)
        {
            Compatibility status = Compatibility.Incompatible;
            if (Enum.TryParse<Compatibility>(relation, out status) == false)
                return new Tuple<bool, string>(false, "Compatibility status is wrong.");

            List<string> pn1List = new List<string>();
            List<string> pn2List = new List<string>();

            foreach (var pn in partNo1.Split('|'))
            {
                if (pn1List.Contains(pn.Trim()))
                    return new Tuple<bool, string>(false, string.Format("This part No - {0} is duplicate in textbox 1.", pn));
                else
                    pn1List.Add(pn.Trim());
            }
            pn1List = pn1List.OrderBy(p => p).ToList();

            foreach (var pn in partNo2.Split('|'))
            {
                if (pn2List.Contains(pn.Trim()) || pn1List.Contains(pn.Trim()))
                    return new Tuple<bool, string>(false, string.Format("This part No - {0} is duplicate in textbox 2.", pn));
                else
                    pn2List.Add(pn.Trim());
            }
            pn2List = pn2List.OrderBy(p => p).ToList();

            try
            {
                object count = SqlProvider.dbExecuteScalar("MY", string.Format("SELECT COUNT(*) FROM PRODUCT_COMPATIBILITY_TW WHERE PART_NO1 = '{0}' AND PART_NO2 = '{1}'", string.Join("|", pn1List), string.Join("|", pn2List)));
                if (count != null && ((int)count) > 0)
                    return new Tuple<bool, string>(false, "Duplicate combination data in database.");

                //ICC 2017/10/25 Change to SQL parameter to save chinese text
                //StringBuilder sql = new StringBuilder();
                //sql.AppendFormat("INSERT INTO PRODUCT_COMPATIBILITY_TW VALUES(N'{0}', N'{1}', {2}, '{3}', '{4}', GETDATE()); ", string.Join("|", pn1List), string.Join("|", pn2List), (int)status, reason.Trim(), userID.Trim());
                //sql.AppendFormat("INSERT INTO PRODUCT_COMPATIBILITY_TW VALUES(N'{0}', N'{1}', {2}, '{3}', '{4}', GETDATE()); ", string.Join("|", pn2List), string.Join("|", pn1List), (int)status, reason.Trim(), userID.Trim());
                //SqlProvider.dbExecuteNoQuery("MY", sql.ToString());

                SqlParameter p1 = new SqlParameter("@pn1", SqlDbType.NVarChar, 1000);
                p1.Value = string.Join("|", pn1List);

                SqlParameter p2 = new SqlParameter("@pn2", SqlDbType.NVarChar, 1000);
                p2.Value = string.Join("|", pn2List);

                SqlParameter p3 = new SqlParameter("@relation", SqlDbType.Int);
                p3.Value = (int)status;

                SqlParameter p4 = new SqlParameter("@reason", SqlDbType.NVarChar, 1500);
                p4.Value = reason.Trim();

                SqlParameter p5 = new SqlParameter("@user", SqlDbType.NVarChar, 100);
                p5.Value = userID.Trim();

                List<SqlParameter> ps = new List<SqlParameter>() { p1, p2, p3, p4, p5 };

                SqlProvider.dbExecuteNoQuery2("MY", "INSERT INTO PRODUCT_COMPATIBILITY_TW VALUES(@pn1, @pn2, @relation, @reason, @user, GETDATE()); INSERT INTO PRODUCT_COMPATIBILITY_TW VALUES(@pn2, @pn1, @relation, @reason, @user, GETDATE());", ps.ToArray());
                return new Tuple<bool, string>(true, "Success");
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.ToString());
            }
        }

        public static DataTable GetProductCompatibilityTW()
        {
            try
            {
                return SqlProvider.dbGetDataTable("MY", "SELECT ID, REPLACE(PART_NO1, '|', ', ') AS [PART_NO1], REPLACE(PART_NO2, '|', ', ') AS [PART_NO2], CASE RELATION WHEN 1 THEN 'Compatible' ELSE 'Incompatible' END  AS [RELATION], Reason AS [REASON], UPDATE_ID AS [UPDATE_ID] FROM PRODUCT_COMPATIBILITY_TW where ID % 2 = 1 ORDER BY ID DESC");
            }
            catch
            {
                return new DataTable();
            }
        }

        public static Tuple<bool, string> DeleteProductCompatibilityTW(int ID, string email)
        {
            try
            {
                DataTable dt = SqlProvider.dbGetDataTable("MY", string.Format("SELECT TOP 1 * FROM PRODUCT_COMPATIBILITY_TW WHERE ID = {0}", ID));
                if (dt != null && dt.Rows.Count > 0)
                {
                    string userID = dt.Rows[0]["UPDATE_ID"].ToString();
                    if (userID.IndexOf("@") > -1)
                    {
                        string pn1 = dt.Rows[0]["PART_NO1"].ToString();
                        string pn2 = dt.Rows[0]["PART_NO2"].ToString();
                        string relation = dt.Rows[0]["RELATION"].ToString() == "1" ? Compatibility.Compatible.ToString().ToLower() : Compatibility.Incompatible.ToString().ToLower();
                        System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings["SMTPServer"]);
                        System.Net.Mail.MailMessage msg = new System.Net.Mail.MailMessage("MyAdvantech@advantech.com", userID);
                        msg.Bcc.Add("MyAdvantech@advantech.com");
                        msg.Subject = "TW Product compatibility data has been changed";
                        msg.IsBodyHtml = true;
                        List<string> list = userID.Split('@').ToList();
                        msg.Body = string.Format("Dear {0},<br /> Your data has been deleted by {1}.<br /> Data content: {2} {3} {4}.<br /> Thanks.", list[0], email, pn1, relation, pn2);
                        smtp.Send(msg);
                    }
                }

                SqlProvider.dbExecuteNoQuery("MY", string.Format("DELETE FROM PRODUCT_COMPATIBILITY_TW WHERE ID IN ({0}, {1})", ID, (ID + 1)));
                return new Tuple<bool, string>(true, string.Empty);
            }
            catch (Exception ex)
            {
                return new Tuple<bool, string>(false, ex.ToString());
            }
        }

        public static DataTable GetCBOMV2ExcelData(String _CBOMORG)
        {
            DataTable dtfianl = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.TreeData2Datatable("GetTableSchema", "DL");

            //String strCatalog = "DECLARE @Child hierarchyid " +
            //            " SELECT @Child = HIE_ID FROM CBOM_CATALOG_V2 " +
            //            " WHERE ID = '" + _CBOMORG + "_Root' " +
            //            " SELECT a.ID, a.CATALOG_NAME, a.CATALOG_DESC, a.CATEGORY_GUID, b.CATEGORY_ID as CATEGORY_NAME, " +
            //            " (select count(*) from ASSIGNED_CTOS where category_id = a.CATEGORY_GUID) as VisibilityCount " +
            //            " FROM CBOM_CATALOG_V2 a left join CBOM_CATALOG_CATEGORY_V2 b on a.CATEGORY_GUID = b.ID " +
            //            " WHERE a.HIE_ID.GetAncestor(1) = @Child " +
            //            " ORDER BY a.SEQ_NO";

            //DataTable dtCatalog = SqlProvider.dbGetDataTable("CBOMV2", strCatalog);

            //if (dtCatalog != null && dtCatalog.Rows.Count > 0)
            //{
            //    foreach (DataRow drCatalog in dtCatalog.Rows)
            //    {
            //        String strBTO = "DECLARE @Child hierarchyid " +
            //            " SELECT @Child = HIE_ID FROM CBOM_CATALOG_V2 " +
            //            " WHERE ID = '" + drCatalog["ID"].ToString() + "' " +
            //            " SELECT a.ID, a.CATALOG_NAME, a.CATALOG_DESC, a.CATEGORY_GUID " +
            //            " FROM CBOM_CATALOG_V2 a " +
            //            " WHERE a.HIE_ID.GetAncestor(1) = @Child " +
            //            " ORDER BY a.SEQ_NO";

            //        DataTable dtBTO = SqlProvider.dbGetDataTable("CBOMV2", strBTO);

            //        foreach (DataRow d in dtBTO.Rows)
            //        {
            //            DataTable dtCategory = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.TreeData2Datatable(d["CATEGORY_GUID"].ToString(), "DL");

            //            if (dtCategory.Rows.Count > 0)
            //            {
            //                dtfianl.Rows.Add(dtfianl.NewRow());
            //                dtfianl.Merge(dtCategory);
            //            }
            //        }
            //    }
            //}


            String strCatalog = " DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + _CBOMORG + @"_BTOS' " +
                                " SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child ORDER BY CATEGORY_ID";
            DataTable dtCatalog = SqlProvider.dbGetDataTable("CBOMV2", strCatalog);

            if (dtCatalog != null && dtCatalog.Rows.Count > 0)
            {
                foreach (DataRow drCatalog in dtCatalog.Rows)
                {
                    DataTable dtCategory = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.TreeData2Datatable(drCatalog["ID"].ToString(), _CBOMORG);

                    if (dtCategory.Rows.Count > 0)
                    {
                        dtfianl.Rows.Add(dtfianl.NewRow());
                        dtfianl.Merge(dtCategory);
                    }
                }
            }

            return dtfianl;
        }

        public static DataTable TreeData2Datatable(String _rootid, String _orgid)
        {
            List<EasyUITreeNode> TreeNodes = new List<EasyUITreeNode>();
            List<CBOM_CATEGORY_RECORD> CBOMCategoryRecords = CBOMV2_EditorDAL.GetCBOMCategoryTreeByRootId(_rootid, _orgid);
            List<CBOM_CATEGORY_RECORD> RootRecord = (from q in CBOMCategoryRecords where q.LEVEL == 2 select q).ToList();

            DataTable dt = new DataTable();
            dt.Columns.Add("Level");
            dt.Columns.Add("FATHER");
            dt.Columns.Add("FatherDescription");
            dt.Columns.Add("Category");
            dt.Columns.Add("IsCategoryExpand");
            dt.Columns.Add("IsCategoryRequired");
            dt.Columns.Add("IsCategoryShared");
            dt.Columns.Add("Item");
            dt.Columns.Add("Component");
            dt.Columns.Add("Description");
            dt.Columns.Add("IsComponentExpand");
            dt.Columns.Add("IsComponentDefault");
            dt.Columns.Add("IsComponentShared");
            dt.Columns.Add("IsLooseItem");
            dt.Columns.Add("Qty");           

            if (RootRecord.Count == 1)
            {
                EasyUITreeNode RootTreeNode = new EasyUITreeNode(RootRecord.First().ID, RootRecord.First().ID, RootRecord.First().CATEGORY_ID, "", RootRecord.First().HIE_ID, "", 0, 0, 1, 0, 0, 0, 0);
                CBOMV2_EditorDAL.CheckSharedCategory(new List<String>(), ref CBOMCategoryRecords);
                RootTreeNode.csstype = NodeCssType.Tree_Node_Root;
                CBOMV2_EditorDAL.CBOMCategoryRecordsToEasyUITreeNode(CBOMCategoryRecords, RootTreeNode);
                TreeNodes.Add(RootTreeNode);

                //Get Root Description from CBOM_CATALOG table
                var RootCatalogDesc = SqlProvider.dbExecuteScalar("CBOMV2", String.Format("SELECT top 1 CATALOG_DESC FROM CBOM_CATALOG_V2 where CATEGORY_GUID = '{0}'", _rootid));
                if (RootCatalogDesc != null && !String.IsNullOrEmpty(RootCatalogDesc.ToString()))
                {
                    RootRecord.FirstOrDefault().CATEGORY_NOTE = RootCatalogDesc.ToString();
                }

                // Input root row
                dt.Rows.Add(dt.NewRow());
                DataRow rRoot = dt.NewRow();
                rRoot["Level"] = "1";
                rRoot["FATHER"] = RootRecord.FirstOrDefault().CATEGORY_ID;
                rRoot["FatherDescription"] = RootRecord.FirstOrDefault().CATEGORY_NOTE;
                rRoot["Category"] = "";
                rRoot["IsCategoryExpand"] = "";
                rRoot["IsCategoryRequired"] = "";
                rRoot["IsCategoryShared"] = "";
                rRoot["Item"] = "";
                rRoot["Component"] = "";
                rRoot["Description"] = "";
                rRoot["IsComponentExpand"] = "";
                rRoot["IsComponentDefault"] = "";
                rRoot["IsComponentShared"] = "";
                rRoot["IsLooseItem"] = "";
                rRoot["Qty"] = "";
                dt.Rows.Add(rRoot);

                RecursiveAddDataRowForReportDownload(RootRecord.FirstOrDefault(), 1, RootTreeNode, ref dt);

                dt.Rows.Add(dt.NewRow());

            }
            return dt;
        }

        public static void RecursiveAddDataRowForReportDownload(CBOM_CATEGORY_RECORD _root, int level, EasyUITreeNode _component, ref DataTable _dt)
        {
            foreach (EasyUITreeNode ChildCategory in _component.children)
            {
                if (ChildCategory.children != null && ChildCategory.children.Count > 0)
                {
                    foreach (EasyUITreeNode ChildComponent in ChildCategory.children)
                    {
                        // Input root row
                        DataRow rComponent = _dt.NewRow();
                        rComponent["Level"] = level;
                        rComponent["FATHER"] = _root.CATEGORY_ID;
                        rComponent["FatherDescription"] = _root.CATEGORY_NOTE;
                        rComponent["Category"] = ChildCategory.text;
                        rComponent["IsCategoryExpand"] = ChildCategory.isexpand;
                        rComponent["IsCategoryRequired"] = ChildCategory.isrequired;
                        rComponent["IsCategoryShared"] = (ChildCategory.type == 3) ? "V" : "";
                        rComponent["Item"] = "";
                        rComponent["Component"] = ChildComponent.text;
                        rComponent["Description"] = ChildComponent.desc;
                        rComponent["IsComponentExpand"] = ChildComponent.isexpand;
                        rComponent["IsComponentDefault"] = ChildComponent.isdefault;
                        rComponent["IsComponentShared"] = (ChildComponent.type == 4) ? "V" : "";
                        rComponent["IsLooseItem"] = (ChildComponent.configurationrule == 1) ? "V" : "";
                        rComponent["Qty"] = ChildCategory.qty;
                        _dt.Rows.Add(rComponent);

                        RecursiveAddDataRowForReportDownload(_root, level + 1, ChildComponent, ref _dt);
                    }
                }
            }
        }

        public static List<AssignedCTOS_Master> GetAssignedCTOSfromCompanyID(string org_ID, string companyID)
        {
            var sql = new StringBuilder(string.Format(@"select a.*, b.CATALOG_NAME, b.CATALOG_DESC 
                from ASSIGNED_CTOS a inner join CBOM_CATALOG_V2 b on a.CATEGORY_ID = b.ID
                where b.ORG= '{0}' ", org_ID));

            if (!string.IsNullOrEmpty(companyID))
                sql.AppendFormat(" and a.COMPANY_ID = '{0}' ", companyID);
            sql.Append(" order by a.COMPANY_ID ");

            DataTable dt = SqlProvider.dbGetDataTable("CBOMV2", sql.ToString());

            if (dt != null && dt.Rows.Count > 0)
            {
                List<AssignedCTOS_Master> masters = new List<AssignedCTOS_Master>();
                Dictionary<string, List<AssignedCTOS_Detail>> dic = new Dictionary<string, List<AssignedCTOS_Detail>>();
                foreach (DataRow dr in dt.Rows)
                {
                    string ERPID = dr["COMPANY_ID"].ToString().ToUpper();
                    if (dic.ContainsKey(ERPID))
                    {
                        var list = dic[ERPID];
                        AssignedCTOS_Detail detail = new AssignedCTOS_Detail()
                        {
                            Row_ID = int.Parse(dr["ROW_ID"].ToString()),
                            CTOSName = dr["CATALOG_NAME"].ToString(),
                            CTOSDescription = dr["CATALOG_DESC"].ToString(),
                            UserID = dr["USERID"].ToString(),
                            CreatedDate = DateTime.Parse(dr["CREATEDDATE"].ToString()).ToString("yyyy/MM/dd")
                        };
                        list.Add(detail);
                        dic[ERPID] = list;
                    }
                    else
                    {
                        AssignedCTOS_Master master = new AssignedCTOS_Master()
                        {
                            Row_ID = int.Parse(dr["ROW_ID"].ToString()),
                            CompanyID = dr["COMPANY_ID"].ToString().ToUpper()
                        };
                        masters.Add(master);

                        List<AssignedCTOS_Detail> list = new List<AssignedCTOS_Detail>();
                        AssignedCTOS_Detail detail = new AssignedCTOS_Detail()
                        {
                            Row_ID = int.Parse(dr["ROW_ID"].ToString()),
                            CTOSName = dr["CATALOG_NAME"].ToString(),
                            CTOSDescription = dr["CATALOG_DESC"].ToString(),
                            UserID = dr["USERID"].ToString(),
                            CreatedDate = DateTime.Parse(dr["CREATEDDATE"].ToString()).ToString("yyyy/MM/dd")
                        };
                        list.Add(detail);
                        dic.Add(ERPID, list);
                    }
                }

                foreach (var master in masters)
                {
                    if (dic.ContainsKey(master.CompanyID))
                        master.Details = dic[master.CompanyID];
                }
                return masters;
            }
            else
                return new List<AssignedCTOS_Master>();
        }

        public static void AddAssignedCTOS(List<String> ERPIDs, string CategoryID, string userID)
        {
            //Check exist data first

            StringBuilder sql = new StringBuilder();
            foreach (var ERPID in ERPIDs)
                sql.AppendFormat("insert into ASSIGNED_CTOS values ('{0}', '{1}', '{2}', GETDATE())", ERPID.ToUpper(), CategoryID, userID);
            try
            {
                SqlProvider.dbExecuteNoQuery("CBOMV2", sql.ToString());
            }
            catch
            {

            }
        }

        public static void DeleteAssignedCTOS(int ID)
        {
            try
            {
                SqlProvider.dbExecuteNoQuery("CBOMV2", string.Format("delete from ASSIGNED_CTOS where ROW_ID = {0}", ID));
            }
            catch
            {

            }
        }
    }
}