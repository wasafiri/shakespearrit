module AdminRoutes
  def self.load(r)
    r.hash_branch "admin" do |r|
      # Authentication & Authorization
      require_login!
      unless current_user&.is_admin
        flash["error"] = "Admin access required"
        r.redirect("/")
      end

      r.on "plays" do
        # GET /admin/plays - List all plays
        r.get do
          @plays = Play.order(Sequel.asc(:title)).all
          view("admin/plays/index")
        end

        # Play creation routes
        r.is "new" do
          r.get do
            view("admin/plays/new_play")
          end

          # POST /admin/plays - Create play
          r.post do
            begin
              title = r.params["title"]&.strip
              author = r.params["author"]&.strip
              notes = r.params["notes"]&.strip

              play = Play.new(
                title: title,
                author: author,
                notes: notes
              )

              if play.valid? && play.save
                flash["notice"] = "Play '#{play.title}' created successfully."
                r.redirect("/admin/plays")
              else
                flash["error"] = "Error creating play: #{play.errors.full_messages.join(", ")}"
                r.redirect("/admin/plays/new")
              end
            rescue Sequel::Error => e
              flash["error"] = "Database error: #{e.message}"
              r.redirect("/admin/plays/new")
            end
          end
        end

        # Routes for specific play
        r.on Integer do |play_id|
          begin
            play = Play[play_id] or r.halt(404, "Play not found")

            # GET /admin/plays/:play_id - Show play details
            r.get do
              @play = play
              @acts = play.acts_dataset.order(:act_number).all
              view("admin/plays/show_play")
            end

            # Routes for editing play
            r.on "edit" do
              r.get do
                @play = play
                view("admin/plays/edit_play")
              end

              r.post do
                begin
                  title = r.params["title"]&.strip
                  author = r.params["author"]&.strip
                  notes = r.params["notes"]&.strip

                  if play.update(
                    title: title,
                    author: author,
                    notes: notes
                  )
                    flash["notice"] = "Play updated successfully."
                    r.redirect("/admin/plays/#{play_id}")
                  else
                    flash["error"] = "Error updating play: #{play.errors.full_messages.join(", ")}"
                    r.redirect("/admin/plays/#{play_id}/edit")
                  end
                rescue Sequel::Error => e
                  flash["error"] = "Database error: #{e.message}"
                  r.redirect("/admin/plays/#{play_id}/edit")
                end
              end
            end

            # Routes for deleting play
            r.on "delete" do
              r.post do
                begin
                  play_title = play.title
                  DB.transaction do
                    play.destroy
                  end
                  flash["notice"] = "Play '#{play_title}' deleted successfully."
                  r.redirect("/admin/plays")
                rescue Sequel::Error => e
                  flash["error"] = "Error deleting play: #{e.message}"
                  r.redirect("/admin/plays/#{play_id}")
                end
              end
            end

            # Act management routes
            r.on "acts" do
              # Create new act
              r.post "new" do
                begin
                  act_number = r.params["act_number"]&.to_i
                  description = r.params["description"]&.strip

                  act = Act.new(
                    play_id: play.id,
                    act_number: act_number,
                    description: description
                  )

                  if act.valid? && act.save
                    flash["notice"] = "Act #{act.act_number} created successfully."
                  else
                    flash["error"] = "Error creating act: #{act.errors.full_messages.join(", ")}"
                  end
                  r.redirect("/admin/plays/#{play_id}")
                rescue Sequel::Error => e
                  flash["error"] = "Database error: #{e.message}"
                  r.redirect("/admin/plays/#{play_id}")
                end
              end

              # Edit act
              r.on Integer do |act_id|
                act = Act[act_id] or r.halt(404, "Act not found")
                
                r.post "edit" do
                  begin
                    act_number = r.params["act_number"]&.to_i
                    description = r.params["description"]&.strip

                    if act.update(
                      act_number: act_number,
                      description: description
                    )
                      flash["notice"] = "Act updated successfully."
                    else
                      flash["error"] = "Error updating act: #{act.errors.full_messages.join(", ")}"
                    end
                    r.redirect("/admin/plays/#{play_id}")
                  rescue Sequel::Error => e
                    flash["error"] = "Database error: #{e.message}"
                    r.redirect("/admin/plays/#{play_id}")
                  end
                end

                # Delete act
                r.post "delete" do
                  begin
                    DB.transaction do
                      act.destroy
                    end
                    flash["notice"] = "Act #{act.act_number} deleted successfully."
                    r.redirect("/admin/plays/#{play_id}")
                  rescue Sequel::Error => e
                    flash["error"] = "Error deleting act: #{e.message}"
                    r.redirect("/admin/plays/#{play_id}")
                  end
                end
              end
            end
          rescue Sequel::Error => e
            flash["error"] = "Database error: #{e.message}"
            r.redirect("/admin/plays")
          end
        end
      end
      
      # Admin Dashboard
      r.is do
        r.get do
          @all_users = User.order(Sequel.desc(:created_at)).all
          @all_interps = Interpretation.order(Sequel.desc(:created_at)).limit(50).all
          @stats = {
            total_users: User.count,
            total_plays: Play.count,
            total_interpretations: Interpretation.count,
            recent_interpretations: Interpretation.where { created_at > Time.now - 7*24*60*60 }.count
          }
          view("admin/index")
        end
      end
    end
  end
end