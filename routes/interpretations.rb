class ShakespeareApp
  route("interpretations") do |r|
    # Index route for interpretations
    r.is do
      r.get do
        @interpretations = Interpretation.order(Sequel.desc(:created_at))
        view("interpretations/index")
      end
    end

    # Create new interpretation
    r.on "new" do
      require_login!

      line_id = r.typecast_params.pos_int("line_id")
      @speech_line = SpeechLine[line_id] or r.halt(404, "Line not found")

      r.is do
        r.get do
          view("interpretations/new")
        end

        r.post do
          youtube_video_id = r.typecast_params.nonempty_str!("youtube_video_id").strip
          description = r.typecast_params.str("description", "").strip

          begin
            @interp = Interpretation.create(
              speech_line_id: @speech_line.id,
              user_id: current_user.id,
              youtube_video_id: youtube_video_id,
              description: description
            )
            flash["notice"] = "Interpretation created successfully"
            r.redirect("/interpretations/#{@interp.id}")
          rescue Sequel::ValidationError => e
            flash["error"] = e.message
            view("interpretations/new")
          end
        end
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
      end

      # Routes requiring ownership
      r.on do
        require_login!
        unless current_user.id == @interp.user_id || current_user.is_admin
          flash["error"] = "Not authorized to perform this action"
          r.redirect("/interpretations/#{interp_id}")
        end

        # Edit routes
        r.on "edit" do
          r.is do
            r.get do
              view("interpretations/edit")
            end

            r.post do
              youtube_video_id = r.typecast_params.nonempty_str!("youtube_video_id").strip
              description = r.typecast_params.str("description", "").strip

              begin
                @interp.update(
                  youtube_video_id: youtube_video_id,
                  description: description
                )
                flash["notice"] = "Interpretation updated successfully"
                r.redirect("/interpretations/#{interp_id}")
              rescue Sequel::ValidationError => e
                flash["error"] = e.message
                view("interpretations/edit")
              end
            end
          end
        end

        # Delete route
        r.on "delete" do
          r.post do
            @interp.destroy
            flash["notice"] = "Interpretation deleted successfully"
            r.redirect("/interpretations")
          end
        end
      end
    end
  end
end
