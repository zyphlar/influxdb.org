require "rubygems"
require "net/http"
require "net/https"
require "uri"
require "json"
require "time"
require "influxdb"

QUERY = "bitcoin"

http = Net::HTTP.new("api.thriftdb.com", 443)
http.use_ssl = true

influxdb = InfluxDB::Client.new "tp-tweets1", {
  :host => "sandbox.influxdb.org",
  :port => 9061,
  :username => "todd",
  :password => "password"
}

(0..9).each do |count|
  params = {
    "q" => QUERY,
    "start" => 100*count,
    "limit" => 100,
    "sortby" => "create_ts desc",
    "weights[title]" => "1.0",
  }

  request = Net::HTTP::Get.new "/api.hnsearch.com/items/_search?"+URI.encode_www_form(params)
  response = http.request(request)
  data = JSON.parse(response.body)

  data["results"].each do |result|
    influxdb.write_point("posts", {
      :message => result["item"]["title"],
      :time => Time.parse(result["item"]["create_ts"]).to_i * 1000
    })
  end
end
