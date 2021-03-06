require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "google-storage"
    gem.summary = %Q{Ruby bindings for the GoogleStorage API}
    gem.description = %Q{
      Ruby bindings for the GoogleStorage API\n
      Google Storage lets you store, share, and manage your data on Google's 
      storage infrastructure. You can use Google Storage to store all sizes of files.
    }
    gem.email = "jurisgalang@gmail.com"
    gem.homepage = "http://jurisgalang.github.com/google-storage"
    gem.authors = ["Juris Galang"]
    gem.add_dependency "named-parameters", ">= 0.0.2"
    gem.add_dependency "typhoeus", ">= 0.1.31"
    gem.add_dependency "nokogiri", ">= 1.4.3.1"
    #gem.add_dependency "facets", ">= 2.8.4"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.files.exclude 'adhoc-tests'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
