require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'scoped_css'
  s.version     = ScopedCss::VERSION
  s.summary     = "Scoped CSS"
  s.description = "Scope CSS to templates and ViewComponents"
  s.authors     = ["Ewan McDougall"]
  s.email       = 'ewan@mrloop.com'
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.license     = 'MIT'
  s.require_path = 'lib'
end
