## Python

The [InfluxDB Python library lives on GitHub](https://github.com/influxdb/influxdb-python) thanks to [smly](https://github.com/smly).

## Get and Install

### Manual Installation

    git clone https://github.com/influxdb/influxdb-python.git
    cd influxdb-python
    pip install -r requirements.txt 
    python setup.py install

### Initialization

First, create a new InfluxDB object by connecting to a running instance.

    from influxdb import client as influxdb
    db = influxdb.InfluxDBClient(host, port, username, password, database)

### Available Functions

#### create_database(_database_)

Create database. Requires cluster-admin privileges.

#### delete_database(_database_)

Delete database. Requires cluster-admin privileges.

#### switch_db(_databaseName_)

Switch to another database.

#### switch_user(_username_, _password_)

Change your user-context.

#### write_points(_data_)

Write to multiple time series names.

#### write_points_with_precision(_data_, _time-precision_='s')

Write to multiple time series names with defined precision.

#### query(_query_, _time-precision_='s', _chunked_=False)

Query for data
