$(document).ready(function() {
var temp='';

 var changeBanner = setInterval(Periodic,15000);

  $("#message").mouseover(function() {
  temp = $("#messageLink").text();
    $("#messageLink").css('font-size','3em');
  $("#messageLink").text('Bite!');
});

 $("#message").mouseout(function() {
 $("#messageLink").css('font-size','1em');
  $("#messageLink").text(temp);
});


 $("#message").click(function() {
   $("#embeddedVid").toggle('slow');
});

 $("#rightArrow").click(function() { 
  clearInterval(changeBanner);
 changeBanner = setInterval(Periodic,15000);

 var output; 
  $("#fullBanner").animate({opacity:0});
  
  $.get("/changeChatIndex?index=next", function(result) {
    output = result;
 
       },'html');
       
       var t = setTimeout(function(){$("#fullBanner").animate({opacity:1}).html(output)}, 600);
 });

 $("#leftArrow").click(function() {
 clearInterval(changeBanner);
 changeBanner = setInterval(Periodic,15000);
 
 var output; 


  $("#fullBanner").animate({opacity:0});
  
  $.get("/changeChatIndex?index=previous", function(result) {
    output = result;
     
       },'html');
       
       var t = setTimeout(function(){$("#fullBanner").animate({opacity:1}).html(output)}, 600);
});

});
function Bite() {
  temp = $("#messageLink").text();

  $("#messageLink").css('font-size','3em');
 // $("#message").css('margin-left','0px');
  $("#messageLink").text('Bite!');

}

function Normal(){
$("#messageLink").css('font-size','1em');
  // $("#message").css('margin-left',orientation);
  $("#messageLink").text(temp);
    
}

function showVid(){
//alert(changeBanner);
 //clearInterval(changeBanner);
 //alert(changeBanner);
  $("#embeddedVid").toggle('slow');
}


function Periodic(){

var output=''; 
  $("#fullBanner").animate({opacity:0});
  
  $.get("/changeChatIndex?index=next", function(result) {
    output = result;
     
       },'html');
       
       var t = setTimeout(function(){$("#fullBanner").animate({opacity:1}).html(output)}, 600);
}

