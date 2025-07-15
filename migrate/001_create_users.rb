Sequel.migration do
    change do
      create_table(:users) do
        primary_key :id
        String :email, null: false, unique: true
        String :password_digest, text: true  # storing a hashed password
        String :display_name
        Boolean :is_admin, default: false
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end
  