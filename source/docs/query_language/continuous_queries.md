# Continuous Queries

When writing in large amounts of raw data, you will often want to query a downsampled variant of the data for viewing or analysis. In some cases, this downsampled data may be needed many times in the future, and repeatedly computing the same rollups is wasteful. Continuous queries let you precompute these expensive queries into another time series in real-time. Here are a few examples:

```sql
select percentile(value, 95) from response_times group by time(5m) 
into response_times.percentiles.5m.95

select count(type) from events group by time(10m), type 
into events.count_per_type.10m
```

## Creating Continuous Queries

Continuous queries are created when you issue a select statement with an into clause. Instead of returning the results immediately like a normal select query, InfluxDB will instead store this continuous query and run it periodically as data is collected. It's important to note that not all select queries can be turned into continuous queries, only those with no group by clause (fanout) or those with a time-based group by clause (downsample).

### Fanout Continuous Queries

The following query will write every point from time series `clicks` into `events`:

```sql
select * from clicks into events.global;
```

This can be valuable if you want to combine the results of multiple time series into a single time series, rather than attempting to merge data later.

### Downsampled Continuous Queries

This is expected to be the primary use case for continunous queries. When a continuous query is created from a select query that contains a group by time() clause, InfluxDB will write the aggregate into the target time series when each time interval elapses.

```sql
select count(name) from clicks group by time(1h) into clicks.count.1h
```

Each hour, this query will count the number of points written into the time series called `clicks` and write a single point into the target time series called `clicks.count.1h`.

## Listing Continuous Queries

In order to see what continuous queries you have defined, just issue `list continuous queries` and InfluxDB will return the id and query for each continuous query in the queried database.

## Deleting Continuous Queries

Continuous queries are referred to by their internal id, which can be retrieved through the `list continuous queries` command. The drop query takes the following form:

```sql
drop continuous_query <id>
```

## Backfilling Data

In the event that the source time series already has data in it when you create a new downsampled continuous query, InfluxDB will go back in time and calculate the values for all intervals up to the present. The continuous query will then continue running in the background for all current and future intervals.
