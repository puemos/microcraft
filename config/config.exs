# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

alias AshMoney.Types.Money

config :ash,
  include_embedded_source_by_default?: false,
  show_keysets_for_all_actions?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false],
  known_types: [Money],
  custom_types: [
    money: Money,
    currency: Microcraft.Types.Currency,
    unit: Microcraft.Types.Unit
  ]

config :elixir, :time_zone_database, Tz.TimeZoneDatabase

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  microcraft: [
    args:
      ~w(js/app.js js/storybook.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :ex_cldr, default_backend: Microcraft.Cldr

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :microcraft, Microcraft.Mailer, adapter: Swoosh.Adapters.Local

# Configures the endpoint
config :microcraft, MicrocraftWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: MicrocraftWeb.ErrorHTML, json: MicrocraftWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Microcraft.PubSub,
  live_view: [signing_salt: "vNk6HzXn"]

config :microcraft,
  ecto_repos: [Microcraft.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [
    Microcraft.Settings,
    Microcraft.CRM,
    Microcraft.Orders,
    Microcraft.Inventory,
    Microcraft.Catalog,
    Microcraft.Accounts
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :authentication,
        :tokens,
        :postgres,
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [section_order: [:resources, :policies, :authorization, :domain, :execution]]
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  microcraft: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ],
  storybook: [
    args: ~w(
            --config=tailwind.config.js
            --input=css/storybook.css
            --output=../priv/static/assets/storybook.css
          ),

    # Import environment specific config. This must remain at the bottom
    # of this file so it overrides the configuration defined above.
    cd: Path.expand("../assets", __DIR__)
  ]

import_config "#{config_env()}.exs"
