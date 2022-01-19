defmodule PastimesRegWeb.OrgUserSessionControllerTest do
  use PastimesRegWeb.ConnCase, async: true

  import PastimesReg.AccountsFixtures

  setup do
    %{org_user: org_user_fixture()}
  end

  describe "GET /org_users/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.org_user_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Sign in"
      assert response =~ "Log in"
      assert response =~ "Register"
      assert response =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn, org_user: org_user} do
      conn = conn |> log_in_org_user(org_user) |> get(Routes.org_user_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /org_users/log_in" do
    test "logs the org_user in", %{conn: conn, org_user: org_user} do
      conn =
        post(conn, Routes.org_user_session_path(conn, :create), %{
          "org_user" => %{"email" => org_user.email, "password" => valid_org_user_password()}
        })

      assert get_session(conn, :org_user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on account page to confirm email of user exist since logged in
      conn = get(conn, "/org_users/account")
      response = html_response(conn, 200)
      assert response =~ org_user.email
    end

    test "logs the org_user in with remember me", %{conn: conn, org_user: org_user} do
      conn =
        post(conn, Routes.org_user_session_path(conn, :create), %{
          "org_user" => %{
            "email" => org_user.email,
            "password" => valid_org_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_pastimes_reg_web_org_user_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the org_user in with return to", %{conn: conn, org_user: org_user} do
      conn =
        conn
        |> init_test_session(org_user_return_to: "/foo/bar")
        |> post(Routes.org_user_session_path(conn, :create), %{
          "org_user" => %{
            "email" => org_user.email,
            "password" => valid_org_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, org_user: org_user} do
      conn =
        post(conn, Routes.org_user_session_path(conn, :create), %{
          "org_user" => %{"email" => org_user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "Invalid email or password"
      assert response =~ "Sign in"
    end
  end

  describe "DELETE /org_users/log_out" do
    test "logs the org_user out", %{conn: conn, org_user: org_user} do
      conn =
        conn |> log_in_org_user(org_user) |> delete(Routes.org_user_session_path(conn, :delete))

      assert redirected_to(conn) == "/"
      refute get_session(conn, :org_user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the org_user is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.org_user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :org_user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
