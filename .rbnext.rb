module MRubyNext
  refine MRuby::Gem::Specification do
    # Add transpiled files to the list of Ruby files instead of source files
    def setup_ruby_next!(next_dir: ".rbnext")
      lib_root = File.join(@dir, "mrblib")

      next_root = Pathname.new(next_dir).absolute? ? next_dir : File.join(lib_root, next_dir)

      Dir.glob("#{next_root}/**/*.rb").each do |next_file|
        orig_file = next_file.sub(next_root, lib_root)
        index = @rbfiles.index(orig_file)
        raise "Source file not found for: #{next_file}" unless index
        @rbfiles[index] = next_file
      end
    end
  end
end
