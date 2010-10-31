This gem implements Ruby bindings for the GoogleStorage API.

[Google Storage](http://code.google.com/apis/storage/) lets you store, share, and manage your data on Google's 
storage infrastructure. You can use Google Storage to store all sizes of files.

Installation
------------

    gem install google-storage

Usage
-----    
The basics:

    # use the gem
    require 'google-storage'
    include GoogleStorage
    
    # create a credentials object to use for services
    credentials = Credentials.new :accesskey => '...', :secretkey => '...'
    service     = Service.new credentials

    # create a service object (alternative method)
    service = Service.new :accesskey => '...', :secretkey => '...'

    # list buckets
    service.buckets.each do |entry|
      puts "#{entry[:name]} #{entry[:creation_date]}"
    end

    # get a reference to a bucket
    bucket = service["my-bucket"] 

    # get a reference to a bucket (using a credentials object)
    credentials = Credentials.new :accesskey => '...', :secretkey => '...'
    bucket      = Bucket.new "my-bucket", credentials

    # get a reference to a bucket (alternative method)
    bucket = Bucket.new "my-bucket", :accesskey => '...', :secretkey => '...'

    # list contents of bucket
    bucket.objects.each do |entry|
      puts "#{entry[:key]} #{entry[:last_modified]} #{entry[:size]}"
    end

    # create a folder
    bucket.mkdir "private/folder"

    # remove a folder
    bucket.rmdir "private/folder"

    # remove a folder but raise an error if it fails
    bucket.rmdir! "private/folder"
    
    # get a reference to an object
    object = bucket["lorem-ipsum.txt"]
    
    # check if an object is a file
    object.file?

    # check if an object is a directory?
    object.directory?

    # check if an object is a directory? (alternative method)
    object.folder?
    
    # set a object's acl
    object.acl = Acl.new(File.read "/path/to/acl.xml")

    # get an object's acl
    acl = object.acl

    # download an object from the bucket
    bucket.download "lorem-ipsum.txt"
    
    # upload an object into the bucket
    bucket.upload File.new("lorem-ipsum.txt")

    # upload an object into the bucket in a specific location
    bucket.upload File.new("photo.jpg"), :dest => "private/folder/photo.jpg" 

    # delete an object
    bucket.delete "private/folder/photo.jpg"

    # delete an object (alternative method)
    object = bucket["private/folder/photo.jpg"]
    object.destroy
    
    # delete an object but raise an error if it fails
    object = bucket["private/folder/photo.jpg"]
    object.destroy!

    # create a bucket
    bucket = Bucket::create["my-other-bucket"]

    # set a bucket's acl
    bucket.acl = Acl.new(File.read "/path/to/acl.xml")

    # get a bucket's acl
    acl = bucket.acl
    
    # delete a bucket
    bucket.destroy

    # delete a bucket but raise an error if it fails
    bucket.destroy!
    
    # copy an object from another bucket
    bucket.copy "source-bucket/photo.jpg"

    # copy an object from another bucket into a specific location
    bucket.copy "source-bucket/photo.jpg", :dest => "private/folder/photo.jpg"

Configuration 
-------------
Create a `GoogleStorage::Configuration` object by passing the path to a YAML
file, or `Hash` containing the expected configuration keys and values:

    config = Configuration.new '/path/to/google-storage.yml'

The `credentials` method will return a `GoogleStorage::Credentials` object
using one of the key-pairs listed in the configuration file:

    # use the key-pair labeled `development`
    credentials = config.credentials :development 
    
    # or, use the first key-pair listed in the configuration file
    credentials = config.credentials            

The following is the layout of the configuration file as expected by the 
`GoogleStorage::Configuration` class:

    # gem/library runtime settings
    settings:
      # default protocol used when accessing the service provider
      ssl: true

      # default storage provider id (GOOG1 or AWS) when requesting service
      provider: GOOG1 

      # default storage provider host/end-point
      host: commondatastorage.googleapis.com
  
    # set the appropriate values in this configuration file if you wish to run the 
    # tests; ref: https://code.google.com/apis/storage/docs/developer-guide.html#authorization
    credentials:  
      # google storage id
      id: 01231abcdef01293129481abcdef9856722458923abcdef93498ab2342bacdfe

      # email address
      email: user@example.com

      # forum/group email address (optional)
      group-email: gs-discussion@googlegroups.com

      # google apps email address (optional)
      apps-domain: user@example.com

      # google storage access_key/secret_key section; define as many pairs as \
      # needed - the label for each pair is arbitrary.
      development:                                                         
        accesskey: GOOGLQ344542322342BB                                   
        secretkey: TkIkd012+eUnkxNeXCzmPkilJeR5ZaODNEYp7uz6                

      stage:                                                              
        accesskey: GOOGRESAMPLE12345BAC                                   
        secretkey: Hanothe3xamplea134af45sdgikLdz2rx1XRnmqb                

      production:                                                          
        accesskey: GOOGHJKL33MASAMPLE34                                   
        secretkey: AJYdwOneMor123Ex+ampl33tAbCdfegd2dfPiUNH                

For more information related to authorization requirements to Google Storage
see the Google Storage API's 
[Developer Guide](https://code.google.com/apis/storage/docs/developer-guide.html#authorization)

Settings
--------
The `settings` section of the configuration file dictates the behavior of the 
gem at runtime. Assigning a `Configuration` object to the `GoogleStorage::settings` 
attribute applies its values:

    GoogleStorage.settings = Configuration.new '/path/to/google-storage.yml'
    
Dependencies
------------
Runtime:

* `Nokogiri >= 1.4.3.1`
* `Typhoeus >= 0.1.31`

It also has pieces of the `Facets` gem embedded in the package itself.

Development:

* `yard >= 0`
* `rspec >= 1.2.9`

Download
--------
You can download this project in either
[zip](http://github.com/jurisgalang/google-storage/zipball/master) or
[tar](http://github.com/jurisgalang/google-storage/tarball/master") formats.

You can also clone the project with [Git](http://git-scm.com)
by running: 

    git clone git://github.com/jurisgalang/google-storage

Note on Patches/Pull Requests
-----------------------------
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version 
  unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have 
  your own version, that is fine but bump version in a commit by itself I can 
  ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Releases
--------
Please read the `RELEASENOTES` file for the details of each release. 

In general: patch releases will not include breaking changes while releases 
that bumps the major or minor components of the version string may or may not 
include breaking changes.

Author
------
[Juris Galang](http://github.com/jurisgalang/)

License
-------
Dual licensed under the MIT or GPL Version 2 licenses.
