defmodule RocketFuel.Utils do
  @moduledoc """
    Module created to support and bring some "utility tools" to `RocketFuel.Calculator`
  """

  @type a() :: number()
  @type b() :: number()

  require Logger

  @doc """
    Transforms a given number into a decimal.
    It can be float or integer.
  """
  @spec transform_to_decimal(number()) :: number()
  def transform_to_decimal(number) when is_number(number) do
    number
    |> Kernel.inspect()
    |> Decimal.new()
  end

  # Parses a string into a number and transform it into a decimal.
  # Returns 0 if the argument cannot be parsed. ex: "abc"
  @spec transform_to_decimal(String.t()) :: number()
  def transform_to_decimal(number) when is_binary(number) do
    case Integer.parse(number) do
      {result, _} ->
        result
        |> transform_to_decimal()

      # It returns :error when the `number` argument cannot be parsed
      :error ->
        # Warns the user
        Logger.warn("Mass must be a number in order to be calculated.")
        Decimal.new(0)
    end
  end

  # Returns nil when the argument is neither a string or a number
  def transform_to_decimal(_), do: nil

  @doc """
    This function compare two decimals (a, b). 
    It returns TRUE if A is less than or equals to B.
    It returns FALSE otherwise.
  """
  @spec lte?(a(), b()) :: boolean()
  def lte?(a, b), do: Decimal.lt?(a, b) or Decimal.eq?(a, b)
end
