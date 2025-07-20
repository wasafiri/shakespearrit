Sequel.migration do
  change do
    alter_table(:users) do
      add_column :youtube_refresh_token, String
    end
  end
end
