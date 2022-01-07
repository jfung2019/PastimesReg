defmodule PastimesRegWeb.CreateEventsLiveTest do
  use PastimesRegWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup :register_and_log_in_org_user

  test "user can go to create-events page if logged in", %{conn: conn} do
    {:ok, view, html} = live(conn, "/org_users/create-events")

    assert html =~ "Create your Event"
  end
end
