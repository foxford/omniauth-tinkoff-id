# T-Id OAuth strategy for OmniAuth

[![Ruby](https://github.com/foxford/omniauth-tinkoff-id/actions/workflows/main.yml/badge.svg)](https://github.com/foxford/omniauth-tinkoff-id/actions/workflows/main.yml)

[![sponsored by foxford](https://user-images.githubusercontent.com/1637293/224282750-6131144c-fdee-4943-9387-35641cedd99c.svg)](https://foxford.ru?utm_source=github)

## Getting Started

### Prerequisites

This gem require [OmniAuth](http://github.com/intridea/omniauth)

But you no need add `gem 'omniauth'`.

This gem already added.

### Installation

    gem "omniauth-tinkoff-id"

[Join](https://developer.tbank.ru/docs/intro/partner/tid) to TinkoffId

### Usage

1. Add to omniauth.rb tinkoff_id provider:

        Rails.application.config.middleware.use OmniAuth::Builder do
            provider :tinkoff_id, ENV['TINKOFF_CLIENT_ID'], ENV['TINKOFF_CLIENT_SECRET']
        end

2. Add route

        get '/auth/:provider/callback', to: 'sessions#create'

3. Create SessionController
###### note: This controller only as example how to create user by callback

        class SessionsController < ApplicationController
          def create
            @user = User.find_or_create_from_auth_hash(auth_hash)
            redirect_to '/'
          end

          protected

          def auth_hash
            request.env['omniauth.auth']
          end
        end


## Contributing

1. Fork it (<https://github.com/foxford/omniauth-tinkoff-id/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available,
see the [tags on this repository](ttps://github.com/foxford/omniauth-tinkoff-id/tags).

## Authors

* [ Yury Druzhkov ](https://github.com/badlamer) - Initial work

See also the list of [contributors](https://github.com/foxford/omniauth-tinkoff-id/contributors) who participated in this project.

## License

This project is licensed under the [MIT License](LICENSE.txt).

## Acknowledgments

* https://developer.tbank.ru/docs/intro/partner/tid
