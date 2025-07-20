Sequel.migration do
  change do
    create_table(:ratings) do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade, null: false
      foreign_key :interpretation_id, :interpretations, on_delete: :cascade, null: false
      Integer :stars, null: false
      String :tag
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

      index [:user_id, :interpretation_id], unique: true
      index :tag
    end
  end
end
