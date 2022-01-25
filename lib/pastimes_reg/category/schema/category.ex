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
    field :fee, :string
    field :registration_close_date, :utc_datetime
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
      :fee,
      :registration_close_date
    ])
    |> validate_required([:fee])
  end
end
