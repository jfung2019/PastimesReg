defmodule PastimesRegWeb.OrgUserAccountLive do
  use PastimesRegWeb, :live_view

  alias PastimesReg.Accounts

  def render(assigns) do
    Phoenix.View.render(PastimesRegWeb.OrgUserAccountView, "new.html", assigns)
  end

  def mount(_params, %{"org_user_token" => token}, socket) do
    current_org_user = Accounts.get_org_user_by_session_token(token)

    changeset = Accounts.update_form_step_init_changeset(%PastimesReg.Accounts.OrgUser{})

    {:ok, assign(socket, current_org_user: current_org_user, changeset: changeset, attrs: %{})}
  end

  # def handle_event(
  #     "validate",
  #     %{"org_user" => params},
  #     %{assigns: %{attrs: attrs}} = socket
  #   ) do
  # attrs = Map.merge(attrs, params)

  # changeset =
  #   Accounts.registration_form_step_1_changeset(attrs)
  #   |> IO.inspect()

  # {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
  # end

  def handle_event(
        "send",
        %{"org_user" => org_user_params},
        %{assigns: %{attrs: attrs}} = socket
      ) do
    attrs =
      attrs
      |> Map.merge(org_user_params)
      |> IO.inspect()

    case Accounts.update_org_user(attrs) do
      {:ok, org_user} ->
        {:ok, _} =
          Accounts.deliver_org_user_confirmation_instructions(
            org_user,
            &Routes.org_user_confirmation_url(socket, :edit, &1)
          )

        socket =
          socket
          |> put_flash(:info, "You have change details successfully")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset, attrs: attrs)}
    end
  end
end
