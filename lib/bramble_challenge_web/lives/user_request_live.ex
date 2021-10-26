defmodule BrambleChallengeWeb.UserRequestLive do
  use BrambleChallengeWeb, :live_view

  alias BrambleChallenge.Accounts
  alias BrambleChallenge.Accounts.User
  alias BrambleChallenge.UserSearch
  alias BrambleChallengeWeb.UserRequestView

  @user_request_topic "incoming-user-request"

  def render(assigns) do
    UserRequestView.render("index.html", assigns)
  end

  def mount(_params, %{"user_token" => token}, socket) do
    if connected?(socket),
      do: Phoenix.PubSub.subscribe(BrambleChallenge.PubSub, @user_request_topic)

    case Accounts.get_user_by_session_token(token) do
      %User{} = user ->
        socket =
          socket
          |> assign(current_user: user)

        {:ok, socket}

      nil ->
        socket =
          socket
          |> put_flash(:error, "You're not authorized.")
          |> redirect(to: "/")

        {:ok, socket}
    end
  end

  def handle_info(:update_user_request, %{assigns: %{search_params: search_params}} = socket) do
    page = UserSearch.search(search_params)

    {:noreply, assign(socket, page: page)}
  end

  def handle_params(unsigned_params, _uri, socket) do
    default_search_params = %{
      "sort" => %{"api_request" => "desc"},
      "page" => 1
    }

    search_params = Map.merge(default_search_params, unsigned_params)

    page = UserSearch.search(search_params)

    {:noreply,
     assign(socket,
       page: page,
       search_params: search_params,
       page_path_func:
         &Routes.live_path(socket, __MODULE__, Map.merge(search_params, %{page: &1}))
     )}
  end

  def handle_event("search", %{"value" => term}, socket) do
    # TODO - could change this into `suggestions` and limit the return results.
    page = UserSearch.search(%{"term" => term})

    {:noreply, assign(socket, page: page)}
  end
end
