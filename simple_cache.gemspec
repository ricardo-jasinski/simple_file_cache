Gem::Specification.new do |gem|
  gem.name = 'simple_cache'
  gem.version = '0.0.0'
  gem.summary = 'SimpleCache writes a ruby object to a binary file so that it ' +
    'can be retrieved later from the disk rather than recomputed from scratch.'
  gem.description = 'SimpleCache writes a ruby object to a binary file so that it ' +
    'can be retrieved later from the disk rather than recomputed from scratch. ' +
    'It defines a single method #load_or_recompute that receives a file path ' +
    'and a block. If the file exists and is recent (last changed today), it ' +
    'returns the file contents read with Marshal#load. Otherwise, it executes' +
    'the block, saves its return value with Marshal#dump and returns the new data.'
  gem.files = ['lib/simple_cache.rb']
  gem.authors = ['Ricardo Jasinski']
  gem.email = 'jasinski@solvis.com.br'
  gem.add_development_dependency 'rspec', '~> 3.7'
end
