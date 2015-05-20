//http://www.w3schools.com/tags/canvas_putimagedata.asp



var loadimage = function ( source, boxname  ){
//	console.log( 'loadimage:', '(',source,',', boxname ,')');
	src = document.getElementById(source)[(boxname)].options[document.getElementById(source)[(boxname)].selectedIndex].value;
//	console.log( 'loadimage:', 'img_reset(', src ,')');
	return img_reset ( src );
}

var scaleFactor = 0.8;
var saved_img;
var lastX;
var lastY;
var lastW;
var lastH;
var imgWscale;
var imgHscale;
var cW;
var cH;

var img_reset = function(ImgId, src ) {
	var c = document.getElementById('ScalableCanvas');
	
	var ctx = c.getContext("2d");
	ctx.fillStyle = "white";
	ctx.fillRect(0, 0, c.width, c.height);
	var img = document.getElementById(ImgId);
	
	if (!(img === null)) {
		saved_img = img;
	} else {
		img = saved_img;
	}
//	console.log('img_reset canvas', c, img,ImgId, src );
	c.getContext("2d").drawImage(img, 0, 0, c.width, c.height);
	lastX = 0;
	lastY = 0;
	cW = lastW = c.width;
	cH = lastH = c.height;
	imgWscale = img.width / c.width;
	imgHscale = img.height / c.height;
	//console.log( 'img_reset', img.width,  img.height, cW, cH, imgWscale, imgHscale )
}

var register_mousewheelzoom = function(name) {
	$('#ScalableCanvas').bind('mouseleave', function() {
		img_reset();
	});
	$('#ScalableCanvas').bind('mousemove', function(e) {
		x_pos = (e.pageX - $('#ScalableCanvas').offset().left);// +
															// $(window).scrollLeft();
		y_pos = (e.pageY - $('#ScalableCanvas').offset().top); // +
															// $(window).scrollTop();
		// console.log( 'mouseover', x_pos, ";", y_pos);
	});
	$('#ScalableCanvas').mousewheel(
			function(event, delta, deltaX, deltaY) {
				var c = document.getElementById('ScalableCanvas');
				var ctx = c.getContext("2d");
				var img = saved_img;
				if (deltaY < 0) {
					// crop an image from the img
					var zoomedVals = zoom_out(-1);
					//console.log("Wheel up", zoomedVals, 0, 0, c.width,c.height);
				} else {
					var zoomedVals = zoom_in(+1);
					//console.log("Wheel down", zoomedVals, 0, 0, c.width,c.height);
				}
				ctx.fillStyle="white";
				ctx.fillRect(0,0,c.width,c.height); 
				ctx.drawImage(img, Math.round(zoomedVals.sourceX
							* imgWscale), Math.round(zoomedVals.sourceY
							* imgHscale), Math.round(zoomedVals.sourceWidth
							* imgWscale), Math.round(zoomedVals.sourceHeight
							* imgHscale), 0, 0, c.width, c.height);
				return false;
			});

}
// sourceX, sourceY, sourceWidth, sourceHeight
// lastX = 0;
// lastY = 0;
// lastW = c.width;
// lastH = c.height;

var zoom_in = function(value) {
	var c = document.getElementById('ScalableCanvas');
	//console.log('zoom: #1 ', lastX, lastY, lastH, lastW, 'xpos', x_pos, 'ypos',	y_pos);

	// first get the right values for this frame 

	var sourceWidth = cW * scaleFactor;
	var sourceHeight = cH * scaleFactor;

	var sourceX = x_pos - sourceWidth / 2;
	var sourceY = y_pos - sourceHeight / 2;

	//console.log('zoom: orig #2 ', sourceX, sourceY, sourceWidth, sourceHeight);

//	if (sourceX + sourceWidth > cW) {
//		sourceX = cW - sourceWidth;
//	}
//	if (sourceY + sourceHeight > cH) {
//		sourceY = cH - sourceHeight;
//	}

	//console.log('zoom: mod1 #2 ', sourceX, sourceY, sourceWidth, sourceHeight);

	if (sourceX < 0) {
		sourceX = 0;
	}

	if (sourceY < 0) {
		sourceY = 0;
	}

	//console.log('zoom: mod2 #2 ', sourceX, sourceY, sourceWidth, sourceHeight);

	// And now I need to recalculate the values in relation to the last clip
	// and in the end I need to recalculate that in ref to the img object!
	lastX = lastX + sourceX * (lastW / cW);
	lastY = lastY + sourceY * (lastH / cH);
	lastW = sourceWidth * (lastW / cW);
	lastH = sourceHeight * (lastH / cH);
	//console.log('zoom: #3 ', lastX, lastY, lastW, lastH);

	return {
		sourceX : lastX,
		sourceY : lastY,
		sourceWidth : lastW,
		sourceHeight : lastH
	}
}

zoom_out = function(value) {
	var c = document.getElementById('ScalableCanvas');
	//console.log('zoom: #1 ', lastX, lastY, lastH, lastW, 'xpos', x_pos, 'ypos',y_pos);

	// first get the right values for this frame 

	var sourceWidth = cW * 1/scaleFactor;
	var sourceHeight = cH * 1/scaleFactor;

	var sourceX = x_pos - sourceWidth / 2;
	var sourceY = y_pos - sourceHeight / 2;

	// And now I need to recalculate the values in relation to the last clip
	lastX = lastX + sourceX * (lastW / cW);
	if ( lastX < 0 ) {
		//outside of this selection
		lastX = 0;
	}
	lastY = lastY + sourceY * (lastH / cH);
	if ( lastY < 0 ) {
		//outside of this selection
		lastY = 0;
	}
	lastW = sourceWidth * (lastW / cW);
	lastH = sourceHeight * (lastH / cH);
	
	//console.log('zoom: #3 ', lastX, lastY, lastW, lastH);

	return {
		sourceX : lastX,
		sourceY : lastY,
		sourceWidth : lastW,
		sourceHeight : lastH
	}
}