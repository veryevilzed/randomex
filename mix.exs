defmodule Randomex.Mixfile do
  use Mix.Project

  def project do
    [app: :randomex,
     version: "0.0.2",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:sfmt],
     mod: {Randomex, []}]
  end

  defp deps do
    [
      {:sfmt, github: "jj1bdx/sfmt-erlang" }
    ]
  end
end
