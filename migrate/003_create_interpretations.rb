Sequel.migration do
    change do
      create_table(:interpretations) do
        primary_key :id
        foreign_key :user_id, :users, on_delete: :cascade
        foreign_key :speech_line_id, :speech_lines, on_delete: :cascade

        add_index :interpretations, :user_id
        add_index :interpretations, :speech_line_id
  
        # We'll store a YouTube URL
        String :youtube_url, null: false
        Text :description  # optional user-provided note
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end
  