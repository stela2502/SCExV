function preview(img, selection) {
	console.log(selection);
	if (!selection.width || !selection.height)
		return;
	$('#x1').val(selection.x1);
	$('#y1').val(selection.y1);
	$('#x2').val(selection.x2);
	$('#y2').val(selection.y2);
	console.log($('#x1').val);
}

function mds_show(){
	form_fun( 'master', 'mds_alg', {a:'LLE', b:'ISOMAP'} ); }
function clust_show( ) {
	form_fun( 'master', 'cluster_type',  {a:'hierarchical clust', b:'mclust', c:'kmeans', d:'tclust'} );
}
function clust_show_rf( ) {
	form_fun_match( 'master', 'UG', 'randomForest', 'randomForest');
}
function form_fun ( formn, fieldn, all ) { 
	var x = document.forms[formn].elements[fieldn].value;
	for (t in all) {
		document.getElementById(all[t]).style.display ='none';
		if ( x.match(all[t])){
			document.getElementById(x).style.display ='inline';
		}
	}
}
function form_fun_match ( formn, fieldn, showThis, match ) { 
	var x = document.forms[formn].elements[fieldn].value;
	if ( x.match( match ) ) {
		document.getElementById(showThis).style.display ='inline'; 
	}else {
		document.getElementById(showThis).style.display ='none';
	}
}


$(document).ready(function () {	
	clust_show();
	mds_show();
	clust_show_rf();
/*	var intervalID = setInterval(function(){
		$.getJSON('/scrapbook/ajaxgroups/', {}, function(data){
			var SB  = document.getElementsByClassName('formField_UG')[0];
			alert( SB );
			var l = SB.options.length;
			for ( var x=l; x>= 0; x-- ){
				SB.remove( x );
			}
			for (var x = 0; x < data.length; x++) {
				var option = document.createElement("option");
				option.text = data[x];
		//		SB.add(option);
			}
		});

	}, 5000); // do that every fifth second
*/
});
