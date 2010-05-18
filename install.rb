require 'FileUtils'

dir = Dir.getwd

# Copy required javascripts to public/javascripts
begin
  FileUtils.cp "#{dir}/javascripts/excanvas.pack.js", "#{dir}/../../../public/javascripts/excanvas.pack.js"
  FileUtils.cp "#{dir}/javascripts/jquery.flot.pack.js", "#{dir}/../../../public/javascripts/jquery.flot.pack.js"
rescue
  puts "Could not copy excanvas.js and jquery.flot.js.  Please manually copy them to your public/javascripts directory."
end