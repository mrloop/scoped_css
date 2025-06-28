require_relative 'lib/version'

Gem::Specification.new do |s|
  s.name        = 'scoped_css'
  s.version     = ScopedCss::VERSION
  s.summary     = "Scope CSS to templates and ViewComponents"
  s.description = "scoped_css provides automatic CSS scoping for Rails templates and ViewComponents. It ensures styles are isolated to specific components or templates, preventing CSS conflicts and enabling modular styling. The gem works by automatically adding unique scope identifiers to CSS rules and corresponding HTML elements, making it easy to maintain clean, conflict-free stylesheets in large applications. No CSS preprocessors or postprocessors are required."
  s.authors     = ["Ewan McDougall"]
  s.email       = 'ewan@mrloop.com'
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.license     = 'MIT'
  s.require_path = 'lib'
  s.homepage    = 'https://github.com/mrloop/scoped_css'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
