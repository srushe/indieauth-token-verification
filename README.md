# IndieAuth::TokenVerification

Verify an IndieAuth access token against a token endpoint, ensuring that the scope required is one of those associated with the token.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'indieauth-token-verification'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install indieauth-token-verification

## Configuration

Use of the gem **requires** two environment variables to be specified, `TOKEN_ENDPOINT`, and `DOMAIN`.

`TOKEN_ENDPOINT` specifies the token endpoint to be used to validate the access token. Failure to specify `TOKEN_ENDPOINT` will result in a `IndieAuth::TokenVerification::MissingTokenEndpointError` error being raised.

`DOMAIN` specifies the domain we expect to see in the response from the validated token. It should match that specified when the token was first generated. Failure to specify `DOMAIN` will result in a `IndieAuth::TokenVerification::MissingDomainError` error being raised.

## Usage

```ruby
# Verify the provided access token, with no scope requirement
IndieAuth::TokenVerification.new(access_token).verify

# Verify the provided access token, requiring a particular scope
IndieAuth::TokenVerification.new(access_token).verify("media")
```

## Errors

As well as `MissingTokenEndpointError` and `MissingDomainError` mentioned above, there are other errors which will be raised in certain circumstances...

* `IndieAuth::TokenVerification::AccessTokenMissingError` - when the access token is missing
* `IndieAuth::TokenVerification::ForbiddenUserError` - when the token endpoint reports an error
* `IndieAuth::TokenVerification::IncorrectMeError` - when the `me` value in the response does not match the `DOMAIN`
* `IndieAuth::TokenVerification::InsufficentScopeError` - when the scope requested is not granted by the access token

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/srushe/indieauth-token-verification. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
