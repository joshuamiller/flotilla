begin
  require 'json'
rescue LoadError
  p "Flotilla will not work without the 'json' gem"
end

module ActionView
  module Helpers
    module ScriptaculousHelper
      
      # Insert a flot chart into the page.  <tt>placeholder</tt> should be the 
      # name of the div that will hold the chart, <tt>collections</tt> is a hash 
      # of legends (as strings) and datasets with options as hashes, <tt>options</tt>
      # contains graph-wide options.
      # 
      # Example usage:
      #   
      #  chart("graph_div", { 
      #   "January" => { :collection => @january, :x => :day, :y => :sales, :options => { :lines => {:show =>true}} }, 
      #   "February" => { :collection => @february, :x => :day, :y => :sales, :options => { :points => {:show =>true} } },
      #   :grid => { :backgroundColor => "#fffaff" })
      # 
      # Options:
      #   :js_includes - includes flot library inline
      #   :js_tags - wraps resulting javascript in javascript tags if true.  Defaults to true.
      #   :placeholder_tag - appends a placeholder div for graph
      #   :placeholder_size - specifys the size of the placeholder div
      def chart(placeholder, series, options = {}, html_options = {})
        html_options.reverse_merge!({ :js_includes => true, :js_tags => true, :placeholder_tag => true, :placeholder_size => "800x300" })
        width, height = html_options[:placeholder_size].split("x") if html_options[:placeholder_size].respond_to?(:split)
        
        data, x_is_date, y_is_date = series_to_json(series)
        if x_is_date
          options[:xaxis] ||= {}
          options[:xaxis].merge!({ :mode => 'time' })
        end
        if y_is_date
          options[:yaxis] ||= {}
          options[:yaxis].merge!({ :mode => 'time' })
        end

        if html_options[:js_includes]
          chart_js = <<-EOF
          <!--[if IE]><script language="javascript" type="text/javascript" src="/javascripts/excanvas.pack.js"></script><![endif]-->
          <script language="javascript" type="text/javascript" src="/javascripts/jquery.flot.pack.js"></script>
          <script type="text/javascript">
            $(function () {
              jQuery.plot($('##{placeholder}'), #{data}, #{options.to_json});
            });
          </script>
          EOF
        else
          chart_js = <<-EOF
          $(function () {
            jQuery.plot($('##{placeholder}'), #{data}, #{options.to_json});
          });
          EOF
        end        
        
        html_options[:js_tags] ? javascript_tag(chart_js) : chart_js
        output = html_options[:placeholder_tag] ? chart_js + content_tag(:div, nil, :id => placeholder, :style => "width:#{width}px;height:#{height}px;") : chart_js
        output.html_safe
      end

      private
      def series_to_json(series)
        data_sets = []
        x_is_date, y_is_date = false, false
        series.each do |name, values|
          set, data = {}, []
          set[:label] = name
          first = values[:collection].first
          if first
            x_is_date = first.send(values[:x]).acts_like?(:date) || first.send(values[:x]).acts_like?(:time)
            y_is_date = first.send(values[:y]).acts_like?(:date) || first.send(values[:y]).acts_like?(:time)
          end
          values[:collection].each do |object|
            x_value, y_value = object.send(values[:x]), object.send(values[:y])
            x = x_is_date ? x_value.to_time.to_i * 1000 : x_value.to_f
            y = y_is_date ? y_value.to_time.to_i * 1000 : y_value.to_f
            data << [x,y]
          end
          set[:data] = data
          values[:options].each {|option, parameters| set[option] = parameters } if values[:options]
          data_sets << set
        end
        return data_sets.to_json, x_is_date, y_is_date
      end

    end
  end
end

