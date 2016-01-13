function show(element) {
	element.className += "hover";
}
function hide(element) {
	element.className = element.className = "";
}
function RFcheck(form) {
    if (window.XMLHttpRequest){
        var xhReq = new XMLHttpRequest();
  }
  else{
        var xhReq = new ActiveXObject("Microsoft.XMLHTTP");
  }
    xhReq.open('get',"/analyse/rfgrouping" , true);
    xhReq.send();
    xhReq.onreadystatechange = function() {
	if ( xhReq.readyState != 4 ) return ;
	data = xhReq.responseXML;
	x = xmlDoc.getElementsByTagName("CHANGED");
	if ( x ) {
	    x = xmlDoc.getElementsByTagName("GROUPS");
	    form.UG.options.length=0
	    for (id = form.UG.options.length; id < (form.UG.options.length + x.length); id++) {
		i = id - form.UG.options.length;
		form.UG.options[id]=new Option( x[i].childNodes[0].nodeValue, x[i].childNodes[0].nodeValue )
	    }
	}
    }
}