defmodule PastimesRegWeb.CreateEventsLive do
  use PastimesRegWeb, :live_view

  alias PastimesReg.Events
  alias PastimesReg.Activities
  alias PastimesReg.TimeZones
  alias PastimesReg.Accounts
  alias SimpleS3Upload

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.CreateEventView, "new.html", assigns)
  end

  @spec mount(any, map, Phoenix.LiveView.Socket.t()) :: {:ok, any}
  def mount(_params, %{"org_user_token" => token}, socket) do
    %{id: org_user_id} = Accounts.get_org_user_by_session_token(token)
    changeset = Events.event_create_form_step_init_changeset(%PastimesReg.Events.Event{})

    {:ok,
     assign(
       socket
       |> allow_upload(:cover_photo,
         accept: ~w(.jpg .jpeg .png),
         max_entries: 1,
         external: &presign_entry/2
       )
       |> allow_upload(:photos, accept: ~w(.jpg .jpeg .png), max_entries: 9, external: &presign_entry/2)
       |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png), max_entries: 1, external: &presign_entry/2),
       toggle: [true],
       toggle_category_pop_up: [false],
       current_step: 1,
       changeset: changeset,
       available_activities: Activities.ActivitiesOption.activity_options(),
       available_timezones: TimeZones.TimeZoneOption.timezone_options(),
       attrs: %{},
       org_user_id: org_user_id,
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
    consume_uploaded_entries(socket, :cover_photo, fn _meta, _entry -> :ok end)
    consume_uploaded_entries(socket, :photos, fn _meta, _entry -> :ok end)

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
    consume_uploaded_entries(socket, :logo, fn _meta, _entry -> :ok end)

    attrs =
      attrs
      |> Map.merge(events_params)
      |> Map.put("logo", get_logo_url(socket))
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

  def handle_event(
        "add_category",
        _,
        %{assigns: %{changeset: changeset, toggle: toggle, toggle_category_pop_up: toggle_category_pop_up}} = socket
      ) do
    changeset = Events.append_category(changeset)

    toggle =
      case toggle do
        [] ->
          [true]

        list ->
          List.insert_at(list, -1, true)
      end

      toggle_category_pop_up =
        case toggle_category_pop_up do
          [] ->
            [false]

          list ->
            List.insert_at(list, -1, false)
        end

    IO.inspect(toggle)
    IO.inspect(toggle_category_pop_up)
    {:noreply, assign(socket, changeset: changeset, toggle: toggle, toggle_category_pop_up: toggle_category_pop_up)}
  end

  def handle_event(
        "remove_category",
        %{"index" => string_index},
        %{assigns: %{changeset: changeset, toggle: toggle, toggle_category_pop_up: toggle_category_pop_up}} = socket
      ) do
    {index, _} = Integer.parse(string_index)
    changeset = Events.delete_category(changeset, index)

    toggle =
      case toggle do
        [] ->
          toggle

        list ->
          List.delete_at(list, index)
      end

    toggle_category_pop_up =
      case toggle_category_pop_up do
        [] ->
          toggle_category_pop_up

        list ->
          List.delete_at(list, index)
      end

    socket =
      socket
      |> assign(changeset: changeset, toggle: toggle, toggle_category_pop_up: toggle_category_pop_up)

    {:noreply, socket}
  end

  def handle_event("toggle_change", %{"index" => string_index}, %{assigns: %{toggle: toggle_list, toggle_category_pop_up: toggle_category_pop_up_list}} = socket) do
    {index, _} = Integer.parse(string_index)

    toggle = List.update_at(toggle_list, index, &(!&1))
    toggle_category_pop_up = List.update_at(toggle_category_pop_up_list, index, &(!&1))

    socket =
      socket
      |> assign(toggle: toggle, toggle_category_pop_up: toggle_category_pop_up)

    {:noreply, socket}
  end

  # def handle_event("toggle_change", _params, %{assigns: %{toggle: false}} = socket) do
  #   toggle = true

  #   socket =
  #     socket
  #     |> assign(toggle: toggle)
  #     |> push_event("toggle-updated", %{toggle: toggle})

  #   {:noreply, socket}
  # end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover_photo, ref)}
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  def handle_event("cancel-upload-logo", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
  end

  defp get_cover_photo_url(socket) do
    {completed, []} = uploaded_entries(socket, :cover_photo)

    case completed do
      [] ->
        nil

      [completed | _] ->
        Path.join(s3_host(), s3_key(completed))
    end
  end

  defp get_logo_url(socket) do
    {completed, []} = uploaded_entries(socket, :logo)

    case completed do
      [] ->
        nil

      [completed | _] ->
        Path.join(s3_host(), s3_key(completed))
    end
  end

  defp get_photos_url(socket) do
    {completed, []} = uploaded_entries(socket, :photos)

    case completed do
      [] ->
        nil

      completed ->
        for entry <- completed do
          Path.join(s3_host(), s3_key(entry))
        end
    end
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  # external upload using s3 bucket amazon
  @bucket "pastimes-event-reg-staging"
  defp s3_host, do: "//#{@bucket}.s3.amazonaws.com"
  defp s3_key(entry), do: "#{entry.uuid}.#{ext(entry)}"

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    key = s3_key(entry)

    config = %{
      region: "us-west-2",
      access_key_id: "AKIAV2HK4NH7ATUK7QQK",
      secret_access_key: "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"
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(config, @bucket,
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.cover_photo.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end
end
