# -*- encoding: utf-8 -*-
# stub: spree_avatax_certified 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "spree_avatax_certified".freeze
  s.version = "3.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Allison Reilly".freeze]
  s.date = "2017-09-07"
  s.description = "Spree extension for Avalara tax calculation.".freeze
  s.email = "acreilly3@gmail.com".freeze
  s.homepage = "http://boomer.digital".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.requirements = ["none".freeze]
  s.rubygems_version = "2.6.12".freeze
  s.summary = "Spree extension for Avalara tax calculation.".freeze

  s.installed_by_version = "2.6.12" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>.freeze, ["~> 3.1.3"])
      s.add_runtime_dependency(%q<json>.freeze, ["~> 1.7"])
      s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.3"])
      s.add_runtime_dependency(%q<rest-client>.freeze, ["~> 2.0"])
      s.add_runtime_dependency(%q<psych>.freeze, ["~> 2.0.4"])
      s.add_runtime_dependency(%q<logging>.freeze, ["~> 1.8"])
      s.add_development_dependency(%q<dotenv>.freeze, [">= 0"])
      s.add_development_dependency(%q<deface>.freeze, [">= 0"])
      s.add_development_dependency(%q<capybara>.freeze, ["~> 2.4"])
      s.add_development_dependency(%q<coffee-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<database_cleaner>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<factory_girl>.freeze, ["~> 4.5"])
      s.add_development_dependency(%q<ffaker>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 3.1"])
      s.add_development_dependency(%q<rspec-its>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<sass-rails>.freeze, ["~> 5.0.0.beta1"])
      s.add_development_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_development_dependency(%q<shoulda-matchers>.freeze, ["~> 2.8.0"])
    else
      s.add_dependency(%q<spree_core>.freeze, ["~> 3.1.3"])
      s.add_dependency(%q<json>.freeze, ["~> 1.7"])
      s.add_dependency(%q<addressable>.freeze, ["~> 2.3"])
      s.add_dependency(%q<rest-client>.freeze, ["~> 2.0"])
      s.add_dependency(%q<psych>.freeze, ["~> 2.0.4"])
      s.add_dependency(%q<logging>.freeze, ["~> 1.8"])
      s.add_dependency(%q<dotenv>.freeze, [">= 0"])
      s.add_dependency(%q<deface>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, ["~> 2.4"])
      s.add_dependency(%q<coffee-rails>.freeze, [">= 0"])
      s.add_dependency(%q<database_cleaner>.freeze, ["~> 1.2"])
      s.add_dependency(%q<factory_girl>.freeze, ["~> 4.5"])
      s.add_dependency(%q<ffaker>.freeze, [">= 0"])
      s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.1"])
      s.add_dependency(%q<rspec-its>.freeze, ["~> 1.0"])
      s.add_dependency(%q<sass-rails>.freeze, ["~> 5.0.0.beta1"])
      s.add_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.8"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
      s.add_dependency(%q<shoulda-matchers>.freeze, ["~> 2.8.0"])
    end
  else
    s.add_dependency(%q<spree_core>.freeze, ["~> 3.1.3"])
    s.add_dependency(%q<json>.freeze, ["~> 1.7"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.3"])
    s.add_dependency(%q<rest-client>.freeze, ["~> 2.0"])
    s.add_dependency(%q<psych>.freeze, ["~> 2.0.4"])
    s.add_dependency(%q<logging>.freeze, ["~> 1.8"])
    s.add_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_dependency(%q<deface>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, ["~> 2.4"])
    s.add_dependency(%q<coffee-rails>.freeze, [">= 0"])
    s.add_dependency(%q<database_cleaner>.freeze, ["~> 1.2"])
    s.add_dependency(%q<factory_girl>.freeze, ["~> 4.5"])
    s.add_dependency(%q<ffaker>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 3.1"])
    s.add_dependency(%q<rspec-its>.freeze, ["~> 1.0"])
    s.add_dependency(%q<sass-rails>.freeze, ["~> 5.0.0.beta1"])
    s.add_dependency(%q<selenium-webdriver>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.8"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    s.add_dependency(%q<shoulda-matchers>.freeze, ["~> 2.8.0"])
  end
end
