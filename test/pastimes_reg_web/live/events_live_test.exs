defmodule PastimesRegWeb.EventsLiveTest do
  use PastimesRegWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup :register_and_log_in_org_user

  test "user can go to events page if logged in", %{conn: conn} do
    {:ok, view, html} = live(conn, "/org_users/events")

    assert html =~ "Your Events"
  end


end
