defmodule PastimesReg.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias PastimesReg.Repo

  alias PastimesReg.Accounts.{OrgUser, OrgUserToken, OrgUserNotifier}

  ## Database getters

  @doc """
  Gets a org_user by email.

  ## Examples

      iex> get_org_user_by_email("foo@example.com")
      %OrgUser{}

      iex> get_org_user_by_email("unknown@example.com")
      nil

  """
  def get_org_user_by_email(email) when is_binary(email) do
    Repo.get_by(OrgUser, email: email)
  end

  @doc """
  Gets a org_user by email and password.

  ## Examples

      iex> get_org_user_by_email_and_password("foo@example.com", "correct_password")
      %OrgUser{}

      iex> get_org_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_org_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    org_user = Repo.get_by(OrgUser, email: email)
    if OrgUser.valid_password?(org_user, password), do: org_user
  end

  @doc """
  Gets a single org_user.

  Raises `Ecto.NoResultsError` if the OrgUser does not exist.

  ## Examples

      iex> get_org_user!(123)
      %OrgUser{}

      iex> get_org_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_org_user!(id), do: Repo.get!(OrgUser, id)

  ## Org user registration

  @doc """
  Registers a org_user.

  ## Examples

      iex> register_org_user(%{field: value})
      {:ok, %OrgUser{}}

      iex> register_org_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_org_user(attrs) do
    %OrgUser{}
    |> OrgUser.registration_changeset_step_1(attrs)
    |> OrgUser.registration_changeset_step_2(attrs)
    |> OrgUser.registration_changeset_step_3(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking org_user changes for 3 changesets used for form step 1 to 3.

  ## Examples

      iex> change_org_user_registration(org_user)
      %Ecto.Changeset{data: %OrgUser{}}

  """

  def registration_form_step_init_changeset(%OrgUser{} = org_user, attrs \\ %{}) do
    OrgUser.registration_changeset_step_1(org_user, attrs, hash_password: false)
  end

  def registration_form_step_1_changeset(attrs) do
    %OrgUser{}
    |> OrgUser.registration_changeset_step_1(attrs)
    |> Map.put(:action, :insert)
  end

  def registration_form_step_2_changeset(attrs) do
    %OrgUser{}
    |> OrgUser.registration_changeset_step_2(attrs)
    |> Map.put(:action, :insert)
  end

  @spec registration_form_step_3_changeset(
          :invalid
          | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def registration_form_step_3_changeset(attrs) do
    %OrgUser{}
    |> OrgUser.registration_changeset_step_3(attrs)
    |> Map.put(:action, :insert)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking org_user changes.

  ## Examples

      iex> change_org_user_registration(org_user)
      %Ecto.Changeset{data: %OrgUser{}}

  """
  def change_org_user_registration(%OrgUser{} = org_user, attrs \\ %{}) do
    OrgUser.registration_changeset(org_user, attrs, hash_password: false)
  end

  ## Settings

  @spec change_org_user_email(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc """
  Returns an `%Ecto.Changeset{}` for changing the org_user email.

  ## Examples

      iex> change_org_user_email(org_user)
      %Ecto.Changeset{data: %OrgUser{}}

  """
  def change_org_user_email(org_user, attrs \\ %{}) do
    OrgUser.email_changeset(org_user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_org_user_email(org_user, "valid password", %{email: ...})
      {:ok, %OrgUser{}}

      iex> apply_org_user_email(org_user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_org_user_email(org_user, password, attrs) do
    org_user
    |> OrgUser.email_changeset(attrs)
    |> OrgUser.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the org_user email using the given token.

  If the token matches, the org_user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_org_user_email(org_user, token) do
    context = "change:#{org_user.email}"

    with {:ok, query} <- OrgUserToken.verify_change_email_token_query(token, context),
         %OrgUserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(org_user_email_multi(org_user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp org_user_email_multi(org_user, email, context) do
    changeset =
      org_user
      |> OrgUser.email_changeset(%{email: email})
      |> OrgUser.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:org_user, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      OrgUserToken.org_user_and_contexts_query(org_user, [context])
    )
  end

  @doc """
  Delivers the update email instructions to the given org_user.

  ## Examples

      iex> deliver_update_email_instructions(org_user, current_email, &Routes.org_user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(
        %OrgUser{} = org_user,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, org_user_token} =
      OrgUserToken.build_email_token(org_user, "change:#{current_email}")

    Repo.insert!(org_user_token)

    OrgUserNotifier.deliver_update_email_instructions(
      org_user,
      update_email_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the org_user password.

  ## Examples

      iex> change_org_user_password(org_user)
      %Ecto.Changeset{data: %OrgUser{}}

  """
  def change_org_user_password(org_user, attrs \\ %{}) do
    OrgUser.password_changeset(org_user, attrs, hash_password: false)
  end

  @doc """
  Updates the org_user password.

  ## Examples

      iex> update_org_user_password(org_user, "valid password", %{password: ...})
      {:ok, %OrgUser{}}

      iex> update_org_user_password(org_user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_org_user_password(org_user, password, attrs) do
    changeset =
      org_user
      |> OrgUser.password_changeset(attrs)
      |> OrgUser.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:org_user, changeset)
    |> Ecto.Multi.delete_all(:tokens, OrgUserToken.org_user_and_contexts_query(org_user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{org_user: org_user}} -> {:ok, org_user}
      {:error, :org_user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_org_user_session_token(org_user) do
    {token, org_user_token} = OrgUserToken.build_session_token(org_user)
    Repo.insert!(org_user_token)
    token
  end

  @doc """
  Gets the org_user with the given signed token.
  """
  def get_org_user_by_session_token(token) do
    {:ok, query} = OrgUserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(OrgUserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given org_user.

  ## Examples

      iex> deliver_org_user_confirmation_instructions(org_user, &Routes.org_user_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_org_user_confirmation_instructions(confirmed_org_user, &Routes.org_user_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_org_user_confirmation_instructions(%OrgUser{} = org_user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if org_user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, org_user_token} = OrgUserToken.build_email_token(org_user, "confirm")
      Repo.insert!(org_user_token)

      OrgUserNotifier.deliver_confirmation_instructions(
        org_user,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @spec confirm_org_user(binary) :: :error | {:ok, any}
  @doc """
  Confirms a org_user by the given token.

  If the token matches, the org_user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_org_user(token) do
    with {:ok, query} <- OrgUserToken.verify_email_token_query(token, "confirm"),
         %OrgUser{} = org_user <- Repo.one(query),
         {:ok, %{org_user: org_user}} <- Repo.transaction(confirm_org_user_multi(org_user)) do
      {:ok, org_user}
    else
      _ -> :error
    end
  end

  defp confirm_org_user_multi(org_user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:org_user, OrgUser.confirm_changeset(org_user))
    |> Ecto.Multi.delete_all(
      :tokens,
      OrgUserToken.org_user_and_contexts_query(org_user, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given org_user.

  ## Examples

      iex> deliver_org_user_reset_password_instructions(org_user, &Routes.org_user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_org_user_reset_password_instructions(%OrgUser{} = org_user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, org_user_token} = OrgUserToken.build_email_token(org_user, "reset_password")
    Repo.insert!(org_user_token)

    OrgUserNotifier.deliver_reset_password_instructions(
      org_user,
      reset_password_url_fun.(encoded_token)
    )
  end

  @doc """
  Gets the org_user by reset password token.

  ## Examples

      iex> get_org_user_by_reset_password_token("validtoken")
      %OrgUser{}

      iex> get_org_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_org_user_by_reset_password_token(token) do
    with {:ok, query} <- OrgUserToken.verify_email_token_query(token, "reset_password"),
         %OrgUser{} = org_user <- Repo.one(query) do
      org_user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the org_user password.

  ## Examples

      iex> reset_org_user_password(org_user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %OrgUser{}}

      iex> reset_org_user_password(org_user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_org_user_password(org_user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:org_user, OrgUser.password_changeset(org_user, attrs))
    |> Ecto.Multi.delete_all(:tokens, OrgUserToken.org_user_and_contexts_query(org_user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{org_user: org_user}} -> {:ok, org_user}
      {:error, :org_user, changeset, _} -> {:error, changeset}
    end
  end
end
