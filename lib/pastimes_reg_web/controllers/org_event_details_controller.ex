defmodule PastimesRegWeb.EventDetailsController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, "new.html", event: event)
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    Events.delete_event(event)
    conn
    |> put_flash(:info, "Event Deleted successfully.")
    |> redirect(to: "/")
  end

end
