defmodule BrambleChallengeWeb.UserRequestView do
  use BrambleChallengeWeb, :view

  import Phoenix.LiveView.Helpers, only: [live_patch: 2]
  alias BrambleChallengeWeb.UserRequestLive

  def live_sort_link(text, socket, search_params, sort_key) do
    sort_key = to_string(sort_key)
    {sorted_field, sorted_direction} = fetch_sorted(search_params)
    {sort_direction, sort_icon} = toggle_sort(sorted_field, sorted_direction, sort_key)

    search_params =
      search_params
      |> Map.put("sort", %{sort_key => sort_direction})
      |> Map.put("page", 1)

    ~E"""
      <%= live_patch to: Routes.live_path(socket, UserRequestLive, search_params) do %>
        <span><%= text %> <%= sort_icon %></span>
      <% end %>
    """
  end

  defp fetch_sorted(%{"sort" => sort_query}) when is_map(sort_query) do
    sort_query
    |> Enum.map(& &1)
    |> List.first()
  end

  defp fetch_sorted(_), do: {nil, nil}

  defp toggle_sort(field, "asc", field), do: {"desc", "↑"}
  defp toggle_sort(field, "desc", field), do: {"asc", "↓"}
  defp toggle_sort(_, _, _), do: {"desc", ""}

  def pagination(%Scrivener.Page{total_entries: 0}, _page_path_func),
    do: "No results found"

  def pagination(%Scrivener.Page{} = page, page_path_func) do
    content_tag :div, class: "flex" do
      content_tag :nav, class: "text-center" do
        pagination_link(page, page_path_func)
      end
    end
  end

  defp pagination_link(page, page_path_func) do
    content_tag :div, class: "flex-1 flex justify-between sm:justify-end" do
      ~E"""
      <%= if page.page_number > 1 do %>
        <%= live_patch "Previous", to: page_path_func.(page.page_number - 1), class: "inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50" %>
      <% end %>
      <%= if page.page_number < page.total_pages do %>
        <%= live_patch "Next", to: page_path_func.(page.page_number + 1), class: "ml-3 inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50" %>
      <% end %>
      """
    end
  end
end
