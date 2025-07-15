module AuthRoutes
  def self.load(r)
    r.on "auth" do
      # Rate limiting setup
      THROTTLE_LIMIT = 5
      THROTTLE_PERIOD = 900 # 15 minutes in seconds
      
      r.on "login" do
        # GET /auth/login
        r.get do
          view("auth/login")
        end

        # POST /auth/login
        r.post do
          email = r.params["email"]&.strip&.downcase
          
          # Rate limiting check
          attempts = r.session["login_attempts"] || {}
          attempts = attempts.select { |_, time| time > Time.now.to_i - THROTTLE_PERIOD }
          
          if attempts.size >= THROTTLE_LIMIT
            flash["error"] = "Too many login attempts. Please try again in 15 minutes."
            r.redirect("/auth/login")
            return
          end

          user = User[email: email]
          if user && user.valid_password?(r.params["password"])
            # Successful login
            session.clear # Clear any old session data
            session[:user_id] = user.id
            session[:created_at] = Time.now.to_i
            
            # Update last login timestamp
            user.update(last_login_at: Sequel::CURRENT_TIMESTAMP)
            
            flash["notice"] = "Welcome back, #{user.display_name || user.email}!"
            r.redirect(session[:return_to] || "/")
            session[:return_to] = nil
          else
            # Failed login attempt
            attempts[Time.now.to_i] = Time.now.to_i
            session["login_attempts"] = attempts
            
            flash["error"] = "Invalid email or password"
            r.redirect("/auth/login")
          end
        end
      end

      r.on "logout" do
        # POST /auth/logout (changed from GET for security)
        r.post do
          session.clear
          flash["notice"] = "Logged out successfully."
          r.redirect("/")
        end
      end

      r.on "register" do
        # GET /auth/register
        r.get do
          view("auth/register")
        end

        # POST /auth/register
        r.post do
          email = r.params["email"]&.strip&.downcase
          pass = r.params["password"]
          pass_confirm = r.params["password_confirmation"]
          disp = r.params["display_name"]&.strip

          errors = []
          errors << "Email is required" if email.blank?
          errors << "Display name is required" if disp.blank?
          errors << "Password is required" if pass.blank?
          errors << "Passwords don't match" if pass != pass_confirm
          errors << "Password must be at least 8 characters" if pass && pass.length < 8
          
          if errors.any?
            flash["error"] = errors.join(", ")
            r.redirect("/auth/register")
            return
          end

          user = User.new(
            email: email,
            display_name: disp,
            email_verified: false
          )
          user.password = pass

          if user.save
            # Send verification email (implemented elsewhere)
            UserMailer.verification_email(user)
            
            session[:user_id] = user.id
            session[:created_at] = Time.now.to_i
            flash["notice"] = "Welcome! Please check your email to verify your account."
            r.redirect("/")
          else
            flash["error"] = user.errors.full_messages.join(", ")
            r.redirect("/auth/register")
          end
        end
      end

      r.on "profile" do
        r.is do
          # Must be logged in to access profile
          unless current_user
            session[:return_to] = "/auth/profile"
            flash["notice"] = "Please log in to access your profile"
            r.redirect("/auth/login")
          end

          # GET /auth/profile
          r.get do
            view("auth/profile")
          end

          # POST /auth/profile
          r.post do
            if current_user.update(
              display_name: r.params["display_name"]&.strip,
              email: r.params["email"]&.strip&.downcase,
              bio: r.params["bio"]&.strip
            )
              flash["notice"] = "Profile updated successfully"
            else
              flash["error"] = current_user.errors.full_messages.join(", ")
            end
            r.redirect("/auth/profile")
          end
        end

        r.on "change_password" do
          # POST /auth/profile/change_password
          r.post do
            unless current_user.valid_password?(r.params["current_password"])
              flash["error"] = "Current password is incorrect"
              r.redirect("/auth/profile")
              return
            end

            new_pass = r.params["new_password"]
            if new_pass.length < 8
              flash["error"] = "New password must be at least 8 characters"
              r.redirect("/auth/profile")
              return
            end

            if new_pass != r.params["new_password_confirmation"]
              flash["error"] = "New passwords don't match"
              r.redirect("/auth/profile")
              return
            end

            current_user.password = new_pass
            if current_user.save
              flash["notice"] = "Password updated successfully"
              # Force re-login with new password
              session.clear
              r.redirect("/auth/login")
            else
              flash["error"] = "Error updating password"
              r.redirect("/auth/profile")
            end
          end
        end
      end

      r.on "verify" do
        # GET /auth/verify/:token
        r.get String do |token|
          user = User.find(verification_token: token)
          if user && !user.email_verified?
            user.update(
              email_verified: true,
              verification_token: nil,
              verified_at: Sequel::CURRENT_TIMESTAMP
            )
            flash["notice"] = "Email verified successfully!"
          else
            flash["error"] = "Invalid or expired verification link"
          end
          r.redirect("/")
        end
      end
    end
  end
end