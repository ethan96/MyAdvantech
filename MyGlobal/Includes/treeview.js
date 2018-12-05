function OnTreeNodeChecked() 
 { 
    var ele = event.srcElement; 
    if(ele.type=='checkbox') 
     { 
        var childrenDivID = ele.id.replace('CheckBox','Nodes');
        var div = document.getElementById(childrenDivID); 
        if(div != null)
         {
//            var checkBoxs = div.getElementsByTagName('INPUT'); 
//            for(var i=0;i<checkBoxs.length;i++) 
//             { 
//                if(checkBoxs[i].type=='checkbox') 
//                checkBoxs[i].checked=ele.checked; 
//            }
        }
        else
         {
            var div = GetParentByTagName(ele,'DIV');
            var checkBoxs = div.getElementsByTagName('INPUT'); 
            var parentCheckBoxID = div.id.replace('Nodes','CheckBox');
            var parentCheckBox = document.getElementById(parentCheckBoxID);
            for(var i=0;i<checkBoxs.length;i++) 
             {
                if(checkBoxs[i].type=='checkbox' && checkBoxs[i].checked)
                 {
                    parentCheckBox.checked = true;
                    return;
                }
            }
            parentCheckBox.checked = false;
        }
        
    } 
}

function GetParentByTagName(element, tagName)  {
    var parent = element.parentNode;
    var upperTagName = tagName.toUpperCase();
    while (parent && (parent.tagName.toUpperCase() != upperTagName))  {
        parent = parent.parentNode ? parent.parentNode : parent.parentElement;
    }
    return parent;
}