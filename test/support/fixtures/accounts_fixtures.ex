defmodule PastimesReg.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PastimesReg.Accounts` context.
  """
  def valid_org_user_first_name, do: "hello world!"
  def valid_org_user_last_name, do: "hello world!"
  def unique_org_user_email, do: "org_user#{System.unique_integer()}@example.com"
  def valid_org_user_password, do: "hello world!"
  @spec valid_org_user_organization :: <<_::96>>
  def valid_org_user_organization, do: "hello world!"
  def valid_org_user_license, do: "hello world!"
  def valid_org_user_address_line_1, do: "hello world!"
  def valid_org_user_address_line_2, do: "hello world!"
  def valid_org_user_city, do: "hello world!"
  def valid_org_user_state, do: "hello world!"
  def valid_org_user_zip, do: "hello world!"
  def valid_org_user_country, do: "hello world!"
  def valid_org_user_phone_number, do: "+123 1234567"
  def valid_org_user_routing_number, do: "hello 1234567!"
  def valid_org_user_account_number, do: "hello 1234567!"

  def valid_org_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      first_name: valid_org_user_first_name(),
      last_name: valid_org_user_last_name(),
      email: unique_org_user_email(),
      password: valid_org_user_password(),
      organization: valid_org_user_organization(),
      address_line_1: valid_org_user_address_line_1(),
      address_line_2: valid_org_user_address_line_2(),
      city: valid_org_user_city(),
      state: valid_org_user_state(),
      zip: valid_org_user_zip(),
      country: valid_org_user_country(),
      phone: valid_org_user_phone_number(),
      routing_number: valid_org_user_routing_number(),
      account_number: valid_org_user_account_number()
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
