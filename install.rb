require 'FileUtils'

dir = Dir.getwd

# Copy required javascripts to public/javascripts
begin
  FileUtils.cp "#{dir}/javascripts/excanvas.js", "#{dir}/../../../public/javascripts/excanvas.js"
  FileUtils.cp "#{dir}/javascripts/jquery.flot.js", "#{dir}/../../../public/javascripts/jquery.flot.js"
rescue
  puts "Could not copy excanvas.js and jquery.flot.js.  Please manually copy them to your public/javascripts directory."
end