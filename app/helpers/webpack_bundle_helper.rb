module WebpackBundleHelper
  class BundleNotFound < StandardError; end

  def asset_bundle_path(entry, **options)
    raise BundleNotFound, "Could not find bundle with name #{entry}" unless manifest.key? entry
    asset_path(manifest.fetch(entry), **options)
  end

  # For image_bundle_tag, write entry properly with the extension
  def image_bundle_tag(entry, **options)
    raise ArgumentError, "Extname is missing with #{entry}" unless File.extname(entry).present?
    image_tag asset_bundle_path(entry), **options
  end

  def javascript_packs_with_chunks_tag(entry, **options)
    javascript_include_tag(asset_bundle_path(entry), **options)
  end

  def stylesheet_packs_with_chunks_tag(entry, **options)
    stylesheet_link_tag(asset_bundle_path(entry), **options)
  rescue BundleNotFound
    # May not extract css. In that case, an error occurs but nothing is returned.
  end

  private

  MANIFEST_PATH = 'public/packs/manifest.json'.freeze

  def manifest
    @manifest ||= JSON.parse(File.read(MANIFEST_PATH))
  end
end