defmodule PastimesRegWeb.EventsLiveTest do
  use PastimesRegWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias PastimesReg.Events
  alias PastimesReg.Events.Event

  setup :register_and_log_in_org_user

  test "user can go to events page (homepage) if logged in and see the default state of homepage without events yet",
       %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.live_path(conn, PastimesRegWeb.EventsLive))

    assert html =~ "get started creating your first event"
  end

  test "user can go to events page (homepage) if logged in and see the event/s they've already created",
       %{conn: conn, org_user: org_user} do
    {:ok, _} =
      Events.create_event(
        %{
          activity_type: "Backpacking",
          name: "this is name of event sample",
          address: "address 1 sample",
          start_date: "2022-01-20 16:42:00",
          end_date: "2022-01-20 16:42:00"
        },
        org_user.id
      )

    {:ok, view, html} = live(conn, Routes.live_path(conn, PastimesRegWeb.EventsLive))

    assert html =~ "Your Events"
  end

  test "a link to create an event (if event does not exist yet) that let's them to create new event/s",
       %{conn: conn} do
    {:ok, view, html} = live(conn, Routes.live_path(conn, PastimesRegWeb.EventsLive))

    assert html =~ "<a href=\"/events/new\">"
  end
end
