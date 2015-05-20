var preview = function (img, selection) {
	if (!selection.width || !selection.height){return;}
    $('#x1').val(selection.x1);
    $('#y1').val(selection.y1);
    $('#x2').val(selection.x2);
    $('#y2').val(selection.y2); 
};

$(document).ready(function () {
    $('img#data').imgAreaSelect({
       handles: true,
       onSelectEnd: preview,
    });
});
