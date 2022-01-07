defmodule PastimesReg.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}
  embedded_schema do
    field(:expires_in, :integer)
    field(:extra, :boolean)
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:size, :color])
    |> validate_required([])
  end
end
