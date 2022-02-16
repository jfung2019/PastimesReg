defmodule PastimesReg.ParticipantsTest do
  use PastimesReg.DataCase

  alias PastimesReg.Participants

  describe "participants" do
    alias PastimesReg.Participants.Participant

    import PastimesReg.ParticipantsFixtures

    @invalid_attrs %{
      address_1: nil,
      address_2: nil,
      city: nil,
      country: nil,
      dob: nil,
      email_address: nil,
      email_address_confirmation: nil,
      emergency_contact_name: nil,
      emergency_contact_number: nil,
      first_name: nil,
      gender: nil,
      last_name: nil,
      phone_number: nil,
      state: nil,
      waiver_initials: nil,
      zip: nil
    }

    test "list_participants/0 returns all participants" do
      participant = participant_fixture()
      assert Participants.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
      assert Participants.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      valid_attrs = %{
        address_1: "some address_1",
        address_2: "some address_2",
        city: "some city",
        country: "some country",
        dob: "some dob",
        email_address: "some email_address",
        email_address_confirmation: "some email_address_confirmation",
        emergency_contact_name: "some emergency_contact_name",
        emergency_contact_number: "some emergency_contact_number",
        first_name: "some first_name",
        gender: "some gender",
        last_name: "some last_name",
        phone_number: "some phone_number",
        state: "some state",
        waiver_initials: "some waiver_initials",
        zip: "some zip"
      }

      assert {:ok, %Participant{} = participant} = Participants.create_participant(valid_attrs)
      assert participant.address_1 == "some address_1"
      assert participant.address_2 == "some address_2"
      assert participant.city == "some city"
      assert participant.country == "some country"
      assert participant.dob == "some dob"
      assert participant.email_address == "some email_address"
      assert participant.email_address_confirmation == "some email_address_confirmation"
      assert participant.emergency_contact_name == "some emergency_contact_name"
      assert participant.emergency_contact_number == "some emergency_contact_number"
      assert participant.first_name == "some first_name"
      assert participant.gender == "some gender"
      assert participant.last_name == "some last_name"
      assert participant.phone_number == "some phone_number"
      assert participant.state == "some state"
      assert participant.waiver_initials == "some waiver_initials"
      assert participant.zip == "some zip"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Participants.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()

      update_attrs = %{
        address_1: "some updated address_1",
        address_2: "some updated address_2",
        city: "some updated city",
        country: "some updated country",
        dob: "some updated dob",
        email_address: "some updated email_address",
        email_address_confirmation: "some updated email_address_confirmation",
        emergency_contact_name: "some updated emergency_contact_name",
        emergency_contact_number: "some updated emergency_contact_number",
        first_name: "some updated first_name",
        gender: "some updated gender",
        last_name: "some updated last_name",
        phone_number: "some updated phone_number",
        state: "some updated state",
        waiver_initials: "some updated waiver_initials",
        zip: "some updated zip"
      }

      assert {:ok, %Participant{} = participant} =
               Participants.update_participant(participant, update_attrs)

      assert participant.address_1 == "some updated address_1"
      assert participant.address_2 == "some updated address_2"
      assert participant.city == "some updated city"
      assert participant.country == "some updated country"
      assert participant.dob == "some updated dob"
      assert participant.email_address == "some updated email_address"
      assert participant.email_address_confirmation == "some updated email_address_confirmation"
      assert participant.emergency_contact_name == "some updated emergency_contact_name"
      assert participant.emergency_contact_number == "some updated emergency_contact_number"
      assert participant.first_name == "some updated first_name"
      assert participant.gender == "some updated gender"
      assert participant.last_name == "some updated last_name"
      assert participant.phone_number == "some updated phone_number"
      assert participant.state == "some updated state"
      assert participant.waiver_initials == "some updated waiver_initials"
      assert participant.zip == "some updated zip"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Participants.update_participant(participant, @invalid_attrs)

      assert participant == Participants.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Participants.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Participants.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Participants.change_participant(participant)
    end
  end
end
