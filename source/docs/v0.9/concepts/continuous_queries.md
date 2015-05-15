# Continuous Queries

When writing in large amounts of raw data, you will often want to query a downsampled variant of the data for viewing or analysis. In some cases, this downsampled data may be needed many times in the future, and repeatedly computing the same rollups is wasteful. Continuous queries let you precompute these expensive queries into another time series in real-time.

## Creating Continuous Queries

Continuous queries are created on a database. Instead of returning the results immediately like a normal query, InfluxDB will instead store this continuous query and run it periodically as data is collected. Only cluster and database admins are allowed to create continuous queries.

Here are a few examples:

```sql
CREATE CONTINUOUS QUERY response_times_percentile ON mydb BEGIN
  SELECT percentile(value, 95) INTO "response_times.percentiles.5m.95" FROM response_times GROUP BY time(5m)
END

CREATE CONTINUOUS QUERY event_counts_per_10m_by_type ON mydb BEGIN
  SELECT COUNT(type) INTO typeCount_10m_byType FROM events GROUP BY time(10m), type
END
```

### Downsampling Continuous Queries

This is expected to be the primary use case for continuous queries. When a continuous query is created from a select query that contains a `GROUP BY` time() clause, InfluxDB will write the aggregate into the target time series when each time interval elapses. On creation, the cluster will backfill old data asynchronously in the background.

```sql
CREATE CONTINUOUS QUERY clicks_per_hour ON mydb BEGIN
  SELECT COUNT(name) INTO clicksCount_1h FROM clicks GROUP BY time(1h) 
END
```


## Listing Continuous Queries

To see the continuous queries you have defined, query `SHOW CONTINUOUS QUERIES` and InfluxDB will return the name and query for each continuous query in the database.

## Deleting Continuous Queries

The drop query takes the following form:

```sql
DROP CONTINUOUS QUERY <name> ON <database>
```
