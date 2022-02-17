defmodule PastimesRegWeb.EventRegistrationConfirmationController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events
  alias PastimesReg.Participants

  def show(conn, %{"event_id" => event_id, "id" => id}) do
    event = Events.get_event!(event_id)
    participant = Participants.get_participant!(id)
    render(conn, "new.html", event: event, id: id, participant: participant)
  end
end
