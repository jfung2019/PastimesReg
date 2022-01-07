defmodule PastimesRegWeb.RegisterLiveTest do
  use PastimesRegWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "user can go to registration page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/org_users/register")

    assert html =~ "Create your Account"
    assert html =~ "Create Account"
  end

  test "user can register and pass from step 1 to 3 and submit", %{conn: conn} do
    {:ok, view, html} = live(conn, "/org_users/register")

    # step 1
    html =
      view
      |> form("#register",
        org_user: %{
          first_name: "testingtesting@testing.com",
          last_name: "testingtesting@testing.com",
          email: "testingtesting@testing.com",
          email_confirmation: "testingtesting@testing.com",
          password: "testingtesting@testing.com",
          password_confirmation: "testingtesting@testing.com"
        }
      )
      |> render_submit()

    assert html =~ "Add Org Information"

    # step 2
    html =
      view
      |> form("#register",
        org_user: %{
          organization: "testingtesting@testing.com",
          address_line_1: "testingtesting testing.com",
          address_line_2: "testingtesting testing.com",
          city: "testingtesting@testing.com",
          state: "testingtesting@testing.com",
          zip: "testingtesting@testing.com",
          country: "testingtesting@testing.com",
          phone: "testingtesting@testing.com"
        }
      )
      |> render_submit()

    assert html =~ "Add Bank Information"

    # step 3
    html =
      view
      |> form("#register",
        org_user: %{
          routing_number: "testingtesting@testing.com",
          account_number: "testingtestingtesting.com",
          account_number_confirmation: "testingtestingtesting.com"
        }
      )
      |> render_submit()

      assert_redirected(view, Routes.org_user_session_path(conn, :new))
  end



  test "user registration with error data: does not match confirmation for step 1", %{conn: conn} do
    {:ok, view, html} = live(conn, "/org_users/register")

    # step 1
    html =
      view
      |> form("#register",
        org_user: %{
          first_name: "testingtesting@testing.com",
          last_name: "testingtesting@testing.com",
          email: "testingtesting@testing.com",
          email_confirmation: "testingtesting@testing.com",
          password: "testingtesting@testing.com",
          password_confirmation: "testingtesting@ testing.com"
        }
      )
      |> render_change()

    assert html =~ "does not match confirmation"
  end


  test "user registration with error data: cant be blank step 1", %{conn: conn} do
    {:ok, view, html} = live(conn, "/org_users/register")

    # step 1
    html =
      view
      |> form("#register",
        org_user: %{
          first_name: "",
          last_name: "testingtesting@testing.com",
          email: "testingtesting@testing.com",
          email_confirmation: "testingtesting@testing.com",
          password: "testingtesting@testing.com",
          password_confirmation: "testingtesting@ testing.com"
        }
      )
      |> render_change()

    assert html =~ "can&#39;t be blank"
  end

  # test "user can register step 2", %{conn: conn} do
  #   {:ok, view, html} = live(conn, "/org_users/register")

  #   html =
  #     view
  #     |> form("#register",
  #       org_user: %{
  #         organization: "testingtesting@testing.com",
  #         address_line_1: "testingtesting testing.com",
  #         address_line_2: "testingtesting testing.com",
  #         city: "testingtesting@testing.com",
  #         state: "testingtesting@testing.com",
  #         zip: "testingtesting@testing.com",
  #         country: "testingtesting@testing.com",
  #         phone: "testingtesting@testing.com"
  #       }
  #     )
  #     |> render_submit()

  #   assert html =~ "Add Bank Information"
  # end
end
