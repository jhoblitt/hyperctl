$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'hyperctl/version'

Gem::Specification.new do |s|
  s.name        = 'hyperctl'
  s.version     = Hyperctl::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Joshua Hoblitt']
  s.email       = ['jhoblitt@cpan.org']
  s.homepage    = 'https://github.com/jhoblitt/hyperctl'
  s.summary     = %q{A utility for enabling/disabling hyperthreading}
  s.description = %q{A utility for enabling/disabling hyperthreading}
  s.license     = 'Apache 2.0'

  s.required_ruby_version = '>= 1.8.7'
  s.add_runtime_dependency("docopt", ">= 0.5.0")
  s.add_development_dependency('rspec', '>= 2.0.0')
  s.add_development_dependency('rspec-expectations', '>= 2.0.0')
  s.add_development_dependency('rspec-mocks', '>= 2.0.0')
  s.add_development_dependency('rake', '>= 10.0.0')
  s.add_development_dependency('aruba', '~> 0.4.6')
  s.add_development_dependency('fakefs', '~> 0.5.2')
  s.add_development_dependency('mocha', '~> 1.0')
  s.add_development_dependency('yard', '~> 0.8')

  s.rubygems_version = '>= 1.6.1'
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path     = 'lib'
end
