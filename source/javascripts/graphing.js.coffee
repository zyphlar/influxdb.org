$ ->
  $("button#visualize").on "click", (e) ->

    influxdb = new InfluxDB("sandbox.influxdb.org", 9061, "todd", "password", "tp-tweets1");

    influxdb.query("SELECT COUNT(message) FROM posts WHERE time > now() - 365d GROUP BY time(24h);", (points) ->
        data = points.map (point) ->
          {x: Math.floor(point.time / 1000), y: point.count}
        .reverse()

        graph = new Rickshaw.Graph({
                element: document.querySelector("#chart"),
                width:720,
                height:240,
                renderer: 'line',
                series: [{
                        data: data,
                        color: 'steelblue'
                }]
        });

        xAxis = new Rickshaw.Graph.Axis.Time graph: graph
        yAxis = new Rickshaw.Graph.Axis.Y graph: graph, ticks: 5

        xAxis.render();
        yAxis.render();
        graph.render();
    )

