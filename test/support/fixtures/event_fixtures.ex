defmodule PastimesReg.EventFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PastimesReg.Events` context.
  """

  @doc """
  Generate a events.
  """
  def events_fixture(attrs \\ %{}, org_user_id) do
    {:ok, events} =
      attrs
      |> Enum.into(%{
        activity_type: "Badminton",
        address: "some address_location",
        confirmation_message_to_participants: "some confirmation_message_to_participants",
        cover_photo: "some cover_photo",
        details: "some details_event",
        email_address: "some email_address",
        email_notification: true,
        end_date: "2022-01-05 03:13:00",
        contact_information: true,
        name: "some name_event",
        number_of_hours_before_event: "some number_of_hours_before_event",
        phone_number: "some phone_number",
        promote_event: true,
        start_date: "2022-01-05 03:13:00",
        website_url: "some website_url_event"
      })
      |> PastimesReg.Events.create_event(org_user_id)

    events
  end
end
