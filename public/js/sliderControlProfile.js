$(document).ready(function() {

$('#switcher').click(function(){
 alert($(this).children().html());
    if($(this).children().html()=="Switch"){
     $(this).children().html("Switch Back");
      $("#myCampaigns").css("display","none");
      $("#otherCampaigns").fadeIn();
    }else{

     $(this).children().html("Switch");
      $("#otherCampaigns").css("display","none");
      $("#myCampaigns").fadeIn();
    }
 });

var numberTiles = $(".sliderMain").attr("name");
var showMessage =  $("#closeMessage").attr("name");
var temp;
if(showMessage == "showMessage") $("#flashMessage").fadeIn(); 
  
 $('.sliderMain').children('.sliderInstance').each(function(){
    temp = $(this).attr('id').substr(7);
   
    if(temp<numberTiles){
    $("#divWrap"+temp).children().children().fadeIn();
    }
    
  });
  
 
  if(temp > 1){
      $(".sliderArrow").css("visibility","visible").fadeIn();
    }
    
  $(".sliderInstance").mouseover(function(){
    $(this).css({  
    "border-bottom-style": "solid",
    "border-bottom-color": "orange",
    "border-bottom-width": "10px"
    });
  });
  
  $(".sliderInstance").mouseout(function(){
    $(this).css({  
    "border-bottom-style": "solid",
    "border-bottom-color": "orange",
    "border-bottom-width": "0px"
    });
  });
  
   $("#closeMessage").click(function(){
    $("#flashMessage").fadeOut();  
   });
   
});




function next(){

  var sliderLength = $('.sliderMain').children().children(':visible').length;
  var visibleIds = new Array();
  var allIds = new Array();
  
  $('.sliderMain').children().children().children(':visible').each(function(){
    visibleIds.push($(this).attr('id'));
  });
  
   $('.sliderMain').children('.library').each(function(){
    allIds.push($(this).attr('id'));
  });


  var fullArray = allIds.concat(allIds);
  
  for(var i=0;i<sliderLength;i++){
  
    var j = $.inArray(('temp'+$('#divWrap'+i).children().children().attr('id')),allIds);
    var temp = $('#'+fullArray[j+1]).html();
    var tempID =  $('#'+fullArray[j+1]).attr('id');
    // $('#divWrap'+i).css('padding-right','100px');
     $('#divWrap'+i).html(temp);
    
     $('#divWrap'+i).children().children().attr('id',tempID.substring(4));
    }  
}



function previous(){

  var sliderLength = $('.sliderMain').children().children(':visible').length;
  var visibleIds = new Array();
  var allIds = new Array();
  
  $('.sliderMain').children().children().children(':visible').each(function(){
    visibleIds.push($(this).attr('id'));
  });
  
   $('.sliderMain').children('.library').each(function(){
    allIds.push($(this).attr('id'));
  });
  
  var fullArray = allIds.concat(allIds);
  
  for(var i=0;i<sliderLength;i++){
  
    var j = $.inArray(('temp'+$('#divWrap'+i).children().children().attr('id')),allIds)+(allIds.length);
    var temp = $('#'+fullArray[j-1]).html();
    var tempID =  $('#'+fullArray[j-1]).attr('id');
  
     $('#divWrap'+i).html(temp);
     $('#divWrap'+i).children().children().attr('id',tempID.substring(4));
    }  
}