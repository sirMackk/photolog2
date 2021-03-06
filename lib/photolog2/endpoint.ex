defmodule Photolog2.Endpoint do
  use Phoenix.Endpoint, otp_app: :photolog2

  socket "/socket", Photolog2.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :photolog2, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt OpenSans-Light.ttf)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader

    plug Plug.Static,
      at: "/media", from: "media", gzip: false
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    length: 100_000_000

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_photolog2_key",
    signing_salt: "C/Y/SXXz"

  plug Photolog2.Router
end
