class SimpleCache

  # Checks whether cache file exists and is recent (last modified today). If so,
  # reads data from file using Marshal#load. Otherwise, executes the given block
  # to obtain the new data, saves to cache file using Marshal#dump and returns
  # the updated data.
  def self.load_or_recompute(cache_file_name, &block)
    if cache_file_name.include?('/')
      cache_file_pathname = cache_file_name
    else
      cache_file_pathname = 'tmp/cache/' + cache_file_name
    end

    cache_file_exists = File.exists?(cache_file_pathname)
    cache_file_is_recent = cache_file_exists && (File.mtime(cache_file_pathname) > Date.today.to_time)
    rails_production_env = defined?(Rails) && Rails.env.production?
    use_cached_copy = cache_file_is_recent && !rails_production_env

    if use_cached_copy
      log "File '#{cache_file_pathname}' exists and is recent. Using cached file."
      cache_file_contents = File.binread(cache_file_pathname)
      return Marshal.load(cache_file_contents)
    else
      log "File '#{cache_file_pathname}' inexistent or out of date. Creating new cache file."
      data_to_cache = block.call
      File.binwrite(cache_file_pathname, Marshal.dump(data_to_cache))
      return data_to_cache
    end
  end

private

  def self.log(message)
    return if ENV['TEST']
    puts message
  end

end
