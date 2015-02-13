# Continuous Queries

When writing in large amounts of raw data, you will often want to query a downsampled variant of the data for viewing or analysis. In some cases, this downsampled data may be needed many times in the future, and repeatedly computing the same rollups is wasteful. Continuous queries let you precompute these expensive queries into another time series in real-time.

Here are a few examples:

```sql
SELECT percentile(value, 95) FROM response_times GROUP BY time(5m)
INTO response_times.percentiles.5m.95

SELECT COUNT(type) FROM events GROUP BY time(10m), type
INTO events.count_per_type.10m
```

## Creating Continuous Queries

Continuous queries are created when you issue a select statement with an `INTO` clause. Instead of returning the results immediately like a normal select query, InfluxDB will instead store this continuous query and run it periodically as data is collected. Only cluster and database admins are allowed to create continuous queries.

### Fanout Continuous Queries

Fanout queries work as a kind of index. If you have a series where you're commonly querying `WHERE some_col = 'some string'` then you may want to use the fanout query to create series for each column values.

For example, the following query will fan every point from the time series `events` into a separate series per unique `page_id`:

```sql
SELECT * FROM events INTO events.[page_id]
```

The `[page_id]` will get interpolated with the value from the `page_id` column. Null values will result in a time series like `events.` so it's up to you to ensure that you actually write a `page_id` value with each event.

You can save some space by selecting only the columns you want included in the fanned out series:

```sql
SELECT type FROM events INTO events.[page_id]
```

This would take only the `type` column into each page specific events series. Fanout queries won't backfill old data. Only data written in after the creation of the fanout query will be evaluated.

#### Associating fanned out points with the original points

When points are fanned out, the resulting points have the same `time` and `sequence_number`. That means if you know the source series, you'll be able to query the point that produced a fanout point by time and sequence number.

### Downsampling Continuous Queries

This is expected to be the primary use case for continuous queries. When a continuous query is created from a select query that contains a `GROUP BY` time() clause, InfluxDB will write the aggregate into the target time series when each time interval elapses. On creation, the cluster will backfill old data asynchronously in the background.

```sql
SELECT COUNT(name) FROM clicks GROUP BY time(1h) INTO clicks.count.1h
```

### Continuous Downsampling of Many Series

If you have many series that you want downsampled, it's best to create a convention with a single continuous query that downsamples many series. Here's an example:

```sql
SELECT mean(value), percentile(90, value) AS percentile_90, percentile(99, value) AS percentile_99
FROM /^stats.*/ group by time(10m) INTO 10m.:series_name
```

The `:series_name` will get interpolated into the series that is selected from. Note that you should specify in the regex that the query must begin with a given name. Otherwise you can end up in a loop where new series get generated and selected from in the next run.


## Listing Continuous Queries

To see the continuous queries you have defined, query `SHOW CONTINUOUS QUERIES` and InfluxDB will return the name and query for each continuous query in the database.

## Deleting Continuous Queries

Continuous queries are referred to by their internal id, which can be retrieved through the `DROP CONTINUOUS QUERY` command. The drop query takes the following form:

```sql
DROP CONTINUOUS QUERY <name>
```

## Backfilling Data

In the event that the source time series already has data in it when you create a new downsampled continuous query, InfluxDB will go back in time and calculate the values for all intervals up to the present. The continuous query will then continue running in the background for all current and future intervals.

If you have a mountain of historical data that you don't want to churn through to backfill you can issue the query with the option `backfill(false)` at the very end to tell InfluxDB to not bother backfilling.

Fanout queries currently don't backfill. Watch this [issue to track fanout backfill](https://github.com/influxdb/influxdb/issues/186).

## Recalculating Historical Intervals

Currently, the only way to recalculate historical intervals is to drop the continuous query and recreate it. However, there is an [issue open to be able to recalculate the continuous query for arbitrary ranges in the past](https://github.com/influxdb/influxdb/issues/211).

## Restrictions on Continuous Queries

It's important to note that not all `SELECT` queries can be turned into continuous queries. The limitations are specific to whether you have a `GROUP BY` time clause (downsampling) or no `GROUP BY` time clause (fanout).

Fanout queries don't work with inner joins, merges, or the `WHERE` clause.
