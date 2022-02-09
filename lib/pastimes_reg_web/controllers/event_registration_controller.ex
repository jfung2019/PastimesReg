defmodule PastimesRegWeb.EventRegistrationController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events
  alias PastimesReg.Accounts

  def show(conn, %{"id" => event_id}) do
    event = Events.get_event!(event_id)
    render(conn, "new.html", event: event)
  end
end
