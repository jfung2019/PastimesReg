defmodule PastimesRegWeb.EventRegistrationLive do
  use PastimesRegWeb, :live_view
  alias PastimesReg.Participants
  alias PastimesReg.Participants.Participant
  alias PastimesReg.Events

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.EventRegistrationView, "new.html", assigns)
  end

  def mount(%{"id" => event_id, "name" => category_name}, session, socket) do
    event = Events.get_event!(event_id)
    changeset = Participants.event_registration_form_step_init_changeset(%PastimesReg.Participants.Participant{})
    {:ok, assign(socket, current_step: 1, attrs: %{}, changeset: changeset, event: event, category_name: category_name, event_id: String.to_integer(event_id))}
  end

  def handle_event(
        "validate",
        %{"participant" => params},
        %{assigns: %{current_step: 1, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Participants.event_registration_form_step_1_changeset(attrs)
      |> IO.inspect()

    {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
  end

  def handle_event(
        "submit",
        %{"participant" => params},
        %{assigns: %{current_step: 1, attrs: attrs, category_name: category_name}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(params)
      |> Map.put("category", category_name)
      |> IO.inspect()

    socket =
      case Participants.event_registration_form_step_1_changeset(attrs) do
        %{valid?: true} = changeset ->
          socket
          |> assign(
            changeset: changeset,
            attrs: attrs,
            current_step: 2
          )

        changeset ->
          socket
          |> assign(changeset: changeset, attrs: attrs)
      end

    {:noreply, socket}
  end

  def handle_event(
      "submit",
      _params,
      %{assigns: %{current_step: 2, attrs: attrs}} = socket
    ) do
  socket =
    socket
    |> assign(changeset: Participants.event_registration_form_step_1_changeset(attrs), current_step: 3)

  {:noreply, socket}
  end

  def handle_event(
      "submit",
      _,
      %{assigns: %{current_step: 3, attrs: attrs, event_id: event_id}} = socket
    ) do

    case Participants.create_participant(attrs, event_id) do
      {:ok, _} ->
        {:noreply,
        socket
        |> put_flash(:info, "You have sucessfully registered for an event.")
        |> redirect(
          to: Routes.org_event_details_path(PastimesRegWeb.Endpoint, :show, event_id)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
    end
  end

end
