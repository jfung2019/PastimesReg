defmodule PastimesRegWeb.OrgUserRegistrationControllerTest do
  use PastimesRegWeb.ConnCase, async: true

  import PastimesReg.AccountsFixtures

  describe "GET /org_users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.live_path(conn, PastimesRegWeb.RegisterLive))
      response = html_response(conn, 200)
      assert response =~ "Create Account"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn =
        conn
        |> log_in_org_user(org_user_fixture())
        |> get(Routes.live_path(conn, PastimesRegWeb.RegisterLive))

      assert redirected_to(conn) == "/"
    end
  end

  # describe "POST /org_users/register" do
  #   @tag :capture_log
  #   test "creates account and logs the org_user in", %{conn: conn} do
  #     email = unique_org_user_email()

  #     conn =
  #       post(conn, Routes.live_path(conn, PastimesRegWeb.RegisterLive), %{
  #         "org_user" => valid_org_user_attributes(email: email)
  #       })

  #     assert get_session(conn, :org_user_token)
  #     assert redirected_to(conn) == "/"

  #     # Now do a logged in request and assert on the menu
  #     conn = get(conn, "/")
  #     response = html_response(conn, 200)
  #     assert response =~ email
  #     assert response =~ "Settings</a>"
  #     assert response =~ "Log out</a>"
  #   end

  #   test "render errors for invalid data", %{conn: conn} do
  #     conn =
  #       post(conn, Routes.org_user_registration_path(conn, :create), %{
  #         "org_user" => %{"email" => "with spaces", "password" => "too short"}
  #       })

  #     response = html_response(conn, 200)
  #     assert response =~ "<h1>Register</h1>"
  #     assert response =~ "must have the @ sign and no spaces"
  #     assert response =~ "should be at least 12 character"
  #   end
  # end
end
