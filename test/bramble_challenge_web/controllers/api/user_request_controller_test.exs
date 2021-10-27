defmodule BrambleChallengeWeb.API.UserRequestControllerTest do
  use BrambleChallengeWeb.ConnCase
  import Plug.Conn

  alias BrambleChallenge.Accounts
  alias BrambleChallenge.Accounts.UserToken

  @default_password "hello world!"
  @non_existed_email "non_existed_email@example.com"

  describe "Basic auth" do
    setup %{conn: conn} do
      user = BrambleChallenge.AccountsFixtures.user_fixture()

      {:ok, conn: conn, user: user}
    end

    test "get access token from authenticated user", %{conn: conn, user: user} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header(
          "authorization",
          Plug.BasicAuth.encode_basic_auth(user.email, @default_password)
        )
        |> put_resp_header("content-type", "application/json")
        |> post(Routes.api_user_request_path(conn, :create))

      assert json_response(conn, 200)
      assert Repo.get_by(UserToken, user_id: user.id, context: "api")
    end

    test "un-registered user or wrong email & password return unauthorized", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header(
          "authorization",
          Plug.BasicAuth.encode_basic_auth(@non_existed_email, @default_password)
        )
        |> put_resp_header("content-type", "application/json")
        |> post(Routes.api_user_request_path(conn, :create))

      assert json_response(conn, 401)
    end
  end

  describe "Bearer auth" do
    setup %{conn: conn} do
      user = BrambleChallenge.AccountsFixtures.user_fixture()

      {:ok, access_token} = Accounts.find_or_insert_access_token(user)

      {:ok, conn: conn, access_token: access_token}
    end

    test "get a list of top user requests by api usage", %{conn: conn, access_token: access_token} do
      BrambleChallenge.AccountsFixtures.insert_user(%{api_request: 3})
      BrambleChallenge.AccountsFixtures.insert_user(%{api_request: 4})
      BrambleChallenge.AccountsFixtures.insert_user(%{api_request: 5})

      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> put_req_header(
          "authorization",
          "Bearer #{access_token}"
        )
        |> put_resp_header("content-type", "application/json")
        |> post(Routes.api_user_request_path(conn, :index))

      assert resp = json_response(conn, 200)
      assert Enum.map(resp["users"], & &1["api_request"]) == [5, 4, 3]
    end
  end

  # TODO - test rate limiter
end
