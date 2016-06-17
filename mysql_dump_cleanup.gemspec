$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mysql_dump_cleanup/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mysql_dump_cleanup"
  s.version     = MysqlDumpCleanup::VERSION
  s.authors     = ["Kvokka"]
  s.email       = ["root_p@mail.ru"]
  s.homepage    = "http://github.com/kvokka/mysql_dump_cleanup"
  s.summary     = "Deletion of some fields al MySQL sump"
  s.description = "Easy way to make your dump secure for other developers"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.0"

end
