Gem::Specification.new do |gem|
  gem.name        = 'deputy53'
  gem.version     = `git describe --tags --abbrev=0`.chomp
  gem.licenses    = 'MIT'
  gem.authors     = ['Chris Olstrom']
  gem.email       = 'chris@olstrom.com'
  gem.homepage    = 'https://github.com/colstrom/deputy53'
  gem.summary     = 'Delegates a subdomain to another zone with Route53'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'aws-sdk', '~> 2.3', '>= 2.3.0'
  gem.add_runtime_dependency 'contracts', '~> 0.14', '>= 0.14.0'
  gem.add_runtime_dependency 'exponential-backoff', '~> 0.0.2', '>= 0.0.2'
  gem.add_runtime_dependency 'instacli', '~> 1.1', '>= 1.1.1'
end
