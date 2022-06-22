source 'https://rubygems.org'
ruby File.read('.ruby-version', mode: 'rb').chomp

gem 'beeminder', git: 'https://github.com/beeminder/beeminder-gem.git'
gem 'awesome_print', :require => 'ap'
gem 'sequel'
# gem 'sqlite3'
gem 'activesupport', '~> 6.0'
gem 'thor'
gem 'rake'
gem 'rspec', '~> 3.0'
gem 'rspec_junit_formatter'
# gem 'nokogiri'
gem 'rest-client'
gem 'webmock'
# gem 'pry'
# gem 'ruby-debug-ide'

def os_is(re)
  RbConfig::CONFIG['host_os'] =~ re
end

## Select a debase version for your OS when using ruby-debug-ide
# gem 'debase', '~> 0.2.5.beta2', platforms: :ruby, install_if: os_is(/linux/)
# gem 'debase', '~> 0.2.4', platforms: :ruby, install_if: os_is(/darwin/)

gem 'fiber_scheduler'
# gem 'faraday'
# gem 'byebug'
# gem 'tty-command', git: 'https://github.com/justingaylor/tty-command.git', branch: 'fixDoubleSplatRuby3'
