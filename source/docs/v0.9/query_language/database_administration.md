---
_PLEASE NOTE 0.9.0 IS PRE-RELEASE SOFTWARE. THESE DOCUMENTS ARE TESTING REFERENCES_.

# Server Administraton
Full configuration and managament of an InfluxDB system is provided through the query language. This section describes how to manage databases, retention policies, users, and user privileges using the query language.

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
[{}]
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
[{}]
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
[
    {
        "rows": [
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
```

## Retention Policy Management
Retention policies can be created, modified, listed, and deleted.

To create a retention policy issue the following command:

```sql
CREATE RETENTION POLICY <rp-name> ON <db-name> DURATION <duration> REPLICATION <n> [DEFAULT]
```

To delete a retention policy issue the following command:

```sql
DROP RETENTION POLICY <rp-name> ON <db-name>
```

To modify a retention policy, issue the following command:

```sql
ALTER RETENTION POLICY <rp-name> ON <db-name> [DURATION <duration>] [REPLICATION <n>] [DEFAULT]
```

At least 1 of `DURATION`, `REPLICATION`, or the `DEFAULT` flag must be set.

To see all existing retention policies issue the following command:

```sql
LIST RETENTION POLICIES <db-name>
```

## User Management
Users can be created, modified, listed, and deleted.

To create a user, issue the following command:

```sql
CREATE USER <username> WITH PASSWORD '<password>'
```
Note that is is required that _password_ be quoted.

To delete a user, issue the following command:

```sql
DROP USER <username>
```

The following command lists all users in the system:

```sql
LIST USERS
```

## Privilege Control
In InfluxDB, privileges are controlled on per-database user. Any given user can have `READ`, `WRITE`, or `ALL` access to an individual database. Without explicitly some access to a given database, a user has no access to it whatsoever.

The grant access to a user for a given databasse, issue the following command:

```sql
GRANT READ|WRITE|ALL PRIVILEGES ON <database> TO <user>
```

### Setting the Cluster Adminstrator
To grant cluster administration privileges to a user, issue the following command:

```sql
GRANT ALL PRIVILEGES TO <user>
```

Only the cluster adminstrator can create and drop databases, and manage users.
