defmodule Rational do

  @moduledoc """

  Implements exact rational numbers.  In its simplest form, Rational.new(3,4)
  will produce an exact rational number representation for 3/4. The fraction
  will be stored in the lowest terms (i.e., a reduced fraction) by dividing
  numerator and denominator through by their greatest common divisor.  For
  example the fraction 8/12 will be reduced to 2/3.

  Both parameters must be integers. The numerator defaults to 0 and the
  denominator defaults to 1 so that Rational.new(3) = 3/1 = 3 and Rational.new() =
  0/1 = 0

  ## Examples
      iex> Rational.new(3, 4)
      #Rational<3/4>

      iex> Rational.new(8,12)
      #Rational<2/3>
  """

  # Un-import Kernel functions to prevent name clashes.  We're redefining these
  # functions to work on rationals.
  import Kernel, except: [abs: 1, div: 2]

  @compile {:inline, maybe_unwrap: 1}
  if Code.ensure_loaded?(:hipe) do
    @compile [:native, {:hipe, [:o3]}]
  end

  defstruct num: 0, den: 1

  @typedoc """
   Rational numbers (num/den)
   """
  @type rational :: %Rational{
    num: integer,
    den: non_neg_integer}

  @doc """
  Finds the greatest common divisor of a pair of numbers. The greatest
  common divisor (also known as greatest common factor, highest common
  divisor or highest common factor) of two numbers is the largest positive
  integer that divides the numbers without remainder.   This function uses
  the recursive Euclid's algorithm.

  #### See also
  [new/2](#new/2)

  #### Examples
      iex> Rational.gcd(42, 56)
      14

      iex> Rational.gcd(13, 13)
      13

      iex> Rational.gcd(37, 600)
      1

      iex> Rational.gcd(20, 100)
      20

      iex> Rational.gcd(624129, 2061517)
      18913
  """
  @spec gcd(integer, integer) :: integer
  def gcd(m, 0), do: m
  def gcd(m, n) do
    gcd(n, rem(m, n))
  end


  @doc """
  This function extracts the sign from the provided number.  It returns 0 if
  the supplied number is 0, -1 if it's less than zero, and +1 if it's greater
  than 0.

  #### See also
  [gcd/2](#gcd/2)

  #### Examples
      iex> Rational.sign(3)
      1

      iex> Rational.sign(0)
      0

      iex> Rational.sign(-3)
      -1
  """
  @spec sign(rational | number) :: -1 | 0 | 1
  def sign(%{num: num}), do: sign(num)
  def sign(x) when x < 0, do: -1
  def sign(x) when x > 0, do: +1
  def sign(_), do: 0



  @doc """
  Returns a new rational with the specified numerator and denominator.

  #### See also
  [gcd/2](#gcd/2)

  #### Examples
      iex> Rational.new(3, 4)
      #Rational<3/4>

      iex> Rational.new(8,12)
      #Rational<2/3>

      iex> Rational.new()
      0

      iex> Rational.new(3)
      3

      iex> Rational.new(-3, 4)
      #Rational<-3/4>

      iex> Rational.new(3, -4)
      #Rational<-3/4>

      iex> Rational.new(-3, -4)
      #Rational<3/4>

      iex> Rational.new(0,0)
      ** (ArgumentError) cannot create nan (den=0)
  """
  @spec new(rational | number, integer | number) :: rational | number
  def new(numerator \\ 0, denominator \\ 1)   # Bodyless clause to set defaults

  # Handle NaN cases
  def new(_, denominator) when denominator == 0 do
    raise ArgumentError, message: "cannot create nan (den=0)"
  end

  def new(numerator, _) when numerator == 0, do: 0

  def new(numerator, denominator) when is_integer(numerator) and is_integer(denominator) do
    g = gcd(numerator, denominator)

    # Want to form rational as (numerator/g, denominator/g).  Force the
    # sign to reside on the numerator.
    n = Kernel.div(numerator, g)
    d = Kernel.div(denominator, g)
    sgn = sign(n)*sign(d)

    %Rational{num: sgn*Kernel.abs(n), den: Kernel.abs(d)}
    |> maybe_unwrap()
  end
  def new(numerator, denominator) do
    div(numerator, denominator)
  end


  @doc """
  Returns the floating point value of the rational

  #### Examples
      iex> Rational.value( Rational.new(3,4) )
      0.75

      iex> Rational.value( Rational.add(0.2, 0.3) )
      0.5

      iex> Rational.value( Rational.new(-3,4) )
      -0.75
  """
  @spec value(rational | number) :: number
  def value(number) do
    case maybe_wrap(number) do
      %{den: 1, num: num} ->
        num
      %{den: den, num: num} ->
        num / den
    end
  end


  @doc """
  Returns a new rational which is the sum of the specified rationals (a+b).

  #### See also
  [gcd/2](#gcd/2), [sub/2](#sub/2), [mult/2](#mult/2), [div/2](#div/2)

  #### Examples
      iex> Rational.add( Rational.new(3,4), Rational.new(5,8) )
      #Rational<11/8>

      iex> Rational.add( Rational.new(13,32), Rational.new(5,64) )
      #Rational<31/64>

      iex> Rational.add( Rational.new(-3,4), Rational.new(5,8) )
      #Rational<-1/8>
  """
  @spec add(rational | number, rational | number) :: rational | integer
  def add(a, b) when a == 0, do: b
  def add(a, b) when b == 0, do: a
  def add(a, b) do
    a = maybe_wrap(a)
    b = maybe_wrap(b)
    new(a.num * b.den + b.num * a.den, a.den * b.den)
  end


  @doc """
  Returns a new rational which is the difference of the specified rationals
  (a-b).

  #### See also
  [gcd/2](#gcd/2), [add/2](#add/2), [mult/2](#mult/2), [div/2](#div/2)

  #### Examples
      iex> Rational.sub( Rational.new(3,4), Rational.new(5,8) )
      #Rational<1/8>

      iex> Rational.sub( Rational.new(13,32), Rational.new(5,64) )
      #Rational<21/64>

      iex> Rational.sub( Rational.new(-3,4), Rational.new(5,8) )
      #Rational<-11/8>
  """
  @spec sub(rational | number, rational | number) :: rational | integer
  def sub(a, b) when a == 0, do: neg(b)
  def sub(a, b) when b == 0, do: a
  def sub(a, b) do
    a = maybe_wrap(a)
    b = maybe_wrap(b)
    new(a.num * b.den - b.num * a.den, a.den * b.den)
  end


  @doc """
  Returns a new rational which is the product of the specified rationals
  (a*b).

  #### See also
  [gcd/2](#gcd/2), [add/2](#add/2), [sub/2](#sub/2), [div/2](#div/2)

  #### Examples
      iex> Rational.mult( Rational.new(3,4), Rational.new(5,8) )
      #Rational<15/32>

      iex> Rational.mult( Rational.new(13,32), Rational.new(5,64) )
      #Rational<65/2048>

      iex> Rational.mult( Rational.new(-3,4), Rational.new(5,8) )
      #Rational<-15/32>
  """
  @spec mult(rational | number, rational | number) :: rational | integer
  def mult(a, b) when a == 0 or b == 0 do
    0
  end
  def mult(a, b) do
    a = maybe_wrap(a)
    b = maybe_wrap(b)
    new(a.num * b.num, a.den * b.den)
  end


  @doc """
  Returns a new rational which is the ratio of the specified rationals
  (a/b).

  #### See also
  [gcd/2](#gcd/2), [add/2](#add/2), [sub/2](#sub/2), [mult/2](#mult/2)

  #### Examples
      iex> Rational.div( Rational.new(3,4), Rational.new(5,8) )
      #Rational<6/5>

      iex> Rational.div( Rational.new(13,32), Rational.new(5,64) )
      #Rational<26/5>

      iex> Rational.div( Rational.new(-3,4), Rational.new(5,8) )
      #Rational<-6/5>
  """
  @spec div(rational | number, rational | number) :: rational | integer
  def div(a, _) when a == 0, do: 0
  def div(_, b) when b == 0 do
    raise ArgumentError, message: "cannot create nan (den=0)"
  end
  def div(a, b) do
    a = maybe_wrap(a)
    b = maybe_wrap(b)
    new(a.num * b.den, a.den * b.num)
  end


  @doc """
  Compares two Rationals. If the first number (a) is greater than the second
  number (b), 1 is returned, if a is less than b, -1 is returned. Otherwise,
  if both numbers are equal and 0 is returned.

  #### See also
  [gt/2](#gt/2), [le/2](#le/2)

  #### Examples
      iex> Rational.compare( Rational.new(3,4), Rational.new(5,8) )
      1

      iex> Rational.compare( Rational.new(-3,4), Rational.new(-5,8) )
      -1

      iex> Rational.compare( Rational.new(3,64), Rational.new(3,64) )
      0
  """
  @spec compare(rational | number, rational | number) :: (-1 | 0 | 1)
  def compare(a, b) do
    x = maybe_wrap(sub(a, b))
    cond do
      x.num == 0      -> 0
      sign(x.num) < 0 -> -1
      sign(x.num) > 0 -> 1
    end
  end



  @doc """
  Returns a boolean indicating whether parameter a is equal to parameter b.

  #### See also
  [gt/2](#gt/2), [le/2](#le/2)

  #### Examples
      iex> Rational.equal?( Rational.new(), Rational.new(0,1) )
      true

      iex> Rational.equal?( Rational.new(3,4), Rational.new(5,8) )
      false

      iex> Rational.equal?( Rational.new(-3,4), Rational.new(-3,4) )
      true
  """
  @spec equal?(rational | number, rational | number) :: boolean
  def equal?(a, b) do
    compare(a, b) == 0
  end

  @doc """
  Returns a boolean indicating whether the parameter a is less than parameter b.

  #### See also
  [gt/2](#gt/2), [le/2](#le/2)

  #### Examples
      iex> Rational.lt?( Rational.new(13,32), Rational.new(5,64) )
      false

      iex> Rational.lt?( Rational.new(-3,4), Rational.new(-5,8) )
      true

      iex> Rational.lt?( Rational.new(-3,4), Rational.new(5,8) )
      true
  """
  @spec lt?(rational | number, rational | number) :: boolean
  def lt?(a, b) do
    compare(a, b) == -1
  end


  @doc """
  Returns a boolean indicating whether the parameter a is less than or equal to
  parameter b.

  #### See also
  [ge/2](#ge/2), [lt/2](#lt/2)

  #### Examples
      iex> Rational.le?( Rational.new(13,32), Rational.new(5,64) )
      false

      iex> Rational.le?( Rational.new(-3,4), Rational.new(-5,8) )
      true

      iex> Rational.le?( Rational.new(-3,4), Rational.new(5,8) )
      true

      iex> Rational.le?( Rational.new(3,4), Rational.new(3,4) )
      true

      iex> Rational.le?( Rational.new(-3,4), Rational.new(-3,4) )
      true

      iex> Rational.le?( Rational.new(), Rational.new() )
      true
  """
  @spec le?(rational | number, rational | number) :: boolean
  def le?(a, b) do
    compare(a, b) != 1
  end


  @doc """
  Returns a boolean indicating whether the parameter a is greater than
  parameter b.

  #### See also
  [lt/2](#lt/2), [le/2](#le/2)

  #### Examples
      iex> Rational.gt?( Rational.new(13,32), Rational.new(5,64) )
      true

      iex> Rational.gt?( Rational.new(-3,4), Rational.new(-5,8) )
      false

      iex> Rational.gt?( Rational.new(-3,4), Rational.new(5,8) )
      false
  """
  @spec gt?(rational | number, rational | number) :: boolean
  def gt?(a, b), do: not le?(a,b)


  @doc """
  Returns a boolean indicating whether the parameter a is greater than or equal
  to parameter b.

  #### See also
  [le/2](#le/2), [gt/2](#gt/2)

  #### Examples
      iex> Rational.ge?( Rational.new(13,32), Rational.new(5,64) )
      true

      iex> Rational.ge?( Rational.new(-3,4), Rational.new(-5,8) )
      false

      iex> Rational.ge?( Rational.new(-3,4), Rational.new(5,8) )
      false

      iex> Rational.ge?( Rational.new(3,4), Rational.new(3,4) )
      true

      iex> Rational.ge?( Rational.new(-3,4), Rational.new(-3,4) )
      true

      iex> Rational.ge?( Rational.new(), Rational.new() )
      true
  """
  @spec ge?(rational | number, rational | number) :: boolean
  def ge?(a, b), do: not lt?(a,b)


  @doc """
  Returns a new rational which is the negative of the specified rational (a).

  #### See also
  [new/2](#new/2), [abs/2](#abs/2)

  #### Examples
      iex> Rational.neg( Rational.new(3,4) )
      #Rational<-3/4>

      iex> Rational.neg( Rational.new(-13,32) )
      #Rational<13/32>

      iex> Rational.neg( Rational.new() )
      0
  """
  @spec neg(rational | number) :: rational | integer
  def neg(a) do
    a = maybe_wrap(a)
    new(-a.num, a.den)
  end


  @doc """
  Returns a new rational which is the absolute value of the specified rational
  (a).

  #### See also
  [new/2](#new/2), [add/2](#add/2), [neg/2](#neg/2)

  #### Examples
      iex> Rational.abs( Rational.new(3,4) )
      #Rational<3/4>

      iex> Rational.abs( Rational.new(-13,32) )
      #Rational<13/32>

      iex> Rational.abs( Rational.new() )
      0
  """
  @spec abs(rational | number) :: rational | integer
  def abs(a) do
    a = maybe_wrap(a)
    new(Kernel.abs(a.num), a.den)
  end

  @spec maybe_wrap(rational | number) :: rational
  defp maybe_wrap(a) when is_integer(a) do
    %__MODULE__{num: a, den: 1}
  end
  defp maybe_wrap(a) when is_float(a) do
    from_float(a)
  end
  defp maybe_wrap(rational = %__MODULE__{}) do
    rational
  end
  defp maybe_wrap(other) do
    raise ArgumentError, message: "unsupported datatype #{inspect(other)}"
  end

  @spec maybe_unwrap(rational) :: rational | integer
  defp maybe_unwrap(%{den: 1, num: num}) do
    num
  end
  defp maybe_unwrap(rational) do
    rational
  end

  defp from_float(num, den \\ 1) do
    truncated = trunc(num)
    cond do
      truncated == num ->
        new(truncated, den)
      true ->
        from_float(num * 10, den * 10)
    end
  end
end

defimpl Inspect, for: Rational do
  def inspect(%{num: num, den: den}, opts) do
    "#Rational<#{Inspect.inspect(num, opts)}/#{Inspect.inspect(den, opts)}>"
  end
end
