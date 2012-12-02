//<script type="text/javascript" src="https://www.google.com/jsapi"></script>
function graph(inputData){
alert("what");
      alert(inputData);
      inputData = inputData.substring(1,inputData.length-1);
      inputData = inputData.split(",");
      alert(inputData.length);
      alert(inputData[0]);
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
     
           
           
           
      function drawChart() {
      
        var data = new google.visualization.DataTable();
            data.addColumn('string','Date');
            data.addColumn('number','Donation');
            data.addRows(inputData.length);
            for(var i=0;i<inputData.length;i++){
              data.setValue(i,0,"");
              data.setValue(i,1,inputData[i]);
            // graphData.push(new Array("",inputData[i]));
           
           }
           
       

/*
var data = google.visualization.arrayToDataTable([
             ['Country', 'Population', 'Area'],
  ['CN', 1324, 9640821],
  ['IN', 1133, 3287263],
  ['US', 304, 9629091],
  ['ID', 232, 1904569],
  ['BR', 187, 8514877]
           
        ]);
        */
        var options = {
          title: 'Goal Progress',
    
        };

        var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
}