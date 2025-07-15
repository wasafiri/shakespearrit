module InterpretationsRoutes
  def self.load(r)
    r.on "interpretations" do
      # Index route for interpretations (if needed)
      r.is do
        r.get do
          @interpretations = Interpretation.order(Sequel.desc(:created_at))
          view("interpretations/index")
        end
      end

      # Show, Edit, Delete routes for specific interpretation
      r.on Integer do |interp_id|
        @interp = Interpretation[interp_id] or r.halt(404, "Interpretation not found")

        # GET /interpretations/:id
        r.is do
          r.get do
            view("interpretations/show")
          end

          # POST /interpretations/:id (Voting)
          r.post do
            require_login!
            
            vote_type = r.params["vote_type"]
            allowed_votes = ['upvote', 'downvote', 'inappropriate']

            unless allowed_votes.include?(vote_type)
              flash["error"] = "Invalid vote type."
              return r.redirect("/interpretations/#{interp_id}")
            end

            begin
              DB.transaction do
                existing_vote = InterpretationVote.where(
                  user_id: current_user.id,
                  interpretation_id: @interp.id
                ).first

                if existing_vote
                  existing_vote.update(vote_type: vote_type)
                else
                  InterpretationVote.create(
                    user_id: current_user.id,
                    interpretation_id: @interp.id,
                    vote_type: vote_type
                  )
                end
              end
              
              flash["notice"] = "Your vote has been recorded."
            rescue Sequel::Error => e
              flash["error"] = "Error recording vote. Please try again."
              logger.error "Vote error for interpretation #{@interp.id}: #{e.message}"
            end

            r.redirect("/interpretations/#{interp_id}")
          end
        end

        # Edit routes
        r.on "edit" do
          require_login!
          unless current_user.id == @interp.user_id || current_user.is_admin
            flash["error"] = "Not authorized to edit this interpretation"
            return r.redirect("/interpretations/#{interp_id}")
          end

          r.get do
            view("interpretations/edit")
          end

          r.post do
            if r.params["youtube_url"].to_s.strip.empty?
              flash["error"] = "YouTube URL is required"
              return view("interpretations/edit")
            end

            begin
              @interp.update(
                youtube_url: r.params["youtube_url"].strip,
                description: r.params["description"].to_s.strip
              )
              flash["notice"] = "Interpretation updated successfully"
              r.redirect("/interpretations/#{interp_id}")
            rescue Sequel::ValidationError => e
              flash["error"] = e.message
              view("interpretations/edit")
            end
          end
        end

        # Delete routes
        r.on "delete" do
          require_login!
          unless current_user.id == @interp.user_id || current_user.is_admin
            flash["error"] = "Not authorized to delete this interpretation"
            return r.redirect("/interpretations/#{interp_id}")
          end

          r.post do
            begin
              DB.transaction do
                @interp.interpretation_votes_dataset.delete  # Delete associated votes
                @interp.delete                              # Delete the interpretation
              end
              flash["notice"] = "Interpretation deleted successfully"
              r.redirect("/plays")
            rescue => e
              flash["error"] = "Error deleting interpretation"
              logger.error "Delete error for interpretation #{@interp.id}: #{e.message}"
              r.redirect("/interpretations/#{interp_id}")
            end
          end
        end
      end

      # Create new interpretation
      r.on "new" do
        require_login!

        line_id = r.params["line_id"]
        @speech_line = SpeechLine[line_id] or r.halt(404, "Line not found")

        r.get do
          view("interpretations/new")
        end

        r.post do
          youtube_url = r.params["youtube_url"].to_s.strip
          description = r.params["description"].to_s.strip

          if youtube_url.empty?
            flash["error"] = "YouTube URL is required"
            return r.redirect("/interpretations/new?line_id=#{line_id}")
          end

          begin
            interp = Interpretation.create(
              user_id: current_user.id,
              speech_line_id: @speech_line.id,
              youtube_url: youtube_url,
              description: description
            )
            
            # Check if user earned any achievements
            Achievement.check_achievements_for(current_user)
            
            flash["notice"] = "ASL interpretation submitted successfully!"
            r.redirect("/interpretations/#{interp.id}")
          rescue Sequel::ValidationError => e
            flash["error"] = e.message
            r.redirect("/interpretations/new?line_id=#{line_id}")
          rescue => e
            flash["error"] = "Error creating interpretation"
            logger.error "Create error: #{e.message}"
            r.redirect("/interpretations/new?line_id=#{line_id}")
          end
        end
      end
    end
  end
end