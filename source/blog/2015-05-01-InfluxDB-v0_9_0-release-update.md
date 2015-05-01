---
title: InfluxDB v0.9.0 release update
author: Paul Dix
published_on: May 1, 2015
---

This is an update to [the v0.9.0 release plan](/blog/2015/04/01/InfluxDB-v0_9_0-release-plan.html) I posted a month ago. The short answer is: it's not released or ready yet, but we're making solid progress. There are only three items from that list that we still have to finish:

* [Data nodes can get shards that have been truncated](https://github.com/influxdb/influxdb/issues/1948)
* [Replacing a downed node](https://github.com/influxdb/influxdb/issues/1472)
* [Write back-pressure if data nodes are falling behind on replication](https://github.com/influxdb/influxdb/issues/1946)

We've decided to add a few features to that list:

* [non\_negative\_derivative aggregate](https://github.com/influxdb/influxdb/issues/1477)
* [count(distinct(...)) aggregate](https://github.com/influxdb/influxdb/issues/1891)
* [top aggregate](https://github.com/influxdb/influxdb/issues/1821)
* [Select Tag Names](https://github.com/influxdb/influxdb/issues/1989)

The first three are important for the new API to hit important use cases for InfluxDB users. The last one is a usability enhancement based on many people finding it counter-intuitive that they can't select tag names. Currently, you can get tag names by putting them in the `GROUP BY` clause.

We also have bug fixes that need to go in for continuous queries and more work to do on clustering. Clustering has improved dramatically over the last few weeks alone. [Last month we merged 153 PRs](https://github.com/influxdb/influxdb/pulls?utf8=%E2%9C%93&q=is%3Apr+merged%3A%222015-03-31+..+2015-05-01%22+). You can see from the [CHANGELOG](https://github.com/influxdb/influxdb/blob/master/CHANGELOG.md) that there have been many bug fixes and features.

For the underlying data store, we don't anticipate making any more breaking changes in the 0.9.0 release cycle. That means that you should be able to upgrade from one RC to another from this point and still keep your data around. However, beware that if we need to make a breaking change, we will. We just don't have anything on the open list that would cause that so we don't anticipate it happening.

I'm hesitant to offer delivery estimates since this release is obviously lagging far behind what we had originally hoped for. I've updated the front page to say "coming soon". However, we're aiming to have those features done no later than May 31st. We'll also be fixing bugs as they appear from people testing out the 0.9.0 RCs. The official release won't happen until we've done extensive testing AFTER feature complete. We're doing testing now, but there's more we need to do and we need to hit feature freeze. That means the full release won't be until sometime after that since we'll have to do a month of soak testing against whatever RC becomes the final release.

The current batch of RCs aren't truly release candidates. The first one that will be a true release candidate will be after those features are done and any show stopper bugs have been fixed. I'll be announcing that build on this blog as soon as it's available. However, if you're developing a new project, the current 0.9.0 RCs are what you're best developing against. We'll continue to release those regularly as we fix bugs and add these last features.

For everyone that has been eagerly awaiting this release, I apologize for yet another delay. I'm sure it's painful for you and it's definitely painful for us. However, we aren't going to cut this release until we have these key features and have done extensive testing to have confidence that it is reliable, robust, recoverable, and truly production worthy.

For those wanting to pitch in, testing on new RCs (particularly clusters under load) is very helpful. Also, we're actively taking PRs from the community and [we're hiring](https://jobs.lever.co/influxdb). We've had a number of contributors roll up their sleeves over the last few months and that seems to be picking up. Thank you to everyone in the community for contributing and for those of you giving us encouragement.

From this point on I'll post an update on our progress every two weeks until 0.9.0 is released. I'll highlight community contributions and talk about the high level things from the CHANGELOG.

More soon.