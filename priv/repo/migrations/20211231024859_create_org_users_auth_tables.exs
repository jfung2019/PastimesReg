defmodule PastimesReg.Repo.Migrations.CreateOrgUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:org_users) do
      # Basic information
      add :first_name, :varchar, null: false
      add :last_name, :varchar, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime

      # Organization information
      add :organization, :varchar, null: false
      add :license, :varchar, null: true
      add :address_line_1, :varchar, null: false
      add :address_line_2, :varchar, null: true
      add :city, :varchar, null: false
      add :state, :varchar, null: false
      add :zip, :varchar, null: false
      add :country, :varchar, null: false
      add :phone, :varchar, null: false
      add :support_email, :varchar, null: true
      add :support_phone, :varchar, null: true
      add :instagram_url, :varchar, null: true
      add :facebook_url, :varchar, null: true
      add :twitter_url, :varchar, null: true
      add :website_url, :varchar, null: true
      add :logo, :varchar, null: true

      # Bank information
      add :routing_number, :varchar, null: true
      add :account_number, :varchar, null: true
      timestamps()
    end

    create unique_index(:org_users, [:email])

    create table(:org_users_tokens) do
      add :org_user_id, references(:org_users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:org_users_tokens, [:org_user_id])
    create unique_index(:org_users_tokens, [:context, :token])
  end
end
