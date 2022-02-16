defmodule PastimesReg.Participants do
  @moduledoc """
  The Participants context.
  """

  import Ecto.Query, warn: false
  alias PastimesReg.Repo

  alias PastimesReg.Participants.Participant
  alias PastimesReg.Events.Event

  @doc """
  Returns the list of participants.

  ## Examples

      iex> list_participants()
      [%Participant{}, ...]

  """
  def list_participants do
    Repo.all(Participant)
  end

  @doc """
  Gets a single participant.

  Raises `Ecto.NoResultsError` if the Participant does not exist.

  ## Examples

      iex> get_participant!(123)
      %Participant{}

      iex> get_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participant!(id), do: Repo.get!(Participant, id)

  def list_participant_by_event_category_name(name, event_id) do
    from(
      p in Participant,
      left_join: e in Event,
      on: p.event_id == ^event_id,
      where: e.name == ^name,
      select: p
    )
    |> Repo.all()
  end

  @doc """
  Creates a participant.

  ## Examples

      iex> create_participant(%{field: value})
      {:ok, %Participant{}}

      iex> create_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participant(attrs \\ %{}, event_id) do
    %Participant{event_id: event_id}
    |> Participant.event_registration_changeset_step_1(attrs)
    |> Repo.insert()
  end

  def event_registration_form_step_init_changeset(%Participant{} = participant, attrs \\ %{}) do
    Participant.event_registration_changeset_step_1(participant, attrs)
  end

  def event_registration_form_step_1_changeset(attrs) do
    %Participant{}
    |> Participant.event_registration_changeset_step_1(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Updates a participant.

  ## Examples

      iex> update_participant(participant, %{field: new_value})
      {:ok, %Participant{}}

      iex> update_participant(participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participant(%Participant{} = participant, attrs) do
    participant
    |> Participant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a participant.

  ## Examples

      iex> delete_participant(participant)
      {:ok, %Participant{}}

      iex> delete_participant(participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_participant(%Participant{} = participant) do
    Repo.delete(participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participant changes.

  ## Examples

      iex> change_participant(participant)
      %Ecto.Changeset{data: %Participant{}}

  """
  def change_participant(%Participant{} = participant, attrs \\ %{}) do
    Participant.changeset(participant, attrs)
  end
end
