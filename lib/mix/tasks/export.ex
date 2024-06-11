defmodule Mix.Tasks.Export do
  use Mix.Task

  @shortdoc "exports a list to be consumed."
  def run(_) do
    SPDX.export()
  end
end
