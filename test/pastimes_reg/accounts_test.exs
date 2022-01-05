defmodule PastimesReg.AccountsTest do
  use PastimesReg.DataCase

  alias PastimesReg.Accounts

  import PastimesReg.AccountsFixtures
  alias PastimesReg.Accounts.{OrgUser, OrgUserToken}

  describe "get_org_user_by_email/1" do
    test "does not return the org_user if the email does not exist" do
      refute Accounts.get_org_user_by_email("unknown@example.com")
    end

    test "returns the org_user if the email exists" do
      %{id: id} = org_user = org_user_fixture()
      assert %OrgUser{id: ^id} = Accounts.get_org_user_by_email(org_user.email)
    end
  end

  describe "get_org_user_by_email_and_password/2" do
    test "does not return the org_user if the email does not exist" do
      refute Accounts.get_org_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the org_user if the password is not valid" do
      org_user = org_user_fixture()
      refute Accounts.get_org_user_by_email_and_password(org_user.email, "invalid")
    end

    test "returns the org_user if the email and password are valid" do
      %{id: id} = org_user = org_user_fixture()

      assert %OrgUser{id: ^id} =
               Accounts.get_org_user_by_email_and_password(
                 org_user.email,
                 valid_org_user_password()
               )
    end
  end

  describe "get_org_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_org_user!(-1)
      end
    end

    test "returns the org_user with the given id" do
      %{id: id} = org_user = org_user_fixture()
      assert %OrgUser{id: ^id} = Accounts.get_org_user!(org_user.id)
    end
  end

  describe "register_org_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_org_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} =
        Accounts.register_org_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_org_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = org_user_fixture()
      {:error, changeset} = Accounts.register_org_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_org_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers org_users with a hashed password" do
      email = unique_org_user_email()
      {:ok, org_user} = Accounts.register_org_user(valid_org_user_attributes(email: email))
      assert org_user.email == email
      assert is_binary(org_user.hashed_password)
      assert is_nil(org_user.confirmed_at)
      assert is_nil(org_user.password)
    end
  end

  describe "change_org_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_org_user_registration(%OrgUser{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_org_user_email()
      password = valid_org_user_password()

      changeset =
        Accounts.change_org_user_registration(
          %OrgUser{},
          valid_org_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_org_user_email/2" do
    test "returns a org_user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_org_user_email(%OrgUser{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_org_user_email/3" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "requires email to change", %{org_user: org_user} do
      {:error, changeset} =
        Accounts.apply_org_user_email(org_user, valid_org_user_password(), %{})

      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{org_user: org_user} do
      {:error, changeset} =
        Accounts.apply_org_user_email(org_user, valid_org_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{org_user: org_user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_org_user_email(org_user, valid_org_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{org_user: org_user} do
      %{email: email} = org_user_fixture()

      {:error, changeset} =
        Accounts.apply_org_user_email(org_user, valid_org_user_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{org_user: org_user} do
      {:error, changeset} =
        Accounts.apply_org_user_email(org_user, "invalid", %{email: unique_org_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{org_user: org_user} do
      email = unique_org_user_email()

      {:ok, org_user} =
        Accounts.apply_org_user_email(org_user, valid_org_user_password(), %{email: email})

      assert org_user.email == email
      assert Accounts.get_org_user!(org_user.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "sends token through notification", %{org_user: org_user} do
      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_update_email_instructions(org_user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert org_user_token = Repo.get_by(OrgUserToken, token: :crypto.hash(:sha256, token))
      assert org_user_token.org_user_id == org_user.id
      assert org_user_token.sent_to == org_user.email
      assert org_user_token.context == "change:current@example.com"
    end
  end

  describe "update_org_user_email/2" do
    setup do
      org_user = org_user_fixture()
      email = unique_org_user_email()

      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_update_email_instructions(
            %{org_user | email: email},
            org_user.email,
            url
          )
        end)

      %{org_user: org_user, token: token, email: email}
    end

    test "updates the email with a valid token", %{org_user: org_user, token: token, email: email} do
      assert Accounts.update_org_user_email(org_user, token) == :ok
      changed_org_user = Repo.get!(OrgUser, org_user.id)
      assert changed_org_user.email != org_user.email
      assert changed_org_user.email == email
      assert changed_org_user.confirmed_at
      assert changed_org_user.confirmed_at != org_user.confirmed_at
      refute Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end

    test "does not update email with invalid token", %{org_user: org_user} do
      assert Accounts.update_org_user_email(org_user, "oops") == :error
      assert Repo.get!(OrgUser, org_user.id).email == org_user.email
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end

    test "does not update email if org_user email changed", %{org_user: org_user, token: token} do
      assert Accounts.update_org_user_email(%{org_user | email: "current@example.com"}, token) ==
               :error

      assert Repo.get!(OrgUser, org_user.id).email == org_user.email
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end

    test "does not update email if token expired", %{org_user: org_user, token: token} do
      {1, nil} = Repo.update_all(OrgUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_org_user_email(org_user, token) == :error
      assert Repo.get!(OrgUser, org_user.id).email == org_user.email
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end
  end

  describe "change_org_user_password/2" do
    test "returns a org_user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_org_user_password(%OrgUser{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_org_user_password(%OrgUser{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_org_user_password/3" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "validates password", %{org_user: org_user} do
      {:error, changeset} =
        Accounts.update_org_user_password(org_user, valid_org_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{org_user: org_user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_org_user_password(org_user, valid_org_user_password(), %{
          password: too_long
        })

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{org_user: org_user} do
      {:error, changeset} =
        Accounts.update_org_user_password(org_user, "invalid", %{
          password: valid_org_user_password()
        })

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{org_user: org_user} do
      {:ok, org_user} =
        Accounts.update_org_user_password(org_user, valid_org_user_password(), %{
          password: "new valid password"
        })

      assert is_nil(org_user.password)
      assert Accounts.get_org_user_by_email_and_password(org_user.email, "new valid password")
    end

    test "deletes all tokens for the given org_user", %{org_user: org_user} do
      _ = Accounts.generate_org_user_session_token(org_user)

      {:ok, _} =
        Accounts.update_org_user_password(org_user, valid_org_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end
  end

  describe "generate_org_user_session_token/1" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "generates a token", %{org_user: org_user} do
      token = Accounts.generate_org_user_session_token(org_user)
      assert org_user_token = Repo.get_by(OrgUserToken, token: token)
      assert org_user_token.context == "session"

      # Creating the same token for another org_user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%OrgUserToken{
          token: org_user_token.token,
          org_user_id: org_user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_org_user_by_session_token/1" do
    setup do
      org_user = org_user_fixture()
      token = Accounts.generate_org_user_session_token(org_user)
      %{org_user: org_user, token: token}
    end

    test "returns org_user by token", %{org_user: org_user, token: token} do
      assert session_org_user = Accounts.get_org_user_by_session_token(token)
      assert session_org_user.id == org_user.id
    end

    test "does not return org_user for invalid token" do
      refute Accounts.get_org_user_by_session_token("oops")
    end

    test "does not return org_user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(OrgUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_org_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      org_user = org_user_fixture()
      token = Accounts.generate_org_user_session_token(org_user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_org_user_by_session_token(token)
    end
  end

  describe "deliver_org_user_confirmation_instructions/2" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "sends token through notification", %{org_user: org_user} do
      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_confirmation_instructions(org_user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert org_user_token = Repo.get_by(OrgUserToken, token: :crypto.hash(:sha256, token))
      assert org_user_token.org_user_id == org_user.id
      assert org_user_token.sent_to == org_user.email
      assert org_user_token.context == "confirm"
    end
  end

  describe "confirm_org_user/1" do
    setup do
      org_user = org_user_fixture()

      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_confirmation_instructions(org_user, url)
        end)

      %{org_user: org_user, token: token}
    end

    test "confirms the email with a valid token", %{org_user: org_user, token: token} do
      assert {:ok, confirmed_org_user} = Accounts.confirm_org_user(token)
      assert confirmed_org_user.confirmed_at
      assert confirmed_org_user.confirmed_at != org_user.confirmed_at
      assert Repo.get!(OrgUser, org_user.id).confirmed_at
      refute Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end

    test "does not confirm with invalid token", %{org_user: org_user} do
      assert Accounts.confirm_org_user("oops") == :error
      refute Repo.get!(OrgUser, org_user.id).confirmed_at
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end

    test "does not confirm email if token expired", %{org_user: org_user, token: token} do
      {1, nil} = Repo.update_all(OrgUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.confirm_org_user(token) == :error
      refute Repo.get!(OrgUser, org_user.id).confirmed_at
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end
  end

  describe "deliver_org_user_reset_password_instructions/2" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "sends token through notification", %{org_user: org_user} do
      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_reset_password_instructions(org_user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert org_user_token = Repo.get_by(OrgUserToken, token: :crypto.hash(:sha256, token))
      assert org_user_token.org_user_id == org_user.id
      assert org_user_token.sent_to == org_user.email
      assert org_user_token.context == "reset_password"
    end
  end

  describe "get_org_user_by_reset_password_token/1" do
    setup do
      org_user = org_user_fixture()

      token =
        extract_org_user_token(fn url ->
          Accounts.deliver_org_user_reset_password_instructions(org_user, url)
        end)

      %{org_user: org_user, token: token}
    end

    test "returns the org_user with valid token", %{org_user: %{id: id}, token: token} do
      assert %OrgUser{id: ^id} = Accounts.get_org_user_by_reset_password_token(token)
      assert Repo.get_by(OrgUserToken, org_user_id: id)
    end

    test "does not return the org_user with invalid token", %{org_user: org_user} do
      refute Accounts.get_org_user_by_reset_password_token("oops")
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end

    test "does not return the org_user if token expired", %{org_user: org_user, token: token} do
      {1, nil} = Repo.update_all(OrgUserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_org_user_by_reset_password_token(token)
      assert Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end
  end

  describe "reset_org_user_password/2" do
    setup do
      %{org_user: org_user_fixture()}
    end

    test "validates password", %{org_user: org_user} do
      {:error, changeset} =
        Accounts.reset_org_user_password(org_user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{org_user: org_user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_org_user_password(org_user, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{org_user: org_user} do
      {:ok, updated_org_user} =
        Accounts.reset_org_user_password(org_user, %{password: "new valid password"})

      assert is_nil(updated_org_user.password)
      assert Accounts.get_org_user_by_email_and_password(org_user.email, "new valid password")
    end

    test "deletes all tokens for the given org_user", %{org_user: org_user} do
      _ = Accounts.generate_org_user_session_token(org_user)
      {:ok, _} = Accounts.reset_org_user_password(org_user, %{password: "new valid password"})
      refute Repo.get_by(OrgUserToken, org_user_id: org_user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%OrgUser{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
