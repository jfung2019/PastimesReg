defmodule PastimesRegWeb.OrgUserConfirmationController do
  use PastimesRegWeb, :controller

  alias PastimesReg.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"org_user" => %{"email" => email}}) do
    if org_user = Accounts.get_org_user_by_email(email) do
      Accounts.deliver_org_user_confirmation_instructions(
        org_user,
        &Routes.org_user_confirmation_url(conn, :edit, &1)
      )
    end

    # In order to prevent user enumeration attacks, regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the org_user after confirmation to avoid a
  # leaked token giving the org_user access to the account.
  def update(conn, %{"token" => token}) do
    case Accounts.confirm_org_user(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Org user confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current org_user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the org_user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_org_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Org user confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
