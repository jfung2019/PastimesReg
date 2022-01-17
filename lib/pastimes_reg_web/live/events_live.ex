defmodule PastimesRegWeb.EventsLive do
  use PastimesRegWeb, :live_view

  alias PastimesReg.Events
  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserEventsView, "index.html", assigns)
  end

  def mount(_params, session, socket) do
    case Map.get(session, "org_user_token") do
      nil -> {:ok, assign(socket, :current_org_user, nil)}
      token ->
        current_org_user = Accounts.get_org_user_by_session_token(token)

        upcoming_events = Events.list_upcoming_events_by_org_user_id(current_org_user.id)
        past_events = Events.list_past_events_by_org_user_id(current_org_user.id)
        events = Events.list_events_by_org_user_id(current_org_user.id)
        {:ok,
        assign(socket,
          upcoming_events: upcoming_events,
          past_events: past_events,
          events: events,
          current_org_user: current_org_user
        )}
    end

  end
end
