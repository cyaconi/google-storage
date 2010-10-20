google-storage
==============
This is a Ruby binding for the GoogleStorage API.

Usage
-----
Briefly:

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
    
    # download an object from the bucket
    bucket.download "lorem-ipsum.txt"

    # upload an object into the bucket
    bucket.upload File.new("lorem-ipsum.txt")

    # upload an object into the bucket in a specific location
    bucket.upload File.new("photo.jpg"), :dest => "private/folder/photo.jpg" 

    # delete an object
    bucket.delete "private/folder/photo.jpg" 
    
### TODO
* Example for creating a new bucket
* Example for setting/getting bucket ACL
* Example for setting/getting object ACL

Note on Patches/Pull Requests
----------------------------- 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------
Dual licensed under the MIT or GPL Version 2 licenses.

---
Copyright &copy; 2010, Juris Galang. All Rights Reserved.
