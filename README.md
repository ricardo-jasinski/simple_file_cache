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
SimpleCache cache policy can be set 
 
SimpleCache supports two different cache policies selected via the 
configuration variable `cache_expiration_policy`.

* :not_from_today: the cache file will be regenerated it was not modified
  today
* :max_age: the cache file will be regenerated if was not modified in the
  last N seconds (N is set via the cache_max_age_in_seconds configuration
  value)

