require 'htmlcompressor'
require 'yui/compressor'
require 'uglifier'
# --------------------------------------
#  Activate and configure Extensions
# --------------------------------------

# i18n
activate :i18n, mount_at_root: :de

# Aria Current
activate :aria_current

# Sprockets
require 'sassc'
activate :sprockets do |c|
  c.expose_middleman_helpers = true
end

# RailsAssets
if defined? RailsAssets
  RailsAssets.load_paths.each do |path|
    sprockets.append_path path
  end
end

# --------------------------------------
#  Piwik-specific Configuration
# --------------------------------------

activate :piwikmiddleman do |p|
  p.domain = 'fahrschuleguth.de'
  p.url    = 'piwik'
  p.id     = 1
end

# --------------------------------------
#  Helpers-specific Configuration
# --------------------------------------

helpers do
  # Component
  def component(component_name, locals = {}, &block)
    capture_block = Proc.new { capture(&block) } if block
    partial("components/#{component_name}", locals: locals, &capture_block)
  end
  alias c component
  alias com component
end

# --------------------------------------
#  Layout-specific Configuration
# --------------------------------------

# Default Layout
config[:layout] = 'layouts/application'

# No Layout
page '/*.xml',     layout: false
page '/*.txt',     layout: false
page '/*.json',    layout: false
page '/.htaccess', layout: false
page '/404.html',  layout: false, directory_index: false

# Sass
set :sass, line_comments: false, debug_info: false, style: :compressed

# --------------------------------------
#  Server-specific Configuration
# --------------------------------------

configure :server do
  # Relative URLs
  activate :relative_assets
  config[:relative_links] = true
  # Debug Assets
  config[:debug_assets] = true
end

# --------------------------------------
#  Development-specific Configuration
# --------------------------------------

configure :development do
  # Assets Pipeline Sets
  config[:css_dir]    = 'assets/stylesheets'
  config[:js_dir]     = 'assets/javascripts'
  config[:images_dir] = 'assets/images'
  config[:fonts_dir]  = 'assets/fonts'
  # Image Tag Helper
  activate :automatic_image_sizes
  activate :automatic_alt_tags
  # Pretty URLs
  activate :directory_indexes
  # Autoprefixer
  activate :autoprefixer do |prefix|
    prefix.browsers = 'last 2 versions'
    prefix.cascade  = false
    prefix.inline   = true
  end
  # Host
  config[:protocol] = 'http'
  config[:host]     = 'localhost'
  config[:port]     = '4567'
  # Livereload
  activate :livereload do |reload|
    reload.no_swf = true
  end
end

# --------------------------------------
#  Production-specific Configuration
# --------------------------------------

configure :production do
  # Assets Pipeline Sets
  config[:css_dir]    = 'assets/stylesheets'
  config[:js_dir]     = 'assets/javascripts'
  config[:images_dir] = 'assets/images'
  config[:fonts_dir]  = 'assets/fonts'
  # Image Tag Helper
  activate :automatic_image_sizes
  activate :automatic_alt_tags
  # Pretty URLs
  activate :directory_indexes
  # Autoprefixer
  activate :autoprefixer do |prefix|
    prefix.browsers = 'last 2 versions'
    prefix.cascade  = false
    prefix.inline   = true
  end
  # Clean Build
  require_relative './lib/clean_build'
  activate :clean_build
end

# --------------------------------------
#  Build-specific Configuration
# --------------------------------------

configure :build do
  # Host
  config[:host] = "#{@app.data.site.url}"
  # Asset Hash
  activate :asset_hash, exts: %w(.css .js .svg .eot .ttf .woff .woff2), ignore: [/images/, /fonts/]
  # Minify CSS on Build
  activate :minify_css, inline: true, ignore: ['/assets/fonts/*', '/assets/stylesheets/fonts/*.css'],
    compressor: proc {
      ::YUI::CssCompressor.new()
    }
  # Minify JS on Build
  activate :minify_javascript, inline: true,
    compressor: proc {
      ::Uglifier.new(mangle: {toplevel: false}, compress: {unsafe: true}, output: {comments: :none}, harmony: true)
    }
  # Minify HTML on Build
  activate :minify_html do |html|
    html.remove_multi_spaces        = true
    html.remove_comments            = true
    html.remove_intertag_spaces     = true
    html.remove_quotes              = true
    html.simple_doctype             = false
    html.remove_script_attributes   = true
    html.remove_style_attributes    = true
    html.remove_link_attributes     = true
    html.remove_form_attributes     = true
    html.remove_input_attributes    = true
    html.remove_javascript_protocol = true
    html.remove_http_protocol       = false
    html.remove_https_protocol      = true
    html.preserve_line_breaks       = false
    html.simple_boolean_attributes  = true
    html.preserve_patterns          = nil
  end
  # Sitemap
  activate :seo_sitemap, default_host: "#{@app.data.site.url}"
  # Robots
  activate :robots,
    rules: [{user_agent: '*', allow: %w(/)}],
    sitemap: config[:host] + '/sitemap.xml'
  # Relative URLs
  activate :relative_assets
  config[:relative_links] = true
end
