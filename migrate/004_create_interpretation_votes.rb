Sequel.migration do
  change do
    create_table(:interpretation_votes) do
      primary_key :id
      foreign_key :user_id, :users, on_delete: :cascade
      foreign_key :interpretation_id, :interpretations, on_delete: :cascade
      String :vote_type, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # Add a check constraint to ensure vote_type is valid
    alter_table(:interpretation_votes) do
      add_constraint(:vote_type_constraint, "vote_type IN ('upvote', 'downvote', 'inappropriate')")
      add_index [:user_id, :interpretation_id], unique: true, name: :unique_user_interpretation_vote
    end
  end
end
