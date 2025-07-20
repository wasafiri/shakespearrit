class ShakespeareApp
  route("auth") do |r|
    THROTTLE_LIMIT = 5
    THROTTLE_PERIOD = 900 # 15 minutes in seconds

    r.on "login" do
      # GET /auth/login
      r.get do
        view("auth/login")
      end

      # POST /auth/login
      r.post do
        email = r.typecast_params.nonempty_str!("email").strip.downcase
        password = r.typecast_params.nonempty_str!("password")
        
        # Rate limiting check
        attempts = session["login_attempts"] || {}
        attempts = attempts.select { |_, time| time > Time.now.to_i - THROTTLE_PERIOD }
        
        if attempts.size >= THROTTLE_LIMIT
          flash["error"] = "Too many login attempts. Please try again in 15 minutes."
          r.redirect("/auth/login")
        end

        user = User.first(email: email)
        if user && BCrypt::Password.new(user.password_hash) == password
          session[:user_id] = user.id
          session["login_attempts"] = {}
          flash["notice"] = "Successfully logged in"
          r.redirect("/")
        else
          attempts[Time.now.to_i] = Time.now.to_i
          session["login_attempts"] = attempts
          flash["error"] = "Invalid email or password"
          r.redirect("/auth/login")
        end
      end
    end

    r.on "logout" do
      r.post do
        session.clear
        flash["notice"] = "Successfully logged out"
        r.redirect("/")
      end
    end

    r.on "register" do
      r.get do
        view("auth/register")
      end

      r.post do
        email = r.typecast_params.nonempty_str!("email").strip.downcase
        password = r.typecast_params.nonempty_str!("password")
        
        begin
          user = User.create(
            email: email,
            password_hash: BCrypt::Password.create(password)
          )
          session[:user_id] = user.id
          flash["notice"] = "Account created successfully"
          r.redirect("/")
        rescue Sequel::ValidationError => e
          flash["error"] = e.message
          view("auth/register")
        end
      end
    end
  end
end
