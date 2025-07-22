Sequel.migration do
  up do
    # Only proceed if the old column still exists
    if DB.table_exists?(:interpretations) && DB[:interpretations].columns.include?(:speech_line_id)
      alter_table(:interpretations) do
        # Now that data is migrated, we can enforce NOT NULL constraints
        set_column_not_null :interpretable_id
        set_column_not_null :interpretable_type

        # Drop the old foreign key and column
        drop_foreign_key [:speech_line_id]
        drop_column :speech_line_id
      end
    end
  end

  down do
    alter_table(:interpretations) do
      # Re-add the old column and foreign key.
      # Note: Data would need to be migrated back in a separate step.
      add_column :speech_line_id, Integer
      add_foreign_key [:speech_line_id], :speech_lines, on_delete: :cascade

      # Allow nulls on the polymorphic columns again as they are no longer the primary reference
      set_column_allow_null :interpretable_id
      set_column_allow_null :interpretable_type
    end
  end
end