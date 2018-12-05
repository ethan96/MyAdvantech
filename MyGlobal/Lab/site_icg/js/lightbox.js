function getInternetExplorerVersion()
{
    var rv = -1; // Return value assumes failure.

    if (navigator.appName == 'Microsoft Internet Explorer')
    {
        var ua = navigator.userAgent;
        var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
        if (re.exec(ua) != null)
            rv = parseFloat( RegExp.$1 );
    }

    return rv;
}

jQuery.browser = {};
jQuery.browser.mozilla = /mozilla/.test(navigator.userAgent.toLowerCase()) && !/webkit/.test(navigator.userAgent.toLowerCase());
jQuery.browser.webkit = /webkit/.test(navigator.userAgent.toLowerCase());
jQuery.browser.opera = /opera/.test(navigator.userAgent.toLowerCase());
jQuery.browser.msie = /msie/.test(navigator.userAgent.toLowerCase());

/*
console.log("mozilla = " + jQuery.browser.mozilla);
console.log("webkit = " + jQuery.browser.webkit);
console.log("opera = " + jQuery.browser.opera);
console.log("msie = " + jQuery.browser.msie);
*/

var openTopLoginBox;	// function 內容寫在 default.js line37

$.fn.lightBox = function(settings) {

	// default value
	var DEFAULT_SETTINGS = {
			boxName:           "#box",
			lightBoxName:      "#lightbox",
			btnName:           "#closeBtn",
			btnOkName:         undefined,
			backgroundOpacity: 0.8,

			// Callback function
			maskClickClose:    true,
			onOpen:            undefined,
			onClose:           undefined,
			onOk:              undefined
		},
		_settings = $.extend(DEFAULT_SETTINGS, settings),
		html = $("html") , 
		body = $("body") , 
		box = $(_settings.boxName) , 
		lightBox = $(_settings.lightBoxName) , 
		lightBoxZ = lightBox.css("z-index") , 
		boxShow = flatBrowser = thinBrowser = boxX = boxY = browserW = browserH = bodyW = bodyH = boxH = scrollTop = lockCheck = scrollbarWidth = 0 , 
		scrollPosition = [],
		lightBoxCID, lightBoxCIDiv;

	var ver = getInternetExplorerVersion();
	// IE7
	if( ver == "7.0" ){body = $("html");}

	// when open lightbox or change browser size
	var checkSize = function(){

		// record scroll position
		scrollPosition = [self.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft , self.pageYOffset || document.documentElement.scrollTop  || document.body.scrollTop];
		scrollTop = $(window).scrollTop();		// scrollbar top

		// hide XY scroll for analysis browser width & height correctly
		if(boxShow==0){body.css({"overflow-y": "hidden","overflow-x": "hidden"});}

		browserW = $(window).width();		// browser weight
		browserH = $(window).height();		// browser height
		bodyW = $(document).width();		// body width
		bodyH = $("body").height();			// body height
		boxW = box.outerWidth(true);		// box width
		boxH = box.outerHeight(true);		// box height

		if( ver == "8.0" || ver == "6.0"){bodyW-=4}	// bodyW more 4px when useIE6, IE8
		if(boxShow==1){lightBox.width(browserW);}								// lightbox width = browserW ,avoid wrong bodyW when narrow browser

		// recovery XY scroll & analysis scrollbar width
		if(boxShow==0){
			body.css({"overflow-y": "scroll","overflow-x": "auto"});
			scrollbarWidth = browserW - $(window).width();
		}
		whenUseFF();

		// z-index value
		box.css("z-index", ++lightBoxZ);

		// change lightbox gray bg height
		var boxHY = boxH+boxY,height,width;
		if( browserH > bodyH ){height = ( browserH > boxHY ) ? browserH : boxHY;}
		else{height = ( boxHY > bodyH ) ? boxHY : bodyH;}

		// change lightbox gray bg width
		if( browserW < bodyW ){width = ( bodyW > boxW ) ? bodyW : boxW;}
		else{width = ( boxW > browserW ) ? boxW : browserW;}

		lightBox.height(height).width(width);

		// change box position
		browserW < boxW ? boxX = 20 : boxX = (browserW-boxW)/2;
		browserH < boxH ? boxY = scrollTop+20 : boxY = (browserH-boxH)/2 + scrollTop;
		box.css("left",boxX);
		box.css("top",boxY);

		// analysis browser's shape
		flatBrowser = 0; thinBrowser = 0;
		browserW < (boxW+20) ? flatBrowser=1 : flatBrowser=0 ;
		browserH < (boxH+20) ? thinBrowser=1 : thinBrowser=0 ;
	};

	// CSS
	if( ver != "6.0"){
		lightBox.css("position","fixed");	// IE6 can't read fixed
	}
	$("body").css({"overflow-y": "scroll","overflow-x": "auto"});
	// IE7
	if( ver == "7.0"){$("body" ).css({"overflow-y": "hidden","overflow-x": "hidden"});}

	// lock scroll
	var lockScroll = function(){
		lockCheck = 1;
		body.data({"scroll-position": scrollPosition,"previous-overflow": body.css("overflow")}).css({"overflow-y": "hidden","overflow-x": "hidden"});
		whenUseFF();
		body.css("margin-right",scrollbarWidth);
		box.css("left",boxX);
		lightBox.css("overflow-y","scroll");
	};

	// un-lock scroll
	var unlockScroll = function(){
		lockCheck = 0;
		body.css({"overflow": body.data("previous-overflow"),"overflow-y": "scroll","overflow-x": "auto"});
		whenUseFF();
		body.css("margin-right","0");
		box.css("left",boxX);
		lightBox.css("overflow-y","hidden");
	};

	// scroll to current position when use FireFox
	var whenUseFF = function(){
		if ( jQuery.browser.mozilla == true &&  jQuery.browser.msie == false ){
			window.scrollTo(scrollPosition[0], scrollPosition[1]);
		}
	};

	// Resize when it show
	$(window).resize(function(){
		if(boxShow==1){
			checkSize();
			if(thinBrowser == 0 && flatBrowser == 0){
				if(lockCheck == 0){lockScroll();}
			}else{
				if(lockCheck == 1){unlockScroll();}
			}
		};
	});

	// define lightbox bg class name
	lightBoxCID = "LB" + Math.ceil(Math.random()*100);
	lightBoxCIDiv = "." + lightBoxCID;

	// close do
	var closeDo = function(){
		if(thinBrowser == 0 && flatBrowser == 0){unlockScroll();}
		lightBox.fadeOut(250);
		box.fadeOut(250);
		boxShow=0;
	}

	// open lightbox
	var openFunc = function(){
		if(_settings.onOpen === undefined || _settings.onOpen(box) !== false ){
			checkSize();
			if(thinBrowser == 0 && flatBrowser == 0){lockScroll();}
			lightBox.fadeTo(250, _settings.backgroundOpacity);
			box.fadeIn(250);
			boxShow=1;
			lightBox.attr("class",lightBoxCID);
		}
	};
	box.data("open",openFunc);

	// close lightbox
	var closeFunc = function(){
		if(typeof(scrollPosition[1]) != "undefined"){
			if(_settings.onClose === undefined || _settings.onClose(box) !== false){
				closeDo();
			}
		}
	};
	box.data("close",closeFunc);
	
	// mask bg click close
	$(document).on("click",lightBoxCIDiv,function(event){
		if(_settings.maskClickClose){
			closeFunc();
		}
	});

	// box close icon
	$(document).on("click",_settings.btnName,function(event){
		closeFunc();
	});

	// button OK name
	if(typeof _settings.btnOkName == "string"){
		$(document).on("click",_settings.btnOkName,function(event){
			if(_settings.onOk === undefined || _settings.onOk(box) !== false){
				closeDo();
			}
		});
	}

	// open lightbox
	$(this).on("click", function(){
		if( $(window).width() > 770 )
		{
			openFunc();
		}
		else
		{
			openTopLoginBox();
		}
	});
};