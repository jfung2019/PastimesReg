defmodule PastimesRegWeb.OrgUserResetPasswordControllerTest do
  use PastimesRegWeb.ConnCase, async: true

  alias PastimesReg.Accounts
  alias PastimesReg.Repo
  import PastimesReg.AccountsFixtures

  setup do
    %{org_user: org_user_fixture()}
  end

  describe "GET /org_users/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.org_user_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /org_users/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, org_user: org_user} do
      conn =
        post(conn, Routes.org_user_reset_password_path(conn, :create), %{
          "org_user" => %{"email" => org_user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.OrgUserToken, org_user_id: org_user.id).context == "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.org_user_reset_password_path(conn, :create), %{
          "org_user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.OrgUserToken) == []
    end
  end

  describe "GET /org_users/reset_password/:token" do
    setup %{org_user: org_user} do
      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_reset_password_instructions(org_user, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.org_user_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.org_user_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /org_users/reset_password/:token" do
    setup %{org_user: org_user} do
      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_reset_password_instructions(org_user, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, org_user: org_user, token: token} do
      conn =
        put(conn, Routes.org_user_reset_password_path(conn, :update, token), %{
          "org_user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.org_user_session_path(conn, :new)
      refute get_session(conn, :org_user_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"
      assert Accounts.get_org_user_by_email_and_password(org_user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.org_user_reset_password_path(conn, :update, token), %{
          "org_user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.org_user_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
