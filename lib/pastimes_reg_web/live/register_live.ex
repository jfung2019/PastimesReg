defmodule PastimesRegWeb.RegisterLive do
  use PastimesRegWeb, :live_view
  alias PastimesReg.Accounts


  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserRegistrationView, "new.html", assigns)
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.registration_form_step_init_changeset(%PastimesReg.Accounts.OrgUser{})
    {:ok, assign(socket, current_step: 1, valid_count: 0, changeset: changeset, attrs: %{})}
  end

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
      valid_count = if changeset.valid? do
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
      valid_count = if changeset.valid? do
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
      valid_count = if changeset.valid? do
        valid_count + 3
      end

    {:noreply, assign(socket, changeset: changeset, valid_count: valid_count, attrs: attrs)}
  end

  def handle_event("send", %{"org_user" => org_user_params}, socket) do
    case Accounts.register_org_user(org_user_params) do
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
        {:noreply, assign(socket, changeset: changeset)}
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
end
