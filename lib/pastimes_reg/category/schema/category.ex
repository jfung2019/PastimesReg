defmodule PastimesReg.Events.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}
  embedded_schema do
    field :name, :string, default: "General Admission"
    field :bullet_point_1, :string
    field :bullet_point_2, :string
    field :bullet_point_3, :string
    field :details, :string
    field :start_date, :utc_datetime
    field :spot_availability, :string
    field :fee_1, :string
    field :fee_2, :string
    field :fee_3, :string
    field :registration_date_1, :utc_datetime
    field :registration_date_2, :utc_datetime
    field :registration_date_3, :utc_datetime
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [
      :name,
      :bullet_point_1,
      :bullet_point_2,
      :bullet_point_3,
      :details,
      :start_date,
      :spot_availability,
      :fee_1,
      :fee_2,
      :fee_3,
      :registration_date_1,
      :registration_date_2,
      :registration_date_3
    ])
    |> validate_required([:fee_1])
  end
end
