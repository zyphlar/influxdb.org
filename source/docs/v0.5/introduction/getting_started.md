# Getting Started

Now that you've [InfluxDB installed](installation.html) you're ready to start doing awesome things. There are many client libraries available for InfluxDB, but in this section we're going to use the built in user interface to get started quickly.

## Logging in and creating your first database
If you've installed locally, point your browser to <a href="http://localhost:8083" target="_blank">localhost:8083</a>. The built in user interface runs on port `8083` by default. You should see a screen like this:

![Admin login](/images/docs/admin_login.png)

The default options for hostname of `localhost` and port of `8086` should work. The InfluxDB HTTP API runs on port `8086` by default. Enter the username `root` and password `root` and click Connect. You'll then see a logged in screen like this:

![Logged in with no databases](/images/docs/logged_in_no_databases.png)

Enter in a database name and click Create. Database names should contain only letters, numbers, or underscores. Once you're created a database you should see it on the screen:

![Database list screen](/images/docs/database_created.png)

## Writing and exploring data in the UI
Go ahead and click the "Explore" link to get here:

![Explore data interface](/images/docs/explore_screen.png)

From this screen you can write some test data. More importantly, you'll be able to issue ad-hoc queries and see basic visualizations. Let's write a little data in to see how things work. Data in InfluxDB is organized by "time series" which then have "points" which have a `time`, `sequence_number`, and `columns`. Think of it kind of like SQL tables, and rows where the primary index is always time. The difference is that with InfluxDB you can have hundreds of thousands of series, you don't have to define schemas up front, and null values aren't stored.

Let's write some data. Here are a couple of examples of things we'd want to write. We'll show the screenshot and what the JSON data looks like right after.

![Storing log lines](/images/docs/log_lines.png)

```json
[
  {
    "name" : "log_lines",
    "columns" : ["line"],
    "points" : [
      ["here's some useful log info from paul@influx.com"]
    ]
  }
]
```

![Storing response times](/images/docs/response_times.png)

```json
[
  {
    "name" : "response_times",
    "columns" : ["code", "value", "controller_action"],
    "points" : [
      [200, 234, "users#show"]
    ]
  }
]
```

![Storing user analytics data](/images/docs/user_events.png)

```json
[
  {
    "name" : "user_events",
    "columns" : ["type", "url_base", "user_id"],
    "points" : [
      ["add_friend", "friends#show", 23]
    ]
  }
]
```

![Storing sensor data](/images/docs/device_temperatures.png)

```json
[
  {
    "name" : "device_temperatures",
    "columns" : ["value"],
    "points" : [
      [88.2]
    ]
  }
]
```

Now that we've written a few points. Let's take a look at them. Issue this query

```sql
select * from log_lines
```

![Selecting all log lines](/images/docs/select_log_lines.png)

We can see there that the point we wrote in earlier is there. We also notice two columns that we didn't explicitly write in: `time` and `sequence_number`. Those are automatically assigned by InfluxDB when you write data in if they're not specified. In the UI time is represented as an epoch in seconds, but the underlying storage keeps them as microsecond epochs. 