
function addInput( divName, limit=20, name="myInputs" ) {
    var form = document.forms[0];
    counter = name.concat("", "_counter" );
    
    if ( form[counter].value == limit)  {

        alert("You have reached the limit of adding " + counter + " inputs");

   }

   else {
        form[counter].value = (parseInt(form[counter].value) + 1);
        
        var newdiv = document.createElement('div');

        newdiv.innerHTML = "Group " + (parseInt(form[counter].value)) + " <br><textarea id='"+ name +"[]' name='" + name + "[]'></textarea>";

        document.getElementById(divName).appendChild(newdiv);

   }

}