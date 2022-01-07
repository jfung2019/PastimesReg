defmodule PastimesReg.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:events) do
      # Basic Information
      add :activity_type, :string, null: false
      add :name_event, :varchar, null: false
      add :address_location, :varchar, null: false
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime, null: false
      add :details_event, :varchar, null: true
      add :website_url_event, :varchar, null: true
      add :cover_photo, :string

      # Category Information
      # Other Event Information
      add :confirmation_message_to_participants, :varchar, null: true
      add :event_contact_information, :boolean, default: false, null: true
      add :email_adress, :varchar, null: true
      add :phone_number, :varchar, null: true
      add :promote_event, :boolean, default: false, null: true
      add :number_of_hours_before_event, :varchar, null: true
      add :email_notification, :boolean, default: false, null: true
      add :org_users_id, references(:org_users, on_delete: :nothing)

      timestamps()
    end

    create index(:events, [:org_users_id])
  end
end
