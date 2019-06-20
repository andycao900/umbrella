defmodule Manifold.Chrome.ChromeClient.HTTP do
  @moduledoc """
  The http implementation of the ChromeClient behavior
  """
  alias Eex
  alias Manifold.Chrome.Features.Category
  alias Manifold.Chrome.Styles.VehicleDescription
  alias URI
  import SweetXml

  @behaviour Manifold.Chrome.ChromeClient

  @url "services.chromedata.com/Description/7a"
  @headers [{"Content-Type", "text/xml"}]

  @spec fetch_vehicle_description(binary(), binary(), binary(), binary()) ::
          {:ok, VehicleDescription.t()} | {:error, binary()}
  def fetch_vehicle_description(make, model, year, url \\ @url) do
    request = build_vehicle_description_request(make, model, year)

    request
    |> make_request(url)
    |> parse_vehicle_description_response()
  end

  def fetch_vehicle_description_by_vin(vin, url \\ @url) do
    request = build_vehicle_description_request(vin)

    request
    |> make_request(url)
    |> parse_vehicle_description_response()
  end

  @spec fetch_vehicle_features(binary()) :: {:ok, Category.t()} | {:error, binary()}
  def fetch_vehicle_features(url \\ @url) do
    request = build_vehicle_features_request()

    request
    |> make_request(url)
    |> parse_vehicle_features_response()
  end

  defp build_vehicle_description_request(make, model, year) do
    """
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:description7a.services.chrome.com">
        <soapenv:Header/>
        <soapenv:Body>
            <urn:VehicleDescriptionRequest>
                #{account_info()}
                <urn:modelYear>#{year}</urn:modelYear>
                <urn:makeName>#{make}</urn:makeName>
                <urn:modelName>#{model}</urn:modelName>
                <urn:switch>ShowExtendedDescriptions</urn:switch>
                <urn:switch>ShowExtendedTechnicalSpecifications</urn:switch>
                <urn:switch>IncludeDefinitions</urn:switch>
                <urn:switch>ShowAvailableEquipment</urn:switch>
                <urn:switch>ShowConsumerInformation</urn:switch>
                <urn:switch>DisableSafeStandards</urn:switch>
            </urn:VehicleDescriptionRequest>
        </soapenv:Body>
    </soapenv:Envelope>
    """
  end

  defp build_vehicle_description_request(vin) do
    """
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:description7a.services.chrome.com">
        <soapenv:Header/>
        <soapenv:Body>
            <urn:VehicleDescriptionRequest>
                #{account_info()}
                <urn:vin>#{vin}</urn:vin>
                <urn:switch>ShowExtendedDescriptions</urn:switch>
                <urn:switch>ShowExtendedTechnicalSpecifications</urn:switch>
                <urn:switch>IncludeDefinitions</urn:switch>
                <urn:switch>ShowAvailableEquipment</urn:switch>
                <urn:switch>ShowConsumerInformation</urn:switch>
                <urn:switch>DisableSafeStandards</urn:switch>
            </urn:VehicleDescriptionRequest>
        </soapenv:Body>
    </soapenv:Envelope>
    """
  end

  defp build_vehicle_features_request do
    """
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:description7a.services.chrome.com">
        <soapenv:Header/>
        <soapenv:Body>
            <urn:CategoryDefinitionsRequest>
                #{account_info()}
            </urn:CategoryDefinitionsRequest>
        </soapenv:Body>
    </soapenv:Envelope>
    """
  end

  defp account_info do
    account = Application.fetch_env!(:pipeline, :chrome_data)[:account_info]
    secret = Application.fetch_env!(:pipeline, :chrome_data)[:secret]

    """
    <urn:accountInfo number="#{account}" secret="#{secret}" country="US" language="EN"/>
    """
  end

  defp make_request(body, url) do
    HTTPoison.post(url, body, @headers)
  end

  defp parse_vehicle_description_response({:error, %{reason: _reason}}) do
    {:error, "Connection failed"}
  end

  defp parse_vehicle_description_response({:ok, %{status_code: 200, body: body}}) do
    error = parse_error(body)

    if error == nil do
      {:ok,
       %VehicleDescription{
         engines: parse_engines(body),
         exterior_colors: parse_exterior_colors(body),
         interior_colors: parse_interior_colors(body),
         styles: parse_styles(body),
         transmissions: parse_transmissions(body)
       }}
    else
      code = xpath(error, ~x"./@code")
      message = xpath(error, ~x"./text()")

      {:error, "Error response from Chrome Data #{code}:\n#{message}"}
    end
  end

  defp parse_vehicle_description_response({:ok, %{status_code: _status_code, body: body}}) do
    {:error, body}
  end

  defp parse_engines(xml_document) do
    xml_document
    |> xpath(
      ~x"//S:Envelope/S:Body/VehicleDescription/genericEquipment[contains(definition/type/@id, 4)]"l,
      category: ~x"./definition/category/@id"s,
      name: ~x"./definition/category/text()"s,
      style_ids: ~x"./styleId/text()"sl
    )
    |> Enum.map(&struct(VehicleDescription.Engine, &1))
  end

  defp parse_exterior_colors(xml_document) do
    xml_document
    |> xpath(~x"//S:Envelope/S:Body/VehicleDescription/exteriorColor"l,
      code: ~x"./@colorCode"s,
      name: ~x"./@colorName"s,
      rgb_value: ~x"./@rgbValue"s,
      style_ids: ~x"./styleId/text()"sl,
      generic_names: ~x"./genericColor/@name"sl
    )
    |> Enum.map(&struct!(VehicleDescription.ExteriorColor, &1))
  end

  defp parse_interior_colors(xml_document) do
    xml_document
    |> xpath(~x"//S:Envelope/S:Body/VehicleDescription/interiorColor"l,
      code: ~x"./@colorCode"s,
      name: ~x"./@colorName"s,
      style_ids: ~x"./styleId/text()"sl
    )
    |> Enum.map(&struct!(VehicleDescription.InteriorColor, &1))
  end

  defp parse_styles(xml_document) do
    xml_document
    |> xpath(~x"//S:Envelope/S:Body/VehicleDescription/style"l,
      chrome_id: ~x"./@id"s,
      division: ~x"./division/text()"s,
      drivetrain: ~x"./@drivetrain"s,
      model: ~x"./model/text()"s,
      model_year: ~x"./@modelYear"s,
      msrp: ~x"./basePrice/@msrp"s,
      name: ~x"./@name"s,
      trim: ~x"./@trim"s
    )
    |> Enum.map(&struct!(VehicleDescription.Style, &1))
  end

  defp parse_transmissions(xml_document) do
    xml_document
    |> xpath(
      ~x"//S:Envelope/S:Body/VehicleDescription/genericEquipment[contains(definition/type/@id, 15)]"l,
      category: ~x"./definition/category/@id"s,
      name: ~x"./definition/category/text()"s,
      style_ids: ~x"./styleId/text()"sl
    )
    |> Enum.map(&struct(VehicleDescription.Transmission, &1))
  end

  defp parse_error(xml_document) do
    xml_document |> xpath(~x"//S:Envelope/S:Body/VehicleDescription/responseStatus/status")
  end

  defp parse_vehicle_features_response({:error, %{reason: _reason}}) do
    {:error, "Connection failed"}
  end

  defp parse_vehicle_features_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, parse_vehicle_features(body)}
  end

  defp parse_vehicle_features_response({:ok, %{status_code: _status_code, body: body}}) do
    {:error, body}
  end

  defp parse_vehicle_features(xml_document) do
    xml_document
    |> xpath(
      ~x"//S:Envelope/S:Body/CategoryDefinitions/category"l,
      group_id: ~x"./group/@id"s,
      group_name: ~x"./group/text()"s,
      header_id: ~x"./header/@id"s,
      header_name: ~x"./header/text()"s,
      category_id: ~x"./category/@id"s,
      category_name: ~x"./category/text()"s
    )
    |> Enum.map(&struct(Category, &1))
  end
end
