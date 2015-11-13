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
      %Rational{den: 4, num: 3}

      iex> Rational.new(8,12)
      %Rational{den: 3, num: 2}
  """

  # Un-import Kernel functions to prevent name clashes.  We're redefining these
  # functions to work on rationals.
  import Kernel, except: [abs: 1, div: 2]


  defstruct num: 0, den: 1

  @typedoc """
   Rational numbers (num/den)
   """
  @type rational :: %Rational{num: integer, den: integer}

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
  def gcd(m,n) do
    cond do
      n == 0        -> m
      #rem(m,n) == 0 -> n
      true          -> gcd(n, rem(m,n))
    end
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

  #### To Do
  This function uses a direct comparison with 0 (that is it uses x==0).  This
  is probably not a good idea.  Rather it should use an approximate equality
  so it's accurate with floats.
  """
  @spec sign(number) :: -1 | 0 | 1
  def sign(x) when x < 0, do: -1
  def sign(x) when x > 0, do: +1
  def sign(_), do: 0


  @doc """
  Returns a new rational with the specified numerator and denominator.

  #### See also
  [gcd/2](#gcd/2)

  #### Examples
      iex> Rational.new(3, 4)
      %Rational{den: 4, num: 3}

      iex> Rational.new(8,12)
      %Rational{den: 3, num: 2}

      iex> Rational.new()
      %Rational{den: 1, num: 0}

      iex> Rational.new(3)
      %Rational{den: 1, num: 3}

      iex> Rational.new(-3, 4)
      %Rational{den: 4, num: -3}

      iex> Rational.new(3, -4)
      %Rational{den: 4, num: -3}

      iex> Rational.new(-3, -4)
      %Rational{den: 4, num: 3}
  """
  @spec new(integer, integer) :: rational
  def new(numerator \\ 0, denominator \\ 1) do
    g = gcd(numerator, denominator)

    # Want to form rational as (numerator/g, denominator/g).  Force the
    # division to give integers and force the sign to reside on the numerator.
    n = round(numerator / g)
    d = round(denominator / g)
    sgn = sign(n)*sign(d)

    %Rational{num: sgn*Kernel.abs(n), den: Kernel.abs(d)}
  end


  @doc """
  Returns a new rational which is the sum of the specified rationals (a+b).

  #### See also
  [gcd/2](#gcd/2), [sub/2](#sub/2), [mult/2](#mult/2), [div/2](#div/2)

  #### Examples
      iex> Rational.add( Rational.new(3,4), Rational.new(5,8) )
      %Rational{den: 8, num: 11}

      iex> Rational.add( Rational.new(13,32), Rational.new(5,64) )
      %Rational{den: 64, num: 31}

      iex> Rational.add( Rational.new(-3,4), Rational.new(5,8) )
      %Rational{den: 8, num: -1}
  """
  @spec add(rational, rational) :: rational
  def add(a, b) do
    new(a.num*b.den + b.num*a.den, a.den*b.den)
  end


  @doc """
  Returns a new rational which is the difference of the specified rationals
  (a-b).

  #### See also
  [gcd/2](#gcd/2), [add/2](#add/2), [mult/2](#mult/2), [div/2](#div/2)

  #### Examples
      iex> Rational.sub( Rational.new(3,4), Rational.new(5,8) )
      %Rational{den: 8, num: 1}

      iex> Rational.sub( Rational.new(13,32), Rational.new(5,64) )
      %Rational{den: 64, num: 21}

      iex> Rational.sub( Rational.new(-3,4), Rational.new(5,8) )
      %Rational{den: 8, num: -11}
  """
  @spec sub(rational, rational) :: rational
  def sub(a, b) do
    new(a.num*b.den - b.num*a.den, a.den*b.den)
  end


  @doc """
  Returns a new rational which is the product of the specified rationals
  (a*b).

  #### See also
  [gcd/2](#gcd/2), [add/2](#add/2), [sub/2](#sub/2), [div/2](#div/2)

  #### Examples
      iex> Rational.mult( Rational.new(3,4), Rational.new(5,8) )
      %Rational{den: 32, num: 15}

      iex> Rational.mult( Rational.new(13,32), Rational.new(5,64) )
      %Rational{den: 2048, num: 65}

      iex> Rational.mult( Rational.new(-3,4), Rational.new(5,8) )
      %Rational{den: 32, num: -15}
  """
  @spec mult(rational, rational) :: rational
  def mult(a, b) do
    new(a.num*b.num, a.den*b.den)
  end


  @doc """
  Returns a new rational which is the ratio of the specified rationals
  (a/b).

  #### See also
  [gcd/2](#gcd/2), [add/2](#add/2), [sub/2](#sub/2), [mult/2](#mult/2)

  #### Examples
      iex> Rational.div( Rational.new(3,4), Rational.new(5,8) )
      %Rational{den: 5, num: 6}

      iex> Rational.div( Rational.new(13,32), Rational.new(5,64) )
      %Rational{den: 5, num: 26}

      iex> Rational.div( Rational.new(-3,4), Rational.new(5,8) )
      %Rational{den: 5, num: -6}
  """
  @spec div(rational, rational) :: rational
  def div(a, b) do
    new(a.num*b.den, a.den*b.num)
  end


  @doc """
  Returns a boolean indicating whether the parameter a is less than parameter b.

  #### See also
  [gt/2](#gt/2), [le/2](#le/2)

  #### Examples
      iex> Rational.lt( Rational.new(13,32), Rational.new(5,64) )
      false

      iex> Rational.lt( Rational.new(-3,4), Rational.new(-5,8) )
      true

      iex> Rational.lt( Rational.new(-3,4), Rational.new(5,8) )
      true
  """
  @spec lt(rational, rational) :: boolean
  def lt(a, b) do
    x = sub(a,b)
    sign(x.num) < 0
  end


  @doc """
  Returns a boolean indicating whether the parameter a is less than or equal to
  parameter b.

  #### See also
  [ge/2](#ge/2), [lt/2](#lt/2)

  #### Examples
      iex> Rational.le( Rational.new(13,32), Rational.new(5,64) )
      false

      iex> Rational.le( Rational.new(-3,4), Rational.new(-5,8) )
      true

      iex> Rational.le( Rational.new(-3,4), Rational.new(5,8) )
      true

      iex> Rational.le( Rational.new(3,4), Rational.new(3,4) )
      true

      iex> Rational.le( Rational.new(-3,4), Rational.new(-3,4) )
      true

      iex> Rational.le( Rational.new(), Rational.new() )
      true
  """
  @spec le(rational, rational) :: boolean
  def le(a, b) do
    x = sub(a,b)
    sign(x.num) <= 0
  end


  @doc """
  Returns a boolean indicating whether the parameter a is greater than
  parameter b.

  #### See also
  [lt/2](#lt/2), [le/2](#le/2)

  #### Examples
      iex> Rational.gt( Rational.new(13,32), Rational.new(5,64) )
      true

      iex> Rational.gt( Rational.new(-3,4), Rational.new(-5,8) )
      false

      iex> Rational.gt( Rational.new(-3,4), Rational.new(5,8) )
      false
  """
  @spec gt(rational, rational) :: boolean
  def gt(a, b), do: not le(a,b)


  @doc """
  Returns a boolean indicating whether the parameter a is greater than or equal
  to parameter b.

  #### See also
  [le/2](#le/2), [gt/2](#gt/2)

  #### Examples
      iex> Rational.ge( Rational.new(13,32), Rational.new(5,64) )
      true

      iex> Rational.ge( Rational.new(-3,4), Rational.new(-5,8) )
      false

      iex> Rational.ge( Rational.new(-3,4), Rational.new(5,8) )
      false

      iex> Rational.ge( Rational.new(3,4), Rational.new(3,4) )
      true

      iex> Rational.ge( Rational.new(-3,4), Rational.new(-3,4) )
      true

      iex> Rational.ge( Rational.new(), Rational.new() )
      true
  """
  @spec ge(rational, rational) :: boolean
  def ge(a, b), do: not lt(a,b)


  @doc """
  Returns a new rational which is the negative of the specified rational (a).

  #### See also
  [new/2](#new/2), [abs/2](#abs/2)

  #### Examples
      iex> Rational.neg( Rational.new(3,4) )
      %Rational{den: 4, num: -3}

      iex> Rational.neg( Rational.new(-13,32) )
      %Rational{den: 32, num: 13}

      iex> Rational.neg( Rational.new() )
      %Rational{den: 1, num: 0}
  """
  @spec neg(rational) :: rational
  def neg(a) do
    new(-a.num, a.den)
  end


  @doc """
  Returns a new rational which is the absolute value of the specified rational
  (a).

  #### See also
  [new/2](#new/2), [add/2](#add/2), [neg/2](#neg/2)

  #### Examples
      iex> Rational.abs( Rational.new(3,4) )
      %Rational{den: 4, num: 3}

      iex> Rational.abs( Rational.new(-13,32) )
      %Rational{den: 32, num: 13}

      iex> Rational.abs( Rational.new() )
      %Rational{den: 1, num: 0}
  """
  @spec abs(rational) :: rational
  def abs(a) do
    new(Kernel.abs(a.num), a.den)
  end

end
