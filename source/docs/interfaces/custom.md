# Custom Interfaces

The InfluxDB administration interface allows you to create modular interfaces that can be dropped in and used along with the pre-existing offering. This section will detail the methods available to you when creating your own interface.

### File Structure

By default, InfluxDB will look inside the folder `admin/interfaces` and return a list of directories with which the admin interface will populate its interfaces dropdown. These directory names should be comprised of lowercase letters and underscores, and will be humanized automatically. Thus, `awesome_graph_dashboard` will be seen as `Awesome Graph Dashboard` by the user. The application should be static HTML and JavaScript, with the first page being named `index.html`. Since the content is loaded via an iframe, the application will be responsible for loading its own assets. 

### Connecting To InfluxDB

Your custom interface will be loaded in an iframe, so the InfluxDB object used by the admin interface is available to you for use. This will be accessible as `parent.influxdb` and will have the same interface as the [JavaScript library](https://github.com/influxdb/influxdb-js). If you are unsure which version of the JavaScript library is being loaded by your admin interface, you can access `parent.influxdb.VERSION`.

It is safe to assume that your InfluxDB object will already be authenticated when your custom interface loads, but if you need to create any other connections, you should create your own connection object. Changing the connection settings on the parent windows's object will probably result in unwanted behavior.

### URL Manipulation

The admin interface is powered by AngularJS, which makes routing via hash fragments easy. If you have a need to either manipulate or query the hash parameters, you can do so by calling `parent.getHashParams()` or `parent.setHashParams({...})`. This will allow you to provide a level of statefulness to your application.

### Contributing

Did you develop a custom interface that you think others would like to use? If so, just fork [our admin repository](https://github.com/influxdb/influxdb-admin), make your changes, and send us a pull request. Also, bear in mind that our admin interface uses [middleman](http://middlemanapp.com/), so feel free to use the asset pipeline to your advantage.
