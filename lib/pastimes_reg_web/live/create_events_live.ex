defmodule PastimesRegWeb.CreateEventsLive do
  use PastimesRegWeb, :live_view

  alias PastimesReg.Events
  alias PastimesReg.Events.Event
  alias PastimesReg.Activities
  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.CreateEventView, "new.html", assigns)
  end

  def mount(_params, %{"org_user_token" => token}, socket) do
    %{id: org_user_id} = Accounts.get_org_user_by_session_token(token)
    changeset = Events.event_create_form_step_init_changeset(%PastimesReg.Events.Event{})

    {:ok,
     assign(
       socket
       |> allow_upload(:cover_photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
       |> allow_upload(:photos, accept: ~w(.jpg .jpeg .png), max_entries: 9),
       uploaded_files: [],
       current_step: 1,
       changeset: changeset,
       available_activities: Activities.ActivitiesOption.activity_options(),
       attrs: %{},
       org_user_id: org_user_id,
       show_first_category_form: false
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

    {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
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

    {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
  end

  def handle_event(
        "submit",
        %{"event" => events_params},
        %{assigns: %{current_step: 1, attrs: attrs}} = socket
      ) do
      consume_uploaded_entries(socket, :cover_photo, fn %{path: path}, entry ->
        dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
        File.cp!(path, dest)
        {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
      end)

      consume_uploaded_entries(socket, :photos, fn %{path: path}, entry ->
        dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
        File.cp!(path, dest)
        {:ok, Routes.static_path(socket, "/uploads/#{Path.basename(dest)}")}
      end)

    attrs =
      attrs
      |> Map.merge(events_params)
      |> Map.put("cover_photo", get_cover_photo_url(socket))
      |> Map.put("photos", get_photos_url(socket))
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
        "submit",
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
        "submit",
        _params,
        %{assigns: %{current_step: 2, attrs: attrs}} = socket
      ) do
    socket =
      socket
      |> assign(changeset: Events.event_create_form_step_1_changeset(attrs), current_step: 3)

    {:noreply, socket}
  end

  def handle_event(
        "submit",
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

  def handle_event("add_category", _params, %{assigns: %{changeset: changeset}} = socket) do
    IO.puts("called!")
    {:noreply, assign(socket, changeset: Events.append_category(changeset))}
  end

  def handle_event("save_temp_category", _params, socket) do
    IO.puts("called save temp!")
    {:noreply, socket}
  end

  def handle_event(
        "remove_category",
        %{"index" => string_index},
        %{assigns: %{changeset: changeset}} = socket
      ) do
    {index, _} = Integer.parse(string_index)
    changeset = Events.delete_category(changeset, index)

    socket =
      socket
      |> assign(changeset: changeset)

    {:noreply, socket}
  end

  def handle_event("show_first_category_form", _unsigned_params, socket) do
    socket =
      socket
      |> assign(show_first_category_form: true)

    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover_photo, ref)}
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  # def handle_event("index_show", %{"index" => string_index}, socket) do
  #   {index, _} = Integer.parse(string_index)

  #   socket =
  #     socket
  #     |> assign(index_show: true)

  #   {:noreply, socket}
  # end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp get_cover_photo_url(socket) do
    {completed, []} = uploaded_entries(socket, :cover_photo)

    case completed do
      [] ->
        nil

      [completed | _] ->
        Routes.static_path(socket, "/uploads/#{completed.uuid}.#{ext(completed)}")
        # Path.join(s3_host(), s3_key(completed))
    end
  end

  defp get_photos_url(socket) do
    {completed, []} = uploaded_entries(socket, :photos)

    case completed do
      [] ->
        nil

      completed ->
        for entry <- completed do
          Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}")
        end
    end
  end

  # defp consume_photo_urls(socket) do
  #   consume_uploaded_entries(socket, :cover_photo, fn meta, entry ->
  #     dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
  #     File.cp!(meta.path, dest)
  #   end)
  # end
end
