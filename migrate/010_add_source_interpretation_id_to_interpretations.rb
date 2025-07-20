Sequel.migration do
  change do
    alter_table(:interpretations) do
      add_foreign_key :source_interpretation_id, :interpretations, null: true, on_delete: :set_null
    end
  end
end