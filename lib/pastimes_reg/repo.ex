defmodule PastimesReg.Repo do
  use Ecto.Repo,
    otp_app: :pastimes_reg,
    adapter: Ecto.Adapters.Postgres
end
