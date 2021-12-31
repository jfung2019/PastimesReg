defmodule PastimesRegWeb.Router do
  use PastimesRegWeb, :router

  import PastimesRegWeb.OrgUserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PastimesRegWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_org_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PastimesRegWeb do
    pipe_through :browser

    get "/", PageController, :index
    # get "/register", RegisterController, :index
    live "/register", RegisterLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PastimesRegWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PastimesRegWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PastimesRegWeb do
    pipe_through [:browser, :redirect_if_org_user_is_authenticated]

    get "/org_users/register", OrgUserRegistrationController, :new
    post "/org_users/register", OrgUserRegistrationController, :create
    get "/org_users/log_in", OrgUserSessionController, :new
    post "/org_users/log_in", OrgUserSessionController, :create
    get "/org_users/reset_password", OrgUserResetPasswordController, :new
    post "/org_users/reset_password", OrgUserResetPasswordController, :create
    get "/org_users/reset_password/:token", OrgUserResetPasswordController, :edit
    put "/org_users/reset_password/:token", OrgUserResetPasswordController, :update
  end

  scope "/", PastimesRegWeb do
    pipe_through [:browser, :require_authenticated_org_user]

    get "/create-event", CreateEventController, :index
    get "/org_users/settings", OrgUserSettingsController, :edit
    put "/org_users/settings", OrgUserSettingsController, :update
    get "/org_users/settings/confirm_email/:token", OrgUserSettingsController, :confirm_email
  end

  scope "/", PastimesRegWeb do
    pipe_through [:browser]

    delete "/org_users/log_out", OrgUserSessionController, :delete
    get "/org_users/confirm", OrgUserConfirmationController, :new
    post "/org_users/confirm", OrgUserConfirmationController, :create
    get "/org_users/confirm/:token", OrgUserConfirmationController, :edit
    post "/org_users/confirm/:token", OrgUserConfirmationController, :update
  end
end
