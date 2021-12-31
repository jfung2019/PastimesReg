defmodule PastimesReg.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PastimesReg.Accounts` context.
  """

  def unique_org_user_email, do: "org_user#{System.unique_integer()}@example.com"
  def valid_org_user_password, do: "hello world!"

  def valid_org_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_org_user_email(),
      password: valid_org_user_password()
    })
  end

  def org_user_fixture(attrs \\ %{}) do
    {:ok, org_user} =
      attrs
      |> valid_org_user_attributes()
      |> PastimesReg.Accounts.register_org_user()

    org_user
  end

  def extract_org_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
