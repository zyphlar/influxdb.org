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

DOCS_VERSIONS = ['0.6', '0.7']

helpers do
  def heading_link(h, id, text)
    "<#{h} id=\"#{id}\"><a href=\"##{id}\">#{text}</a></#{h}>"
  end

  def doc_version_links()
    DOCS_VERSIONS.map do |v|
      link_to "v#{v}", "/docs/v#{v}/introduction/overview.html"
    end.join("<br />")
  end
end

activate :s3_sync do |s3_sync|
  s3_sync.bucket                     = 'influxdb.com' # The name of the S3 bucket you are targetting. This is globally unique.
  s3_sync.region                     = 'us-east-1'     # The AWS region for your bucket.
  s3_sync.after_build                = true
end

page "/feed.xml", :layout => false

DOCS_VERSIONS.each do |version|
  set :docs_version, "v#{version}"
  with_layout "docs.v#{version}.index" do
    page "/docs/v#{version}/*"
  end
end

page "/docs", :layout => "docs.v#{DOCS_VERSIONS.last}.index"

page "/graphing.html", :layout => false

page "/blog/*", :layout => :article
page "/blog/index.html", :layout => :layout

activate :blog do |blog|
  blog.prefix = "blog"
end

activate :alias
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
