# Rational

Implements exact rational numbers.  In its simplest form, Rational.new(3,4)
will produce an exact rational number representation for 3/4. Both parameters
must be integers. The numerator defaults to 0 and the denominator defaults to
1 so that Rational.new(3) = 3/1 = 3 and Rational.new() = 0/1 = 0


## Installation

Add *rational* as a dependency in your `mix.exs` file.

```elixir
def deps do
  [ { :rational, "~> 0.0.0" } ]
end
```

After you are done, run `mix deps.get` in your shell to fetch and compile
the Rational module. Start an interactive Elixir shell with `iex -S mix` and
try the examples in the [examples section](#examples).


## Documentation

Documentation for the package is available online via Hex at
[http://hexdocs.pm/rational](http://hexdocs.pm/rational).  You can also generate
local docs via the mix task
```elixir
mix docs
```
This will generate the HTML documentation and place it into the `doc` subdirectory.

## Examples
```elixir
iex> Rational.new(3, 4)
%Rational{den: 4, num: 3}

iex> Rational.new(8,12)
%Rational{den: 3, num: 2}
```

## License

   Copyright 2015 Thomas Krauss

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
