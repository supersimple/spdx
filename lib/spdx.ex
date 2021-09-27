defmodule SPDX do
  # License list taken from: https://github.com/spdx/license-list-data/blob/master/json/licenses.json
  def export do
    [File.cwd!(), "src", "licenses.json"]
    |> Path.join()
    |> File.read!()
    |> Jason.decode!()
    |> simplify_list()
    |> write_to_file()

    :ok
  end

  defp simplify_list(full_data) do
    Enum.map(full_data["licenses"], fn lic ->
      %{
        license_id: Map.get(lic, "licenseId", ""),
        deprecated?: Map.get(lic, "isDeprecatedLicenseId", false),
        osi_approved?: Map.get(lic, "isOsiApproved", true)
      }
    end)
  end

  defp write_to_file(data) do
    contents = inspect(data, limit: :infinity)
    [File.cwd!(), "spdx_list.exs"]
    |> Path.join()
    |> File.write!(contents)

    write_erlterm_file()
  end

  defp write_erlterm_file() do
    f = Code.eval_file("spdx_list.exs")
    f = elem(f, 0)
    {:ok, file} = :file.open("spdx_list.erlterm", [:write])
    :io.fwrite(file, "~p~n", [f])
    :file.close(file)
  end
end
