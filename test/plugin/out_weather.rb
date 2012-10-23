require 'test_helper'
require 'fluent/plugin/out_weather'

class WeatherOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  # http://www.wunderground.com/weather/api/d/docs?d=resources/phrase-glossary
  CONFIG = %[
    api_key foo
    <weather_types>
      1 sunny|clear
      2 cloud|overcast|haze|fog
      3 rain|sleet|snow|storms
    </weather_types>
    <store>
      type test
      name c0
    </store>
    <store>
      type test
      name c1
    </store>
    <store>
      type test
      name c2
    </store>
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::WeatherOutput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal("foo", d.instance.api_key)
    assert_equal("sunny|clear", d.instance.weather_types["1"])
    assert_equal("cloud|overcast|haze|fog", d.instance.weather_types["2"])
    assert_equal("rain|sleet|snow|storms", d.instance.weather_types["3"])
  end

  def test_emit
    d = create_driver
    expecting = [
      { latlon: [ 35, 135 ], emit: { "a" => 1, "latitude" => 35, "longitude" => 135 }, weather: "Mostly Sunny", weather_types: "1" },
      { latlon: [ 30, 135 ], emit: { "a" => 2, "latitude" => 30, "longitude" => 135 }, weather: "Cloudy", weather_types: "2" },
      { latlon: [ 30, 135 ], emit: { "a" => 2, "latitude" => 30, "longitude" => 135 }, weather: "Sunny", weather_types: "1" },
      { latlon: [ 30, 135 ], emit: { "a" => 2, "latitude" => 30, "longitude" => 135 }, weather: "Rain", weather_types: "3" },
      { latlon: [ 30, 135 ], emit: { "a" => 2, "latitude" => 30, "longitude" => 135 }, weather: "UnkownWeather", weather_types: nil },
      { latlon: [ 30, 135 ], emit: { "a" => 2, "latitude" => 30, "longitude" => 135 }, weather: "Partly Cloudy", weather_types: "2" }
    ].map do |e|
      Fluent::WeatherOutput.any_instance.
        stubs(:weather).
        with(*e[:latlon]).
        returns(e[:weather])
      time = Time.parse("2011-01-02 13:14:15 UTC").to_i
      d.emit(e[:emit], time)

      [ time, e[:emit].merge("weather" => e[:weather_types]) ]
    end

    d.instance.outputs.each {|o|
      assert_equal(expecting, o.events)
    }
  end
end
