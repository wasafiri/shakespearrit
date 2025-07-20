class ShakespeareApp
  route("search") do |r|
    r.is do
      r.get do
        query = r.typecast_params.str("q", "").strip
        
        if query.empty?
          @results = []
        else
          # Search across plays, speeches, and interpretations
          @results = {
            plays: Play.where(Sequel.ilike(:title, "%#{query}%")).limit(10).all,
            speeches: Speech.where(Sequel.ilike(:character, "%#{query}%")).limit(10).all,
            interpretations: Interpretation.where(Sequel.ilike(:description, "%#{query}%")).limit(10).all
          }
        end
        
        view("search/results")
      end
    end
  end
end
