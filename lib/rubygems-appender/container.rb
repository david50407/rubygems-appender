module RubyGemsAppender
  class Container
    attr_reader :specs

    def initialize(indexer)
      @specs = []
      @gems = []
      @indexer = indexer
    end

    def add(spec_or_gem)
      if spec_or_gem.is_a? String
        add_gem(spec_or_gem)
      else
        add_spec(spec_or_gem)
      end
    end

    def add_spec(spec)
      @specs << spec
    end

    def add_gem(path)
      @gems << path
    end

    def pull_gemspecs!
      @specs.push(*@indexer.map_gems_to_specs(@gems))
      @gems.clear
    end
  end
end
