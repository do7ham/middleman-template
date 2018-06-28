require 'htmlcompressor'
require 'yui/compressor'
require 'uglifier'
# --------------------------------------
#  Activate and configure Extensions
# --------------------------------------

# Aria Current
activate :aria_current

# Inline SVG
activate :inline_svg do |config|
  config.defaults = {
    role: 'img'
  }
end

# i18n
activate :i18n, mount_at_root: :de

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
#  Layout-specific Configuration
# --------------------------------------

# No Layout
page '/*.txt',    layout: false
page '/*.xml',    layout: false
page '/*.json',   layout: false
page '/404.html', layout: false, directory_index: false

# Sass
set :sass, line_comments: false, debug_info: false, style: :compressed

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
  # Asset Hash
  activate :asset_hash, ignore: [%r{(.*\.jpeg|.*\.jpg|.*\.png|.*\.svg)$}i]
  # Minify CSS on Build
  activate :minify_css, inline: true, compressor: YUI::CssCompressor.new
  # Minify HTML on Build
  activate :minify_html do |html|
    html.remove_http_protocol    = false
    html.remove_input_attributes = false
    html.remove_quotes           = true
    html.remove_intertag_spaces  = true
  end
  # Minify JS on Build
  activate :minify_javascript, inline: true, compressor: proc { ::Uglifier.new(mangle: false, harmony: true) }
  # Relative URLs
  activate :relative_assets
  config[:relative_links] = true
end
