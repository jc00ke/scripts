# get images
# for i in $(seq 30); do echo "http://www.example.com/page$i.html" ; done | wget -i -

# rename
# for file in *.cgi ; do mv $file `echo $file | sed 's/\(.*\.\)cgi/\1jpg/'` ; done

require 'rubygems'
require 'image_science'
    
source = ARGV[0]
destination = ARGV[1]
i = 1

images = Dir.new(source).entries.sort

images.each do |image|
	if (image[0] != ?. && (image.downcase.include? "jpg"))
		puts "#{source}/#{image}"
		ImageScience.with_image("#{source}/#{image}") do |img|
			img.thumbnail(300) do |img2|
				img2.save "#{destination}/#{i}.jpg"
			end
		end
		i += 1
	end

end    
