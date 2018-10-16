require 'rubygems/indexer'
require 'rubygems-appender/appender'

class Gem::Indexer
  prepend RubyGemsAppender::Appender
end
