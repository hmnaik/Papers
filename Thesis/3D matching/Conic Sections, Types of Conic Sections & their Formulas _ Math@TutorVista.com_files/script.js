var timeoutCheck;
if(typeof(window.addLoadEvent) == "undefined") {
function addLoadEvent(func) { 
	if(typeof(func)!='function')return;
	if(typeof(addLoadEvent.callfx) == 'undefined') {
		addLoadEvent.callfx = [];
		window.onload = function() {
			for(i=0;i<addLoadEvent.callfx.length;i++){
				
				addLoadEvent.callfx[i]();
			}
		} 
	}
	addLoadEvent.callfx.push(func)
}
}
function check_iframe() {
	var url=String(window.location);
	if(url.indexOf("close_iframe")!='-1') {
		window.location.hash="";
		document.getElementById("ifrm_tv").style.display="none";
		window.clearInterval(timeoutCheck);
	}
}
function showMe(obj) {
	if(obj.src.length>0) {
		obj.style.display="block";
	}
}
function processTvIframeUrl(el,tv_af_profile_id,tv_af_widget_id,tv_af_instance_id,gy,passParams,firstTimeOut,secondTimeOut) {
	var useTimeOut=0;
	if(gy.split('/')[2] == window.location.hostname) {
		useTimeOut=secondTimeOut;
	}
	else {
		useTimeOut=firstTimeOut;		
	}
	
	var url;
	if(tv_af_profile_id && tv_af_widget_id && tv_af_instance_id) {
		url='http://affiliate.tutorvista.com/serve/'+tv_af_profile_id+'/'+tv_af_widget_id+'/'+tv_af_instance_id+'?parent_location='+encodeURIComponent(window.location)+'&tv_af_referer='+encodeURIComponent(gy)+"&"+passParams;
		
	}
	else {
		url='http://affiliate.tutorvista.com/serve/';
		
	}
	window.setTimeout(function(){
		el.setAttribute('src', url);
	},useTimeOut);
	
}
function calculate_styles() {
	var temp_array=af_config.split(':');
	var position=temp_array[0];
	var style_array=temp_array[1].substr(1).split(/[a-z]/g);
	var return_array= new Array();
	return_array['position']=position;
	return_array['bottom']=style_array[0];
	return_array['left']=style_array[1];
	return_array['top']=style_array[2];
	return_array['right']=style_array[3];
	return return_array;
}
function show_iframe() {

	var config_array=calculate_styles();
	var el = document.getElementById("ifrm_tv");
	el.style.width=af_width;
	el.style.height=af_height;
	for(x in config_array) {
		if(config_array[x]!='-1') {
			el.style[x]=config_array[x];
		}
	}
	el.style.zIndex="10000";
	el.style.border="none";
	
	var id_array=tv_aff_id.split('-');
	var tv_af_profile_id=id_array[0];
	var tv_af_widget_id=id_array[1];
	var tv_af_instance_id=id_array[2];
	var gy=document.referrer;
	var passParams="";
	var firstTimeOut=0;
	var secondTimeOut=0;
	if(typeof(tv_aff_params)=="object") {
		for(params in tv_aff_params) {
			passParams+=params+"="+encodeURIComponent(tv_aff_params[params])+"&";	
			if(params=="firstTimeOut") {
				firstTimeOut=tv_aff_params[params];	
			}
			if(params=="secondTimeOut") {
				secondTimeOut=tv_aff_params[params];	
			}	
		}	
	}
	
	processTvIframeUrl(el,tv_af_profile_id,tv_af_widget_id,tv_af_instance_id,gy,passParams,firstTimeOut,secondTimeOut);
	timeoutCheck=window.setInterval("check_iframe()",1000);
}
document.write("<iframe id='ifrm_tv' scrolling='no' marginwidth='0' allowtransparency='true' marginheight='0' frameborder='0' vspace='0' hspace='0' style='display:none' onload='showMe(this)'></iframe>");
addLoadEvent(show_iframe);
