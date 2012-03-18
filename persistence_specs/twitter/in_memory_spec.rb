require 'spec_helper'
require 'twitter/persistence/in_memory'
require_relative 'persistence_spec'

PERSISTENCE_SPEC.call(Twitter::Persistence::User)
