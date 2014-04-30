require 'slim'

set :site_title, "InfluxDB - Open Source Time Series, Metrics, and Analytics Database"
set :site_url, "http://influxdb.org"

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#

helpers do
  def heading_link(h, id, text)
    "<#{h} id=\"#{id}\"><a href=\"##{id}\">#{text}</a></#{h}>"
  end
end

page "/feed.xml", :layout => false

set :docs_version, "v0.5"
with_layout "docs.v0.5.index" do
  page "/docs/v0.5/*"
end

page "/graphing.html", :layout => false

page "/blog/*", :layout => :article
page "/blog/index.html", :layout => :layout

activate :blog do |blog|
  blog.prefix = "blog"
end

activate :livereload
activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true, :with_toc_data => true

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
