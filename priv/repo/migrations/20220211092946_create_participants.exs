defmodule PastimesReg.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do

    create table(:participants) do
      add :first_name, :varchar, null: false
      add :last_name, :varchar, null: false
      add :address_1, :varchar, null: false
      add :address_2, :varchar, null: true
      add :city, :varchar, null: false
      add :state, :varchar, null: false
      add :zip, :varchar, null: false
      add :country, :varchar, null: false
      add :phone_number, :varchar, null: false
      add :email_address, :varchar, null: false
      add :dob, :date, null: false
      add :gender, :varchar, null: false
      add :emergency_contact_name, :varchar, null: false
      add :emergency_contact_number, :varchar, null: false
      add :waiver_initials, :varchar, null: false
      add :category, :varchar, null: false
      add :read_agreed_waiver, :boolean, default: false, null: false
      add :read_agreed_tos, :boolean, default: false, null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:participants, [:event_id])
    create unique_index(:participants, [:event_id, :email_address, :category])
  end
end
