# RubyGems Appender

This plugin can let you append gems into indexes without pulling all gems.

## Usage

Put your gems into `gems` inside indexes directory structure.

And remember to put last indexes (and `quick`) into the directory.

```
> indexer = Gem::Indexer.new('path/to/indexes_directory')
> indexer.appender do |c|
>   c.add('gem/some_awesome_gem-2.0.0.gem')
>   c.add('gem/some_awesome_gem-2.1.0.gem')
> end
Generating Marshal quick index gemspecs for 2 gems

Complete
Generated Marshal quick index gemspecs: 0.000s
Generating specs index
Generated specs index: 0.000s
Generating latest specs index
Generated latest specs index: 0.000s
Generating prerelease specs index
Generated prerelease specs index: 0.014s
Compressing indices
Compressed indices: 0.001s
```

:tada:

## License

MIT License.
