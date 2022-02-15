defmodule PastimesRegWeb.RegisterLive do
  use PastimesRegWeb, :live_view
  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserRegistrationView, "new.html", assigns)
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.registration_form_step_init_changeset(%PastimesReg.Accounts.OrgUser{})
    {:ok, assign(
      socket
      |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png), max_entries: 1, external: &presign_entry/2),
      current_step: 1,
      valid_count: 0,
      changeset: changeset,
      attrs: %{})
    }
  end

  @spec handle_event(<<_::32, _::_*8>>, any, any) :: {:noreply, any}
  def handle_event(
        "validate",
        %{"org_user" => params},
        %{assigns: %{current_step: 1, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Accounts.registration_form_step_1_changeset(attrs)
      |> IO.inspect()

    valid_count = 0

    valid_count =
      if changeset.valid? do
        valid_count + 1
      end

    {:noreply, assign(socket, changeset: changeset, valid_count: valid_count, attrs: attrs)}
  end

  def handle_event(
        "validate",
        %{"org_user" => params},
        %{assigns: %{current_step: 2, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Accounts.registration_form_step_2_changeset(attrs)
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
        %{"org_user" => params},
        %{assigns: %{current_step: 3, attrs: attrs}} = socket
      ) do
    attrs = Map.merge(attrs, params)

    changeset =
      Accounts.registration_form_step_3_changeset(attrs)
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
        %{"org_user" => org_user_params},
        %{assigns: %{current_step: 1, attrs: attrs}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(org_user_params)
      |> IO.inspect()

    socket =
      case Accounts.registration_form_step_1_changeset(attrs) do
        %{valid?: true} = changeset ->
          socket
          |> assign(changeset: changeset, attrs: attrs, current_step: 2)

        changeset ->
          socket
          |> assign(changeset: changeset, attrs: attrs)
      end

    {:noreply, socket}
  end

  def handle_event(
        "send",
        %{"org_user" => org_user_params},
        %{assigns: %{current_step: 2, attrs: attrs}} = socket
      ) do
    consume_uploaded_entries(socket, :logo, fn _meta, _entry -> :ok end)

    attrs =
      attrs
      |> Map.merge(org_user_params)
      |> Map.put("logo", get_logo_url(socket))
      |> IO.inspect()

    socket =
      case Accounts.registration_form_step_2_changeset(attrs) do
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
        %{"org_user" => org_user_params},
        %{assigns: %{current_step: 3, attrs: attrs}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(org_user_params)
      |> IO.inspect()

    case Accounts.register_org_user(attrs) do
      {:ok, org_user} ->
        {:ok, _} =
          Accounts.deliver_org_user_confirmation_instructions(
            org_user,
            &Routes.org_user_confirmation_url(socket, :edit, &1)
          )

        # Log in page
        sign_in_path = Routes.org_user_session_path(socket, :new)

        socket =
          socket
          |> put_flash(:info, "Organizer user created successfully.")
          |> redirect(to: sign_in_path)

        {:noreply, socket}

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

  def handle_event("step_3", _, socket) do
    socket =
      socket
      |> assign(current_step: 3)

    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :logo, ref)}
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
        max_file_size: uploads.logo.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end
end
