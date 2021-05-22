defmodule SPDX do
  # License list taken from: https://github.com/spdx/license-list-data/blob/master/json/licenses.json
  def export do
    [File.cwd!(), "src", "licenses.json"]
    |> Path.join()
    |> File.read!()
    |> Jason.decode!()
    |> simplify_list()
    |> write_to_file()
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
    [File.cwd!(), "spdx_list.exs"]
    |> Path.join()
    |> File.write!(inspect(data, limit: :infinity))
  end
end
