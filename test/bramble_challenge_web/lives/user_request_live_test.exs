defmodule BrambleChallenWeb.UserRequestLiveTest do
  use BrambleChallengeWeb.ConnCase
  import Phoenix.LiveViewTest
  alias BrambleChallenge.Accounts

  @live_view "/users/requests"

  test "registered users should be able to access", %{conn: conn} do
    user = BrambleChallenge.AccountsFixtures.user_fixture()
    conn = log_in_user(conn, user)

    {:ok, _view, html} = live(conn, @live_view)

    assert html =~ "Users requests"
  end

  test "registered users can search by email", %{conn: conn} do
    user = BrambleChallenge.AccountsFixtures.user_fixture()
    conn = log_in_user(conn, user)

    {:ok, view, html} = live(conn, @live_view)

    assert html =~ "Users requests"

    test_email = "test@example.com"
    BrambleChallenge.AccountsFixtures.user_fixture(%{email: test_email})

    assert view |> element("#search-input") |> render_keyup(%{value: "test"}) =~ test_email
    refute view |> element("#search-input") |> render_keyup(%{value: "test"}) =~ user.email
  end

  # TODO
  #   - test pagination
  #   - test sort
  #   - test page will be updated when user make an API request
end
