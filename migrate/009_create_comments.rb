Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      foreign_key :interpretation_id, :interpretations, on_delete: :cascade, null: false
      foreign_key :parent_comment_id, :comments, on_delete: :cascade
      Text :body, null: false
      String :video_asset_id # For video comments, if using a service like Mux
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

      index :user_id
      index :interpretation_id
      index :parent_comment_id
    end
  end
end
