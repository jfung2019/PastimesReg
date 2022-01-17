defmodule PastimesRegWeb.CreateEventsLive do
  use PastimesRegWeb, :live_view

  alias PastimesReg.Events
  alias PastimesReg.Activities
  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.CreateEventView, "new.html", assigns)
  end

  def mount(_params, %{"org_user_token" => token}, socket) do
    %{id: org_user_id} = Accounts.get_org_user_by_session_token(token)
    IO.inspect(org_user_id)
    changeset = Events.event_create_form_step_init_changeset(%PastimesReg.Events.Event{})

    {:ok,
     assign(
       socket
       |> allow_upload(:cover_photo, accept: ~w(.jpg .jpeg .png), max_entries: 1),
       uploaded_files: [],
       current_step: 1,
       valid_count: 0,
       changeset: changeset,
       available_activities: Activities.ActivitiesOption.activity_options(),
       attrs: %{},
       org_user_id: org_user_id
     )}
  end

  def handle_event(
        "validate",
        %{"event" => params},
        %{assigns: %{current_step: 1, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Events.event_create_form_step_1_changeset(attrs)
      |> IO.inspect()

    {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
  end

  def handle_event(
        "validate",
        %{"event" => params},
        %{assigns: %{current_step: 2, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Events.event_create_form_step_2_changeset(attrs)
      |> IO.inspect()

    valid_count = 0

    valid_count =
      if changeset.valid? do
        valid_count + 2
      end

    {:noreply, assign(socket, changeset: changeset, valid_count: valid_count, attrs: attrs)}
  end

  def handle_event(
        "validate",
        %{"event" => params},
        %{assigns: %{current_step: 3, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Events.event_create_form_step_3_changeset(attrs)
      |> IO.inspect()

    valid_count = 0

    valid_count =
      if changeset.valid? do
        valid_count + 3
      end

    {:noreply, assign(socket, changeset: changeset, valid_count: valid_count, attrs: attrs)}
  end

  def handle_event(
        "send",
        %{"event" => events_params},
        %{assigns: %{current_step: 1, attrs: attrs}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(events_params)
      |> IO.inspect()

    socket =
      case Events.event_create_form_step_1_changeset(attrs) do
        %{valid?: true} = changeset ->
          socket
          |> assign(
            changeset: Events.append_category(changeset),
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
        "send",
        %{"event" => events_params},
        %{assigns: %{current_step: 2, attrs: attrs}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(events_params)
      |> IO.inspect()

    socket =
      case Events.event_create_form_step_2_changeset(attrs) do
        %{valid?: true} = changeset ->
          socket
          |> assign(changeset: changeset, attrs: attrs, current_step: 3)

        changeset ->
          socket
          |> assign(changeset: changeset, attrs: attrs)
      end

    {:noreply, socket}
  end

  def handle_event(
        "send",
        %{"event" => events_params},
        %{assigns: %{current_step: 3, attrs: attrs, org_user_id: org_user_id}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(events_params)
      |> IO.inspect()

    case Events.create_event(attrs, org_user_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You have sucessfully created an event.")
         |> redirect(
           to: Routes.live_path(PastimesRegWeb.Endpoint, PastimesRegWeb.CreateEventsLive)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
    end
  end

  def handle_event("add_category", _params, %{assigns: %{changeset: changeset}} = socket) do
    {:noreply, assign(socket, changeset: Events.append_category(changeset))}
  end

  def handle_event("step_1", _, socket) do
    socket =
      socket
      |> assign(current_step: 1)

    {:noreply, socket}
  end

  def handle_event("step_2", _, socket) do
    socket =
      socket
      |> assign(current_step: 2)

    {:noreply, socket}
  end
end
