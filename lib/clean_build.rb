# -----------------------------------------------
#  CleanBuild | Middleman
# -----------------------------------------------
class CleanBuild < Middleman::Extension
  # Build Cleaner
  # ==============================
  def initialize(app, options_hash={}, &block)
    super
    FileUtils.rm_rf app.config[:build_dir]
  end
  # Fix Permissions
  # ==============================
  def after_build(builder)
    builder.thor.run 'chmod -R a+r build'
  end
end
::Middleman::Extensions.register(:clean_build, CleanBuild)
