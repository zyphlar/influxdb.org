# Discovering the Data within InfluxDB

There are various ways to learn about the data contained within an InfluxDB system.

## Show Measurements
`SHOW MEASUREMENTS` shows all Measurements in the system.

_Example_

```sql
SHOW MEASUREMENTS
```

In the example response shown below, the system contains two meauresments -- `cpu` and `network`. The first has a tag key `host`, and the second has two tags keys, `host` and `region`.

```json
{
    "results": [
        {
            "rows": [
                {
                    "name": "cpu",
                    "columns": [
                        "host"
                    ]
                },
                {
                    "name": "network",
                    "columns": [
                        "host",
                        "region"
                    ]
                }
            ]
        }
    ]
}
```

## Show Series
`SHOW SERIES` is somewhat similar to `SHOW MEASUREMENTS`, but also shows the distinct key-value pairs each tag key has within the system.

_Example_

```sql
SHOW SERIES
```

In the example response shown below, the system also contains two measurements, but note how the unique tag-key pairs are now shown.

```json
{
    "results": [
        {
            "rows": [
                {
                    "name": "cpu",
                    "columns": [
                        "host"
                    ],
                    "values": [
                        [
                            "server01"
                        ]
                    ]
                },
                {
                    "name": "network",
                    "columns": [
                        "host",
                        "region"
                    ],
                    "values": [
                        [
                            "server01",
                            "us-west"
                        ],
                        [
                            "server01",
                            "us-east"
                        ]
                    ]
                }
            ]
        }
    ]
}
```


```sql
SHOW TAG KEYS
```

```
SHOW TAG VALUES
```

