
function capture3D( cid ) {
	  var canvas  = document.getElementById(cid);

	  if ( typeof canvas.childNodes[0] == 'object' ){
	      canvas= canvas.childNodes[0]; // this is required for the rgl lib  0.95.1429
	  }  
	    
	  var data = canvas.toDataURL();
	  var err = "Error";
	 
	  if (window.XMLHttpRequest){
	        var xhReq = new XMLHttpRequest();
	  }
	  else{
	        var xhReq = new ActiveXObject("Microsoft.XMLHTTP");
	  }
	  xhReq.open('POST',"/scrapbook/screenshotadd" , true);
	  xhReq.setRequestHeader("Content-type", "attachment; charset=utf-8" );

	  xhReq.onreadystatechange = function() {
		  if ( xhReq.readyState != 4 ) return ;
		  var myWindow = window.open( xhReq.responseText ,'ScrapBook' );
		  myWindow.focus();
	  }

	  xhReq.send(data);
}

function capture2D( cid ) {
	var img = document.getElementById(cid);
	var myWindow = window.open("/scrapbook/imageadd/".concat(img.src), 'ScrapBook' );
	myWindow.focus();
}

function processFigure(ev) {
	allowDrop(ev)
	if ( ev.dataTransfer.mozSourceNode.constructor.name === 'HTMLImageElement'){
		var myWindow = window.open("/scrapbook/imageadd/".concat(ev.dataTransfer.mozSourceNode.src), 'ScrapBook' );
	}
	if (ev.dataTransfer.mozSourceNode.constructor.name ===  "HTMLCanvasElement" ){
		//this is a scalable canvas element and not an image!
		var myWindow = window.open("/scrapbook/imageadd/".concat(saved_img.src), 'ScrapBook' );
	}
	
	myWindow.focus();
}



function copyNames ( from, to ) {
	to.value = "";
    for(var i = 0; i < from.length; i++) {
         to.value += from[i].id
    }
}

function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    ev.dataTransfer.setData("text/html", ev.target.id);
}


function drop(ev) {
    ev.preventDefault();
    var data = ev.dataTransfer.getData("text/html");
    typeof( ev.target );
    ev.target.value += data;
    ev.target.appendChild(document.getElementById(data));
}

