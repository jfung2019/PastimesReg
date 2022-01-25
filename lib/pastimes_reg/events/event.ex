defmodule PastimesReg.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import PastimesReg.Activities.ActivitiesOption

  alias PastimesReg.Events.Category

  schema "events" do
    # Basic Information (step 1)
    field :activity_type, :string
    field :name, :string
    field :address, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    field :details, :string
    field :website_url, :string
    field :cover_photo, :string
    field :photos, {:array, :string}, default: []

    # Category Information (step 2)
    embeds_many :categories, Category

    # Other Event Information (step 3)
    field :confirmation_message_to_participants, :string
    field :contact_information, :boolean, default: false
    field :email_address, :string
    field :phone_number, :string
    field :promote_event, :boolean, default: false
    field :number_of_hours_before_event, :string
    field :email_notification, :boolean, default: false

    # Foreign key to users_org table id
    belongs_to :org_user, PastimesReg.Accounts.OrgUser

    timestamps()
  end

  @allowed_attributes [
    :activity_type,
    :name,
    :address,
    :start_date,
    :end_date,
    :details,
    :website_url,
    :cover_photo,
    :confirmation_message_to_participants,
    :contact_information,
    :email_address,
    :phone_number,
    :promote_event,
    :number_of_hours_before_event,
    :email_notification
  ]

  @required_attributes_step_1 [
    :activity_type,
    :name,
    :address,
    :start_date,
    :end_date
  ]

  @required_attributes_step_3 [
    :confirmation_message_to_participants,
    :contact_information,
    :email_address,
    :phone_number,
    :promote_event,
    :refund_policy_strict,
    :refund_policy_flexible,
    :number_of_hours_before_event,
    :email_notification
  ]

  @doc false
  # def changeset(events, attrs) do
  #   events
  #   |> cast(attrs, @allowed_attributes)
  #   |> validate_required(@required_attributes_step_1)
  # end

  def event_create_changeset_step_1(event, attrs) do
    event
    |> cast(
      attrs,
      [
        :activity_type,
        :name,
        :address,
        :start_date,
        :end_date,
        :details,
        :website_url,
        :cover_photo,
        :photos
      ]
    )
    |> validate_required(@required_attributes_step_1)
    |> validate_activity_type()
    |> validate_inclusion(:activity_type, activity_options())
    |> validate_name_event()
    |> validate_address_location()
    |> validate_website_url_event()
    |> validate_date()
    |> check_constraint(:start_date,
      name: :start_date_must_be_before_end_date,
      message: "start date must be before end date"
    )
  end

  def event_create_changeset_step_2(event, attrs) do
    event
    |> cast(attrs, [])
    |> cast_embed(:categories, with: &Category.changeset/2)
  end

  def event_create_changeset_step_3(event, attrs) do
    event
    |> cast(
      attrs,
      [
        :confirmation_message_to_participants,
        :contact_information,
        :email_address,
        :phone_number,
        :promote_event,
        :number_of_hours_before_event,
        :email_notification
      ]
    )
  end

  # step 1
  defp validate_activity_type(changeset) do
    changeset
    |> validate_required([:activity_type])
  end

  defp validate_name_event(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, max: 160)
  end

  defp validate_address_location(changeset) do
    changeset
    |> validate_required([:address])
    |> validate_length(:address, max: 160)
  end

  defp validate_date(changeset) do
    end_date = get_field(changeset, :end_date)
    start_date = get_field(changeset, :start_date)

    changeset =
      cond do
        start_date > end_date -> add_error(changeset, :start_date, "must be before end date")
        true -> changeset
      end

    changeset
    |> validate_required([:start_date])
  end

  # defp validate_details_event(changeset) do
  #   changeset
  #   |> validate_length(:details, max: 1000)
  # end

  defp validate_website_url_event(changeset) do
    changeset
    |> validate_length(:website_url, max: 160)
  end

  # defp validate_cover_photo(changeset) do
  #   changeset
  #   |> validate_required([:cover_photo])
  # end

  # step 2
  # validation done in the embedded module

  # step 3
  # defp validate_confirmation_message_to_participants(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  # defp validate_event_contact_information(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  # defp validate_email_address(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  # defp validate_phone_number(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  # defp validate_promote_event(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  # defp validate_number_of_hours_before_event(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  # defp validate_email_notification(changeset) do
  #   changeset
  #   |> validate_length(:cover_photo, max: 160)
  # end

  @spec append_category_to_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def append_category_to_changeset(changeset) do
    case get_field(changeset, :categories, []) do
      [] ->
        put_embed(changeset, :categories, [%PastimesReg.Events.Category{}])

      list ->
        put_embed(
          changeset,
          :categories,
          List.insert_at(list, -1, %PastimesReg.Events.Category{})
        )
    end
  end

  @spec delete_category_from_changeset_list(Ecto.Changeset.t(), integer()) :: Ecto.Changeset.t()
  def delete_category_from_changeset_list(changeset, category_index) do
    case get_field(changeset, :categories, []) do
      [] ->
        changeset

      list ->
        put_embed(
          changeset,
          :categories,
          List.delete_at(list, category_index)
        )
    end
  end
end
