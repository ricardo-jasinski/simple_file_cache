require 'spec_helper'
require 'tempfile'

describe SimpleCache do

  describe '#load_or_recompute' do
    it 'unmarshalls data from the cache file when it exists' do
      # Manually create a cache file containing an array serialied by Marshal.dump
      cache_file = Tempfile.new('cache.dat')
      File.write(cache_file.path, Marshal.dump([1, :a, 'hello']))

      data = SimpleCache.load_or_recompute(cache_file.path) do
        :this_line_should_never_be_evaluated
      end

      expect(data).not_to eq(:this_line_should_never_be_evaluated)
      expect(data).to eq([1, :a, 'hello'])
    end

    it 'executes the given block and creates the cache file it it does not exist' do
      # Create a temp dir to hold our new cache file
      Dir.mktmpdir do |dir|
        cache_file_pathname = dir + '/cache.dat'

        data = SimpleCache.load_or_recompute(cache_file_pathname) do
          [1, :a, 'hello']
        end

        expect(data).to eq([1, :a, 'hello'])
      end
    end
  end

end