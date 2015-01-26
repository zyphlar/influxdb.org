# Server Administraton
Full configuration and managament of an InfluxDB system is provided through the query language. This section describes how to manage databases, retention policies, users, and user privileges using the query language.

## Database Management
Databases can be created, dropped, and listed. User privileges are also set on a per-database basis.

To create a database, issue the following command:

`CREATE DATABASE <name>`

The name must only contain alphanumeric characters, dashes, and underscores. No database must already exist with the given name.

To delete an existing database, issue the following command:

`DROP DATABASE <name>`

The database must exist or an error is returned.

To see all existing databases, issue the following command:

`LIST DATABASES`

## Retention Policy Management
Retention policies can be created, modified, listed, and deleted.

To create a retention policy issue the following command:

`CREATE RETENTION POLICY <rp-name> ON <db-name> DURATION <duration> REPLICATION <n> [DEFAULT]`

To delete a retention policy issue the following command:

`DROP RETENTION POLICY <rp-name> ON <db-name>`

To modify a retention policy, issue the following command:

`ALTER RETENTION POLICY <rp-name> ON <db-name> [DURATION <duration>] [REPLICATION <n>] [DEFAULT]`

At least 1 of `DURATION`, `REPLICATION`, or the `DEFAULT` flag must be set.

To see all existing retention policies issue the following command:

`LIST RETENTION POLICIES <db-name>`

## User Management
Users can be created, modified, listed, and deleted.

To create a user, issue the following command:

`CREATE USER <username> WITH PASSWORD '<password>'`

To delete a user, issue the following command:

`DROP USER <username>`

The following command lists all users in the system:

`LIST USERS`


