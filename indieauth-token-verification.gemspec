# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'indie_auth/token_verification/version'

Gem::Specification.new do |spec|
  spec.name          = "indieauth-token-verification"
  spec.version       = IndieAuth::TokenVerification::VERSION
  spec.authors       = ["Stephen Rushe"]
  spec.email         = ["steve+gemspec@deeden.co.uk"]

  spec.summary       = %q{Perform the access token verification portion of the IndieAuth process.}
  spec.description   = %q{Perform the access token verification portion of the IndieAuth process by communicationg with a token endpoint.}
  spec.homepage      = "https://github.com/srushe/indieauth-token-verification"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ENV.fetch('GEMSERVER_URL', 'nohost')
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
