defmodule PastimesRegWeb.OrgUserSettingsController do
  use PastimesRegWeb, :controller

  alias PastimesReg.Accounts
  alias PastimesRegWeb.OrgUserAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "org_user" => org_user_params} = params
    org_user = conn.assigns.current_org_user

    case Accounts.apply_org_user_email(org_user, password, org_user_params) do
      {:ok, applied_org_user} ->
        Accounts.deliver_update_email_instructions(
          applied_org_user,
          org_user.email,
          &Routes.org_user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.org_user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "org_user" => org_user_params} = params
    org_user = conn.assigns.current_org_user

    case Accounts.update_org_user_password(org_user, password, org_user_params) do
      {:ok, org_user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:org_user_return_to, Routes.org_user_settings_path(conn, :edit))
        |> OrgUserAuth.log_in_org_user(org_user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_org_user_email(conn.assigns.current_org_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.org_user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.org_user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    org_user = conn.assigns.current_org_user

    conn
    |> assign(:email_changeset, Accounts.change_org_user_email(org_user))
    |> assign(:password_changeset, Accounts.change_org_user_password(org_user))
  end
end
