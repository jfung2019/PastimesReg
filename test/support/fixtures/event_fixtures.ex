defmodule PastimesReg.EventFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PastimesReg.Event` context.
  """

  @doc """
  Generate a events.
  """
  def events_fixture(attrs \\ %{}) do
    {:ok, events} =
      attrs
      |> Enum.into(%{
        activity_type: "some activity_type",
        address_location: "some address_location",
        confirmation_message_to_participants: "some confirmation_message_to_participants",
        cover_photo: "some cover_photo",
        details_event: "some details_event",
        email_adress: "some email_adress",
        email_notification: true,
        end_date: ~U[2022-01-05 03:13:00Z],
        event_contact_information: true,
        name_event: "some name_event",
        number_of_hours_before_event: "some number_of_hours_before_event",
        phone_number: "some phone_number",
        promote_event: true,
        start_date: ~U[2022-01-05 03:13:00Z],
        website_url_event: "some website_url_event"
      })
      |> PastimesReg.Event.create_events()

    events
  end
end
