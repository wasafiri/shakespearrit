require "bundler/setup"
require "roda"
require "rack/session/cookie"
require_relative "models"
require_relative "helpers/highlight_helper"
require_relative "pagy"

class ShakespeareApp < Roda
  # Middleware for sessions
  use Rack::Session::Cookie, secret: ENV.fetch("SESSION_SECRET") { "a_very_long_and_secure_dev_secret_for_testing_purposes_at_least_64_characters_long" }

  # Roda plugins - order matters
  plugin :render, layout: "layout", views: "views", escape: true
  plugin :multi_route
  plugin :assets,
         css: ["breadcrumbs.css"],
         js: ["app.js"],
         public: "assets",
         precompiled: File.expand_path("compiled_assets.json", __dir__),
         gzip: true
  plugin :flash
  plugin :route_csrf
  plugin :typecast_params
  plugin :default_headers, {
    'Content-Type'=>'text/html',
    'Strict-Transport-Security'=>'max-age=16070400;',
    'X-Frame-Options'=>'deny',
    'X-Content-Type-Options'=>'nosniff',
    'X-XSS-Protection'=>'1; mode=block'
  }
  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self, :unsafe_inline
    csp.script_src :self, :unsafe_inline
    csp.connect_src :self
    csp.img_src :self, "https://i.ytimg.com"
    csp.font_src :self
    csp.form_action :self
    csp.base_uri :none
    csp.frame_ancestors :none
    csp.block_all_mixed_content
    csp.frame_src :self, "https://www.youtube.com"
    csp.media_src :self, "https://www.w3schools.com"
  end
  plugin :error_handler
  plugin :not_found
  plugin :json
  plugin :json_parser
  plugin :halt

  # Include Pagy Backend and Frontend
  include Pagy::Backend
  include Pagy::Frontend

  # Load route files using multi_route
  Dir["routes/**/*.rb"].each { |file| require_relative file }

  # Error handlers
  error do |e|
    case e
    when Sequel::ValidationError
      flash["error"] = e.message
      request.redirect(request.referer || "/")
    else
      flash["error"] = "An unexpected error occurred"
      request.redirect("/")
    end
  end

  not_found do
    view("errors/404")
  end

  # Utility methods
  def current_user
    @current_user
  end

  def require_login!
    unless current_user
      flash["error"] = "You must be logged in"
      request.redirect("/auth/login")
    end
  end

  def require_admin!
    unless current_user&.is_admin
      flash["error"] = "Admin access required"
      request.redirect("/")
    end
  end

  def rescue_api_errors
    yield
  rescue Sequel::Error => e
    logger.error "API Error: #{e.message}"
    response.status = 500
    { error: "A database error occurred." }.to_json
  rescue => e
    logger.error "API Error: #{e.class} - #{e.message}"
    response.status = 500
    { error: "An unexpected error occurred." }.to_json
  end

  route do |r|
    r.assets

    # Make current user accessible
    @current_user = session[:user_id] ? User[session[:user_id]] : nil

    check_csrf!

    # Use multi_route for organized routing
    r.multi_route

    # Root route
    r.root do
      view("app/main")
    end
  end
end
