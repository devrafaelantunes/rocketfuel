# RocketFuel

This application calculate the precise amount of fuel required to launch a rocket from one planet
of the Solar system and to land on another, depending on the flight route.

## Description

An in-depth paragraph about your project and overview of use.

## Getting Started

### Installing

* Clone the project
* Run `mix deps.get`

### Executing program

* Run `iex -S mix` to execute the program
* To calculate the amount of fuel, use the `RocketFuel.Calculator.start/2` function. For more info,
check the module's documentation. Example:

```
iex > flight_routes = [{:launch, 9.807}, {:land, 1.62}, {:launch, 1.62}, {:land, 9.807}]
iex > RocketFuel.Calculator.start(28801, flight_routes)
51898
```

## Authors

Rafael Antunes
dev@rafaelantun.es

## Version History

* 0.1
    * Initial Release