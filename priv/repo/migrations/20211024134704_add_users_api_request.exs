defmodule BrambleChallenge.Repo.Migrations.AddUsersApiRequest do
  use Ecto.Migration

  def change do
    alter table(:accounts_users) do
      add :api_request, :integer, default: 0
    end
  end
end
