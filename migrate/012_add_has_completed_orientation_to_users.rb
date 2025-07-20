Sequel.migration do
  change do
    alter_table(:users) do
      add_column :has_completed_orientation, TrueClass, default: false
    end
  end
end