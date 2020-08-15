require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require_relative 'near_earth_objects'


class NearEarthObjectsTest < Minitest::Test
  def test_a_date_returns_a_list_of_neos
    results = NearEarthObjects.call('2019-03-30')
    assert_equal '(2019 GD4)', results[:astroid_list][0][:name]
  end

  def test_api_connection
    date = "2019-03-30"
    results = NASAReader.conn(date)
    assert_equal String, results.class
  end

  def test_ability_to_parse_data
    date = "2019-03-30"
    results = NearEarthObjects.call(date)
    assert_equal Hash, results.class
    assert_equal [:astroid_list, :biggest_astroid, :total_number_of_astroids], results.keys
  end

  def test_data_parser_call
    date = "2019-03-30"
    response = NASAReader.conn(date)
    results = DataParser.new(response, date).call
    assert_equal [:astroid_list, :biggest_astroid, :total_number_of_astroids], results.keys
    assert_equal Array, results[:astroid_list].class
    assert_equal Integer, results[:biggest_astroid].class
    assert_equal Integer, results[:total_number_of_astroids].class
  end



end
