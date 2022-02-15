defmodule PastimesReg.ParticipantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PastimesReg.Participants` context.
  """

  @doc """
  Generate a participant.
  """
  def participant_fixture(attrs \\ %{}) do
    {:ok, participant} =
      attrs
      |> Enum.into(%{
        address_1: "some address_1",
        address_2: "some address_2",
        city: "some city",
        country: "some country",
        dob: "some dob",
        email_address: "some email_address",
        email_address_confirmation: "some email_address_confirmation",
        emergency_contact_name: "some emergency_contact_name",
        emergency_contact_number: "some emergency_contact_number",
        first_name: "some first_name",
        gender: "some gender",
        last_name: "some last_name",
        phone_number: "some phone_number",
        state: "some state",
        waiver_initials: "some waiver_initials",
        zip: "some zip"
      })
      |> PastimesReg.Participants.create_participant()

    participant
  end
end
