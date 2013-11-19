---
title: Visualizing Bitcoin Post Frequency Using InfluxDB And Rickshaw
author: Todd Persen
published_on: November 18, 2013
---

InfluxDB has a straightforward and snappy HTTP API that makes it easy to
pull your time series data out in real-time for use in user interfaces and
visualizations. This makes it a great pairing with [D3](http://d3js.org),
a data visualization library written in JavaScript.

First, we need to supply InfluxDB with some seed data. In practice, you would
probably have a much larger, less-accessible dataset, but for the sake of
demonstration, let's use an open [Hacker News API](https://www.hnsearch.com/api)
to get a list of the last 1,000 posts containing the phrase `bitcoin` in the
title. Here's a quick ruby script that also leverages the InfluxDB rubygem for
the writing of data:

```ruby
require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "json"
require "time"
require "influxdb"

QUERY = "bitcoin"

http = Net::HTTP.new("api.thriftdb.com", 443)
http.use_ssl = true

influxdb = InfluxDB::Client.new "tp-tweets1", {
  :host => "sandbox.influxdb.org",
  :port => 9061,
  :username => "todd",
  :password => "password"
}

(0..9).each do |count|
  params = {
    "q" => QUERY,
    "start" => 100*count,
    "limit" => 100,
    "sortby" => "create_ts desc",
    "weights[title]" => "1.0",
  }

  request = Net::HTTP::Get.new "/api.hnsearch.com/items/_search?" +
    URI.encode_www_form(params)
  response = http.request(request)
  data = JSON.parse(response.body)

  data["results"].each do |result|
    influxdb.write_point("posts", {
      :message => result["item"]["title"],
      :time => Time.parse(result["item"]["create_ts"]).to_i * 1000
    })
  end
end
```

If you don't have a local installation of InfluxDB handy, head on over
to our [InfluxDB Playground](http://play.influxdb.org) and create a free
database to experiment with. Once you've got your username and password,
you can replace the ones in this script.

Once we have our data available, we can turn to the fun part - visualization.
To make things even easier, we're going to use a wrapper for D3
called [Rickshaw](http://code.shutterstock.com/rickshaw/), which was written
by the gang over at Shutterstock.

We'll just use the [InfluxDB Javascript Library](https://github.com/influxdb/influxdb-js)
to fetch the data, and then feed that right into Rickshaw a simple line chart.

```javascript
var influxdb = new InfluxDB("sandbox.influxdb.org", 9061, "todd", "password", "bitcoin");
var request = influxdb._readPoint("SELECT COUNT(message) FROM posts WHERE time > now() - 365d GROUP BY time(24h);");

request.then(function(response) {
  console.log(response);
  var points = response[0].points.map(function(point) {
    return {
      x: Math.floor(point[0] / 1000),
      y: point[2]
    };
  }).reverse();

  var graph = new Rickshaw.Graph({
    element: document.querySelector("#chart"),
    width: 640,
    height: 200,
    renderer: 'line',
    series: [{ data: points, color: 'steelblue' }]
  });

  var xAxis = new Rickshaw.Graph.Axis.Time({
    graph: graph
  });

  var yAxis = new Rickshaw.Graph.Axis.Y({
    graph: graph,
    orientation: 'left',
    element: document.getElementById('y_axis'),
    ticks: 5
  });

  xAxis.render();
  yAxis.render();
  graph.render();
});
```

Since InfluxDB lets us easily query the time series data, all we need is a simple
transformation and then it's ready to feed directly into Rickshaw.

You can view, run, and modify the entire thing on this Fiddle:

<iframe width="100%" height="270" src="http://jsfiddle.net/toddpersen/46ZRj/8/embedded/result,js,html,css" allowfullscreen="allowfullscreen" frameborder="0"></iframe>
