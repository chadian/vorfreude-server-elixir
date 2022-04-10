import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vorfreude, VorfreudeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "IZsISBfraJlAPFXMf+RPXF1Da09lpJWZ1Qd9UJ4egJ3BNCqEJXcMgrFgozoQwNCl",
  server: false

# Use a localhost bypass server
bypass_port = 4800
config :vorfreude, :bypass_port, bypass_port
config :vorfreude, :flickr_api_url, "http://localhost:#{bypass_port}/"

# In test we don't send emails.
config :vorfreude, Vorfreude.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
