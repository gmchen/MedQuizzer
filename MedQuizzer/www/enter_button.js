$(document).keyup(function(event){
	    if(event.keyCode == 13){
		            $("#goButton").click();
		            $("#text").select();
			        }
});
//$(document).on('click', function() {
//      $("#text").select();
//});

//<audio id="yepsound" src="yep.wav"></audio>
//<audio id="nopesound" src="nope.wav"></audio>
//<button onclick="document.getElementById('bflat').play()">Play!</button>

var yepaudio = new Audio('yep.wav');
var nopeaudio = new Audio('nope.wav');

Shiny.addCustomMessageHandler("myCallbackHandler",     
    function(correct) {
     if(correct == 1) {
       yepaudio.play();
     } else {
       nopeaudio.play();
     }
    }
);