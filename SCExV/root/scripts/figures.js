
function showimage(source, target, boxname ) 
{
	if (!document.images) 
		return
		document.getElementById(target).src=
			document.getElementById(source)[(boxname)].options[document.getElementById(source)[(boxname)].selectedIndex].value
}
function showElementByVisible(obj) {
	document.getElementById(obj).style.display = 'inline';
	if ( obj ==='twoD' ){
		$('img#data').imgAreaSelect({
			handles: true,
			onSelectEnd: preview,
		});
	}
}
function hideElementByDisplay(obj) {
	document.getElementById(obj).style.display = 'none';
}

function updatefirst() {
	showimage('mygallery', 'picture_exclude','picture');
	return
}
