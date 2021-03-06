defmodule SPDX do
  # License list taken from: https://github.com/spdx/license-list-data/blob/master/json/licenses.json
  def export do
    [File.cwd!(), "src", "licenses.json"]
    |> Path.join()
    |> File.read!()
    |> Jason.decode!()
    |> simplify_list()
    |> sort_list_by_license_id()
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

  defp sort_list_by_license_id(license_list) do
    Enum.sort_by(license_list, & &1.license_id)
  end

  defp write_to_file(license_list) do
    contents = file_functions(license_list)

    [File.cwd!(), "hex_licenses.erl"]
    |> Path.join()
    |> File.write!(file_head() <> contents <> file_tail())
  end

  defp file_head() do
    ~S"""
    %% @doc
    %% Hex Licenses.
    %% File generated by spdx.ex. Do not edit manually.

    -module(hex_licenses).

    -export([valid/1]).

    """
  end

  defp file_functions(license_list) do
    Enum.reduce(license_list, "", fn license, acc ->
      acc <>
        """
        valid(<<"#{license.license_id}">>) -> true;
        """
    end)
  end

  defp file_tail() do
    ~S"""
    valid(_) -> false.
    """
  end
end
