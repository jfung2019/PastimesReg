defmodule PastimesRegWeb.OrgUserConfirmationControllerTest do
  use PastimesRegWeb.ConnCase, async: true

  alias PastimesReg.Accounts
  alias PastimesReg.Repo
  import PastimesReg.AccountsFixtures

  setup do
    %{org_user: org_user_fixture()}
  end

  describe "GET /org_users/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.org_user_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /org_users/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, org_user: org_user} do
      conn =
        post(conn, Routes.org_user_confirmation_path(conn, :create), %{
          "org_user" => %{"email" => org_user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.OrgUserToken, org_user_id: org_user.id).context == "confirm"
    end

    test "does not send confirmation token if Org user is confirmed", %{conn: conn, org_user: org_user} do
      Repo.update!(Accounts.OrgUser.confirm_changeset(org_user))

      conn =
        post(conn, Routes.org_user_confirmation_path(conn, :create), %{
          "org_user" => %{"email" => org_user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Accounts.OrgUserToken, org_user_id: org_user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.org_user_confirmation_path(conn, :create), %{
          "org_user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.OrgUserToken) == []
    end
  end

  describe "GET /org_users/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.org_user_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.org_user_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /org_users/confirm/:token" do
    test "confirms the given token once", %{conn: conn, org_user: org_user} do
      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_confirmation_instructions(org_user, url)
        end)

      conn = post(conn, Routes.org_user_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Org user confirmed successfully"
      assert Accounts.get_org_user!(org_user.id).confirmed_at
      refute get_session(conn, :org_user_token)
      assert Repo.all(Accounts.OrgUserToken) == []

      # When not logged in
      conn = post(conn, Routes.org_user_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Org user confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_org_user(org_user)
        |> post(Routes.org_user_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, org_user: org_user} do
      conn = post(conn, Routes.org_user_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Org user confirmation link is invalid or it has expired"
      refute Accounts.get_org_user!(org_user.id).confirmed_at
    end
  end
end
