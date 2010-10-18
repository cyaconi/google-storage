class MimeType
  @types = Hash.new("application/octet-stream")
  @types.merge! File.read(File.join(File.dirname(__FILE__), 'resources', 'mime-types.txt')).
    split("\n").map{ |n| n.split(/\s/) }.to_h

  def self.of(filename)
    @types[File.extname(filename).downcase.sub(/\./, '')]
  end
end  
