'use strict';

var Chart;

if (document.getElementById('stages_time')) {

  $(document).ready(function() {
    var barchart = {};
    var chart_data = chart_data || {
      "title":"PQ Statistics: stages time",
      "current_journey":[
        {
          "name":"Draft Answer",
          "time":"0.0"
        },
        {
          "name":"POD Clearance",
          "time":"0.0"
        },
        {
          "name":"Minister Clearance",
          "time":"0.0"
        },
        {
          "name":"Submit Answer",
          "time":"0.0"
        }
      ],
      "benchmark_journey":[
        {
          "name":"Draft Answer",
          "time":"0.0"
        },
        {
          "name":"POD Clearance",
          "time":"0.0"
        },{
          "name":"Minister Clearance",
          "time":"0.0"
        },{
          "name":"Submit Answer",
          "time":"0.0"
        }
      ]
    };

    barchart.labels = chart_data.current_journey.map(function(d) { return d.name; });
    barchart.datasets = [
      {
        label: "Current Journey",
        fillColor: "rgba(220,220,220,0.5)",
        strokeColor: "rgba(220,220,220,0.8)",
        highlightFill: "rgba(220,220,220,0.75)",
        highlightStroke: "rgba(220,220,220,1)",
        data: chart_data.current_journey.map(function(d) { return d.time; })
      },
      {
        label: "Benchmark Journey",
        fillColor: "rgba(151,187,205,0.5)",
        strokeColor: "rgba(151,187,205,0.8)",
        highlightFill: "rgba(151,187,205,0.75)",
        highlightStroke: "rgba(151,187,205,1)",
        data: chart_data.benchmark_journey.map(function(d) { return d.time; })
      }
    ];

    var ctx = document.getElementById("current").getContext("2d");
    var currentBarChart = new Chart(ctx).Bar(barchart, {
      scaleLabel: "<%=value%> hours",
      multiTooltipTemplate: "<%= datasetLabel %>: <%= value %> hours",
      responsive: true
    });
  });
}
