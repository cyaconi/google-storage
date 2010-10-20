google-storage
==============
This gem implements Ruby bindings for the GoogleStorage API.

Usage
-----
The basics:

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

    # create a bucket
    bucket = Bucket::create["my-other-bucket"]

    # set a bucket's acl
    bucket.acl = Acl.new(File.read "/path/to/acl.xml")

    # get a bucket's acl
    acl = bucket.acl
    
TODO
----
* Examples for using the GoogleStorage::Acl
* Examples for alternative ways of instantiating GoogleStorage::Authorization
* Section on how to setup a GS account for development or running the 
  project's tests.
* Example for copying an object from one bucket into another 
* Style examples when using the GoogleStorage::Bucket class
* Style examples when using the GoogleStorage::Object class

Note on Patches/Pull Requests
----------------------------- 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a 
   commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------
Dual licensed under the MIT or GPL Version 2 licenses.

---
Copyright &copy; 2010, Juris Galang. All Rights Reserved.
