defmodule PastimesRegWeb.PageController do
  use PastimesRegWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
