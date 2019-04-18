gem_group :production do
  gem 'mysql2', '>= 0.4.4', '< 0.6.0'
end

gem "ettin", "~> 1.2"
run "bundle install"

environment "::Settings = Ettin.for(Ettin.settings_files(Rails.root.join('config'), Rails.env))"

inject_into_file ".gitignore", after: "/.bundle\n" do <<~EOF

# Ignore local settings overrides
/config/settings.local.yml
/config/settings/*.local.yml
EOF
end

file 'config/database.yml', <<~EOF
# See settings.yml for rails.database. This adds a YAML alias of all values
# there, and then includes them in every environment.
# The development.yml, test.yml, and production.yml files under settings/
# have more specific values that are included for each matching environment.
#
# The DATABASE_URL environment variable will always override settings files.

<%=
YAML.dump({'settings' => Settings.rails.database.to_h.stringify_keys})
  .split("\n")
  .drop(2)
  .unshift('default: &default')
  .join("\n")
%>

development:
  <<: *default
test:
  <<: *default
production:
  <<: *default
EOF

file 'config/cable.yml', <<~EOF
# These settings come from settings.yml, etc. No literals should be
# committed to this file.
default: &default
  adapter:        <%= Settings.rails.cable.adapter %>
  url:            <%= Settings.rails.cable.url %>
  channel_prefix: <%= Settings.rails.cable.channel_prefix %>

development:
  <<: *default
test:
  <<: *default
production:
  <<: *default
EOF

file 'config/settings.yml', <<~EOF
# Master configuration file. This holds the definitions and defaults that
# can be set per environment in settings/, or settings.local.yml. Keys can
# certainly be added in secondary files, but be sure to verify that the key
# will be used. Most values are used individually, rather than passing
# along a whole hash or array.

# These are keys used to bridge between settings and the standard Rails files.
rails:
  # Database settings as they will be mapped into database.yml for the running
  # environment. The shell variable DATABASE_URL will always override values
  # in the settings files.
  database:
    adapter: sqlite3
    pool: 5
    timeout: 5000
  # Action Cable settings applied in cable.yml
  cable:
    adapter: async
EOF

file 'config/settings/development.yml', <<~EOF
rails:
  database:
    database: db/development.sqlite3
EOF

file 'config/settings/test.yml', <<~EOF
rails:
  database:
    # Warning: The database defined as "test" will be erased and
    # re-generated from your development database when you run "rake".
    # Do not set this db to the same as development or production.
    database: db/test.sqlite3
    timeout: 10000
EOF

file 'config/settings/production.yml', <<~EOF
# Production environment configuration. These should generally receive values
# in settings.local.yml for deployed instances. If running a multi-environment
# instance for testing or debugging, production.local.yml may be helpful. As-is,
# they are compatible with a typical container-style approach, where default
# ports on generic hostnames are used for each service/resource.

rails:
  database:
    database: db/production.sqlite3
  cable:
    adapter: redis
    url: redis://redis/1
    channel_prefix: cable
EOF

say <<~EOF
-------------------------------------------------------------------------------

The Moku template has been applied. The config/database.yml and
config/cable.yml files are now totally generic and rely on the global Settings
object. See config/settings.yml for more detail.

Please ensure that any instances have a settings.local.yml file in the moku-dev
branch for that instance and that it reads from infrastructure.yml and maps all
relevant configuration values to the keys you use in the application.

Additional developer-supplied configuration values should generally be placed
in production.local.yml so settings.local.yml is strictly concerned with
mapping infrastructure values.
EOF
