defmodule PastimesRegWeb.CreateEventsLiveTest do
  use PastimesRegWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup :register_and_log_in_org_user

  # :activity_type,
  # :name,
  # :address,
  # :start_date,
  # :end_date,
  # :details,
  # :website_url,
  # :cover_photo,

  # :name,
  # :bullet_point_1,
  # :bullet_point_2,
  # :bullet_point_3,
  # :details,
  # :start_date,
  # :spot_availability,
  # :fee,
  # :registration_close_date

  # :confirmation_message_to_participants,
  # :contact_information,
  # :email_address,
  # :phone_number,
  # :promote_event,
  # :number_of_hours_before_event,
  # :email_notification

  test "user can go to create-events page if logged in", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.live_path(conn, PastimesRegWeb.CreateEventsLive))

    assert html =~ "Create your Event"
  end

  test "user can create event from step 1 to 3 and submit", %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.live_path(conn, PastimesRegWeb.CreateEventsLive))

    # step 1
    html =
      view
      |> form("#create-event",
        event: %{
          activity_type: "Basketball",
          name: "event sample name",
          address: "event address sample",
          start_date: "2022-01-12 17:49:00",
          end_date: "2022-01-12 17:51:00"
        }
      )
      |> render_submit()

    assert html =~ "Category Information"

    # step 2
    html =
      view
      |> form("#create-event",
        event: %{
          categories: %{
            "0": %{
              fee: "$1"
            }
          }
        }
      )
      |> render_submit()

    assert html =~ "Other Event Information"

    # step 3
    html =
      view
      |> form("#create-event",
        event: %{
          confirmation_message_to_participants: "you have successfully registered for this event"
        }
      )
      |> render_submit()

    assert_redirected(view, Routes.live_path(conn, PastimesRegWeb.CreateEventsLive))
  end
end
