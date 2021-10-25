defmodule BrambleChallenge.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BrambleChallenge.Accounts` context.
  """

  alias BrambleChallenge.Repo
  alias BrambleChallenge.Accounts.User

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> BrambleChallenge.Accounts.register_user()

    user
  end

  def insert_user(attrs \\ %{}) do
    attrs =
      attrs
      |> valid_user_attributes()

    {:ok, user} =
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
