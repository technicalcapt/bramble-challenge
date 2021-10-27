defmodule BrambleChallengeWeb.API.UserRequestController do
  use BrambleChallengeWeb, :controller
  alias BrambleChallenge.Accounts
  alias BrambleChallenge.Accounts.User
  alias BrambleChallenge.RateLimiter

  plug :basic_auth when action in [:create]
  plug :bearer_auth when action in [:index]

  @user_request_topic "incoming-user-request"

  def index(%{assigns: %{user_id: user_id}} = conn, _params) do
    case RateLimiter.log(user_id) do
      :ok ->
        {_updates, _selected} = Accounts.update_user_api_request(user_id)

        Phoenix.PubSub.broadcast!(
          BrambleChallenge.PubSub,
          @user_request_topic,
          :update_user_request
        )

        # Maybe we should rescue in case of raise/ unmatch error.

        users = Accounts.list_top_users_by_api_request()

        conn
        |> put_status(:ok)
        |> json(%{users: users})

      {:error, :rate_limited} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "API requests have exceeded 5 requests per minute."})
    end
  end

  def create(%{assigns: %{current_user: current_user}} = conn, _params) do
    {:ok, access_token} = Accounts.find_or_insert_access_token(current_user)

    conn
    |> put_status(:ok)
    |> json(%{access_token: access_token})
  end

  # Plug function to validate basic user authentication.
  defp basic_auth(conn, _opts) do
    with {email, pass} <- Plug.BasicAuth.parse_basic_auth(conn),
         %User{} = user <- Accounts.get_user_by_email_and_password(email, pass) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unknown email or password."})
        |> halt()
    end
  end

  # Plug function to validate bearer (token) authentication.
  defp bearer_auth(conn, _otps) do
    with ["Bearer " <> access_token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Accounts.verify_access_token(access_token) do
      assign(conn, :user_id, user_id)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired token."})
        |> halt()
    end
  end
end
