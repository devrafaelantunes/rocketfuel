defmodule RocketFuel.CalculatorTest do
  use ExUnit.Case

  alias RocketFuel.Calculator
  import ExUnit.CaptureLog
  require Logger

  # Default mass value
  @mass_value 28_801

  describe "start/2" do
    test "returns the amount of fuel needed for one trip when valid arguments are passed" do
      # Single flight route
      flight_routes = [{:land, 9.807}]

      assert Calculator.start(@mass_value, flight_routes) == 13_447
    end

    test "returns the amount of fuel needed for multiple trips when valid arguments are passed" do
      # Multiple flight routes
      flight_routes = [{:launch, 9.807}, {:land, 1.62}, {:launch, 1.62}, {:land, 9.807}]

      assert Calculator.start(@mass_value, flight_routes) == 51_898
    end

    test "ignores routes which the gravity value is higher than 23.8" do
      flight_routes = [{:land, 25}]

      # Assert the warn given to the user
      assert capture_log(fn ->
               assert Calculator.start(@mass_value, flight_routes) == 0
             end) =~ "route could not be calculated"
    end

    test "ignores routes which the direction is not :land or :launch" do
      flight_routes = [{:anything_else, 2.5}]

      assert capture_log(fn ->
               assert Calculator.start(@mass_value, flight_routes) == 0
             end) =~ "route could not be calculated."
    end

    test "returns the amount of fuel needed ignoring the invalid route inserted with wrong direction" do
      flight_routes = [{:anything_else, 2.5}, {:land, 9.807}]

      assert capture_log(fn ->
               assert Calculator.start(@mass_value, flight_routes) == 13_447
             end) =~ "route could not be calculated"
    end

    test "returns the amount of fuel needed ignoring the invalid route inserted with incalculable gravity" do
      flight_routes = [{:launch, 100}, {:land, 9.807}]

      assert capture_log(fn ->
               assert Calculator.start(@mass_value, flight_routes) == 13_447
             end) =~ "route could not be calculated"
    end

    test "returns {:error, reason} when the `flight_routes` argument is not a list" do
      flight_routes = "testing"

      assert Calculator.start(@mass_value, flight_routes) == {:error, :wrong_input}
    end
  end
end
