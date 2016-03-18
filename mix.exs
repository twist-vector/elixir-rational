defmodule Rational.Mixfile do
  use Mix.Project

  def project do
    [app: :rational,
     version: "0.2.0",
     description: description,
     package: package,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     docs: [extras: []]]
  end


  def application do
    [applications: [:logger]]
  end


  defp deps do
    [{:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp description do
   """
   Rational is a module for exact representation and manipulation of rational
   fractions, that is, those fractions that can be exactly represented by a
   ratio of integers (e.g., 1/3 or 4176/22687).
   """
 end

 defp package do
   [maintainers: ["Tom Krauss"],
    licenses: ["Apache 2.0"],
    links: %{"GitHub" => "https://github.com/twist-vector/elixir-rational.git",
             "Docs" => "http://http://hexdocs.pm/rational"}]
 end

end
