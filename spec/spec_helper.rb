# frozen_string_literal: true

require 'rspec'
require 'webmock/rspec'
require 'omniauth'
require 'omniauth/strategies/tinkoff_id'

RSpec.configure do |config|
  config.include WebMock::API
  config.extend  OmniAuth::Test::StrategyMacros, type: :strategy
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
