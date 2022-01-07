defmodule PastimesReg.Event.Events do
  use Ecto.Schema
  import Ecto.Changeset
  import PastimesReg.Activities.ActivitiesOption

  schema "events" do
    # Basic Information (step 1)
    field :activity_type, :string
    field :name_event, :string
    field :address_location, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    field :details_event, :string
    field :website_url_event, :string
    field :cover_photo, :string

    # Category Information (step 2)
    # to add embeded_schema

    # Other Event Information (step 3)
    field :confirmation_message_to_participants, :string
    field :event_contact_information, :boolean, default: false
    field :email_adress, :string
    field :phone_number, :string
    field :promote_event, :boolean, default: false
    field :number_of_hours_before_event, :string
    field :email_notification, :boolean, default: false

    # Foreign key to users_org table id
    field :org_users_id, :id

    belongs_to :org_user, PastimesReg.Accounts.OrgUser

    timestamps()
  end

  @allowed_attributes [
    :activity_type,
    :name_event,
    :address_location,
    :start_date,
    :end_date,
    :details_event,
    :website_url_event,
    :cover_photo,
    :confirmation_message_to_participants,
    :event_contact_information,
    :email_adress,
    :phone_number,
    :promote_event,
    :number_of_hours_before_event,
    :email_notification
  ]
  @required_attributes [
    :activity_type,
    :name_event,
    :address_location,
    :start_date,
    :end_date,
    :details_event,
    :website_url_event,
    :cover_photo,
    :confirmation_message_to_participants,
    :event_contact_information,
    :email_adress,
    :phone_number,
    :promote_event,
    :number_of_hours_before_event,
    :email_notification
  ]

  @doc false
  def changeset(events, attrs) do
    events
    |> cast(attrs, @allowed_attributes)
    |> validate_required(@required_attributes)
    |> validate_inclusion(:activity_type, activity_options())
  end
end
