defmodule PastimesReg.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      # Basic Information
      add :activity_type, :varchar, null: false
      add :name, :varchar, null: false
      add :address, :varchar, null: false
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime, null: false
      add :details, :varchar, null: true
      add :website_url, :varchar, null: true
      add :cover_photo, :varchar

      # Category Information
      add :categories, :jsonb, default: "[]", null: false

      # Other Event Information
      add :confirmation_message_to_participants, :varchar, null: true
      add :contact_information, :boolean, default: false, null: false
      add :email_address, :varchar, null: true
      add :phone_number, :varchar, null: true
      add :promote_event, :boolean, default: false, null: false
      add :number_of_hours_before_event, :varchar, null: true
      add :email_notification, :boolean, default: false, null: false
      add :org_user_id, references(:org_users, on_delete: :delete_all), null: false

      # testing set null to true for few fields
      # add :activity_type, :string, null: true
      # add :name, :varchar, null: false
      # add :address, :varchar, null: true
      # add :start_date, :utc_datetime, null: true
      # add :end_date, :utc_datetime, null: true
      # add :details, :varchar, null: true
      # add :website_url, :varchar, null: true
      # add :cover_photo, :string

      # # Category Information
      # add :categories, :jsonb, default: "[]"

      # # Other Event Information
      # add :confirmation_message_to_participants, :varchar, null: true
      # add :contact_information, :boolean, default: false, null: true
      # add :email_address, :varchar, null: true
      # add :phone_number, :varchar, null: true
      # add :promote_event, :boolean, default: false, null: true
      # add :number_of_hours_before_event, :varchar, null: true
      # add :email_notification, :boolean, default: false, null: true
      # add :org_users_id, references(:org_users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:events, [:org_user_id])
  end
end
