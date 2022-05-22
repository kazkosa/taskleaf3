class ApplicationController < ActionController::Base
  include SessionsHelper
  include WebpackBundleHelper
end
