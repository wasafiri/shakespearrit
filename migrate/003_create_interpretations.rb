Sequel.migration do
  change do
    create_table(:interpretations) do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade
      foreign_key :speech_line_id, :speech_lines, on_delete: :cascade
      String :youtube_video_id
      String :status, default: 'pending'
      Text :description
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    alter_table(:interpretations) do
      add_index :user_id
      add_index :speech_line_id
    end
  end
end