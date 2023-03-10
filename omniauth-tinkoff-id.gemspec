# frozen_string_literal: true

require_relative 'lib/omniauth/tinkoff_id/version'

Gem::Specification.new do |spec|
  spec.name = 'omniauth-tinkoff-id'
  spec.version = Omniauth::TinkoffId::VERSION
  spec.authors = ['Yury Druzhkov']
  spec.email = ['bad1lamer@gmail.com']

  spec.summary = 'TinkoffId OAuth2 Strategy for OmniAuth'
  spec.homepage = 'https://github.com/foxford/omniauth-tinkoff-id'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.files         = `git ls-files`.split("\n")
  spec.require_paths = ['lib']
  spec.add_runtime_dependency 'omniauth-oauth2', '>= 1.5', '<= 1.8.0'
end
