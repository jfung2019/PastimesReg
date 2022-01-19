defmodule PastimesReg.EventTest do
  use PastimesReg.DataCase

  alias PastimesReg.Event
  import PastimesReg.AccountsFixtures

  setup do
    {:ok, org_user: org_user_fixture()}
  end

  describe "events" do
    alias PastimesReg.Events.Event
    alias PastimesReg.Events
    alias PastimesReg.Accounts

    import PastimesReg.AccountsFixtures
    import PastimesReg.EventFixtures

    @invalid_attrs %{
      activity_type: nil,
      address: nil,
      confirmation_message_to_participants: nil,
      cover_photo: nil,
      details: nil,
      email_address: nil,
      email_notification: nil,
      end_date: nil,
      contact_information: nil,
      name: nil,
      number_of_hours_before_event: nil,
      phone_number: nil,
      promote_event: nil,
      start_date: nil,
      website_url: nil
    }

    @valid_attrs %{
      activity_type: "Backcountry Touring",
      name: "some name_event",
      address: "some address_location",
      start_date: ~U[2022-01-05 03:13:00Z],
      end_date: ~U[2022-02-06 03:13:00Z],
      confirmation_message_to_participants: "some confirmation_message_to_participants",
      details: "some details_event",
      email_address: "email_address@.com",
      email_notification: true,
      contact_information: true,
      number_of_hours_before_event: "some number_of_hours_before_event",
      phone_number: "some phone_number",
      promote_event: true,
      website_url: "some website_url_event"
    }

    test "list_events/0 returns all events", %{org_user: %{id: org_user_id}} do
      events = events_fixture(org_user_id)
      assert Events.list_events_by_org_user_id(org_user_id) == [events]
    end

    test "get_events!/1 returns the events with given id", %{org_user: %{id: org_user_id}} do
      events = events_fixture(org_user_id)
      assert Events.get_events!(events.id) == events
    end

    test "create_event/1 with valid data creates a events", %{org_user: %{id: org_user_id}} do
      assert {:ok, %Event{} = events} = Events.create_event(@valid_attrs, org_user_id)
      assert events.activity_type == "Backcountry Touring"
      assert events.name == "some name_event"
      assert events.address == "some address_location"
      assert events.start_date == ~U[2022-01-05 03:13:00Z]
      assert events.end_date == ~U[2022-02-06 03:13:00Z]

      assert events.confirmation_message_to_participants ==
               "some confirmation_message_to_participants"

      assert events.details == "some details_event"
      assert events.email_address == "email_address@.com"
      assert events.email_notification == true
      assert events.contact_information == true
      assert events.number_of_hours_before_event == "some number_of_hours_before_event"
      assert events.phone_number == "some phone_number"
      assert events.promote_event == true
      assert events.website_url == "some website_url_event"
    end

    test "create_event/1 with invalid data returns error changeset", %{
      org_user: %{id: org_user_id}
    } do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs, org_user_id)
    end

    test "update_events/2 with valid data updates the events", %{org_user: %{id: org_user_id}} do
      events = events_fixture(org_user_id)

      update_attrs = %{
        activity_type: "Backcountry Touring",
        name: "some name_event",
        address: "some address_location",
        start_date: ~U[2022-01-05 03:13:00Z],
        end_date: ~U[2022-02-06 03:13:00Z],
        confirmation_message_to_participants: "some confirmation_message_to_participants",
        details: "some details_event",
        email_address: "email_address@.com",
        email_notification: true,
        contact_information: true,
        number_of_hours_before_event: "some number_of_hours_before_event",
        phone_number: "some phone_number",
        promote_event: true,
        website_url: "some website_url_event"
      }

      assert {:ok, %Event{} = events} = Events.update_events(events, update_attrs, org_user_id)
      assert events.activity_type == "Backcountry Touring"
      assert events.name == "some name_event"
      assert events.address == "some address_location"
      assert events.start_date == ~U[2022-01-05 03:13:00Z]
      assert events.end_date == ~U[2022-02-06 03:13:00Z]

      assert events.confirmation_message_to_participants ==
               "some confirmation_message_to_participants"

      assert events.details == "some details_event"
      assert events.email_address == "email_address@.com"
      assert events.email_notification == true
      assert events.contact_information == true
      assert events.number_of_hours_before_event == "some number_of_hours_before_event"
      assert events.phone_number == "some phone_number"
      assert events.promote_event == true
      assert events.website_url == "some website_url_event"
    end

    test "update_events/2 with invalid data returns error changeset", %{
      org_user: %{id: org_user_id}
    } do
      events = events_fixture(org_user_id)

      assert {:error, %Ecto.Changeset{}} =
               Events.update_events(events, @invalid_attrs, org_user_id)

      assert events == Events.get_events!(events.id)
    end

    test "delete_events/1 deletes the events", %{org_user: %{id: org_user_id}} do
      events = events_fixture(org_user_id)
      assert {:ok, %Event{}} = Events.delete_events(events)
      assert_raise Ecto.NoResultsError, fn -> Events.get_events!(events.id) end
    end

    test "change_events/1 returns a events changeset", %{org_user: %{id: org_user_id}} do
      events = events_fixture(org_user_id)
      assert %Ecto.Changeset{} = Events.change_events(events)
    end

    test "start date must be before end date" do
      # enter valid changeset
      assert %{valid?: true} = Events.event_create_form_step_1_changeset(@valid_attrs)
      # turn to invalid end date before the start date
      assert %{valid?: false, errors: [start_date: {"must be before end date", []}]} =
               Events.event_create_form_step_1_changeset(
                 Map.put(@valid_attrs, :end_date, ~U[2022-01-01 03:13:00Z])
               )
    end

    test "Start date is nil, return valid false" do
      assert %{valid?: true} = Events.event_create_form_step_1_changeset(@valid_attrs)
      assert %{valid?: false} =
               Events.event_create_form_step_1_changeset(
                 Map.put(@valid_attrs, :start_date, nil)
               )
    end

    test "End date is nil, return valid false" do
      assert %{valid?: true} = Events.event_create_form_step_1_changeset(@valid_attrs)
      assert %{valid?: false} =
               Events.event_create_form_step_1_changeset(
                 Map.put(@valid_attrs, :end_date, nil)
               )
    end

    test "Start date and end date is nil, return valid false" do
      assert %{valid?: true} = Events.event_create_form_step_1_changeset(@valid_attrs)
      assert %{valid?: false} =
               Events.event_create_form_step_1_changeset(
                 Map.put(@valid_attrs, :start_date, nil)
               )
      assert %{valid?: false} =
                Events.event_create_form_step_1_changeset(
                  Map.put(@valid_attrs, :end_date, nil)
                )
    end
  end
end
