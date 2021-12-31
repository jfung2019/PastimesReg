defmodule PastimesRegWeb.OrgUserSessionController do
  use PastimesRegWeb, :controller

  alias PastimesReg.Accounts
  alias PastimesRegWeb.OrgUserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"org_user" => org_user_params}) do
    %{"email" => email, "password" => password} = org_user_params

    if org_user = Accounts.get_org_user_by_email_and_password(email, password) do
      OrgUserAuth.log_in_org_user(conn, org_user, org_user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> OrgUserAuth.log_out_org_user()
  end
end
