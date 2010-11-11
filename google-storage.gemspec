# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{google-storage}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Juris Galang"]
  s.date = %q{2010-11-11}
  s.default_executable = %q{gs}
  s.description = %q{
      Ruby bindings for the GoogleStorage API

      Google Storage lets you store, share, and manage your data on Google's 
      storage infrastructure. You can use Google Storage to store all sizes of files.
    }
  s.email = %q{jurisgalang@gmail.com}
  s.executables = ["gs"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "GPL-LICENSE",
     "MIT-LICENSE",
     "README.md",
     "RELEASENOTES",
     "Rakefile",
     "VERSION",
     "bin/gs",
     "fixtures/google-storage.yml",
     "fixtures/test-acl.xml",
     "google-storage.gemspec",
     "lib/google-storage.rb",
     "lib/google-storage/acl-entry.rb",
     "lib/google-storage/acl-owner.rb",
     "lib/google-storage/acl.rb",
     "lib/google-storage/base.rb",
     "lib/google-storage/bucket.rb",
     "lib/google-storage/configuration.rb",
     "lib/google-storage/credentials.rb",
     "lib/google-storage/facets/blank.rb",
     "lib/google-storage/facets/file/write.rb",
     "lib/google-storage/facets/hash/op_mul.rb",
     "lib/google-storage/facets/hash/recursively.rb",
     "lib/google-storage/facets/hash/symbolize_keys.rb",
     "lib/google-storage/facets/string/methodize.rb",
     "lib/google-storage/facets/string/modulize.rb",
     "lib/google-storage/facets/to_hash.rb",
     "lib/google-storage/mime-type.rb",
     "lib/google-storage/nokogiri/xml-element.rb",
     "lib/google-storage/object.rb",
     "lib/google-storage/request-methods.rb",
     "lib/google-storage/resources/mime-types.txt",
     "lib/google-storage/service.rb",
     "spec/acl-entry_spec.rb",
     "spec/acl-owner_spec.rb",
     "spec/acl_spec.rb",
     "spec/bucket_spec.rb",
     "spec/object_spec.rb",
     "spec/service_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://jurisgalang.github.com/google-storage}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby bindings for the GoogleStorage API}
  s.test_files = [
    "spec/acl-entry_spec.rb",
     "spec/acl-owner_spec.rb",
     "spec/acl_spec.rb",
     "spec/bucket_spec.rb",
     "spec/object_spec.rb",
     "spec/service_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<named-parameters>, [">= 0.0.2"])
      s.add_runtime_dependency(%q<typhoeus>, [">= 0.1.31"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.3.1"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<named-parameters>, [">= 0.0.2"])
      s.add_dependency(%q<typhoeus>, [">= 0.1.31"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.3.1"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<named-parameters>, [">= 0.0.2"])
    s.add_dependency(%q<typhoeus>, [">= 0.1.31"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.3.1"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

