defmodule PastimesRegWeb.OrgUserRegistrationController do
  use PastimesRegWeb, :controller

  alias PastimesReg.Accounts
  alias PastimesReg.Accounts.OrgUser
  alias PastimesRegWeb.OrgUserAuth

  def new(conn, _params) do
    changeset = Accounts.change_org_user_registration(%OrgUser{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"org_user" => org_user_params}) do
    case Accounts.register_org_user(org_user_params) do
      {:ok, org_user} ->
        {:ok, _} =
          Accounts.deliver_org_user_confirmation_instructions(
            org_user,
            &Routes.org_user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Organizer user created successfully.")
        |> OrgUserAuth.log_in_org_user(org_user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
