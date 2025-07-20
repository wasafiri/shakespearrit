Sequel.migration do
  change do
    alter_table(:users) do
      add_column :karma, Integer, default: 10
    end
  end
end