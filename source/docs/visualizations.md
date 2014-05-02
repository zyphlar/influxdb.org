# Visualizations and Dashbaords

One of the goals with building InfluxDB with an HTTP API first was that it would be easy to build many different visualization tools and dashboards around a standard API. Other than the built in admin interface, here are links to other projects that build visualizations on top of InfluxDB.

### Tasseo

[Tasseo](https://github.com/obfuscurity/tasseo), which describes itself as "a lightweight, easily configurable, near-realtime dashboard for time-series metrics. Charts are refreshed every two seconds and provide a heads-up view of the most current value." Has [support for InfluxDB](https://github.com/obfuscurity/tasseo#influxdb). Thanks to [Jason Dixon](https://twitter.com/obfuscurity) for adding this in!

### Grafana

[Grafana](http://grafana.org/) is a frontend with powerfull visualization features for time series data. It is very easy to install and configure Grafana as it is a client side application that runs in your browser. Has [support for InfluxDB](http://grafana.org/docs/features/influxdb/) as Datasource.
