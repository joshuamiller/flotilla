module ActionView
  module Helpers
    module ScriptaculousHelper
      
      # Insert a flot chart into the page.  <tt>placeholder</tt> should be the 
      # name of the div that will hold the chart, <tt>collections</tt> is a hash 
      # of legends (as strings) and datasets with options as hashes, <tt>options</tt>
      # contains graph-wide options.
      # 
      # Example usage:
      # <tt>chart("graph_div", <br>
      # { "January" => { :collection => @january, :x => :day, :y => :sales, 
      # :options => { :bar => :show } }, <br>
      # "February" => { :collection => @february, :x => :day, :y => :sales, 
      # :options => { :points => :show }},<br>
      # :grid => { :backgroundColor => %{"#fffaff"} })</tt>
      #
      def chart(placeholder, collections, options = nil)
        
        javascript = %{<!--[if IE]><script language="javascript" type="text/javascript" src="/javascripts/excanvas.js"></script><![endif]-->}
        javascript << %{<script type="text/javascript">var data = [}
        collections.each do |name, collection|
            javascript << %{\{ label: "#{name}",\n data: [}
            collection[:collection].each do |object|
              javascript << "[#{object[collection[:x]]},#{object[collection[:y]]}],"
            end
            javascript = javascript.remove_trailing_comma << "], \n"

            collection[:options].each do |option,value|
              javascript << "#{option.to_s}: { #{value.to_s}: true},"
            end
            javascript = javascript.remove_trailing_comma <<  "},"
          end
        
        javascript = javascript.remove_trailing_comma << "];"

        javascript << "$.plot($('##{placeholder}'), data"
        
        if options
          javascript << ", {"
          options.each do |option,value|
            javascript << "#{option}: {"
            value.each do |value_name, value_value|
              javascript << "#{value_name}: #{value_value},"
            end
            javascript = javascript.remove_trailing_comma << " },"
          end
          javascript = javascript.remove_trailing_comma << "}"
        end
        
        javascript << %{);</script>}
        
      end
      
    end
  end
end

class String
  
  def remove_trailing_comma
    return self[0..(self.size-2)]
  end

end