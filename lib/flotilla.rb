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
      #   :js_tags - wraps resulting javascript in javascript tags if true.  Defaults to true.
      def chart(placeholder, series, options = {}, html_options = {})
        html_options.reverse_merge!({ :js_tags => true })

        data, x_is_date, y_is_date = series_to_json(series)
        if x_is_date
          options[:xaxis] ||= {}
          options[:xaxis].merge!({ :mode => 'time' })
        end
        if y_is_date
          options[:yaxis] ||= {}
          options[:yaxis].merge!({ :mode => 'time' })
        end

        chart_js = "$.plot($('##{placeholder}'), #{data}, #{options.to_json});"
        html_options[:js_tags] ? javascript_tag(chart_js) : chart_js
      end

      private

      def series_to_json(series)
        data_sets = []
        x_is_date, y_is_date = false, false
        series.each do |name, values|
          set, data = {}, []
          set[:label] = name
          first = values[:collection].first
          x_is_date = first.send(values[:x]).acts_like?(:date) || first.send(values[:x]).acts_like?(:time)
          y_is_date = first.send(values[:y]).acts_like?(:date) || first.send(values[:y]).acts_like?(:time)
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

