defmodule PastimesRegWeb.CreateEventsLive do
  use PastimesRegWeb, :live_view
  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.CreateEventView, "new.html", assigns)
  end

  def mount(_params, _, socket) do
    changeset = Accounts.registration_form_step_init_changeset(%PastimesReg.Accounts.OrgUser{})
    temperature = 10
    {:ok, assign(socket, :temperature, temperature)}

    {:ok,
     assign(socket,
       current_step: 1,
       valid_count: 0,
       changeset: changeset,
       attrs: %{},
       temperature: temperature
     )}
  end
end
