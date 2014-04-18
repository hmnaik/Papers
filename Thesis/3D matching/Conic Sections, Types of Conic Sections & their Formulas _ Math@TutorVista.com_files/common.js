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

function ge(id){
    return document.getElementById(id);
}

addLoadEvent(function(){
    var el = ge("navigationdata");
    if(el){
        var lis = el.getElementsByTagName("li");
        var beforehasitems = false;
        var afterhasitems = false;
        var currentOver = false;
        for(var i=0;i<lis.length;i++){
            var li = lis[i];
            if(li.className.indexOf('current') != -1){
                currentOver = true;
            }
            else{
                if(li.className.indexOf("immitem") == -1){
                    li.style.display = 'none';
                    if(currentOver)
                        afterhasitems = true;
                    else
                        beforehasitems = true;
                }
            }
        }
        
        if(afterhasitems){
            var selector = document.createElement('li');
            selector.className = 'navlist';
            selector.innerHTML = '<a href="javascript:void(showNavAll(true))" class="selector selectordown" title="Show more"></a>';
            el.appendChild(selector);
        }
        if(beforehasitems){
            var selector = document.createElement('li');
            selector.className = 'navlist';
            selector.innerHTML = '<a href="javascript:void(showNavAll(false))" class="selector selectorup" title="Show more"></a>';
            el.insertBefore(selector, el.firstChild);
        }
    }
});

function showAnswer(id){
    var el = ge('ws_answer_'+id);
    if(el) el.style.display = "block";
}

function showNavAll(dir){
    var el = ge("navigationdata");
    if(el){
        var lis = el.getElementsByTagName("li");
        var currentOver = false;
        for(var i=0;i<lis.length;i++){
            var li = lis[i];
            
            if(dir == false && i == 0){
                li.style.display = 'none';
                continue;
            }
            else if(dir && i==lis.length-1){
                li.style.display = 'none';
                continue;
            }
            
            if(li.className.indexOf('current') != -1){
                currentOver = true;
            }
            else{
                if(li.className.indexOf("immitem") == -1){
                    if(currentOver == dir){
                        li.style.display = '';
                    }
                }
            }
        }
    }
}

var max_width  = 460;
addLoadEvent(function(){
    var container = document.getElementById("vistacontent");
    if(!container)return;
	var images = container.getElementsByTagName('img');
    for (var i=0; i < images.length; i++) {
	      if (images[i].width > max_width && images[i].className != "noresize") {
			  images[i].height = images[i].height * (max_width / images[i].width);
	    	  images[i].width = max_width;
	      }
    }
});
