---
title: InfluxDB Schema Design Guidelines
---

# Schema Design

In the 0.8.x versions of InfluxDB, it is recommended that you encode most metadata into the series names. This is similar to what you'd do in Graphite. A good way to do it is:

```
<tagName>.<tagValue>.<tagName>.<tagValue>.<measurement>
# for example
az.us-west-1.host.serverA.cpu
# or any number of tags
building.2.temperature
```

You can still use the columns, but if you do queries with a `where someColumn = 'someValue'` you should know that those queries do a range scan over the entire time range of those values. This is because columns aren't indexed.

The way to index data is by creating many series. InfluxDB can handle tens of thousands or even hundreds of thousands of different series names.

In the 0.9.0 release there will be support for tags. There will be a migration tool to move from the above schema type, to a tagged representation. Read more about the [InfluxDB 0.9.0 release here](/blog/2014/12/08/clustering_tags_and_enhancements_in_0_9_0.html).