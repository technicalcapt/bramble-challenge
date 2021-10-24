defmodule BrambleChallenge.Repo do
  use Ecto.Repo,
    otp_app: :bramble_challenge,
    adapter: Ecto.Adapters.Postgres
end
