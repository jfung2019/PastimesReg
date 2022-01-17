defmodule PastimesReg.EventTest do
  use PastimesReg.DataCase

  alias PastimesReg.Event

  describe "events" do
    alias PastimesReg.Events.Event

    import PastimesReg.EventFixtures

    @invalid_attrs %{
      activity_type: nil,
      address_location: nil,
      confirmation_message_to_participants: nil,
      cover_photo: nil,
      details_event: nil,
      email_address: nil,
      email_notification: nil,
      end_date: nil,
      contact_information: nil,
      name_event: nil,
      number_of_hours_before_event: nil,
      phone_number: nil,
      promote_event: nil,
      start_date: nil,
      website_url_event: nil
    }

    test "list_events/0 returns all events" do
      events = events_fixture()
      assert Event.list_events() == [events]
    end

    test "get_events!/1 returns the events with given id" do
      events = events_fixture()
      assert Event.get_events!(events.id) == events
    end

    test "create_event/1 with valid data creates a events" do
      valid_attrs = %{
        activity_type: "some activity_type",
        address_location: "some address_location",
        confirmation_message_to_participants: "some confirmation_message_to_participants",
        cover_photo: "some cover_photo",
        details_event: "some details_event",
        email_address: "some email_address",
        email_notification: true,
        end_date: ~U[2022-01-05 03:13:00Z],
        contact_information: true,
        name_event: "some name_event",
        number_of_hours_before_event: "some number_of_hours_before_event",
        phone_number: "some phone_number",
        promote_event: true,
        start_date: ~U[2022-01-05 03:13:00Z],
        website_url_event: "some website_url_event"
      }

      assert {:ok, %Events{} = events} = Event.create_event(valid_attrs)
      assert events.activity_type == "some activity_type"
      assert events.address_location == "some address_location"

      assert events.confirmation_message_to_participants ==
               "some confirmation_message_to_participants"

      assert events.cover_photo == "some cover_photo"
      assert events.details_event == "some details_event"
      assert events.email_address == "some email_address"
      assert events.email_notification == true
      assert events.end_date == ~U[2022-01-05 03:13:00Z]
      assert events.contact_information == true
      assert events.name_event == "some name_event"
      assert events.number_of_hours_before_event == "some number_of_hours_before_event"
      assert events.phone_number == "some phone_number"
      assert events.promote_event == true
      assert events.start_date == ~U[2022-01-05 03:13:00Z]
      assert events.website_url_event == "some website_url_event"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Event.create_event(@invalid_attrs)
    end

    test "update_events/2 with valid data updates the events" do
      events = events_fixture()

      update_attrs = %{
        activity_type: "some updated activity_type",
        address_location: "some updated address_location",
        confirmation_message_to_participants: "some updated confirmation_message_to_participants",
        cover_photo: "some updated cover_photo",
        details_event: "some updated details_event",
        email_address: "some updated email_address",
        email_notification: false,
        end_date: ~U[2022-01-06 03:13:00Z],
        contact_information: false,
        name_event: "some updated name_event",
        number_of_hours_before_event: "some updated number_of_hours_before_event",
        phone_number: "some updated phone_number",
        promote_event: false,
        start_date: ~U[2022-01-06 03:13:00Z],
        website_url_event: "some updated website_url_event"
      }

      assert {:ok, %Events{} = events} = Event.update_events(events, update_attrs)
      assert events.activity_type == "some updated activity_type"
      assert events.address_location == "some updated address_location"

      assert events.confirmation_message_to_participants ==
               "some updated confirmation_message_to_participants"

      assert events.cover_photo == "some updated cover_photo"
      assert events.details_event == "some updated details_event"
      assert events.email_address == "some updated email_address"
      assert events.email_notification == false
      assert events.end_date == ~U[2022-01-06 03:13:00Z]
      assert events.contact_information == false
      assert events.name_event == "some updated name_event"
      assert events.number_of_hours_before_event == "some updated number_of_hours_before_event"
      assert events.phone_number == "some updated phone_number"
      assert events.promote_event == false
      assert events.start_date == ~U[2022-01-06 03:13:00Z]
      assert events.website_url_event == "some updated website_url_event"
    end

    test "update_events/2 with invalid data returns error changeset" do
      events = events_fixture()
      assert {:error, %Ecto.Changeset{}} = Event.update_events(events, @invalid_attrs)
      assert events == Event.get_events!(events.id)
    end

    test "delete_events/1 deletes the events" do
      events = events_fixture()
      assert {:ok, %Events{}} = Event.delete_events(events)
      assert_raise Ecto.NoResultsError, fn -> Event.get_events!(events.id) end
    end

    test "change_events/1 returns a events changeset" do
      events = events_fixture()
      assert %Ecto.Changeset{} = Event.change_events(events)
    end
  end
end
