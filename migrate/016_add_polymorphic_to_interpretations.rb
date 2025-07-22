Sequel.migration do
  change do
    alter_table(:interpretations) do
      add_column :interpretable_id, Integer
      add_column :interpretable_type, String
      add_index [:interpretable_id, :interpretable_type]
    end
  end
end