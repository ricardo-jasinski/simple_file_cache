require 'spec_helper'
require 'tempfile'

describe SimpleCache do

  describe 'configuration' do
    describe '#cache_dir_path=' do
      it 'sets the cache files directory' do
        Dir.mktmpdir do |test_cache_dir|
          SimpleCache.configure {|config| config.cache_dir_path = test_cache_dir }
          SimpleCache.load_or_recompute('test_cache.dat') { 42 }
          expect(File).to exist("#{test_cache_dir}/test_cache.dat")
        end
      end
    end
  end

  describe '#load_or_recompute' do
    it 'unmarshalls data from the cache file when it exists' do
      # Manually create a cache file containing an array serialized by Marshal.dump
      # cache_file = Tempfile.new('cache.dat')
      # File.write(cache_file.path, Marshal.dump([1, :a, 'hello']))
      cache_file = new_tempfile_with_contents([1, :a, 'hello'])

      data = SimpleCache.load_or_recompute(cache_file.path) do
        :this_line_should_never_be_evaluated
      end

      expect(data).not_to eq(:this_line_should_never_be_evaluated)
      expect(data).to eq([1, :a, 'hello'])
    end

    it 'executes the given block and creates the cache file if it does not exist' do
      # Create a temp dir to hold the new cache file
      Dir.mktmpdir do |dir|
        cache_file_pathname = dir + '/cache.dat'
        data = SimpleCache.load_or_recompute(cache_file_pathname) {[1, :a, 'hello']}
        expect(data).to eq([1, :a, 'hello'])
      end
    end

    it 'executes the given block and recreates the cache file if it is outdated' do
      cache_file = new_tempfile_with_contents(13)
      FileUtils.touch cache_file.path, :mtime => Time.now - 1*60*60*24*2
      data = SimpleCache.load_or_recompute(cache_file.path) {42}
      expect(data).to eq(42)
    end

    it 'executes the given block and recreates the cache file if it is recent' do
      cache_file = new_tempfile_with_contents(13)
      FileUtils.touch cache_file.path, :mtime => Time.now
      data = SimpleCache.load_or_recompute(cache_file.path) {42}
      expect(data).to eq(13)
    end
  end

  def new_tempfile_with_contents(file_contents)
    tempfile = Tempfile.new('cache.dat')
    File.write(tempfile.path, Marshal.dump(file_contents))
    tempfile
  end

end