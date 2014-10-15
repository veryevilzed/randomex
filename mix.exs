defmodule Randomex.Mixfile do
  use Mix.Project

  def project do
    [app: :randomex,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [],
     mod: {Randomex, []}]
  end

  defp deps do
    []
  end
end
