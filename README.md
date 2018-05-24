# SimpleCache

SimpleCache writes a ruby object to a binary file so that it can be retrieved 
later from the disk rather than recomputed from scratch.

## Usage
SimpleCache defines a single method #load_or_recompute that receives a file path and a 
block. If the file exists and is recent (e.g., last changed today), #load_or_recompute returns the 
existing file contents (read with Marshal#load). Otherwise, #load_or_recompute executes the block, 
saves its return value (with Marshal#dump) and returns the new data.

```ruby
object = SimpleCache.load_or_recompute('example.dat') do
  # Code that performs a long, computationally expensive task 
  42
end

puts object # => 42
```

### Configuration
