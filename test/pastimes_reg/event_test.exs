defmodule PastimesReg.EventTest do
  use PastimesReg.DataCase

  import PastimesReg.AccountsFixtures
  alias PastimesReg.Events
  alias PastimesReg.Events.Event
  alias PastimesReg.Events.Category
  alias PastimesReg.Accounts

  import PastimesReg.EventFixtures

  setup do
    {:ok, org_user: org_user_fixture()}
  end

  setup %{org_user: %{id: org_user_id}}, do: {:ok, event: event_fixture(org_user_id)}

  describe "events" do
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

    @valid_attrs_category %{
      categories: [
        %{
          bullet_point_1: "",
          bullet_point_2: "",
          bullet_point_3: "",
          details: "",
          fee: "$1",
          name: "",
          registration_close_date: "",
          spot_availability: "",
          start_date: ""
        },
        %{
          bullet_point_1: "",
          bullet_point_2: "",
          bullet_point_3: "",
          details: "",
          fee: "$1",
          name: "",
          registration_close_date: "",
          spot_availability: "",
          start_date: ""
        },
        %{
          bullet_point_1: "",
          bullet_point_2: "",
          bullet_point_3: "",
          details: "",
          fee: "$1",
          name: "",
          registration_close_date: "",
          spot_availability: "",
          start_date: ""
        }
      ]
    }

    test "list_events/0 returns all events", %{event: event} do
      assert Events.list_events() == [event]
    end

    test "get_events!/1 returns the events with given id", %{event: event} do
      assert Events.get_events!(event.id) == event
    end

    test "create_event/1 with valid data creates a events", %{event: event, org_user: %{id: org_user_id}} do
      assert {:ok, %Event{} = event} = Events.create_event(@valid_attrs, org_user_id)
      assert event.activity_type == "Backcountry Touring"
      assert event.name == "some name_event"
      assert event.address == "some address_location"
      assert event.start_date == ~U[2022-01-05 03:13:00Z]
      assert event.end_date == ~U[2022-02-06 03:13:00Z]

      assert event.confirmation_message_to_participants ==
               "some confirmation_message_to_participants"

      assert event.details == "some details_event"
      assert event.email_address == "email_address@.com"
      assert event.email_notification == true
      assert event.contact_information == true
      assert event.number_of_hours_before_event == "some number_of_hours_before_event"
      assert event.phone_number == "some phone_number"
      assert event.promote_event == true
      assert event.website_url == "some website_url_event"
    end

    test "create_event/1 with invalid data returns error changeset", %{
      org_user: %{id: org_user_id}
    } do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs, org_user_id)
    end

    test "update_events/2 with valid data updates the events", %{
      event: event,
      org_user: %{id: org_user_id}
    } do
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

      assert {:ok, %Event{} = event} = Events.update_events(event, update_attrs, org_user_id)
      assert event.activity_type == "Backcountry Touring"
      assert event.name == "some name_event"
      assert event.address == "some address_location"
      assert event.start_date == ~U[2022-01-05 03:13:00Z]
      assert event.end_date == ~U[2022-02-06 03:13:00Z]

      assert event.confirmation_message_to_participants ==
               "some confirmation_message_to_participants"

      assert event.details == "some details_event"
      assert event.email_address == "email_address@.com"
      assert event.email_notification == true
      assert event.contact_information == true
      assert event.number_of_hours_before_event == "some number_of_hours_before_event"
      assert event.phone_number == "some phone_number"
      assert event.promote_event == true
      assert event.website_url == "some website_url_event"
    end

    test "update_events/2 with invalid data returns error changeset", %{
      event: event,
      org_user: %{id: org_user_id}
    } do
      assert {:error, %Ecto.Changeset{}} =
               Events.update_events(event, @invalid_attrs, org_user_id)

      assert event == Events.get_events!(event.id)
    end

    test "delete_events/1 deletes the events", %{event: event} do
      assert {:ok, %Event{}} = Events.delete_events(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_events!(event.id) end
    end

    test "change_events/1 returns a events changeset", %{event: event} do
      assert %Ecto.Changeset{} = Events.change_events(event)
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
               Events.event_create_form_step_1_changeset(Map.put(@valid_attrs, :start_date, nil))
    end

    test "End date is nil, return valid false" do
      assert %{valid?: true} = Events.event_create_form_step_1_changeset(@valid_attrs)

      assert %{valid?: false} =
               Events.event_create_form_step_1_changeset(Map.put(@valid_attrs, :end_date, nil))
    end

    test "Start date and end date is nil, return valid false" do
      assert %{valid?: true} = Events.event_create_form_step_1_changeset(@valid_attrs)

      assert %{valid?: false} =
               Events.event_create_form_step_1_changeset(Map.put(@valid_attrs, :start_date, nil))

      assert %{valid?: false} =
               Events.event_create_form_step_1_changeset(Map.put(@valid_attrs, :end_date, nil))
    end

    test "deletes a category from the category list by index", %{event: event}  do
      # insert valid data to changset with category attrs
      # clicks the category
      # get/detect what index from the category list
      # delete from list
      # delete mid value
      assert changeset = Events.event_create_form_step_2_changeset(@valid_attrs_category)
      assert changeset = Events.delete_category(changeset, 1)

    end
  end
end
