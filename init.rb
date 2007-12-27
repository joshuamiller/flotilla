# Check for presence of jrails plugin
begin
  require 'jrails'
rescue
  p "Flotilla will not work without the jrails plugin installed:"
  p "Visit http://ennerchi.googlecode.com/"
end

require 'flotilla'

ActionView::Helpers