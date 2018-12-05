<?php

/**
 * @author Jimmy Xiao
 * @copyright 2009
 */

 	$mysql_server = 'localhost';
	$mysql_username = 'root';
	$mysql_password = 'xiaoxiao';
	$mysql_database = 'daqurway';	

 
	class ConnectDB
	{
		var $_admin = 'jimmy.xiao@advantech.com.tw';	//database administrators' e-Mail
		var $_server;
		var $_username;
		var $_password;
		var $_database;
		function __construct($server,$username,$password,$database){
			$this->_server = $server;
			$this->_username = $username;
			$this->_password = $password;
			$this->_database = $database;
		}
		
		function __destruct(){
			$this->_server = NULL;
			$this->_username = NULL;
			$this->_password = NULL;
			$this->_database = NULL;
		}
	}
	
	class ConnectMYSQL extends ConnectDB
	{
		function connect()
		{
			$link_mysql = mysql_pconnect($this->_server,$this->_username,$this->_password);
			if(!$link_mysql||!mysql_select_db($this->_database,$link_mysql))
				exit("Connect to $this->_database failed! <br>Please contact the database <a href='mailto:$this->_admin'>administrator</a>...<br>");
		}
	}
	
	class ConnectMSSQL extends ConnectDB
	{
		function connect()
		{
			$link_mssql = mssql_pconnect($this->_server,$this->_username,$this->_password);
			if(!$link_mssql||!mssql_select_db($this->_database,$link_mssql))
				exit("Connect to $this->_database failed! <br>Please contact the database <a href='mailto:$this->_admin'>administrator</a>...<br>");
		}
	}
	
#################################################################################
########################       source from xcart      ###########################
#################################################################################

#
# Execute mysql query and store result into associative array with
# column names as keys
#
function func_sql_query($query) {
	$result = false;

	if ($p_result = db_query($query)) {
		while ($arr = db_fetch_array($p_result))
			$result[] = $arr;
		db_free_result($p_result);
	}

	return $result;
}



	$ObjMYSQL = new ConnectMySQL($mysql_server,$mysql_username,$mysql_password,$mysql_database);
	
	//Connect to both database host
	$ObjMYSQL->connect();

	//Soap Client
	$soap_image = new SoapClient('http://www.advantech.com.tw/webservice/advantechwebservicelocal.asmx?WSDL');

	//start to copy all files to download.apro.com
	//$sqlGetPartNo = "SELECT xcart_products.productid, xcart_products.productcode FROM xcart_products WHERE xcart_products.forsale='Y' ORDER BY xcart_products.productid ASC; ";
	$sqlGetPartNo = "SELECT products.SKU, products.productid FROM products";
	$result = mysql_query($sqlGetPartNo);
	while($row = mysql_fetch_row($result)){
		//get part no
			try{
			$params = array("partNumber"=>$row[0],"LitType"=>"bimg");
			if($respond = $soap_image->getModelImage($params))
			$url = $respond->getModelImageResult;
			$urls = explode(";", $url);
			for($i=0;$i<sizeof($urls)-1;$i++ ){
				$pos = strrpos($urls[$i],"pdf");
				if($pos == 0){
					$str = strstr(substr($urls[$i],43),"/");
					$file_name = ltrim($str,"/");	
					$source_file = str_replace(" ","%20",$urls[$i]);
					//check source_file which is available to open
					if(fopen($source_file,"r")){
						copy($source_file,$file_name);
						$image_url = "product_images/".$file_name;
						$sql = "INSERT INTO product_images SET product_images.productid = '$row[1]', product_images.img_url = '$image_url';";
						mysql_query($sql);
					}
						
						
				}
			}

  		}
  		catch(SoapFault $exception){}
	}

?>