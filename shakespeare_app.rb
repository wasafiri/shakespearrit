require "bundler/setup"
require "roda"
require_relative "models"
require_relative "helpers/highlight_helper"
require_relative "pagy"

# Require route modules
require_relative "routes/admin"
require_relative "routes/auth"
require_relative "routes/interpretations"
require_relative "routes/plays"
require_relative "routes/search"

class ShakespeareApp < Roda
  # Middleware for sessions
  use Rack::Session::Cookie, secret: ENV.fetch("SESSION_SECRET") { "dev_secret_please_change" }

  # Roda plugins
  plugin :render, layout: "layout", views: "views", escape: true
  plugin :hash_branches
  plugin :assets
  plugin :flash   # For flash messages
  plugin :public  # For serving files in /public if needed
  plugin :csrf, secret: ENV.fetch("CSRF_SECRET") { "another_dev_secret_please_change" }
  plugin :csrf_verify

  # Ensure forms include CSRF tokens
  def csrf_token
    request.csrf_token
  end

  def csrf_tag
    "<input type='hidden' name='csrf_token' value='#{csrf_token}' />"
  end

  # Include Pagy Backend and Frontend
  include Pagy::Backend
  include Pagy::Frontend

  # Basic request authentication helper
  route do |r|
    r.public
    r.assets

    # Make current user accessible
    @current_user = session[:user_id] ? User[session[:user_id]] : nil

    # Load route modules
    AdminRoutes.load(r)
    AuthRoutes.load(r)
    InterpretationsRoutes.load(r)
    PlaysRoutes.load(r)
    SearchRoutes.load(r)

    # Root route
    r.root do
      view("index")  # a simple welcome page
    end
  end

  # Utility methods accessible in routes
  def current_user
    @current_user
  end

  def require_login!
    unless current_user
      flash["error"] = "You must be logged in"
      r.redirect("/auth/login")
    end
  end

  def require_admin!
    unless current_user&.is_admin
      flash["error"] = "Admin access required"
      r.redirect("/")
    end
  end

  # Make highlight helper available in views
  def highlight(text, term)
    HighlightHelper.highlight(text, term)
  end
end
