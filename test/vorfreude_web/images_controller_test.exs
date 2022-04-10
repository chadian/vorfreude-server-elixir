defmodule VorfreudeWeb.ImagesControllerTests do
  use VorfreudeWeb.ConnCase

  setup do
    bypass_port = Application.get_env(:vorfreude, :bypass_port)
    bypass = Bypass.open(port: bypass_port)
    {:ok, bypass: bypass}
  end

  describe "images_controller" do
    test "requires a `search` query param", %{conn: conn} do
      conn = get(conn, Routes.images_path(conn, :index))
      assert conn.resp_body == "Search requests must use the `search` query parameter"
    end

    test "fetches proxied results", %{conn: conn, bypass: bypass} do
      flickr_result = ~s<
        {
          "photos": {
            "photo": [
              { "id": "abc123" }
            ]
          }
        }
      >

      Bypass.expect(bypass, "GET", "/", fn c ->
        Plug.Conn.resp(c, 200, flickr_result)
      end)

      conn = get(conn, Routes.images_path(conn, :index, %{"search" => "Brooklyn"}))
      result = Jason.decode!(conn.resp_body)

      [first_photo | tail] = get_in(result, ["photos", "photo"])
      assert first_photo["id"] == "abc123"
    end
  end
end
