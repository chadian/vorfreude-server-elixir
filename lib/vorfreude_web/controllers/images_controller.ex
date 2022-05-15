defmodule VorfreudeWeb.ImagesController do
  use VorfreudeWeb, :controller

  plug(Corsica, origins: "*")

  def index(conn, %{"search" => searchTerms}) do
    json(conn, Vorfreude.FlickrClient.fetch_images(searchTerms))
  end

  def index(conn, _params) do
    conn
    |> put_status(:not_found)
    |> text("Search requests must use the `search` query parameter")
  end
end
