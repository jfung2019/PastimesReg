defmodule PastimesRegWeb.OrgUserAuthTest do
  use PastimesRegWeb.ConnCase, async: true

  alias PastimesReg.Accounts
  alias PastimesRegWeb.OrgUserAuth
  import PastimesReg.AccountsFixtures

  @remember_me_cookie "_pastimes_reg_web_org_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, PastimesRegWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{org_user: org_user_fixture(), conn: conn}
  end

  describe "log_in_org_user/3" do
    test "stores the org_user token in the session", %{conn: conn, org_user: org_user} do
      conn = OrgUserAuth.log_in_org_user(conn, org_user)
      assert token = get_session(conn, :org_user_token)
      assert get_session(conn, :live_socket_id) == "org_users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Accounts.get_org_user_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, org_user: org_user} do
      conn = conn |> put_session(:to_be_removed, "value") |> OrgUserAuth.log_in_org_user(org_user)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, org_user: org_user} do
      conn = conn |> put_session(:org_user_return_to, "/hello") |> OrgUserAuth.log_in_org_user(org_user)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, org_user: org_user} do
      conn = conn |> fetch_cookies() |> OrgUserAuth.log_in_org_user(org_user, %{"remember_me" => "true"})
      assert get_session(conn, :org_user_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :org_user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_org_user/1" do
    test "erases session and cookies", %{conn: conn, org_user: org_user} do
      org_user_token = Accounts.generate_org_user_session_token(org_user)

      conn =
        conn
        |> put_session(:org_user_token, org_user_token)
        |> put_req_cookie(@remember_me_cookie, org_user_token)
        |> fetch_cookies()
        |> OrgUserAuth.log_out_org_user()

      refute get_session(conn, :org_user_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Accounts.get_org_user_by_session_token(org_user_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "org_users_sessions:abcdef-token"
      PastimesRegWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> OrgUserAuth.log_out_org_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if org_user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> OrgUserAuth.log_out_org_user()
      refute get_session(conn, :org_user_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_org_user/2" do
    test "authenticates org_user from session", %{conn: conn, org_user: org_user} do
      org_user_token = Accounts.generate_org_user_session_token(org_user)
      conn = conn |> put_session(:org_user_token, org_user_token) |> OrgUserAuth.fetch_current_org_user([])
      assert conn.assigns.current_org_user.id == org_user.id
    end

    test "authenticates org_user from cookies", %{conn: conn, org_user: org_user} do
      logged_in_conn =
        conn |> fetch_cookies() |> OrgUserAuth.log_in_org_user(org_user, %{"remember_me" => "true"})

      org_user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> OrgUserAuth.fetch_current_org_user([])

      assert get_session(conn, :org_user_token) == org_user_token
      assert conn.assigns.current_org_user.id == org_user.id
    end

    test "does not authenticate if data is missing", %{conn: conn, org_user: org_user} do
      _ = Accounts.generate_org_user_session_token(org_user)
      conn = OrgUserAuth.fetch_current_org_user(conn, [])
      refute get_session(conn, :org_user_token)
      refute conn.assigns.current_org_user
    end
  end

  describe "redirect_if_org_user_is_authenticated/2" do
    test "redirects if org_user is authenticated", %{conn: conn, org_user: org_user} do
      conn = conn |> assign(:current_org_user, org_user) |> OrgUserAuth.redirect_if_org_user_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if org_user is not authenticated", %{conn: conn} do
      conn = OrgUserAuth.redirect_if_org_user_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_org_user/2" do
    test "redirects if org_user is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> OrgUserAuth.require_authenticated_org_user([])
      assert conn.halted
      assert redirected_to(conn) == Routes.org_user_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> OrgUserAuth.require_authenticated_org_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :org_user_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> OrgUserAuth.require_authenticated_org_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :org_user_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> OrgUserAuth.require_authenticated_org_user([])

      assert halted_conn.halted
      refute get_session(halted_conn, :org_user_return_to)
    end

    test "does not redirect if org_user is authenticated", %{conn: conn, org_user: org_user} do
      conn = conn |> assign(:current_org_user, org_user) |> OrgUserAuth.require_authenticated_org_user([])
      refute conn.halted
      refute conn.status
    end
  end
end
