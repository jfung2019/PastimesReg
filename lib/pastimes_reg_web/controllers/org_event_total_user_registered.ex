defmodule PastimesRegWeb.EventTotalUserRegisteredController do
  use PastimesRegWeb, :controller
  alias PastimesReg.Events
  alias PastimesReg.Participants

  def show(conn, %{"id" => id, "event_name" => event_name}) do

    event = Events.get_event!(id)
    participant = Participants.list_participant_by_event_category_name(event_name, id)
    participant_name_registered = Enum.group_by(participant, &(&1.category))
    render(conn, "new.html", event: event, participant: participant, participant_name_registered: participant_name_registered)
  end
end
