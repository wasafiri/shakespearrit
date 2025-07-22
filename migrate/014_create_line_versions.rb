Sequel.migration do
  change do
    create_table(:line_versions) do
      primary_key :id
      foreign_key :speech_line_id, :speech_lines, null: false, on_delete: :cascade
      foreign_key :scholar_source_id, :scholar_sources, null: false, on_delete: :cascade
      Text :version_text, null: false
      Text :notes
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index [:speech_line_id, :scholar_source_id], unique: true
    end
  end
end