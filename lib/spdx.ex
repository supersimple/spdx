defmodule SPDX do
  @src_url "https://raw.githubusercontent.com/spdx/license-list-data/main/json/licenses.json"

  def export do
    fetch_source_file()
    |> simplify_list()
    |> sort_list_by_license_id()
    |> write_to_file()

    :ok
  end

  def fetch_source_file do
    @src_url
    |> Req.get!()
    |> Map.get(:body)
    |> Jason.decode!()
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
    %% File generated by https://github.com/supersimple/spdx. Do not edit manually.

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
