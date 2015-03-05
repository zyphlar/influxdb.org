# Querying Data
InfluxDB features an SQL-like query language for querying data and performing aggregations on that data. This section describes the syntax of the query. All queries that return data use the keyword `SELECT`.

The primary mechanism for issuing any of the queries listed below is through the HTTP API. For example, the command `SELECT * FROM cpu` can be executed using `curl` as follows:

```
curl -G 'http://localhost:8086/query' --data-urlencode "q=SELECT * FROM foo"
```
## Quote Usage
*Identifiers* are either unquoted or double quoted. Identifiers are database names, retention policies, measurements, or tag keys. String literals are always single quoted however.

## Selecting the Database and Retention Period
When selecting data using the query language, the target database and retention period can optionally be specified. Doing so is known as "fully qualifying" your series. A fully-qualified series is in the following form:

```
"<database>"."<retention period>".<series>
```

So, for example, the following statement:

```sql
SELECT value FROM "mydb"."mypolicy".cpu_load
```

queries for data from the series `cpu_load` in the database `mydb`, that has been written to the retention policy `mypolicy`. In the event that the database is not specified, the database is determined by the URL parameter `db`. If the retention period is not specified, the query will use the default retention period for the database.

This feature is particularly useful if you wish to query data from different databases or retention periods, in one single query.

## Select and Time Ranges

By default, InfluxDB returns data in time descending order.

```sql
SELECT value FROM response_times;
```

This simple query pulls the values for the `value` column from the `response_times` series.

### How to set query start and end time

If start and end times aren't set they will default to beginning of time until now, respectively.

The column `time` is built in for every time series in the database. You specify the start and end times by setting conditions on the `time` columns in the where clause.

Below are the different formats that can be used to specify start and end times.

#### Date time strings

Date time strings have the format `YYYY-MM-DD HH:MM:SS.mmm` where `mmm` are the milliseconds within the second. For example:

```sql
SELECT value FROM response_times
WHERE time > '2013-08-12 23:32:01.232' and time < '2013-08-13';
```

The time and date should be wrapped in single quotes. If you only specify the date, the time will be set to `00:00:00`. The `.232` after the hours, minutes, and seconds is optional and specifies the milliseconds.

#### Relative time

You can use `now()` to calculate a timestamp relative to the server's
current timestamp. For example:

```sql
SELECT value FROM response_times WHERE time > now() - 1h limit 1000;
```

will return up to the first 1000 points starting an hour ago until now.

Other options for how to specify time durations are `u` for microseconds, `s` for seconds, `m` for minutes, `h` for hours, `d` for days and `w` for weeks. If no suffix is given the value is interpreted as microseconds.

#### Absolute time

You can specify timestamp in epoch time, which is defined as the number of microseconds that have elapsed since 00:00:00 Coordinated Universal Time (UTC), Thursday, 1 January 1970. You can use the same suffixes from the previous section if you don't want to specify
timestamp in microseconds. For example:

```sql
SELECT value FROM response_times WHERE time > 1388534400s
```

will return all points that were writtern after `2014-01-01 00:00:00`

## Selecting Multiple Series

You can select from multiple series by name or by specifying a regex to match against. Here are a few examples.

```sql
SELECT * FROM events, errors;
```

Get the last hour of data from the two series `events`, and `errors`. Here's a regex example:

```sql
SELECT * FROM /^stats\./i WHERE time > now() - 1h;
```

Get the last hour of data from every time series that starts with `stats.` (case insensitive). Another example:

```sql
SELECT * FROM /.*/ limit 1;
```

Return the last point from every time series in the database.

## Deleting data or dropping series

The delete query looks like the following:

```sql
DELETE FROM response_times WHERE time < now() - 1h
```

With no time constraints this query will delete every point in the time series `response_times`. You must be a cluster or database administrator to run delete queries.

You can also delete from any series that matches a regex:

```sql
DELETE FROM /^stats.*/ WHERE time < now() - 7d
```

Any conditions in the where clause that don't set the start and/or end time will be ignored, for example the following query returns an error:

```sql
DELETE FROM response_times WHERE user = 'foo'
```

Delete time conditions only support ranges, an equals condition (=) is currently not supported.

Deleting all data for a series will only remove the points. It will still remain in the index. If you want to remove all data for a Measurement and remove it from the list of Measurements in a database index use the `DROP` query:

```sql
DROP MEASUREMENT response_times
```

## The WHERE Clause

We've already seen the where clause for selecting time ranges and a specific point. You can also use it to filter based on given values, tags, or regexes. Here are some examples of different ways to use `WHERE`.

```sql
SELECT * FROM events WHERE state = 'NY';

SELECT * FROM log_lines WHERE line =~ /error/i;

SELECT * FROM events WHERE customer_id = 23 AND type = 'click';

SELECT * FROM response_times WHERE value > 500 AND region='us-west'

SELECT * FROM events WHERE email !~ /.*gmail.*/;

SELECT * FROM events WHERE signed_in = false;

SELECT * FROM events
WHERE (email =~ /.*gmail.*/ or email =~ /.*yahoo.*/) AND state = 'ny';
```

The WHERE clause supports comparisons against regexes, strings, booleans, floats, integers, and the times listed before. Comparators include `=` equal to, `>` greater than, `<` less than, `<>` not equal to, `=~` matches against, `!~` doesn't match against. You can chain logic together using `AND` and `OR` and you can separate using `(` and `)`

## Group By

The `GROUP BY` clause in InfluxDB is used not only for grouping by given values, but also for grouping by given time buckets. You'll always be pairing this up with [a function](aggregate_functions.html) in the `SELECT` clause. Here are a few examples to illustrate how group by works.

```sql
-- count of events in 10 minute intervals
SELECT count(type) FROM events GROUP BY time(10m);

-- count of each unique type of event in 10 minute intervals
SELECT count(type) FROM events GROUP BY time(10m), type;

-- count of each unique type of event grouped by host tag
SELECT count(type) FROM events GROUP BY host

-- 95th percentile of response times in 30 second intervals
SELECT percentile(value, 95) FROM response_times GROUP BYtime(30s);
```

By default functions will output a column that have the same name as the function, e.g. `count` will output a column with the name `count`. In order to change the name of the column an `AS` clause is required. Here is an example to illustrate how aliasing work:

```sql
SELECT count(type) AS number_of_types GROUP BY time(10m);
```

The time function takes the time interval which can be in
microseconds, seconds, minutes, hours, days or weeks. To specify the
units you can use the respective suffix `u`, `s`, `m`, `h`, `d` and `w`.

## Merging Series

You can merge multiple time series into a single stream in the `SELECT` clause. This is helpful when you want to run a function over one of the columns with an associated group by time clause.

```sql
SELECT count(type) FROM user_events merge admin_events GROUP BY time(10m)
```

You'd get a single time series with the count of events from the two combined in 10 minute intervals.

## Joining Series

Joins will put two or more series together. Since timestamps may not match exactly, InfluxDB will make a best effort to put points together. Joins are used when you want to perform a transformation of one time series against another. Here are a few examples.

```sql
SELECT ...
```

```sql
SELECT ...
```

## Getting series with special characters

InfluxDB allows you to use any characters in your time series names. However, parsing queries for those series can be tricky. So it's best to wrap your queries for any series that has characters other than letters in double quotes like this:

```sql
SELECT * FROM "series with special characters!"

SELECT * FROM "series with \"double quotes\""
```

