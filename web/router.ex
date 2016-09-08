defmodule Photolog2.Router do
  use Photolog2.Web, :router
  import Photolog2.Auth, only: [authenticate_user: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Photolog2.Auth, repo: Photolog2.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Photolog2 do
    pipe_through :browser # Use the default browser stack

    # Log in and out
    get "/hej", SessionController, :new
    post "/hej", SessionController, :create
    post "/papa", SessionController, :delete

    get "/", PageController, :index

  end

  scope "/gory", Photolog2 do
    pipe_through [:browser, :authenticate_user]

    resources "/", AdminAlbumController
  end


  # Other scopes may use custom stacks.
  # scope "/api", Photolog2 do
  #   pipe_through :api
  # end
end
