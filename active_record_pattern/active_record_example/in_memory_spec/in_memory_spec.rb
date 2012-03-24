require_relative '../spec/spec_helper'
require 'twitter/persistence/in_memory'
require_relative '../spec/twitter/persistence'

PERSISTENCE_SPEC.call(Twitter::Persistence::User)
