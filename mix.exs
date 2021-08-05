defmodule Randomex.Mixfile do
  use Mix.Project

  def project do
    [app: :randomex,
     version: "0.0.3",
     elixir: "~> 1.12.0",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:crypto, :sfmt],
     mod: {Randomex, []}]
  end

  defp deps do
    [
      {:sfmt, github: "jj1bdx/sfmt-erlang" }
    ]
  end
end
