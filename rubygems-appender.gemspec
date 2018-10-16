# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'rubygems-appender'
  s.version = '1.0.0'
  s.author = 'David Kuo'
  s.email = 'me@davy.tw'

  s.summary = %(Appends gems into RubyGems formatted index.)
  s.description = %(Appends new gems to generated index without old gems exists.)
  s.homepage = 'https://github.com/david50407/rubygems-appender'
  s.license = 'MIT'

  s.files = Dir['README.md', 'LICENSE', 'lib/**/*']
  s.require_path = 'lib'
end
