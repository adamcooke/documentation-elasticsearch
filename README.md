# Documentation Elasticsearch

This is a module for Documentation which replaces the searcher searcher with one powered by Elasticsearch.

## Installation

Add the gem to your Gemfile and run `bundle`.

```ruby
gem 'documentation-elasticsearch', '~> 1.0'
```

Once installed, you should add an initializer to your Rails application to add configuration.

```ruby
require 'documentation/searchers/elasticsearch'
Documentation.config.searcher = Documentation::Searchers::Elasticsearch.new(:host => 'localhost')
```

## Setup

Once installed, you'll probably want to index all your documents.

```ruby
# Remove any existing index
Documentation.config.searcher.reset
# Index all pages
Documentation::Page.all.each(&:index)
```
