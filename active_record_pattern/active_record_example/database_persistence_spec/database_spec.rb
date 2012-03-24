require_relative '../spec/spec_helper'
require_relative '../spec/twitter/persistence'
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3', 
  database: 'db/test.db'
)

ActiveRecord::Base.connection.execute(
  %(
    DROP TABLE 
      IF EXISTS 
      users
  )
)

ActiveRecord::Base.connection.execute(
  %(
    CREATE TABLE 
      users(
        id INTEGER, 
        username STRING, 
        PRIMARY KEY(id ASC)
      )
  )
)

require 'twitter/persistence/database'

PERSISTENCE_SPEC.call(Twitter::Persistence::User)
