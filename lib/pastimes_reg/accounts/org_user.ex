defmodule PastimesReg.Accounts.OrgUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "org_users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime

    #Organization information
    field :organization, :string
    field :license, :string
    field :address_line_1, :string
    field :address_line_2, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :country, :string
    field :phone, :string
    field :support_email, :string
    field :support_phone, :string
    field :instagram_url, :string
    field :facebook_url, :string
    field :twitter_url, :string
    field :website_url, :string

    #Bank information
    field :routing_number, :string
    field :account_number, :string

    timestamps()
  end

  @doc """
  A org_user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(org_user, attrs, opts \\ []) do
    org_user
    |> cast(attrs, [:email, :password, :first_name, :last_name])
    |> validate_email()
    |> validate_first_name()
    |> validate_last_name()
    |> validate_password(opts)
  end

  defp validate_first_name(changeset) do
    changeset
    |> validate_required([:first_name])
    |> validate_length(:first_name, max: 160)
    |> unsafe_validate_unique(:first_name, PastimesReg.Repo)
    |> unique_constraint(:first_name)
  end

  defp validate_last_name(changeset) do
    changeset
    |> validate_required([:last_name])
    |> validate_length(:last_name, max: 160)
    |> unsafe_validate_unique(:last_name, PastimesReg.Repo)
    |> unique_constraint(:last_name)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, PastimesReg.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A org_user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(org_user, attrs) do
    org_user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A org_user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(org_user, attrs, opts \\ []) do
    org_user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(org_user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(org_user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no org_user or the org_user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%PastimesReg.Accounts.OrgUser{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
