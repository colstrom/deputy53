Gem::Specification.new do |gem|
  tag = `git describe --tags --abbrev=0`.chomp

  gem.name          = 'deputy53'
  gem.homepage      = 'https://github.com/colstrom/deputy53'
  gem.summary       = 'Delegates a subdomain to another zone with Route53'

  gem.version       = "#{tag}"
  gem.licenses      = ['MIT']
  gem.authors       = ['Chris Olstrom']
  gem.email         = 'chris@olstrom.com'

  gem.cert_chain    = ['trust/certificates/colstrom.pem']
  gem.signing_key   = File.expand_path ENV.fetch 'GEM_SIGNING_KEY'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.test_files    = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  gem.executables   = `git ls-files -z -- bin/*`.split("\x0").map { |f| File.basename(f) }

  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'aws-sdk',             '~> 2.3',   '>= 2.3.0'
  gem.add_runtime_dependency 'contracts',           '~> 0.14',  '>= 0.14.0'
  gem.add_runtime_dependency 'exponential-backoff', '~> 0.0.2', '>= 0.0.2'
  gem.add_runtime_dependency 'instacli',            '~> 1.1',   '>= 1.1.1'
end
