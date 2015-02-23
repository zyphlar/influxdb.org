# Using the Influx Shell

The Influx shell is an interactive shell for InfluxDB, and is part of all InfluxDB distributions. If you install InfluxDB via a package manager, the shell is installed at `/opt/influxdb/influx`.

## Shell Arguments

There are several arguments you can pass into the shell when starting.  You can list them by passing in `--help` to get the following results:

```sh
$ influx --help
Usage of default:
  -database="": database to connect to the server.
  -host="localhost": influxdb host to connect to
  -output="column": format specifies the format of the server responses:  json, csv, or column
  -password="": password to connect to the server.  Leaving blank will prompt for password (--password="")
  -port=8086: influxdb port to connect to
  -username="": username to connect to the server.
```

## Shell Commands

Once you have entered the shell, and successfully connecting to an InfluxDB node, you will see the following output:

```sh
$ influx
InfluxDB shell
Connected to http://localhost:8086 version 0.9
```

### Getting Help

To see a partial list of commands, you can type `help` and see the following:

```sh
> help
Usage:
        connect <host:port>   connect to another node
        auth                  prompt for username and password
        pretty                toggle pretty print
        use <db_name>         set current databases
        format <format>       set the output format: json, csv, or column
        settings              output the current settings for the shell
        exit                  quit the influx shell

        show databases        show database names
        show series           show series information
        show measurements     show measurement information
        show tag keys         show tag key information
        show tag values       show tag value information

        a full list of influxql commands can be found at:
        http://influxdb.com/docs
```

### connect

Connect allows you to connect to a different server without exiting the shell.

```sh
> connect localhost:8087
Connected to http://localhost:8087 version 0.9
```

You do not need specify both parts of the server.  For example,
if your current host is `localhost:8086`, the following command:

```sh
> connect :8087
```

will try to connect to `localhost:8087`.

If you specify only the `host` and not the `port`, port `8086` (the default port)
is always assumed.

### auth

The `auth` command will prompt you for a username and password,
and use those credentials when querying the database.

### settings

Settings will output your the current state of the shell.

```sh
> settings
Host            localhost:8086
Username
Database        foo
Pretty          false
Format          csv
```

### Issuing Queries

For a complete reference to the query language, please read the [online documentation](http://influxdb.com/docs).

#### show databases

```sh
> show databases
name    tags    name
----    ----    ----
                foo
```

### format

Format changes the format in which results are displayed in the shell.  Options
are `column`, `csv`, and `json`.  The default is `column`.

```sh
> format csv
show databases
name,tags,name
,,foo
```

### pretty

Pretty will toggle formatting on the JSON results. This only applies when format
is set to `json`.

```sh
> pretty
Pretty print enabled
> show databases
{
    "results": [
        {
            "series": [
                {
                    "columns": [
                        "name"
                    ],
                    "values": [
                        [
                            "foo"
                        ]
                    ]
                }
            ]
        }
    ]
}
```

### exit

Exit will exit the shell

```sh
exit
```

### Command History

The Influx shell stores that last 1,000 commands in you home directory in a file called `.influx_history`.  To use the history while in the shell, simply use the "up" arrow.
