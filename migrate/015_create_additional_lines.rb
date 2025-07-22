Sequel.migration do
  change do
    create_table(:additional_lines) do
      primary_key :id
      foreign_key :scene_id, :scenes, null: false, on_delete: :cascade
      foreign_key :scholar_source_id, :scholar_sources, null: false, on_delete: :cascade
      foreign_key :position_reference_line_id, :speech_lines, null: false, on_delete: :cascade

      Text :line_text, null: false
      String :character_speaking, null: false
      String :insertion_point, null: false # 'before' or 'after'
      Text :notes

      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end