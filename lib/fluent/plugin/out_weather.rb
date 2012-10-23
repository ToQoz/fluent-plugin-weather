require 'fluent/plugin/out_copy'
require 'wunderground'

module Fluent
  class WeatherOutput < CopyOutput
    Plugin.register_output('weather', self)
    config_param :api_key, :string
    config_param :weather_types, :string

    def configure(conf)
      super
      @api_key = conf["api_key"]
      @weather_types = {}
      conf.elements.each { |e| e.name == 'weather_types' }.each do |e|
        e.keys.each { |w_key| @weather_types[w_key] = e[w_key] }
      end
    end

    # most of method `emit` from fluent/plugin/out_copy
    def emit(tag, es, chain)
      # insert weather to record
      es.each {|time, record|
        weather = weather(record['latitude'], record['longitude'])
        record["weather"] = weather_types.select { |k, v| /#{v}/i.match(weather) }.keys[0]
      }
      unless es.repeatable?
        m = MultiEventStream.new
        es.each {|time, record| m.add(time, record) }
        es = m
      end
      chain = OutputChain.new(@outputs, tag, es, chain)
      chain.next
    end

    def wunderground
      @wunderground ||= Wunderground.new(api_key)
    end

    def weather(lat, lon)
      if lat && lon
        wunderground.forecast_and_conditions_for("#{lat},#{lon}")['current_observation']['weather'] rescue nil
      end
    end
  end
end
