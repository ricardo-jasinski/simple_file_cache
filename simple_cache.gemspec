# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_cache/version'

Gem::Specification.new do |gemspec|
  gemspec.name = 'simple_cache'
  gemspec.version = SimpleCache::VERSION
  gemspec.summary = 'SimpleCache writes a ruby object to a binary file so that it ' +
    'can be retrieved later from the disk rather than recomputed from scratch.'
  gemspec.description = 'SimpleCache writes a ruby object to a binary file so that it ' +
    'can be retrieved later from the disk rather than recomputed from scratch. ' +
    'It defines a single method #load_or_recompute that receives a file path ' +
    'and a block. If the file exists and is recent (last changed today), it ' +
    'returns the file contents read with Marshal#load. Otherwise, it executes' +
    'the block, saves its return value with Marshal#dump and returns the new data.'
  gemspec.files = ['lib/simple_cache.rb']
  gemspec.authors = ['Ricardo Jasinski']
  gemspec.email = 'jasinski@solvis.com.br'
  gemspec.add_development_dependency 'rspec', '~> 3.0'
  gemspec.add_development_dependency 'byebug'
end
