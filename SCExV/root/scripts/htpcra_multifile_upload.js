<script>
var form = document.getElementById('file-form');
var filePCR = document.getElementById('file-PCR');
var fileFacs = document.getElementById('file-facs');
var uploadButton = document.getElementById('upload-button');

form.onsubmit = function(event) {
  	event.defaultPrevented();

  	// Update button text.
  	uploadButton.innerHTML = 'Uploading...';

  	// Get the selected files from the input.
	var formData = new FormData();
	
	// Loop through each of the selected files.
	push2form (formData, filePCR.files, "PCR[]" );
	push2form (formData, fileFacs.files, "FACS[]" );

	// Set up the request.
	ar xhr = new XMLHttpRequest();
	
	// Open the connection.
	xhr.open('POST', '[% c.uri_for('/files/ajaxuploader') %]', true);
	
	// Set up a handler for when the request finishes.
	xhr.onload = function () {
	  	if (xhr.status === 200) {
	    // File(s) uploaded.
	    uploadButton.innerHTML = 'Upload';
	    alert( xhr.responseText  );
  	} else {
	    alert('An error occurred!');
  	}
  	// Send the Data.
	xhr.send(formData);
};
}


push2form = function( formData,files, where ) {
	var patt = /Array\d+/;
	for (var i = 0; i < files.length; i++) {
  		var file = files[i];
  		if ( ! patt.test(file.name) ) {
  			alert( 'Requirements for the filename '.concat(file.name).concat('not fulfilled: array ID has to be given as Array1 to ArrayN') )
  		}
  		else {  		
  		// Add the file to the request.
  		formData.append(where.concat(i), file, file.name);
  		}
	}
}

</script>