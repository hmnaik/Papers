document.domain = 'tutorvista.com';
var page_from = top.location.href;
var tutor_name = "Tutor";
var json_div_content="<div id=\"chead\">\r\n\t<div style=\"float:left;width:150px;\">\r\n\t\t<div style=\"padding:5px 0 0 20px;\" id=\"popupheading\">Live chat with Tutor <\/div>\r\n\t<\/div>\r\n\t<div style=\"float:right;width:55px;height:26px;cursor:pointer;\">\r\n\t\t<a class=\"btnschats\" title=\"Minimize\/Maximize\" id=\"min\" onclick=\"gtminmax()\">&#160;<\/a>\r\n\t\t<a class=\"btnschats\" title=\"Goto sign-up page\" id=\"pop\" onclick=\"gotowhiteboard_popup()\">&#160;<\/a>\r\n\t\t<a class=\"btnschats\" title=\"Close\" id=\"close\" onclick=\"gtclose()\">&#160;<\/a>\r\n\t<\/div>\r\n<\/div>\r\n<div class=\"cbody\" id=\"minbody\">\r\n\t<div class=\"msgs\">\r\n\t\t<div style=\"padding:3px 6px;\" id=\"dismsg_popup\"><\/div>\r\n\t\t<div id=\"ttyping\" style=\"display:none;color:#888;\">&#160;&#160;"+tutor_name+" is typing...<\/div>\r\n\t<\/div>\r\n\t<div class=\"ctype\">\r\n\t<textarea id=\"ctypetext\" onblur=\"areablur_popup()\" onfocus=\"areafocus_popup(1);\" onkeyup=\"areakeyup_popup(event,this)\"><\/textarea>\r\n\t \r\n\t<\/div>\r\n<\/div>";

var blur = 1;
var usermessage = "";
var iid = 0;
var HOST_VISTA_SERVER="";
if(parent.top_chat_box['strSearchValue'])
	var appendKeywordToUrl = "k="+parent.top_chat_box['strSearchValue'];

    
function get_top_chat_box_popup() {
	window.setTimeout(function() {
		parent.document.getElementById("chat_box_iframe_popup").style.display = "block";
		var body = document.getElementsByTagName("body")[0];
		var con = document.createElement("div");
		con.id = "gtcon";
		con.style.display = "none";
		body.appendChild(con);

		document.getElementById("gtcon").innerHTML = json_div_content
			 +
				'<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'+
				'	id="bling" width="1" height="1"'+
				'		codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">'+
				'		<param name="movie" value="http://'+parent.top_chat_box['HOST_CDN_SERVER']+'/seo/popchat/bling.swf" />'+
				'		<param name="quality" value="high" />'+
				'		<param name="bgcolor" value="#869ca7" />'+
				'		<param name="allowScriptAccess" value="always" />'+
				'		<embed src="http://'+parent.top_chat_box['HOST_CDN_SERVER']+'/seo/popchat/bling.swf" quality="high" bgcolor="#869ca7"'+
				'			width="1" height="1" name="bling" align="middle"'+
				'			play="true"'+
				'			loop="false"'+
				'			quality="high"'+
				'			allowScriptAccess="always"'+
				'			type="application/x-shockwave-flash"'+
				'			pluginspage="http://www.adobe.com/go/getflashplayer">'+
				'		</embed>'+
				'</object>';
	},10);

	
	window.setTimeout("initConv_popup()",15000);
}
function getFlexApp(appName)
{
  if (navigator.appName.indexOf ("Microsoft") !=-1)
  {
    return window[appName];
  }
  else
  {
    return document[appName];
  }
}
function playBling()
{
	try{
	var flashMovie=getFlexApp("bling");
	flashMovie.playSound();
	}catch(e){}
}
function showGChat(e,sub){
	document.getElementById("dismsg_popup").innerHTML = "";
	if(sub){
		document.getElementById("popupheading").innerHTML = sub + " tutor";
		tutor_name = sub + " tutor";
	}
	document.getElementById("gtcon").style.display = "block";
	if(!e)
	document.getElementById("chead").style.backgroundColor = "#ff8a00";
}
function initConv_popup(){
	showGChat();
	addMsg_popup(tutor_name,"Hi. I'm a "+tutor_name);

if(parent.top_chat_box['strSearchValue']){
	
	/*addMsg_popup(tutor_name,"I see you came here looking for \""+parent.top_chat_box['strSearchValue']+"\"",2000,function(){
		addMsg_popup(tutor_name,"May I help you? ",1400);
	}); */
	addMsg_popup(tutor_name,"May I help you? ",1400);

}
else {
	addMsg_popup(tutor_name,"May I help you? ",1400);
} 

iid = window.setTimeout(function(){
addMsg_popup(tutor_name,"You there? ",1000);
},12000);

}

function addMsg_popup(name,val,tout,cb) {
	
	if(typeof(addMsg_popup.prev) == "undefined")
		addMsg_popup.prev="";

	if(name=="sys"){
		document.getElementById("gtcon").style.display = "block";
		document.getElementById("dismsg_popup").innerHTML += "<div style='color:#888'>Redirecting to sign-up page...</div>";
		addMsg_popup.prev = name;
		if(typeof(cb)=="function")
			window.setTimeout(function(){cb();},tout);
		return;
	}
	
	if(!tout){
		parent.document.getElementById("chat_box_iframe_popup").style.display = "block";
		document.getElementById("gtcon").style.display = "block";
		document.getElementById("dismsg_popup").innerHTML += "<div>"+(addMsg_popup.prev!=name?("<b>"+name+"</b>:"):"") + "&#160;&#160;" + val + "</div>";
		addMsg_popup.prev = name;
		if(name != "me" && name != "sys"){
			playBling();
			
			if(blur) {
				document.getElementById("chead").style.backgroundColor = "#ff8a00";
			}
		}
	}
	else{
		window.setTimeout(function(){
		document.getElementById("ttyping").style.display = "block";
		},300);
		
		window.setTimeout(function(){
		parent.document.getElementById("chat_box_iframe_popup").style.display = "block";
		document.getElementById("gtcon").style.display = "block";
		document.getElementById("dismsg_popup").innerHTML += "<div>"+(addMsg_popup.prev!=name?("<b>"+name+"</b>:"):"") + "&#160;&#160;" + val + "</div>";
		document.getElementById("ttyping").style.display = "none";
		playBling();
		if(blur) {
			document.getElementById("chead").style.backgroundColor = "#ff8a00";
		}
		
		if(typeof(cb)=="function")cb();
		addMsg_popup.prev = name;
		},tout);		
	}

	
}

function areafocus_popup(d) {
	if(typeof(d)!="undefined")
		blur = 0;
	
	document.getElementById("chead").style.backgroundColor = "#83aef7";
}

function areablur_popup(){
	blur = 1;
}
function startMsg_popup(type) {
    if(type == 'payment'){
        addMsg_popup(tutor_name,"We have the right package for you.",1500,function(){
            addMsg_popup(tutor_name,"Please answer a few questions on the following page.",1500, function(){
                addMsg_popup("sys","Loading Questionare",500,function(){
                    gotoquestionare_popup();
                });
            });
        });

    }
    else{ 
        addMsg_popup(tutor_name,"You have to sign-up with us for getting help.",2000,function(){
            addMsg_popup(tutor_name,"Let me redirect to sign-up page.",2000, function(){
                addMsg_popup("sys","Redirecting to sign-up page.",1000,function(){
                    gotowhiteboard_popup();
                });
            });
        });
    }
}
function areakeyup_popup(e,o) {
	if(!e)e=window.event;
	if(e.keyCode == 13) {
		usermessage = o.value;
        usermessage = usermessage.replace(/([\n\r]+)/g,"");
		if(usermessage.length > 0) {
			addMsg_popup("me",usermessage);
			if(typeof(areakeyup_popup.alreadydone) == "undefined"){
				
                if(parent.top_chat_box['widgetId'] == 245){
                    startMsg_popup('payment');
                }
                else {
                   // wbcachestart_popup();
                    startMsg_popup('whiteboard');
                }
				areakeyup_popup.alreadydone = true;
			}
		}
		o.value = "";
	}
	if(iid){
		window.clearTimeout(iid);
		iid=0;
	}
}


function gtclose(){
	document.getElementById("gtcon").style.display = "none";
	parent.document.getElementById("chat_box_iframe_popup").style.display = "none";
}
function eswf(url) {
    return '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="1" height="1"'+
    ' codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">'+
    ' <param name="movie" value="'+url+'" />'+
    ' <param name="quality" value="high" />'+
    ' <param name="bgcolor" value="#869ca7" />'+
    ' <embed src="'+url+'" quality="high" bgcolor="#869ca7"'+
    ' width="1" height="1" name="bling" align="middle"'+
    ' play="false"'+
    ' loop="false"'+
    ' quality="high"'+
    ' type="application/x-shockwave-flash"'+
    ' pluginspage="http://www.adobe.com/go/getflashplayer">'+
    ' </embed>'+
    '</object>';
}
function jsonpcb(obj){
		parent.top_chat_box['whiteBoardURL'] = parent.top_chat_box['whiteBoardURL'] + "&sid="+obj['sid']+"&mid="+obj['mid'];
    jsonpcb.got = 1;
}

function wbcachestart_popup() {
	var cachediv = document.createElement('div');
    cachediv.id = "cacheholder";
    cachediv.style.position = "absolute";
    cachediv.style.left = "-10000px";
    document.body.appendChild(cachediv);
    
    var sc = document.createElement('script');
    sc.src = parent.top_chat_box['whiteBoardURL'] + "&getsidmid=1&cb=jsonpcb";
    document.body.appendChild(sc);
    
    for(var j=0;j<parent.top_chat_box['cache_swf'].length;j++) {
        var u = parent.top_chat_box['cache_swf'][j];
        if(u)
        document.getElementById("cacheholder").innerHTML += eswf(u);
    }
    
    imar = [];
    
    for(var j=0;j<parent.top_chat_box['cache_js'].length;j++) {
        var u = parent.top_chat_box['cache_js'][j];
        if(u)
        imar[j] = new Image();imar[j].src = u;
    }
    
	if(parent.top_chat_box['strDevMode'] == false) { 
	parent._gaq.push(['_trackEvent','chat_box_clicked', 'top_chat_box_googlechat_clicked_'+parent.top_chat_box['pageType']+'_'+parent.top_chat_box['internalReference']+'_'+parent.top_chat_box['countryType']+'_'+parent.top_chat_box['phone_box_type']]);
	}
	
}

function gotowhiteboard_popup(){
	var redirFrm	= parent.document.createElement('form');
	/*var x = Math.floor((Math.random()*2));
	if(parent.top_chat_box['strDevMode'] == true) {
		if(x == 0)
			var redirectUrl = "http://localvista.tutorvista.com/cm/campaign.php?cpid=50050&ctx=tvd&k=s=SEOc=seo_buy_now";							   
		else
			var redirectUrl = "http://localvista.tutorvista.com/cm/campaign.php?cpid=50050&ctx=tvf&k=s=SEOc=seo_buy_now";
	}
	else{
		if(x == 0)
			var redirectUrl = "http://vista.tutorvista.com/cm/campaign.php?cpid=50050&ctx=tvd&k=s=SEOc=seo_buy_now";							   
		else
			var redirectUrl = "http://vista.tutorvista.com/cm/campaign.php?cpid=50050&ctx=tvf&k=s=SEOc=seo_buy_now";
	}*/
	var redirectUrl = "http://vista.tutorvista.com/cm/campaign.php?cpid=50050&ctx=tvd&k=s=SEOc=seo_buy_now";
	if(appendKeywordToUrl)
		redirectUrl = redirectUrl + appendKeywordToUrl;
	redirFrm.action = redirectUrl;
	redirFrm.method = "post";
    redirFrm.target = "_top";
    redirFrm.style.display = "none";
	redirFrm.name	= "chkout"+(new Date().getTime());
	redirFrm.id	= "chkout"+(new Date().getTime());
	var usrInp	= parent.document.createElement('input');
	usrInp.name	= "ui";
	usrInp.type	= "text";
	
	var pageFrom	= parent.document.createElement('input');
	pageFrom.name	= "pf";
	pageFrom.type	= "text";
	pageFrom.value = page_from;
	
	usermessage = usermessage.replace(/([\n\r]+)/g,"");
	if (parent.top_chat_box['strSearchValue']){
     	 usermessage = usermessage + " [Searched for: " + parent.top_chat_box['strSearchValue'] + "]";
	}
	usrInp.value = escape(usermessage);
	redirFrm.appendChild(usrInp);
	redirFrm.appendChild(pageFrom);
	parent.document.body.appendChild(redirFrm);
	redirFrm.submit();
	
}

function gotoquestionare_popup(){
    window.top.location = '/lp/questionare';
}

function gtminmax(){
	var t = document.getElementById("minbody").style.display;
	document.getElementById("minbody").style.display = (t=="none")?"block":"none";
	document.getElementById("gtcon").style.height = (t=="none")?"300px":"26px";
	parent.document.getElementById("chat_box_iframe_popup").style.height = (t=="none")?"300px":"26px";
	if(t=="none") {blur = 0;}
	else{ blur = 1;}
	areafocus_popup();
}
