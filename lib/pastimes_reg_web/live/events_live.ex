defmodule PastimesRegWeb.EventsLive do
  use PastimesRegWeb, :live_view

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserEventsView, "new.html", assigns)
  end

  def mount(_params, _, socket) do
    temperature = 10
    {:ok, assign(socket, :temperature, temperature)}
  end
end
