defmodule VgkjhbWeb.Router do
  use VgkjhbWeb, :router

  use Beacon.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {VgkjhbWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", VgkjhbWeb do
    pipe_through :browser

    get "/", PageController, :home

  end


  scope "/", VgkjhbWeb do
    pipe_through [:browser]

    live_session :ngb,
        root_layout: {VgkjhbWeb.Layouts, :reader} do
      live "/heidelberg", HeidelbergLive.Index, :index
     end
  end


  # Other scopes may use custom stacks.
  # scope "/api", VgkjhbWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:vgkjhb, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: VgkjhbWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/" do
    pipe_through :browser
    beacon_site "/church_site", site: :church_site
  end


end
