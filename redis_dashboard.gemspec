lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "redis_dashboard"
  spec.version       = "0.1.3"
  spec.authors       = ["Alexis Bernard"]
  spec.email         = ["alexis@bernard.io"]
  spec.summary       = "Sinatra app to monitor Redis servers."
  spec.description   = "Sinatra app to monitor Redis servers"
  spec.homepage      = "https://github.com/BaseSecrete/redis_dashboard"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "sass"
end
