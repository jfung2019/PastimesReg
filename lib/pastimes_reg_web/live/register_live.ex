defmodule PastimesRegWeb.RegisterLive do
  use PastimesRegWeb, :live_view
  alias PastimesReg.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, changeset: Accounts.change_org_user_registration(%PastimesReg.Accounts.OrgUser{}), current_step: 0)}
  end

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserRegistrationView, "new.html", assigns)
  end
end
