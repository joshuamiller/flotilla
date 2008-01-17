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
      def chart(placeholder, series, options = nil)
        
        javascript = %{<!--[if IE]><script language="javascript" type="text/javascript" src="/javascripts/excanvas.js"></script><![endif]-->}
        javascript << %{<script type="text/javascript">\nvar data = [}
        date_range = ""

        series.each do |name, details|
          unless details[:collection].size == 0
            javascript << %{\{ label: "#{name}", data: [}
            date_range = "["
            details[:collection].each do |object|
              x = object.send(details[:x])
              y = object.send(details[:y])
              if x.is_a? Date
                javascript << "[#{x.ld},#{y}],"
                date_range << %{[#{x.ld}, "#{x.mon}/#{x.mday}"],}
              else
                javascript << "[#{x},#{y}]"
              end
            end
            date_range = date_range.remove_trailing_comma << "]"
            javascript = javascript.remove_trailing_comma << "], "
                    
            if details[:options]
              details[:options].each do |option,value|
                javascript << "#{option.to_s}: { #{value.to_s}: true},"
              end
            end

            javascript = javascript.remove_trailing_comma <<  "},"
          end
        end
        
        javascript = javascript.remove_trailing_comma << "];\n"

        javascript << "$.plot($('##{placeholder}'), data"
        
        if options || date_range.size > 4
          
          javascript << ", {"
          
          if date_range.size > 4
            javascript << "xaxis: {ticks: #{date_range}},"
          end

          if options
            options.each do |option,value|
              javascript << "#{option}: {"
              value.each do |value_name, value_value|
                javascript << "#{value_name}: #{value_value},"
              end
              javascript = javascript.remove_trailing_comma << " },"
            end
          end

          javascript = javascript.remove_trailing_comma << "}"
          javascript << %{);</script>}
        end
      
      end
      
    end
  end
end

class String
  
  def remove_trailing_comma
    return self[0..(self.size-2)]
  end

end