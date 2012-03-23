require 'spec_helper'
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
      user_metadata
  )
)

ActiveRecord::Base.connection.execute(
  %(
    CREATE TABLE 
      user_metadata(
        id INTEGER, 
        username STRING, 
        name STRING,
        PRIMARY KEY(id ASC)
      )
  )
)

require 'mappers/database'
require 'ostruct'
require_relative 'persistence'

PERSISTENCE_SPEC.call
