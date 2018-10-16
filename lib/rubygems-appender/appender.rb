require 'rubygems-appender/container'

module RubyGemsAppender
  module Appender
    def current_spec_indexes
      Marshal.load(Gem.read_binary(@dest_specs_index))
    end
    def current_prerelease_spec_indexes
      Marshal.load(Gem.read_binary(@dest_prerelease_specs_index))
    end
    def current_latest_spec_indexes
      Marshal.load(Gem.read_binary(@dest_latest_specs_index))
    end

    def appender(&block)
      container = Container.new self
      yield container
      container.pull_gemspecs!

      make_temp_directories

      files = Gem.time 'Build Marshal gemspecs' do
        build_marshal_gemspecs(container.specs)
      end

      if files.empty?
        say 'Gems not found'
        return
      end

      prerelease, released = container.specs.partition { |s| s.version.prerelease? }
      released_indexes = Gem.time 'Update released indexes' do
        released_indexes = current_spec_indexes.tap do |specs|
          specs.push(*released.map do |spec|
            build_spec_index spec
          end)
        end.uniq.sort
        write_spec_indexes released_indexes, @specs_index
        released_indexes
      end
      Gem.time 'Update pre-release indexes' do
        prerelease_indexes = current_prerelease_spec_indexes.tap do |specs|
          specs.push(*prerelease.map do |spec|
            build_spec_index spec
          end)
        end.uniq.sort - released_indexes
        write_spec_indexes prerelease_indexes, @prerelease_specs_index
      end
      Gem.time 'Update latest indexes' do
        latest_indexes = Hash.new { |hsh, k| hsh[k] = [] } .tap do |map|
          current_latest_spec_indexes.each do |index|
            name, _ = index
            map[name] << index
          end

          released.map do |spec|
            index = build_spec_index spec
            name, _ = index
            map[name] << index
          end
        end.values.map do |indexes|
          indexes.sort! { |(_, l, _), (_, r, _)| l <=> r }.last
        end
        write_spec_indexes latest_indexes, @latest_specs_index
      end

      compress_indices

      files += [
        @specs_index,
        "#{@specs_index}.gz",
        @latest_specs_index,
        "#{@latest_specs_index}.gz",
        @prerelease_specs_index,
        "#{@prerelease_specs_index}.gz",
      ]

      install_appended_indices(files)
    ensure
      FileUtils.rm_rf @directory
    end

    protected

    def build_spec_index(spec)
      platform = spec.original_platform
      platform = Gem::Platform::RUBY if platform.nil? or platform.empty?

      [spec.name, spec.version, platform]
    end

    def write_spec_indexes(indexes, filename)
      File.open filename, 'wb' do |io|
        Marshal.dump(compact_specs(indexes), io)
      end
    end

    def install_appended_indices(files)
      verbose = Gem.configuration.really_verbose

      FileUtils.mkdir_p(File.join(@dest_directory, @quick_marshal_dir_base))

      files.each do |tmpfile|
        file = tmpfile.sub(/^#{Regexp.escape @directory}\/?/, '') # HACK?

        src_name = File.join @directory, file
        dst_name = File.join @dest_directory, file

        FileUtils.rm_rf(dst_name, verbose: verbose)
        FileUtils.mv(src_name, dst_name,
                     verbose: verbose,
                     force: true)
      end
    end
  end
end
