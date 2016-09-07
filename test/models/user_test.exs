defmodule Photolog2.UserTest do
  use Photolog2.ModelCase, async: true

  alias Photolog2.User

  @valid_attrs %{username: "test"}
  @invalid_attrs %{}

  test "changest with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "registration_changeset requires password" do
    changeset = User.registration_changeset(%User{}, %{username: "test"})
    refute changeset.valid?
  end

  @short_passwd %{username: "test", password: "short"}
  test "registration_changeset doesnt accept short passwords" do
    changeset = User.registration_changeset(%User{}, @short_passwd)
    refute changeset.valid?
  end

  @valid_attrs %{username: "test", password: "12345678"}
  test "registration_changeset hashes password" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    %{password: pass, password_hash: pass_hash} = changeset.changes

    assert changeset.valid?
    assert pass_hash
    assert Comeonin.Bcrypt.checkpw(pass, pass_hash)
  end
end
