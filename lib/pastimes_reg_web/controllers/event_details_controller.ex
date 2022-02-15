defmodule PastimesRegWeb.EventDetailsController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events

  def show(conn, %{"id" => event_id}) do
    event = Events.get_event!(event_id)
    render(conn, "new.html", event: event)
  end

end
