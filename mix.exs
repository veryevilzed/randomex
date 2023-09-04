defmodule Randomex.Mixfile do
  use Mix.Project

  def project do
    [app: :randomex,
     version: "0.0.1",
     elixir: "~> 1.14.0",
     deps: []]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [],
     mod: []]
  end
end
