Sequel.migration do
    change do
      create_table(:plays) do
        primary_key :id
        String :title, null: false
        String :author
        Text   :notes
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
  
      create_table(:acts) do
        primary_key :id
        foreign_key :play_id, :plays, on_delete: :cascade
        Integer :act_number, null: false
        String :description
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
  
      create_table(:scenes) do
        primary_key :id
        foreign_key :act_id, :acts, on_delete: :cascade
        Integer :scene_number, null: false
        String :description
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
  
      create_table(:speeches) do
        primary_key :id
        foreign_key :scene_id, :scenes, on_delete: :cascade
        String :speaker_name
        Integer :order_in_scene
        Text   :notes
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
  
      create_table(:speech_lines) do
        primary_key :id
        foreign_key :speech_id, :speeches, on_delete: :cascade
        Integer :start_line_number
        Integer :end_line_number
        Text   :text, null: false
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end
  