require 'faraday'
require 'figaro'
require 'pry'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NASAReader
  def self.conn(date)
    Faraday.new(
      url: 'https://api.nasa.gov',
      params: { start_date: date, api_key: ENV['nasa_api_key']}
    ).get('/neo/rest/v1/feed').body
  end

end

class NearEarthObjects
  def self.call(date)
    response = NASAReader.conn(date)
    DataParser.new(response, date).call
  end

end

class DataParser

  attr_reader :response, :date

  def initialize(response, date)
    @response = response
    @date = date
  end

  def call
    filtered_data = nearearthobject(response, date)
    { astroid_list: formatted_asteroid_data(filtered_data),
      biggest_astroid: largest_astroid_diameter(filtered_data),
      total_number_of_astroids: total_number_of_astroids(filtered_data)
    }
  end

  private

  def largest_astroid_diameter(data)
    data.map do |astroid|
      astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
  end

  def total_number_of_astroids(data)
    data.count
  end

  def formatted_asteroid_data(data)
    data.map do |astroid|
    {
      name: astroid[:name],
      diameter: "#{astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
      miss_distance: "#{astroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
    }
    end
  end

  def nearearthobject(response, date)
    JSON.parse(response, symbolize_names: true)[:near_earth_objects][:"#{date}"]
  end
end
