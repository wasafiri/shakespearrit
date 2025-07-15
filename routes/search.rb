module SearchRoutes
  def self.load(r)
    r.on "search" do
      r.get do
        query = r.params["query"]
        category = r.params["category"]

        # Validate presence of query and category
        if query.nil? || query.strip.empty? || category.nil?
          flash["error"] = "Please enter a search query and select a category."
          r.redirect("/")
        end

        # Validate category
        valid_categories = ["plays", "lines", "interpretations"]
        unless valid_categories.include?(category)
          flash["error"] = "Invalid search category."
          r.redirect("/")
        end

        @query = query.strip
        @category = category

        case category
        when "plays"
          # Search by title or author (case-insensitive partial match)
          dataset = Play.where(Sequel.ilike(:title, "%#{@query}%") | Sequel.ilike(:author, "%#{@query}%"))
        when "lines"
          # Search by text (case-insensitive partial match) or by line number
          if @query =~ /^\d+$/
            # If query is purely numeric, search by line number
            line_number = @query.to_i
            dataset = SpeechLine.where(Sequel.|({ start_line_number: line_number }, { end_line_number: line_number }))
          else
            # Search by text
            dataset = SpeechLine.where(Sequel.ilike(:text, "%#{@query}%"))
          end
        when "interpretations"
          # Search by description or YouTube URL (case-insensitive partial match)
          dataset = Interpretation.where(Sequel.ilike(:description, "%#{@query}%") | Sequel.ilike(:youtube_url, "%#{@query}%"))
        end

        # Implement Pagy pagination
        @pagy, @results = pagy(dataset.order(:id), items: 10) # Adjust `items` as needed

        view("search/results")
      end
    end
  end
end
