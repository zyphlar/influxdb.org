# Authentication and Authorization

InfluxDB provides simple, built-in authentication and authorization capabilities.

## Authentication

### Enabling authentication

Authentication is enforced by checking each HTTP request to API against the user credentials of all users in the cluster.

Authentication is __disabled__ by default.  A new cluster will accept all requests to the API.

To enable authentication, set the `[authentication]` section in the configuration file (shown below) to `true` and restart `influxd`.  

```
[authentication]
enabled = false  # set as 'true' to enable authentication
```

### Bootstrapping a new secure cluster

To bootstrap a secure cluster, a [cluster administrator](authentication_and_authorization.html#cluster-administration-privileges) must be created while authentication is disabled.  Once an initial user has been created, restart the cluster with authentication enabled.

_Note: the first user with admin privileges can only be created when authentication is disabled._

### Authenticating requests

When authentication is enabled, user credentials must be supplied with every request via _Basic Authentication_ as described in [RFC 2617, Section 2](http://tools.ietf.org/html/rfc2617).

Authentication is checked per user.  All users created in an InfluxDB cluster are allowed to send authenticated requests, although a request may still fail if the user does not have the authorization required to execute the request.

_Example_

A request can be sent with _Basic Authentication_ credentials using `curl` with the `-u` option.

```
curl -G http://localhost:8086/query -u mydb_username:mydb_password --data-urlencode "q=CREATE DATABASE mydb"
```

## Authorization

Authorization is set by granting users privileges to access a database or administer the cluster.

Authorization is only enforced when authentication is enabled.  When authentication is disabled, all users have all the privileges of a cluster administrator.

### Cluster administration

Users with cluster administration privileges are known as cluster administrators.  Cluster administrators have read and write access for all databases in a cluster.

Cluster administrators are authorized to execute all of the following administration queries.

- Create and delete users, including admin users
- Set user passwords
- Create and delete databases
- Grant, alter, and revoke database access privileges
- Create and delete retention policies
- Delete measurements and series
- Create and delete continuous queries

The [Cluster Administration](../query_language/database_administration.html) documentation describes the full syntax for administration queries.

### Types of privileges

Users may be assigned one of the following three privileges per database:

- `READ`
- `WRITE`
- `ALL`, grants `READ` and `WRITE`

Cluster administers have `ALL` privileges for all databases even if they have privileges set for a particular database.

## Error messages

When authentication is enabled, all requests which do not provide a valid username and password will receive a `HTTP 401 Unauthorized` response.

Queries by authenticated users lacking read or write privileges on the queried database will receive a `HTTP 401 Unauthorized` response.

When authentication is disabled, all basic authentication query parameters are silently ignored and all users have all privileges (no authorization is enforced).

## Security in production environments

Authentication and authorization should not be relied upon to prevent access and protect data from malicious actors.  If additional security or compliance features are desired, a cluster should be run behind a third-party service.

## Protected endpoints

Also note that the following API endpoints are currently not protected by authentication. [Relevant github issue](https://github.com/influxdb/influxdb/issues/1364)

- `GET /data/metastore`
- `POST /data/process_continuous_queries`

Other github issues relevant to authentication.

- [Proposition for ignoring auth when there are no users](https://github.com/influxdb/influxdb/issues/2193)
- [Secret key to manage influxdb locally](https://github.com/influxdb/influxdb/issues/2278)
