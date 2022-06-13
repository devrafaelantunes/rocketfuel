defmodule RocketFuel.Calculator do
  @moduledoc """
    This is the application's main module. It's responsible for calculating the amount of rocket fuel
    that is needed for a list of flight routes.

    To ensure arbitrary precision and reliability, this module uses the `Decimal` library to do the
    required calculations.
  """

  # Typespecs
  @type fuel() :: number()
  @type mass() :: number()
  @type direction() :: :land | :launch | atom()
  @type gravity() :: number()
  @type flight_routes() :: [{direction(), gravity()}]

  alias RocketFuel.Utils
  require Logger

  @doc """
    This function is responsible for calculating the amount of fuel a rocket need to complete its trip.

    Receives the mass/weight of the ship as the first argument. It can be a number as a string: "2000",
    or an integer/float.

    The second argument is the flight route, which needs to be a list of tuples containing the direction
    of the trip and the gravity of the planet that you are targeting ex: [{:land, 9.807}, {:launch, 9.807}]
    
    It uses the `Enum.reduce` function to iterate over the `flight_routes` list. Each trip contain its
    gravity and direction, both of those values must be validated before being calculated, after validating
    them the function calculates the amount of fuel needed for each trip individually, adding them all up on 
    the Reduce's accumulator. Returning the total amount as a integer.

    The function will ignore the routes that did not pass the verification, but will still calculate the ones
    that did. The user is warned if any of the routes were ignored.

    REMINDER: The flight routes must be in correct order of events.
  """
  @spec start(mass(), flight_routes()) :: number()
  def start(mass, flight_routes) when is_list(flight_routes) do
    # Parses the mass into a decimal struct
    mass = Utils.transform_to_decimal(mass)

    flight_routes
    |> Enum.reverse()
    |> Enum.reduce(Decimal.new(0), fn {option, gravity}, fuel_acc ->
      # Parses the gravity into a decimal struct
      gravity = Utils.transform_to_decimal(gravity)

      cond do
        # During my tests, I found out that the formula used to calculate the amount of fuel needed does not
        # work when the inputted gravity is higher than 23.8. This verification prevents the application from
        # looping.
        Decimal.gt?(gravity, "23.8") ->
          # Warns the user
          Logger.warn(
            "Route with gravity higher than acceptable(#{gravity}) ignored, route could not be calculated."
          )

          # Ignores the trip that did not pass the verification
          Decimal.add(0, fuel_acc)

        # Verifies if the option inputted by the user is valid
        option != :land and option != :launch ->
          Logger.warn(
            "Direction must be :land or :launch. :#{option} route could not be calculated."
          )

          # Ignores any other type of option
          Decimal.add(0, fuel_acc)

        true ->
          mass
          # Adds the mass to the accumulator
          |> Decimal.add(fuel_acc)
          |> calculate_fuel({option, gravity}, Decimal.new(0))
          # Adds the fuel to the accumulator
          |> Decimal.add(fuel_acc)
      end
    end)
    # Parses the decimal into an integer
    |> Decimal.to_integer()
  end

  @spec start(any(), any()) :: {:error, :wrong_input}
  def start(_, _), do: {:error, :wrong_input}

  # Calculates the amount of fuel needed to the trip
  @spec calculate_fuel(mass(), {direction(), gravity()}, number()) :: number()
  defp calculate_fuel(mass, {:land, gravity} = opts, fuel_acc) do
    mass
    |> rounded_fuel_formula_result(gravity, "0.033", 42)
    # Checks if the weight added by the fuel requires extra fuel
    |> maybe_calculate_additional_fuel(opts, fuel_acc)
  end

  defp calculate_fuel(mass, {:launch, gravity} = opts, fuel_acc) do
    mass
    |> rounded_fuel_formula_result(gravity, "0.042", 33)
    |> maybe_calculate_additional_fuel(opts, fuel_acc)
  end

  # As fuel adds weight to the ship, the rocket might need extra fuel to handle the additional weight.
  # This function creates a recursion until no more extra fuel is needed. It has an accumulator that 
  # increases on each run, adding up to the total fuel needed.  
  @spec maybe_calculate_additional_fuel(fuel(), {direction(), gravity()}, number()) :: number()
  defp maybe_calculate_additional_fuel(fuel, {opt, gravity}, fuel_acc) do
    # Checks if is less or equals than zero
    if Utils.lte?(fuel, 0) do
      # Breaks the recursion and returns the total accumulated
      fuel_acc
    else
      # Adds the extra fuel to the accumulator
      total_fuel = Decimal.add(fuel, fuel_acc)

      # Calculates the extra fuel needed
      calculate_fuel(fuel, {opt, gravity}, total_fuel)
    end
  end

  # Uses the fuel calculation formula (mass * gravity * const_a - const_b) to return the amount of rocket fuel needed.
  @spec rounded_fuel_formula_result(mass(), gravity(), String.t(), integer()) :: number()
  defp rounded_fuel_formula_result(mass, gravity, launch_constant_a, launch_constant_b) do
    mass
    |> Decimal.mult(gravity)
    # Both constant A and B depends on the trip direction (launch or land)
    |> Decimal.mult(launch_constant_a)
    |> Decimal.sub(launch_constant_b)
    # Rounds down and remove the decimals before returning it
    |> Decimal.round(0, :down)
  end
end
