Gem::Specification.new do |s|
  s.name = "spellcheck"
  s.version = "0.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Sosedoff"]
  s.date = %q{2010-08-27}
  s.description = %q{Spellcheck module based on Redis key-value storage server}
  s.email = %q{dan.sosedoff@gmail.com}
  s.files = [
    "README",
    "lib/spellcheck.rb",
  ]
  s.homepage = %q{http://github.com/sosedoff/spellcheck}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simple word and phrase spell check/correction}
  
  s.add_dependency("redis", ["~> 2.0.5"])
end

