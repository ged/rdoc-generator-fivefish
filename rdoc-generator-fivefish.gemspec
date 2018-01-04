# -*- encoding: utf-8 -*-
# stub: rdoc-generator-fivefish 0.4.0.pre20180103163021 ruby lib

Gem::Specification.new do |s|
  s.name = "rdoc-generator-fivefish".freeze
  s.version = "0.4.0.pre20180103163021"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2018-01-04"
  s.description = "A(nother) HTML(5) generator for RDoc.\n\nIt uses {Twitter Bootstrap}[http://twitter.github.com/bootstrap/] for the\npretty, doesn't take up valuable horizontal real estate space with indexes\nand stuff, and has a QuickSilver-like incremental searching.".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.extra_rdoc_files = ["History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = [".autotest".freeze, "ChangeLog".freeze, "History.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "data/rdoc-generator-fivefish/css/bootstrap-responsive.min.css".freeze, "data/rdoc-generator-fivefish/css/bootstrap.min.css".freeze, "data/rdoc-generator-fivefish/css/fivefish.min.css".freeze, "data/rdoc-generator-fivefish/fonts/IstokWeb-Bold.woff".freeze, "data/rdoc-generator-fivefish/fonts/IstokWeb-BoldItalic.woff".freeze, "data/rdoc-generator-fivefish/fonts/IstokWeb-Italic.woff".freeze, "data/rdoc-generator-fivefish/fonts/IstokWeb-Regular.woff".freeze, "data/rdoc-generator-fivefish/fonts/OFL.txt".freeze, "data/rdoc-generator-fivefish/img/glyphicons-halflings-white.png".freeze, "data/rdoc-generator-fivefish/img/glyphicons-halflings.png".freeze, "data/rdoc-generator-fivefish/js/bootstrap.min.js".freeze, "data/rdoc-generator-fivefish/js/fivefish.min.js".freeze, "data/rdoc-generator-fivefish/js/jquery-1.7.1.min.js".freeze, "data/rdoc-generator-fivefish/templates/class.tmpl".freeze, "data/rdoc-generator-fivefish/templates/file.tmpl".freeze, "data/rdoc-generator-fivefish/templates/index.tmpl".freeze, "data/rdoc-generator-fivefish/templates/layout.tmpl".freeze, "lib/fivefish.rb".freeze, "lib/rdoc/discover.rb".freeze, "lib/rdoc/generator/fivefish.rb".freeze, "spec/fivefish_spec.rb".freeze, "spec/helpers.rb".freeze, "spec/rdoc/generator/fivefish_spec.rb".freeze]
  s.homepage = "http://deveiate.org/fivefish.html".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "2.7.3".freeze
  s.signing_key = "/Volumes/Keys and Things/ged-private_gem_key.pem".freeze
  s.summary = "A(nother) HTML(5) generator for RDoc".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<inversion>.freeze, ["~> 1.1"])
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.12"])
      s.add_runtime_dependency(%q<yajl-ruby>.freeze, ["~> 1.3"])
      s.add_runtime_dependency(%q<rdoc>.freeze, ["~> 6.0"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<uglifier>.freeze, ["~> 1.3.0"])
      s.add_development_dependency(%q<less>.freeze, ["~> 2.2.0"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.16"])
    else
      s.add_dependency(%q<inversion>.freeze, ["~> 1.1"])
      s.add_dependency(%q<loggability>.freeze, ["~> 0.12"])
      s.add_dependency(%q<yajl-ruby>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<uglifier>.freeze, ["~> 1.3.0"])
      s.add_dependency(%q<less>.freeze, ["~> 2.2.0"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
    end
  else
    s.add_dependency(%q<inversion>.freeze, ["~> 1.1"])
    s.add_dependency(%q<loggability>.freeze, ["~> 0.12"])
    s.add_dependency(%q<yajl-ruby>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.9"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<uglifier>.freeze, ["~> 1.3.0"])
    s.add_dependency(%q<less>.freeze, ["~> 2.2.0"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
  end
end
