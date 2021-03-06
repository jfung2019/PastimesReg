defmodule PastimesReg.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :activity_type, :varchar, null: false
      add :name, :varchar, null: false
      add :address, :varchar, null: false
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime, null: false
      add :timezone, :string, null: false
      add :details, :varchar, null: true
      add :website_url, :varchar, null: true
      add :cover_photo, :varchar
      add :photos, {:array, :varchar}, null: true, default: []
      add :logo, :varchar
      add :categories, :jsonb, default: "[]", null: false
      add :waiver, :varchar, null: true
      add :confirmation_message_to_participants, :varchar, null: true
      add :contact_information, :boolean, default: false, null: false
      add :email_address, :varchar, null: true
      add :phone_number, :varchar, null: true
      add :promote_event, :boolean, default: false, null: false
      add :use_org_logo, :boolean, default: false, null: false
      add :strict, :boolean, default: false, null: false
      add :flexible, :boolean, default: false, null: false
      add :email_notification, :boolean, default: false, null: false
      add :org_user_id, references(:org_users, on_delete: :delete_all), null: false

      timestamps()
    end

    create constraint("events", "start_date_must_be_before_end_date",
             check: "start_date < end_date"
           )

    create index(:events, [:org_user_id])
  end
end
