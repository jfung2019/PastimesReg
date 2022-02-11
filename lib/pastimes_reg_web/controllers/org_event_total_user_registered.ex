defmodule PastimesRegWeb.EventTotalUserRegisteredController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, "new.html", event: event)
  end

end
