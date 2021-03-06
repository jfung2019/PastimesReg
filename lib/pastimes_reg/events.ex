defmodule PastimesReg.Events do
  @moduledoc """
  The Event context.
  """

  import Ecto.Query, warn: false
  alias PastimesReg.Repo

  alias PastimesReg.Events.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Events{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @spec list_upcoming_events_by_org_user_id(integer()) :: [Event.t()]
  def list_upcoming_events_by_org_user_id(org_user_id) do
    from(
      e in Event,
      where: e.org_user_id == ^org_user_id and fragment("? > now()", e.start_date)
    )
    |> Repo.all()
  end

  @spec list_past_events_by_org_user_id(integer()) :: [Event.t()]
  def list_past_events_by_org_user_id(org_user_id) do
    from(
      e in Event,
      where: e.org_user_id == ^org_user_id and fragment("? < now()", e.start_date)
    )
    |> Repo.all()
  end

  @spec list_events_by_org_user_id(integer()) :: [Event.t()]
  def list_events_by_org_user_id(org_user_id) do
    from(
      e in Event,
      where: e.org_user_id == ^org_user_id
    )
    |> Repo.all()
  end

  @doc """
  Gets a single events.

  Raises `Ecto.NoResultsError` if the Events does not exist.

  ## Examples

      iex> get_events!(123)
      %Events{}

      iex> get_events!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id) |> Repo.preload([:org_user])

  @spec create_event(
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any},
          any
        ) :: any
  @doc """
  Creates a events.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Events{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}, org_user_id) do
    %Event{org_user_id: org_user_id}
    |> Event.event_create_changeset_step_1(attrs)
    |> Event.event_create_changeset_step_2(attrs)
    |> Event.event_create_changeset_step_3(attrs)
    |> Repo.insert()
  end

  @spec append_category(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def append_category(changeset) do
    Event.append_category_to_changeset(changeset)
  end

  def delete_category(changeset, category_index) do
    Event.delete_category_from_changeset_list(changeset, category_index)
  end

  def event_create_form_step_init_changeset(%Event{} = event, attrs \\ %{}) do
    Event.event_create_changeset_step_1(event, attrs)
  end

  def event_create_form_step_1_changeset(attrs) do
    %Event{}
    |> Event.event_create_changeset_step_1(attrs)
    |> Map.put(:action, :insert)
  end

  def event_create_form_step_2_changeset(attrs) do
    %Event{}
    |> Event.event_create_changeset_step_2(attrs)
    |> Map.put(:action, :insert)
  end

  def event_create_form_step_3_changeset(attrs) do
    %Event{}
    |> Event.event_create_changeset_step_3(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Updates a events.

  ## Examples

      iex> update_events(events, %{field: new_value})
      {:ok, %Events{}}

      iex> update_events(events, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_events(%Event{org_user_id: org_user_id} = event, attrs, org_user_id) do
    event
    |> Event.event_create_changeset_step_1(attrs)
    |> Event.event_create_changeset_step_2(attrs)
    |> Event.event_create_changeset_step_3(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking events changes.

  ## Examples

      iex> change_events(events)
      %Ecto.Changeset{data: %Events{}}

  """
  def change_events(%Event{} = event, attrs \\ %{}) do
    Event.event_create_changeset_step_1(event, attrs)
    Event.event_create_changeset_step_2(event, attrs)
    Event.event_create_changeset_step_3(event, attrs)
  end
end
