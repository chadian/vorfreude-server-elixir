defmodule VorfreudeWeb.ImagesController do
  require Logger
  use VorfreudeWeb, :controller

  plug Corsica, origins: "*"

  @flickr_api_url "https://api.flickr.com/services/rest"

  def index(conn, %{"search" => searchTerms}) do
    results(conn, HTTPoison.get(flickr_search_url(searchTerms)))
  end

  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> text("Search requests must use the `search` query parameter")
  end

  defp results(conn, {:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    json(conn, Jason.decode!(body))
  end

  defp results(conn, {:error, error}) do
    Logger.error("Failed with error:")
    Logger.error(error)
    empty_result = %{"photos" => %{"photo" => []}}
    json(conn, empty_result)
  end

  defp flickr_search_url(searchTerms) do
    api_key = flickr_api_key()

    query = %{
      "api_key" => api_key,
      "text" => searchTerms,
      "method" => "flickr.photos.search",
      "format" => "json",
      "nojsoncallback" => "1",
      "safe_search" => "1",
      "privacy_filter" => "1",
      "sort" => "interestingness-desc",
      "per_page" => "500",
      "extras" => "url_o"
    }

    encoded_query = URI.encode_query(query)
    @flickr_api_url <> "?" <> encoded_query
  end

  defp flickr_api_key do
    Application.get_env(:vorfreude, :flickr_api_key)
  end
end
