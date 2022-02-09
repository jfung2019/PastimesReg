defmodule PastimesReg.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import PastimesReg.Activities.ActivitiesOption
  import PastimesReg.TimeZones.TimeZoneOption

  alias PastimesReg.Events.Category

  schema "events" do
    # Basic Information (step 1)
    field :activity_type, :string
    field :name, :string
    field :address, :string
    field :details, :string
    field :website_url, :string
    field :cover_photo, :string
    field :photos, {:array, :string}, default: []
    field :start_time_zone, :string
    field :end_time_zone, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    field :start_date_virtual, :date, virtual: true
    field :end_date_virtual, :date, virtual: true
    field :start_time_virtual, :time, virtual: true
    field :end_time_virtual, :time, virtual: true

    # Category Information (step 2)
    embeds_many :categories, Category

    # Other Event Information (step 3)
    field :confirmation_message_to_participants, :string
    field :waiver, :string
    field :contact_information, :boolean, default: false
    field :email_address, :string
    field :phone_number, :string
    field :promote_event, :boolean, default: false
    field :number_of_hours_before_event, :string
    field :email_notification, :boolean, default: false
    field :logo, :string
    field :use_org_logo, :boolean, default: false
    field :strict, :boolean, default: false
    field :flexible, :boolean, default: false

    belongs_to :org_user, PastimesReg.Accounts.OrgUser

    timestamps()
  end

  # @allowed_attributes [
  #   :activity_type,
  #   :name,
  #   :address,
  #   :start_date,
  #   :end_date,
  #   :details,
  #   :website_url,
  #   :cover_photo,
  #   :confirmation_message_to_participants,
  #   :contact_information,
  #   :email_address,
  #   :phone_number,
  #   :promote_event,
  #   :number_of_hours_before_event,
  #   :email_notification
  # ]

  @required_attributes_step_1 [
    :activity_type,
    :name,
    :address,
    :start_date_virtual,
    :end_date_virtual,
    :start_time_virtual,
    :end_time_virtual
  ]

  # @required_attributes_step_3 [
  #   :confirmation_message_to_participants,
  #   :contact_information,
  #   :email_address,
  #   :phone_number,
  #   :promote_event,
  #   :refund_policy_strict,
  #   :refund_policy_flexible,
  #   :number_of_hours_before_event,
  #   :email_notification
  # ]

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
        :details,
        :website_url,
        :cover_photo,
        :photos,
        :start_date,
        :end_date,
        :start_date_virtual,
        :end_date_virtual,
        :start_time_virtual,
        :end_time_virtual,
        :start_time_zone,
        :end_time_zone
      ]
    )
    |> validate_required(@required_attributes_step_1)
    |> validate_activity_type()
    |> validate_time_zone()
    |> validate_inclusion(:activity_type, activity_options())
    |> validate_inclusion(:start_time_zone, start_time_zone_options())
    |> validate_inclusion(:end_time_zone, end_time_zone_options())
    |> validate_name_event()
    |> validate_address_location()
    |> validate_website_url_event()
    |> assemble_date_time()
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
        :waiver,
        :confirmation_message_to_participants,
        :contact_information,
        :email_address,
        :phone_number,
        :promote_event,
        :number_of_hours_before_event,
        :email_notification,
        :logo,
        :use_org_logo,
        :strict,
        :flexible
      ]
    )
  end

  # step 1
  defp validate_activity_type(changeset) do
    changeset
    |> validate_required([:activity_type])
  end

  defp validate_time_zone(changeset) do
    changeset
    |> validate_required([:start_time_zone])
    |> validate_required([:end_time_zone])
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

  defp assemble_date_time(changeset) do
    changeset =
      with %Date{} = start_date <- get_field(changeset, :start_date_virtual),
           %Time{} = start_time <- get_field(changeset, :start_time_virtual),
           %Date{} = end_date <- get_field(changeset, :end_date_virtual),
           %Time{} = end_time <- get_field(changeset, :end_time_virtual),
           timezone when is_binary(timezone) <- get_field(changeset, :start_time_zone),
           {:ok, start_date} <- DateTime.new(start_date, start_time, timezone),
           {:ok, end_date} <- DateTime.new(end_date, end_time, timezone),
           timezone_to_convert = Timex.Timezone.get("UTC", Timex.now()),
           start_date_convert_to_utc = Timex.Timezone.convert(start_date, timezone_to_convert),
           end_date_convert_to_utc = Timex.Timezone.convert(end_date, timezone_to_convert) do
        changeset
        |> put_change(:start_date, start_date_convert_to_utc)
        |> put_change(:end_date, end_date_convert_to_utc)
      else
        _ -> changeset
      end

    changeset
  end

  defp validate_date(changeset) do
    changeset =
      with %DateTime{} = end_date <- get_field(changeset, :end_date),
           %DateTime{} = start_date <- get_field(changeset, :start_date),
           :lt <- DateTime.compare(start_date, end_date) do
        changeset
      else
        nil -> changeset
        _ -> add_error(changeset, :start_date_virtual, "must be before end date")
      end

    changeset
    |> validate_required([:start_date])
  end

  defp validate_website_url_event(changeset) do
    changeset
    |> validate_length(:website_url, max: 160)
  end

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
