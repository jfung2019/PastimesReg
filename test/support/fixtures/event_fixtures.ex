defmodule PastimesReg.EventFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PastimesReg.Events` context.
  """

  @doc """
  Generate a events.
  """
  def event_fixture(attrs \\ %{}, org_user_id) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        activity_type: "Badminton",
        address: "some address_location",
        confirmation_message_to_participants: "some confirmation_message_to_participants",
        cover_photo: "some cover_photo",
        details: "some details_event",
        categories: [
          %{
            bullet_point_1: "",
            bullet_point_2: "",
            bullet_point_3: "",
            details: "",
            fee_1: "$1",
            name: "",
            registration_date_1: "",
            spot_availability: "",
            start_date: ""
          }
        ],
        email_address: "some email_address",
        email_notification: true,
        contact_information: true,
        name: "some name_event",
        phone_number: "some phone_number",
        promote_event: true,
        website_url: "some website_url_event",
        timezone: "Africa/Accra",
        start_date_virtual: ~D[2022-02-11],
        end_date_virtual: ~D[2022-02-12],
        start_time_virtual: ~T[19:24:00],
        end_time_virtual: ~T[19:24:00],
        strict: false,
        flexible: true,
        use_org_logo: true
      })
      |> PastimesReg.Events.create_event(org_user_id)

    event
  end
end
