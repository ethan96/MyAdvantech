
/* jQuery */

$(function(){

	// copy circle div
	/* ---------------------------------------------------------------------------------------- */

	$(window).load(function(){
		var LiNum = $(".mainpic>ul>li").size();
		var cDivWidth = parseInt($(".mainpic .circle ul li").width()) + parseInt($(".mainpic .circle ul li").css("margin-right")) * 2;
		//console.log( $(".mainpic .circle ul li").css("margin-right") );
		//console.log( cDivWidth );
		$(".mainpic .circle ul").css({"width":LiNum*cDivWidth+10,"margin":"0 auto"});

		if( LiNum > 1 )
		{
			for( var i = 1 ; i < LiNum ; i++)
			{ 	
				$(".mainpic .circle ul").append("<li class='c'><a href='javascript:void(0);'></a></li>");
			}
		}
	});

	$(".mainpic .circle").css({"display":"none"});

	$(window).load(function(){

		// show mainpic slice show
		/* ---------------------------------------------------------------------------------------- */

		//console.log("load done!");
		$(".mainpic .pic li a img").css({"display":"block"});
		$(".mainpic .circle").css({"display":"block"});

		var runFunc = function()
		{
			running = setInterval(goNext,3500);			// refresh time
		}
		runFunc();

		var fShow = 0;									// default 1 show
		var fTotal = $(".mainpic>ul>li").size()-1;		// how many ?

		//console.log("fShow = " + fShow);
		//console.log("fTotal = " + fTotal);

		$(".mainpic>ul>li").hide();						// hide all
		$(".mainpic>ul>li:eq(" + fShow + ")").show();	// default 1 show
		$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_on.png) center center no-repeat"});

		// show next

		function goNext()
		{
			$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_off.png) center center no-repeat"});
			$(".mainpic>ul>li:eq(" + fShow + ")").fadeOut(500);
			fShow==fTotal ? fShow = 0 : fShow ++;
			$(".mainpic>ul>li:eq(" + fShow + ")").fadeIn(500);
			$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_on.png) center center no-repeat"});
		}

		// show previous

		function goPrev()
		{
			$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_off.png) center center no-repeat"});
			$(".mainpic>ul>li:eq(" + fShow + ")").fadeOut(500);
			fShow==0 ? fShow = fTotal : fShow --;
			$(".mainpic>ul>li:eq(" + fShow + ")").fadeIn(500);
			$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_on.png) center center no-repeat"});
		}

		// next button

		$(".btn_next a").click(function(){
		//$("body").on("click", ".btn_next a", function (){
			goNext();
			clearInterval(running);
			runFunc();
		});

		// previous button

		$(".btn_prev a").click(function(){
		//$("body").on("click", ".btn_prev a", function (){
			goPrev();
			clearInterval(running);
			runFunc();
		});

		// stop running when mouseover
		/* ---------------------------------------------------------------------------------------- */

		$(".mainpic>ul>li").mouseenter(function(){
			//clearInterval(running);
		});

		// continue when mouseout

		$(".mainpic>ul>li").mouseleave(function(){
			//runFunc();
		});

		// when click circle
		/* ---------------------------------------------------------------------------------------- */

		$(".mainpic .circle ul li a").click(function(){
		//$("body").on("click", ".mainpic .circle ul li a", function (){
			var clickNum = $(this).parent().index();
			$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_off.png) center center no-repeat"});
			$(".mainpic>ul>li:eq(" + fShow + ")").fadeOut(500);
			fShow = clickNum;
			$(".mainpic>ul>li:eq(" + fShow + ")").fadeIn(500);
			$(".mainpic .circle ul li:eq(" + fShow + ") a").css({"background":"url(img/dot_on.png) center center no-repeat"});
			clearInterval(running);
			runFunc();
		});

		/* calulate mainpic height */
		/* ---------------------------------------------------------------------------------------- */

		$(".mainpic").css({"height" : $(".mainpic").width() * 0.208 });	/* W = H * 200 / 960 */
		$(window).resize(function(){
			$(".mainpic").css({"height" : $(".mainpic").width() * 0.208 });
		});

		/* index box3 random show */
		/* ---------------------------------------------------------------------------------------- */
		
		var box3num = Math.floor(Math.random() * 5) + 1;
		/*$(".index-box3 li").css({"display":"none"});*/
		$(".index-box3 li:nth-child("+box3num+")").css({"display":"block"});

	});

});
