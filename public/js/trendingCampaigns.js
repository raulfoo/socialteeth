$(document).ready(function() {
  
  
  $('#featuredAd').children('.allAdsTopBox').eq(0).fadeIn();
  
  $('.nextAd').click(function(){
    $(this).parent().parent().css('display','none');
    if($(this).parent().parent().next().length == 0) {
      $('#featuredAd').children('.allAdsTopBox').eq(0).fadeIn();
    }
    else{
      $(this).parent().parent().next().fadeIn();
    }
  });
  
  
  $("#enlargeAbout").mousedown(function(){ 
  
    if($(this).children().html()=="Enlarge"){
    
      $("#aboutSTVid").css({height: 225, width: 360});
      $(this).children().html("Minimize");
    }
    else{
    
      $("#aboutSTVid").css({height: 150, width: 240});
      $(this).children().html("Enlarge");
    }
  });
  

});

