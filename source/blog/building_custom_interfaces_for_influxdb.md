---
title: Building Custom Interfaces For InfluxDB
author: Todd Persen
published_on: December 2, 2013
---

In addition to shipping with a dead-simple admin interface, InfluxDB also allows you to create [custom interfaces](/docs/interfaces/custom.html) with a little bit of HTML and JavaScript and drop them into the admin interface as plugins. This makes it incredibly easy to build custom dashboards or reporting interfaces that you can share with others. In this post, we'll walk through the basic concepts of building a plugin and put together a quick visualization example.

### Getting Started

First, it helps to know how the admin interface is structured so that you get a better sense of the world in which your custom interface will live. The [admin interface](https://github.com/influxdb/influxdb-admin) is built as a single-page application written in [AngularJS](http://angularjs.org/).Custom interfaces are loaded within an iframe, so that they are effectively isolated from the rest of the admin interface. This means that you will need to load your own JavaScript and CSS assets, but also means that you're free to build the application as you wish. The only requirement is that you build it as a single-page application, so that it doesn't navigate the browser away from the container.

Since the admin interface is responsible for authentication, it exposes an InfluxDB connection that can be accessed from within the iframe so that you aren't required to re-authenticate your custom interface when it loads. You can access this as `window.parent.window.influxdb` or just `parent.influxdb`, and the interface will conform to that of the [InfluxDB JavaScript Library](/docs/libraries/javascript.html).

### How InfluxDB Organizes Interfaces

When you look at the InfluxDB configuration file, you'll see a variable called `AdminAssetsDir`. This is the path that admin interface assets are served from. The `index.html` that ships with InfluxDB is the starting point for the admin interface. There is also a subfolder called `interfaces` which is where the custom interfaces live. By default, InfluxDB comes with an interface called `default`, but you can make your own by creating a subfolder with an appropriate name. These names should be lowercase and underscored, as they will be converted into human readable names automatically. Let's call this one `example`.

### Starting With Some HTML

This example interface is going to pull in some data from an InfluxDB instance and graph it for us, just like we might want on a dashboard. Let's start by setting up an quick framework, which will be a basic HTML page with jQuery, D3, and Bootstrap. Notice that we don't need to include the InfluxDB library because it's already loaded in the parent container, which we'll leverage for free. We'll also add a simple div with an id of `chart`, so that we can insert a graph into it.

```html
<html>
  <head>
    <title>InfluxDB Custom Interface Example</title>
    <script src="http://code.jquery.com/jquery-2.0.3.min.js" type="text/javascript"></script>
    <script src="http://d3js.org/d3.v3.min.js" type="text/javascript"></script>
    <script src="http://influxdb.org/javascripts/vendor/rickshaw.js" type="text/javascript"></script>
    <script src="/javascripts/interfaces/example.js" type="text/javascript"></script>

    <link href="http://influxdb.org/stylesheets/vendor/rickshaw.css" media="screen" rel="stylesheet" type="text/css">
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col-md-12">
          <h1>Important Dashboard</h1>
          <div id="chart"></div>
        </div>
      </div>
    </div>
  </body>
</html>
```

Save this as `index.html` inside the subfolder called `example`, which should leave us with a structure like this:

```bash
admin/
  index.html
  interfaces/
    default/
      index.html
    example/
      index.html
```

### Connecting With Some JavaScript

Now we just need to use the InfluxDB object from the parent window (remember, this is available as `parent.influxdb`).

```javascript
$(function() {
  $("input").click(function() {
    parent.influxdb.query("SELECT COUNT(message) FROM posts WHERE time > now() - 365d GROUP BY time(24h);", function(points) {
      var data = points.map(function(point) {
        return { x: point.time / 1000, y: point.count };
      }).reverse();

      var graph = new Rickshaw.Graph({
        element: document.querySelector("#chart"),
        width: 640,
        height: 200,
        renderer: 'line',
        series: [{ data: data, color: 'steelblue' }]
      });

      var xAxis = new Rickshaw.Graph.Axis.Time({ graph: graph });
      var yAxis = new Rickshaw.Graph.Axis.Y({
        graph: graph,
        orientation: 'left',
        element: document.getElementById('y_axis')
      });

      xAxis.render();
      yAxis.render();
      graph.render();
    });
  });
});
```
