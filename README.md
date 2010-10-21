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
    
    # create an authorization object to use for services
    authorization = Authorization.new("production")
    service       = Service.new(authorization)

    # list buckets
    service.buckets.each do |entry|
      puts "#{entry[:name]} #{entry[:creation_date]}"
    end

    # get a reference to a bucket
    bucket = service["my-bucket"] 

    # list contents of bucket
    bucket.objects.each do |entry|
      puts "#{entry[:key]} #{entry[:last_modified]} #{entry[:size]}"
    end
    
    # get a reference to an object
    object = bucket["lorem-ipsum.txt"]
    
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
The `GoogleStorage::Authorization` class by default expects to find a file 
named `google-storage.yml` in the current directory when it is instantiated.

    # google storage id     
    id: 00234982384abcfdef892348bdc234f30636bcbeaf4398502aced39242ade351
    
    # email address 
    email: user@example.com                                             
    
    # forum/group email address (optional)
    group-email: gs-discussion@googlegroups.com                          
    
    # google apps email address (optional)
    apps-domain: user@example.com                                        

    # google storage access_key/secret_key section; 
    # define as many pairs as needed - the label for each
    # pair is arbitrary
    development:                                                         
      access_key: GOOGTBR1091493294JAG                                   
      secret_key: TiKladfjkdfwe+14sdjf56dsjfshz56sfjshgwn7                
                                                                         
    stage:                                                               
      access_key: GOOGNBAS5DFA9FF9234C                                   
      secret_key: Hwjefwj63gjshgahzziuwfksiudh38wfhwjh2ejw                
                                                                         
    production:                                                          
      access_key: GOOGNBSBNLA9234ZV94D                                   
      secret_key: AKjkdsf42dsfs2342rnkjc2dzskjga+afjafkjww                

For more information related to authorization requirements to Google Storage
see the Google Storage API's [Developer Guide](https://code.google.com/apis/storage/docs/developer-guide.html#authorization)

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

Author
------
[Juris Galang](http://github.com/jurisgalang/)

License
-------
Dual licensed under the MIT or GPL Version 2 licenses.
