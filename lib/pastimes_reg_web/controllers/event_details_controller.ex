defmodule PastimesRegWeb.EventDetailsController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events
  alias PastimesReg.Accounts

  def show(conn, %{"id" => id}) do
    event = Events.get_events!(id)
    render(conn, "new.html", event: event)
  end
end
