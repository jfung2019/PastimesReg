defmodule PastimesReg.Participants.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "participants" do
    field :address_1, :string
    field :address_2, :string
    field :city, :string
    field :country, :string
    field :dob, :date
    field :email_address, :string
    field :email_address_confirmation, :string, virtual: true
    field :emergency_contact_name, :string
    field :emergency_contact_number, :string
    field :first_name, :string
    field :gender, :string
    field :last_name, :string
    field :phone_number, :string
    field :state, :string
    field :zip, :string
    field :read_agreed_waiver, :boolean, default: false
    field :read_agreed_tos, :boolean, default: false
    field :waiver_initials, :string
    field :category, :string

    belongs_to :event, PastimesReg.Events.Event

    timestamps()
  end

  @required_attributes_step_1 [
    :first_name,
    :last_name,
    :address_1,
    :city,
    :state,
    :zip,
    :country,
    :phone_number,
    :email_address,
    :email_address_confirmation,
    :dob,
    :gender,
    :emergency_contact_name,
    :emergency_contact_number,
    :read_agreed_waiver,
    :read_agreed_tos,
    :waiver_initials,
    :category
  ]

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(
      attrs,
      [
        :first_name,
        :last_name,
        :address_1,
        :address_2,
        :city,
        :state,
        :zip,
        :country,
        :phone_number,
        :email_address,
        :email_address_confirmation,
        :dob,
        :gender,
        :emergency_contact_name,
        :emergency_contact_number,
        :read_agreed_waiver,
        :read_agreed_tos,
        :waiver_initials
      ]
    )
    |> validate_required(@required_attributes_step_1)
  end

  def event_registration_changeset_step_1(participant, attrs) do
    participant
    |> cast(
      attrs,
      [
        :first_name,
        :last_name,
        :address_1,
        :address_2,
        :city,
        :state,
        :zip,
        :country,
        :phone_number,
        :email_address,
        :email_address_confirmation,
        :dob,
        :gender,
        :emergency_contact_name,
        :emergency_contact_number,
        :read_agreed_waiver,
        :read_agreed_tos,
        :waiver_initials,
        :category
      ]
    )
    |> validate_required(@required_attributes_step_1)
  end

end
