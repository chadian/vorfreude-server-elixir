defmodule Vorfreude.FlickrClient do
  require Logger

  def fetch_images(searchTerms) do
    HTTPoison.get(flickr_search_url(searchTerms))
    |> handle_result
  end

  defp handle_result(result) do
    missing_api_key_code = 100
    empty_result = %{"photos" => %{"photo" => []}}

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- result,
         parsed_body when not is_map_key(parsed_body, "code") <- Jason.decode!(body) do
      parsed_body
    else
      {:error, error} ->
        Logger.error("Failed with internal error:")
        Logger.error(inspect(error))
        empty_result

      %{"code" => ^missing_api_key_code} ->
        Logger.error(
          "Missing or invalid API KEY, ensure it's correct and set as an environment variable"
        )

        empty_result

      result ->
        Logger.error("Failed with error:")
        Logger.error(inspect(result))
        empty_result
    end
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

    api_url = URI.parse(flickr_api_url())
    api_url = Map.put(api_url, :query, URI.encode_query(query))
    URI.to_string(api_url)
  end


  defp flickr_api_key do
    Application.get_env(:vorfreude, :flickr_api_key)
  end

  defp flickr_api_url do
    Application.get_env(:vorfreude, :flickr_api_url)
  end
end
