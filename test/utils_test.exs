defmodule RocketFuel.UtilsTest do
  use ExUnit.Case

  alias RocketFuel.Utils

  import ExUnit.CaptureLog
  require Logger

  describe "transform_to_decimal/1" do
    test "transforms a integer into a decimal returning a decimal struct" do
      raw_number = 5
      decimal = Decimal.new(raw_number)

      assert Utils.transform_to_decimal(raw_number) == decimal
    end

    test "transforms a float into a decimal returning a decimal struct" do
      raw_number = 5.5
      decimal = Decimal.new("#{raw_number}")

      assert Utils.transform_to_decimal(raw_number) == decimal
    end

    test "transforms a binary into a decimal returning a decimal struct" do
      raw_number = "5"
      decimal = Decimal.new(raw_number)

      assert Utils.transform_to_decimal(raw_number) == decimal
    end

    test "returns 0 when a string cannot be parsed into a decimal" do
      raw_number = "abc"

      assert capture_log(fn ->
               assert Utils.transform_to_decimal(raw_number) == %Decimal{}
             end) =~ "Mass must be a number in order to be calculated."
    end

    test "returns nil when the argument passed is not a number or a string" do
      raw_number = [1, 2, 3]

      assert Utils.transform_to_decimal(raw_number) == nil
    end
  end

  describe "lte?/2" do
    test "returns true when a's value is less than b's" do
      a = Decimal.new(3)
      b = Decimal.new(5)

      assert Utils.lte?(a, b) == true
    end

    test "returns true when a's value is equals than b's" do
      a = Decimal.new(3)
      b = Decimal.new(3)

      assert Utils.lte?(a, b) == true
    end

    test "returns false when b's value is higher than b's" do
      a = Decimal.new(5)
      b = Decimal.new(3)

      assert Utils.lte?(a, b) == false
    end
  end
end
