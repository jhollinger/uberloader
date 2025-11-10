require_relative 'lib/uberloader/version'

Gem::Specification.new do |s|
  s.name = "uberloader"
  s.version = Uberloader::VERSION
  s.licenses = ["MIT"]
  s.summary = "Advanced preloading for ActiveRecord"
  s.description = "Customizable SQL when preloading in ActiveRecord"
  s.authors = ["Jordan Hollinger"]
  s.email = "jordan.hollinger@gmail.com"
  s.homepage = "https://github.com/jhollinger/uberloader"
  s.require_paths = ["lib"]
  s.files = [Dir.glob("lib/**/*"), "README.md"].flatten
  s.required_ruby_version = ">= 3.0.0"
  s.add_runtime_dependency "activerecord", [">= 6.0", "< 9.0"]
end
