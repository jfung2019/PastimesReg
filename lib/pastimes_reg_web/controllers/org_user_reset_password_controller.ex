defmodule PastimesRegWeb.OrgUserResetPasswordController do
  use PastimesRegWeb, :controller

  alias PastimesReg.Accounts

  plug :get_org_user_by_reset_password_token when action in [:edit, :update]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"org_user" => %{"email" => email}}) do
    if org_user = Accounts.get_org_user_by_email(email) do
      Accounts.deliver_org_user_reset_password_instructions(
        org_user,
        &Routes.org_user_reset_password_url(conn, :edit, &1)
      )
    end

    # In order to prevent user enumeration attacks, regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system, you will receive instructions to reset your password shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, _params) do
    render(conn, "edit.html", changeset: Accounts.change_org_user_password(conn.assigns.org_user))
  end

  # Do not log in the org_user after reset password to avoid a
  # leaked token giving the org_user access to the account.
  def update(conn, %{"org_user" => org_user_params}) do
    case Accounts.reset_org_user_password(conn.assigns.org_user, org_user_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password reset successfully.")
        |> redirect(to: Routes.org_user_session_path(conn, :new))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  defp get_org_user_by_reset_password_token(conn, _opts) do
    %{"token" => token} = conn.params

    if org_user = Accounts.get_org_user_by_reset_password_token(token) do
      conn |> assign(:org_user, org_user) |> assign(:token, token)
    else
      conn
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
