defmodule BrambleChallenge.Seed.Demo do
  alias BrambleChallenge.Accounts

  def seed_users do
    Enum.each(1..20, &do_seed_user/1)
  end

  defp do_seed_user(number) do
    attrs = %{
      email: "user#{number}@example.com",
      password: "Test123456789"
    }

    {:ok, user} = Accounts.register_user(attrs)
    user
  end
end
