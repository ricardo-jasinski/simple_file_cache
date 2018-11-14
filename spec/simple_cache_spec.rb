require 'spec_helper'
require 'tempfile'

describe SimpleFileCache do

  describe '#load_or_recompute' do
    it 'unmarshalls data from the cache file when it exists' do
      cache_file = new_tempfile_with_contents([1, :a, 'hello'])

      data = SimpleFileCache.load_or_recompute(cache_file.path) do
        :this_should_never_be_evaluated
      end

      expect(data).not_to eq(:this_should_never_be_evaluated)
      expect(data).to eq([1, :a, 'hello'])
    end

    it 'executes the given block and creates the cache file if it does not exist' do
      # Create a temp dir to hold the new cache file
      Dir.mktmpdir do |dir|
        cache_file_pathname = dir + '/cache.dat'
        data = SimpleFileCache.load_or_recompute(cache_file_pathname) {[1, :a, 'hello']}
        expect(data).to eq([1, :a, 'hello'])
      end
    end

    it 'executes the given block and recreates the cache file if it is outdated' do
      cache_file = new_tempfile_with_contents('existing content')
      FileUtils.touch cache_file.path, mtime: Date.today.prev_day.to_time
      data = SimpleFileCache.load_or_recompute(cache_file.path) {'new content'}
      expect(data).to eq('new content')
    end

    it 'executes the given block and recreates the cache file if it is recent' do
      cache_file = new_tempfile_with_contents('existing content')
      FileUtils.touch cache_file.path, mtime: Time.now
      data = SimpleFileCache.load_or_recompute(cache_file.path) {'new content'}
      expect(data).to eq('existing content')
    end

    describe 'configuration' do
      describe '#cache_dir_path=' do
        it 'sets the cache files directory' do
          Dir.mktmpdir do |test_cache_dir|
            SimpleFileCache.configure {|config| config.cache_dir_path = test_cache_dir }
            SimpleFileCache.load_or_recompute('test_cache.dat') {'new content'}
            expect(File).to exist("#{test_cache_dir}/test_cache.dat")
          end
        end
      end

      describe '#cache_expiration_policy=' do
        describe ':yesterday_or_earlier' do
          before do
            SimpleFileCache.configure do |config|
              config.cache_expiration_policy = :yesterday_or_earlier
            end
            @cache_file = new_tempfile_with_contents('existing content')
          end

          it 'uses the existing file if it was last changed today' do
            todays_first_second = Date.today.to_time
            FileUtils.touch(@cache_file.path, mtime: todays_first_second)
            data = SimpleFileCache.load_or_recompute(@cache_file.path) {'new content'}
            expect(data).to eq('existing content')
          end

          it 'recomputes the file if it was last changed yesterday' do
            yesterdays_last_second = Date.today.to_time - 1
            FileUtils.touch(@cache_file.path, mtime: yesterdays_last_second)
            data = SimpleFileCache.load_or_recompute(@cache_file.path) {'new content'}
            expect(data).to eq('new content')
          end
        end

        describe ':max_age' do
          before do
            allow(Time).to receive(:now).and_return(Time.new('2018-01-01 10:00:00'))
            SimpleFileCache.configure do |config|
              config.cache_expiration_policy = :max_age
              config.cache_max_age_in_seconds = 60
            end
            @cache_file = new_tempfile_with_contents('existing content')
            @one_minute_ago = Time.now - 60
          end

          it 'uses the existing file if it was changed in the last 60 seconds' do
            FileUtils.touch(@cache_file.path, mtime: @one_minute_ago)
            data = SimpleFileCache.load_or_recompute(@cache_file.path) {'new content'}
            expect(data).to eq('existing content')
          end

          it 'recomputes the file if it is older than 60 seconds' do
            FileUtils.touch(@cache_file.path, mtime: @one_minute_ago - 1)
            data = SimpleFileCache.load_or_recompute(@cache_file.path) {'new content'}
            expect(data).to eq('new content')
          end
        end
      end
    end
  end

  def new_tempfile_with_contents(file_contents)
    tempfile = Tempfile.new('cache.dat')
    File.write(tempfile.path, Marshal.dump(file_contents))
    tempfile
  end

end