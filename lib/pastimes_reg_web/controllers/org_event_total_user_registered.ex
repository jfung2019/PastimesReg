defmodule PastimesRegWeb.EventTotalUserRegisteredController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events
  alias PastimesReg.Participants

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    participant = Participants.get_participant!(id)
    render(conn, "new.html", event: event, participant: participant)
  end

end
