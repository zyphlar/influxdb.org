# Server Administraton
Full configuration and managament of an InfluxDB system is provided through the query language. This section describes how to manage databases, retention policies, users, and user privileges using the query language.

The primary mechanism for issuing any of the commands listed below is through the HTTP API. For example, the command `CREATE DATABASE mydb` can be executed using `curl` as follows:

```
curl -G 'http://localhost:8086/query' --data-urlencode "q=CREATE DATABASE mydb"
```

## Database Management
Databases can be created, dropped, and listed. User privileges are also set on a per-database basis.

### Creating a database
```sql
CREATE DATABASE <name>
```

The name must only contain alphanumeric characters, dashes, and underscores. No database must already exist with the given name.

_Example_

```sql
CREATE DATABASE mydb
```
The response returned is:

```json
{"results":[{}]}
```

### Deleting a database
```sql
DROP DATABASE <name>
```

_Example_

```sql
DROP DATABASE mydb
```
The response returned is:

```json
{"results":[{}]}
```

The database must exist or an error is returned.

### Show existing databases
```sql
SHOW DATABASES
```

_Example_

```sql
CREATE DATABASE mydb
SHOW DATABASES
```

The response returned is:

```json
{
    "results":[
        {
            "series": [
                {
                    "columns": [
                        "Name"
                    ],
                    "values": [
                        [
                            "mydb"
                        ]
                    ]
                }
            ]
        }
    ]
}
```

## Retention Policy Management
Retention policies can be created, modified, listed, and deleted. 

### Auto-creation of retention policies
When a database is created, a retention policy named "default", with infinite retention, is automatically created for that database. This may not be desirable for certain deployments, and auto-creation can be disabled via the configuration file.

### Create a retention policy
```sql
CREATE RETENTION POLICY <rp-name>
    ON <db-name>
    DURATION <duration>
    REPLICATION <n>
    [DEFAULT]
```

_Example_

```sql
CREATE RETENTION POLICY mypolicy
    ON mydb
    DURATION 1d
    REPLICATION 1
    DEFAULT
```
The response returned is:

```json
{"results":[{}]}
```
Durations such as `1s`, `30m`, `12h`, `7d`, and `4w`, are all supported and mean 1 second, 30 minutes, 12 hours, 7 day, and 4 weeks, respectively. For infinite retention -- meaning the data will never be deleted -- use `INF` for duration.

### Show existing retention polices
To delete a retention policy issue the following command:

```sql
SHOW RETENTION POLICIES <db-name>
```

_Example_

```sql
SHOW RETENTION POLICIES mydb
```

The response returned is:

```json
{
    "results": [
        {
            "series": [
                {
                    "columns": [
                        "name",
                        "duration",
                        "replicaN"
                    ],
                    "values": [
                        "mypolicy",
                        "24h0m0s",
                        1
                    ]
                }
            ]
        }
    ]
}
```

### Modifying a retention policy
To modify a retention policy, issue the following command:

```sql
ALTER RETENTION POLICY <rp-name>
    ON <db-name>
    [DURATION <duration>]
    [REPLICATION <n>] [DEFAULT]
```

At least 1 of `DURATION`, `REPLICATION`, or the `DEFAULT` flag must be set.

_Example_

```sql
ALTER RETENTION POLICY mypolicy
    ON mydb
    DURATION 2d
```

The response returned is:

```json
{"results":[{}]}
```

## User Management
Users can be created, modified, listed, and deleted.


### Creating a user
```sql
CREATE USER <username> WITH PASSWORD '<password>'
```
Note that it is required that _password_ be quoted.

_Example_

```sql
CREATE USER jdoe WITH PASSWORD 'mypassword'
```

### Showing existing users
```sql
SHOW USERS
```

_Example_

```sql
CREATE USER jdoe WITH PASSWORD 'mypassword'
SHOW USERS
```

The response returned is:

```json
{
    "results": [
        {
            "series": [
                {
                    "columns": [
                        "user"
                    ],
                    "values": [
                        "jdoe"
                    ]
                }
            ]
        }
    ]
}
```

### Deleting a user

```sql
DROP USER <username>
```

_Example_

```sql
DROP USER jdoe
```

The response returned is:

```json
{"results":[{}]}
```

## Privilege Control
In InfluxDB, privileges are controlled on per-database user. Any given user can have `READ`, `WRITE`, or `ALL` access to an individual database. Until a user is granted privileges on a given database, that user has no access to it whatsoever.

### Granting privileges

```sql
GRANT READ|WRITE|ALL
    ON <database>
    TO <user>
```

_Example_

```sql
GRANT READ
    ON mydb
    TO jdoe
```

The response returned is:

```json
{"results":[{}]}
```

### Revoking privileges

```sql
REVOKE READ|WRITE|ALL
    ON <database>
    TO <user>
```

_Example_

```sql
REVOKE ALL
    ON mydb
    TO jdoe
```

The response returned is:

```json
{"results":[{}]}
```

### Setting the Cluster Adminstrator
To grant cluster administration privileges to a user, issue the following command:

```sql
GRANT ALL PRIVILEGES TO <user>
```

_Example_

```sql
GRANT ALL PRIVILEGES TO jdoe
```

The response returned is:

```json
{"results":[{}]}
```

To revoke cluster administration privileges, issue this command:

```sql
REVOKE ALL PRIVILEGES TO <user>
```

_Example_

```sql
REVOKE ALL PRIVILEGES TO jdoe
```

The response returned is:

```json
{"results":[{}]}
```

Only the cluster adminstrator can create and drop databases, and manage users.
