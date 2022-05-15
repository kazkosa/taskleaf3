require 'rack/proxy'

# Proxy getting assets from webpack-dev-server
class DevServerProxy < Rack::Proxy

  def perform_request(env)
    if env['PATH_INFO'].start_with?('/packs/')
      dev_server_host = env['HTTP_HOST'].gsub(':3000', ':3035')
      env['HTTP_HOST'] = dev_server_host
      env['HTTP_X_FORWARDED_HOST'] = dev_server_host
      env['HTTP_X_FORWARDED_SERVER'] = dev_server_host
      super
    else
      @app.call(env)
    end
  end

end