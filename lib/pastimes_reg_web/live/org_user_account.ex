defmodule PastimesRegWeb.OrgUserAccountLive do
  use PastimesRegWeb, :live_view

  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserAccountView, "new.html", assigns)
  end

  def mount(_params, %{"org_user_token" => token}, socket) do
    current_org_user = Accounts.get_org_user_by_session_token(token)
    changeset = Accounts.update_form_step_init_changeset(current_org_user)

    {:ok,
     assign(socket,
       current_org_user: current_org_user,
       changeset: changeset,
       attrs: %{},
       is_toggle_acc: false,
       is_toggle_org: false
     )}
  end

  def handle_event(
        "validate",
        %{"org_user" => org_user_params},
        %{assigns: %{current_org_user: current_org_user}} = socket
      ) do
    changeset =
      Accounts.update_form_acc_changeset(current_org_user, org_user_params)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "send",
        %{"org_user" => org_user_params},
        %{assigns: %{current_org_user: current_org_user}} = socket
      ) do
    case Accounts.update_org_user(current_org_user, org_user_params) do
      {:ok, org_user} ->
        {:ok, _} =
          Accounts.deliver_org_user_confirmation_instructions(
            org_user,
            &Routes.org_user_confirmation_url(socket, :edit, &1)
          )

        socket =
          socket
          |> put_flash(:info, "You have change details successfully")
          |> redirect(
            to: Routes.live_path(PastimesRegWeb.Endpoint, PastimesRegWeb.OrgUserAccountLive)
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("toggle_edit_account", _, %{assigns: %{is_toggle_acc: false}} = socket) do
    socket =
      socket
      |> assign(is_toggle_acc: true)

    {:noreply, socket}
  end

  def handle_event("toggle_edit_account", _, %{assigns: %{is_toggle_acc: true}} = socket) do
    socket =
      socket
      |> assign(is_toggle_acc: false)

    {:noreply, socket}
  end

  def handle_event("toggle_edit_org", _, %{assigns: %{is_toggle_org: false}} = socket) do
    socket =
      socket
      |> assign(is_toggle_org: true)

    {:noreply, socket}
  end

  def handle_event("toggle_edit_org", _, %{assigns: %{is_toggle_org: true}} = socket) do
    socket =
      socket
      |> assign(is_toggle_org: false)

    {:noreply, socket}
  end

  def handle_event("cancel_submit", _, %{assigns: %{is_toggle_acc: true}} = socket) do
    socket =
      socket
      |> assign(is_toggle_acc: false)

    {:noreply, socket}
  end

  def handle_event("cancel_submit", _, %{assigns: %{is_toggle_org: true}} = socket) do
    socket =
      socket
      |> assign(is_toggle_org: false)

    {:noreply, socket}
  end
end
