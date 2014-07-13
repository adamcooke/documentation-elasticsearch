Gem::Specification.new do |s|
  s.name        = "documentation-elasticsearch"
  s.version     = '1.0.0'
  s.authors     = ["Adam Cooke"]
  s.email       = ["adam@atechmedia.com"]
  s.homepage    = "http://adamcooke.io"
  s.licenses    = ['MIT']
  s.summary     = "An Elasticsearch module for the Documentation gem"
  s.description = "Adds support for Elasticsearch to the Documentation gem"
  
  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  
  s.add_dependency "documentation", ">= 1.0.0", "< 2.0.0"
  s.add_dependency 'elasticsearch', '~> 1.0.4'
  
end
