$(document).ready () ->
  #alert "hello!"
  
  $(".subFlowChartFork").click () ->
    name = $(this).attr("name")
    $("#" + name).fadeIn("slow")

    if (name.substring(name.length-3,name.length)=="End") 
      $("#Donate").fadeIn('slow')
    
    if (name == "Tier2Question" || name == "Tier3Question")
      $("#fullFlow").css("height","+=150")
      $("#Donate").css("marginTop","+=150")
      if (name == "Tier3Question")
        $(".subFlowChart").css("clip","rect(0px,800px,600px,0px)")

    if (name == "Tier4YesEnd")
      $("#Tier4YesEndReload").delay(2000).fadeIn("slow")
      $("#Tier2End").delay(2000).fadeIn("slow")

  $("#message").mouseover () ->
    $(this).html("Chew on This!")

  $(".subFlowChartFork").mouseout () ->
    temp = $(this).attr("src")
    highlight = temp.substring(0, temp.length - 4)
    $(this).attr("src", highlight + "Black.png")

  $("#messageLink").click () ->
    #alert "hi"
