# SimpleCache

SimpleCache writes a ruby object to a binary file so that it can be 
retrieved later from the disk rather than recomputed from scratch.

## Usage
SimpleCache defines a single method #load_or_recompute that receives a 
file path and a block. If the file exists and is recent (e.g., last 
changed today), #load_or_recompute returns the existing file contents 
(read with Marshal#load). Otherwise, #load_or_recompute executes the 
block, saves its return value (with Marshal#dump) and returns the new data.

```ruby
object = SimpleCache.load_or_recompute('example.dat') do
  # Code that performs a long, computationally expensive task 
  42
end

puts object # => 42
```

### Configuration

#### Cache expiration policy
SimpleCache supports two different cache policies selected via the 
configuration variable `cache_expiration_policy`.

* :not_from_today: the cache file will be regenerated it was not modified
  today (default)
* :max_age: the cache file will be regenerated if was not modified in the
  last N seconds (N is set via the cache_max_age_in_seconds configuration
  value)

Example:
```ruby
SimpleCache.configure do |config|
  config.cache_expiration_policy = :max_age
  config.cache_max_age_in_seconds = 60
end
```

#### Cache files directory
By default, cache files will be saved in the current working directory ('.').
You can choose the caceh directory via the configuration variable :cache_dir_path:

Example:
```ruby
SimpleCache.configure do |config|
  config.cache_dir_path = 'tmp/cache'
end
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ricardo-jasinski/simple_cache.

## License
The gem is available as open source under the terms of the [Unlicense](http://unlicense.org/UNLICENSE).
