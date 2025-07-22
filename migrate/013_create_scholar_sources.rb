Sequel.migration do
  change do
    create_table(:scholar_sources) do
      primary_key :id
      String :name, null: false, unique: true
      String :author
      Integer :publication_year
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end