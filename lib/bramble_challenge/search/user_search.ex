defmodule BrambleChallenge.UserSearch do
  import Ecto.Query

  alias BrambleChallenge.Accounts.User
  alias BrambleChallenge.Repo

  def search(params) do
    User
    |> put_preload(params)
    |> put_filters(params)
    |> Repo.paginate(params)
  end

  defp put_preload(query, %{"preload" => preload}), do: preload(query, ^preload)
  defp put_preload(query, _), do: query

  defp put_filters(query, params) do
    Enum.reduce(params, query, fn param, query ->
      filter(query, param)
    end)
  end

  # Currently we support search by email
  defp filter(query, {"term", term}) do
    query
    |> where([q], ilike(q.email, ^"%#{term}%"))
  end

  defp filter(query, {"sort", %{"email" => "desc"}}),
    do: query |> order_by([q], desc: q.email)

  defp filter(query, {"sort", %{"email" => "asc"}}),
    do: query |> order_by([q], asc: q.email)

  defp filter(query, {"sort", %{"api_request" => "desc"}}),
    do: query |> order_by([q], desc: q.api_request)

  defp filter(query, {"sort", %{"api_request" => "asc"}}),
    do: query |> order_by([q], asc: q.api_request)

  defp filter(query, _), do: query
end
