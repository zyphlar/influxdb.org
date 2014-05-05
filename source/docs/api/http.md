# HTTP API

The primary interface to InfluxDB is through the HTTP API. Through it you can write data, run queries, and do cluster administration.

### Writing Data

InfluxDB is split into databases which have different time series. Each time series has data points that can have any number of columns. It's like a regular database, but the columns on tables (time series) don't have to be defined up front. So the rows look like a hashmap of key value pairs. Valid characters for time series and column names include letters, numbers, dashes, underscores, or periods.  Time series and column names must start with a number or letter.

Assuming you have a database named `foo_production` you can write data by doing a `POST` to `/db/foo_production/series?u=some_user&p=some_password` with a JSON body of points. Notice that username and password are specified in the query string. Users can be restricted to having read or write access and can also be restricted by the time series name and the queries they can run, but we'll get to administration later. Here's what a sample JSON body looks like:

```json
[
  {
    "name": "events",
    "columns": ["state", "email", "type"],
    "points": [
      ["ny", "paul@influxdb.org", "follow"],
      ["ny", "todd@influxdb.org", "open"]
    ]
  },
  {
    "name": "errors",
    "columns": ["class", "file", "user", "severity"],
    "points": [
      ["DivideByZero", "example.py", "someguy@influxdb.org", "fatal"]
    ]
  }
]
```

As you can see you can write to multiple time series names in a single POST. You can also write multiple points to each series. The values in `points` must have the same index as their respective column names in `columns`. However, not all points need to have values for each column, `null`s are ok.

Note that times weren't specified in those points. In that case the server assigns them automatically. If you want to specify the time you can by including the `time` column in the POST, which should be an epoch from 1, Jan 1970 in either seconds, milliseconds, or microseconds.

```json
[
  {
    "name": "response_times",
    "columns": ["time", "value"],
    "points": [
      [1382819388, 234.3],
      [1382819389, 120.1],
      [1382819380, 340.9]
    ]
  }
]
```

When you include a time, InfluxDB will interpret it in milliseconds. You can specify the precision of the value in the call like `/db/foo_production/series?u=some_user&p=some_password&time_precision=m`. You can specify either second (s), millisecond (m), or microsecond (u) from epoch (1, Jan 1970). The underlying datastore keeps everything at microsecond precision.

#### Updating Points

Individual data points are uniquely identified by their `sequence_number`, `time` and the series name. Sequence numbers are assigned automatically by the cluster. InfluxDB isn't optimized for updates and there are no specific guarantees if multiple writers try to update a point at the same time. However, it is possible to update a point by including the sequence_number in the write. The supplied column values will be overwritten while other columns will remain unchanged.

#### Deleting Points

InfluxDB is designed to delete a range of data, not individual points. It's handy for regularly clearing out raw data to save space in the cluster or when removing data to reimport.

##### One Time Deletes

In order to delete an entire series you can send a `DELETE` request to
the `/db/:db/series/:series` endpoint with the following parameters:

* `u` - username
* `p` - password
* `:db` - the name of the database that contains the series
* `:series` - the name of the series to be deleted

##### Regularly Scheduled Deletes

To create a delete that runs regularly send a `POST` request to `/db/:name/scheduled_deletes` with a JSON body:

```json
{
  "regex": "stats\..*",
  "olderThan": "14d",
  "runAt": 3
}
```

This query will delete data older than 14 days from any series that starts with `stats.` and will run every day at 3:00 AM.

You can see what scheduled deletes are configured and remove them like this:

```bash
# get list of deletes
curl http://localhost:8086/db/site_dev/scheduled_deletes

# remove a regularly scheduled delete
curl -X DELETE http://localhost:8086/db/site_dev/scheduled_deletes/:id
```

### Querying Data

Getting data from InfluxDB is done through a single endpoint. `GET db/:name/series`. It takes five parameters:

* `q` - the query
* `u` - username
* `p` - password
* `time_precision` the precision timestamps should come back in. Valid options are `s` for seconds, `m` for milliseconds, and `u` for microseconds.
* `chunked` - true|false, false is the default.

#### Query

The query parameter uses the [InfluxDB Query Language](/docs/query_language) and should be URI encoded.

#### Sample Response

Responses are JSON data that look like this:

```json
[
  {
    "name": "some_series",
    "columns": ["time", "sequence_number", "column_a", "column_b"],
    "points": [
      [1383059590062, 1, "some string", true]
    ]
  }
]
```

The response is a collection of objects where each object is a collection of points from a specific time series (you can request data from multiple series in a single query). The index of the column name matches up with the associated index in each point. Some column values can be null. The `time` and `sequence_number` columns are special built in columns. Time is always returned as an epoch from 1, Jan, 1970. The precision of the epoch will be whatever was requested in the `time_precision` parameter.

The `sequence_number` will only show up on queries that return raw data points. Points can be uniquely identified by the series, time, and sequence number. When doing group by queries, sequence numbers will not be returned.

The order of the points defaults to time descending. The only other option is to order by time ascending by adding `order asc` to the query.

#### Chunked Responses

If the request asks for a chunked response, JSON objects will get written to the HTTP response as they are ready. They will come in batches in the requested time order. That might look like this:

```json
{
  "name": "a_series",
  "columns": ["time", "sequence_number", "column_a"],
  "points": [
    [1383059590062, 3, 27.3],
    [1383059590062, 4, 97.1]
  ]
}
```

Then followed by

```json
{
  "name": "b_series",
  "columns": ["time", "sequence_number", "column_a"],
  "points": [
    [1383059590062, 2, 2232.1]
  ]
}
```

Then followed by

```json
{
  "name": "a_series",
  "columns": ["time", "sequence_number", "column_a"],
  "points": [
    [1383059590000, 1, 291.7],
    [1383059590000, 2, 44.1]
  ]
}
```

So the chunks for different series can be interleaved, but they will always come back in the correct time order. You should use chunked queries when pulling back a large number of data points. If you're just pulling back data for a graph, which should generally have fewer than a few thousand points, non-chunked responses are easiest to work with.

### Administration & Security

The following section details the endpoints in the HTTP API for administering the cluster and managing database security.

#### Creating and Dropping Databases

There are two endpoints for creating or dropping databases. The requesting user must be a cluster administrator.

```bash
# create a database
curl -X POST 'http://localhost:8086/db?u=root&p=root' \
  -d '{"name": "site_development"}'

# drop a database
curl -X DELETE 'http://localhost:8086/db/site_development?u=root&p=root'
```

##### Replication factor (> v0.4.0)

Starting with version 0.4.0, influxdb support replicating time series
data to multiple servers for high availability. Time series inherit
the replication factor of the database to which it belongs. By default
all new databases have replication factor of 1, meaning every point exist
on one and only one server. In order to create a database with a higher
replication factory you can do the following:

```bash
# create a database
curl -X POST 'http://localhost:8086/db?u=root&p=root' \
  -d '{"name": "site_development", "replicationFactor": 2}'
```

#### Security

InfluxDB has three different kinds of users:

##### cluster admin

A cluster admin can add and drop databases. Add and remove database
users and database admins to any database and change their read and
write access. A cluster admin can't query a database though. Below are
the endpoints specific to cluster admins:

```bash
# get list of cluster admins curl
'http://localhost:8086/cluster_admins?u=root&p=root'

# add cluster admin
curl -X POST 'http://localhost:8086/cluster_admins?u=root&p=root' \
  -d '{"name: "paul", "password": "i write teh docz"}'

# update cluster admin password
curl -X POST 'http://localhost:8086/cluster_admins/paul?u=root&p=root' \
  -d '{"password": "new pass"}'

# delete cluster admin
curl -X DELETE 'http://localhost:8086/cluster_admins/paul?u=root&p=root'
```

##### database admin

A database admin can add and remove databases admins and database
users and change their read and write permissions. It can't add
or remove users from a different database.

##### database user

A database user can read and write data to the current database.
The user can't add or remove users or admins or read/write data
from/to time series that they don't have permissions for.

Below are examples of adding/removing databases users and database
admins:

```bash
# Database users, with a database name of site_dev

# add database user
curl -X POST 'http://localhost:8086/db/site_dev/users?u=root&p=root' \
  -d '{"name": "paul", "password": "i write teh docz"}'

# delete database user
curl -X DELETE 'http://localhost:8086/db/site_dev/users/paul?u=root&p=root'

# update user's password
curl -X POST 'http://localhost:8086/db/site_dev/users/paul?u=root&p=root' \
  -d '{"password": "new pass"}'

# get list of database users
curl 'http://localhost:8086/db/site_dev/users?u=root&p=root'

# add database admin privilege
curl -X POST 'http://localhost:8086/db/site_dev/users/paul?u=root&p=root' \
  -d '{"admin": true}'

# remove database admin privilege
curl -X POST 'http://localhost:8086/db/site_dev/users/paul?u=root&p=root' \
  -d '{"admin": false}'

```

##### Limiting User Access

Database users have two additional arguments when creating or updating
their objects: `readFrom` and `writeTo`. Here's what a
default database user looks like when those arguments aren't specified
on create.

```json
{
  "name": "paul",
  "readFrom": ".*",
  "writeTo": ".*"
}
```

This example user has the ability to read and write from any time
series. If you want to restrict the user to only being able to write
data, update the user by `POST`ing to `db/site_dev/users/paul`.

```json
{
  "name": "paul",
  "readFrom": "^$",
  "writeTo": ".*"
}
```
