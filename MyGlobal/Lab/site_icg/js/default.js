
/* jQuery */

$(function(){

	/* hide link focus dash line */
	/* ---------------------------------------------------------------------------------------- */

	$("a").attr("hidefocus","true");
	$("a").focus(function(){this.blur();});

	/* top search input default value-----------------------------------------------------------*/

	$(".login-desktop .login-id").defaultValue("User Name");
	$(".login-desktop .login-password").defaultValue("Password");
	$(".searchbar .searchBar").defaultValue("What are you looking for...");
	$(".LB-login-id").defaultValue("User Name");
	$(".LB-login-password").defaultValue("Password");

	/*  open lightbox for login ----------------------------------------------------------------*/

	$(".openLightBox").lightBox(
	{
		boxName: "#box_lightbox",
		btnName: "#btn_box_close",
		backgroundOpacity:0.6
	});

	/*  手機狀態下開啟登入區塊 ---------------------------------------------------------------*/

	// 在畫面小於 770 的時候才會打開上方的登區塊
	// 判斷寫在 lightbox.js line 217

	openTopLoginBox = function()
	{
		$(".topLoginBox").slideDown();
		$('html,body').animate({scrollTop: 0}, 500);
	}

	/* 手機狀態下手動開啟登入區塊 -----------------------------------------------------------*/

	$(".login-tablet-mobile button").click(function()
	{
		$(".topLoginBox").slideDown();
	});

	/* 手機狀態下開啟過濾清單 ---------------------------------------------------------------*/

	$(".filter_switch button").click(function()
	{
		var buttonTXT = $(this).text();
		if( buttonTXT =="Filter" )
		{
			$(this).text("Close");
		}
		else
		{
			$(this).text("Filter");
		}

		//$(".filter").toggle();	//IE9以上才可用左方寫法

		if( $(".filter").hasClass("show") )
		{
			$(".filter").removeClass("show");
			$(".filter").addClass("hide");
		}
		else
		{
			$(".filter").removeClass("hide");
			$(".filter").addClass("show");
		}
	});

	/* 手機狀態下下方的產品列表 開/關 --------------------------------------------------------*/

	$(".productsBox dt").click(function(){
		if( $(window).width() <= 480 )
		{
			//$(this).parent().children("dd").toggle();	//IE9以上才可用左方寫法

			$(this).parent().children("dd").each(function()
			{
				if( $(this).hasClass("show") )
				{
					$(this).parent().removeClass("closeIcon");
					$(this).removeClass("show");
					$(this).addClass("hide");
				}
				else
				{
					$(this).parent().addClass("closeIcon");
					$(this).removeClass("hide");
					$(this).addClass("show");
				}
			});
		}
	});

	/*  加入收藏時出現彈跳訊息 ---------------------------------------------------------------*/

	$(".resultList .btn-favorite").click(function()
	{
		if( $(this).attr("name") == 0 )
		{
			$(this).removeClass("btn-info");
			$(this).addClass("btn-gray");
			$(this).attr("name","1")
			var boxW = $(".addFavoriteAlert").width() , boxH = $(".addFavoriteAlert").height();
			$(".addFavoriteAlert").fadeIn(200).css({ "left": ($(window).width()-boxW)/2 , "top": ($(window).height()-boxH)/2 });
			$(".addFavoriteAlert").delay(1000).fadeOut(300);
		}
	});

	/*  切換排列方式 --------------------------------------------------------------------------*/

	$(".resultsBox .listType button.list").click(function()
	{
		if( $(this).hasClass("on") == false )
		{
			$(this).addClass("on");
			$(this).parent().children(".thumbnail").removeClass("on");
			$(".resultsBox").removeClass("type-thumbnail");
			$(".resultsBox").addClass("type-list");
		}
	});

	$(".resultsBox .listType button.thumbnail").click(function()
	{
		if( $(this).hasClass("on") == false )
		{
			$(this).addClass("on");
			$(this).parent().children(".list").removeClass("on");
			$(".resultsBox").removeClass("type-list");
			$(".resultsBox").addClass("type-thumbnail");
		}
	});

	/* 改變瀏覽器大小時 -----------------------------------------------------------------------*/

	$(window).resize(function(){
	
		var windowWidth = $(window).width();

		/* body class name */

		$('body').removeClass();

		if ( windowWidth <= 480 )
		{
			$("body").addClass("for-mobile");
			$(".productsBox dl dd , .filter").hide();
			$(".resultsBox").addClass("mobile-type-thumbnail");
			$(".filter_switch button").text("Filter");
		}
		else if( windowWidth <= 770 )
		{
			$("body").addClass("for-tablet");
			$(".productsBox dl dd , .filter").removeClass("hide show").css({"display":"block"});
			$(".resultsBox").removeClass("mobile-type-thumbnail");
		}
		else if( windowWidth <= 960 )
		{
			$("body").addClass("for-narrow");
			$(".productsBox dl dd , .filter").removeClass("hide show").css({"display":"block"});
			$(".resultsBox").removeClass("mobile-type-thumbnail");
		}

		/* 計算 result.htm 頁面裡面右邊橘色浮動小區塊的位置 */

		$(".floatingFavoriteBox").css({"right": (windowWidth-960)/2 - 60 });

	}).resize();


});
