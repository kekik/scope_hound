# frozen_string_literal: true

module ScopeHound
  # Initialize the rails engine for the gem.
  class Engine < ::Rails::Engine
    isolate_namespace ScopeHound
  end
end
