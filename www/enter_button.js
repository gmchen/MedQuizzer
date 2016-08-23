$(document).keyup(function(event){
	    if(event.keyCode == 13){
		            $("#goButton").click();
		            $("#text").select();
			        }
});
$(document).on('click', function() {
      $("#text").select();
});
