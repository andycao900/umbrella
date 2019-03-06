defmodule Pipeline.Ingestion.CPO.VW do

  alias Engine.InventoryTracker

  @moduledoc """
  Reads pipe-delimited file of VW inventory.
  Keys:
  web_num|id|make|model|price|miles|year|vin|exterior|interior|description|date_created|amenities|certified|stock|transmission|body_type|trim|last_modified|body_style|speeds|doors|cylinders|engine|base_color|price2|trans_text|eng_power|eng_config|displacement|induction|fuel_type|warranty|lot_date|market_class|msrp|photo_url
  Sample Line:
  425068||Volkswagen|Jetta|16988.00|21410|2017|3VWD17AJ9HM392612|Pure White|Black/Ceramique Leatherette|Call Dustin, Cedric, Craig, Kyle or Kevin for details on this very clean 1 owner VW Jetta.|02-FEB-19|Fuel Consumption: City: 25 mpg,Fuel Consumption: Highway: 35 mpg,Remote power door locks,Power windows,Cruise controls on steering wheel,Cruise control,4-wheel ABS Brakes,Front Ventilated disc brakes,1st and 2nd row curtain head airbags,Passenger Airbag,Side airbag,Rear spoiler: Lip,Navigation system with voice activation,Bluetooth wireless phone connectivity,Audio system security,Digital Audio Input,In-Dash single CD player,Audio system memory card slot,MP3 player,SiriusXM AM/FM/HD/Satellite Radio,Radio Data System,Speed Sensitive Audio Volume Control,Total Number of Speakers: 6,Intercooled Turbo,Braking Assist,ABS and Driveline Traction Control,Stability control,Privacy glass: Light,Machined aluminum rims w/ painted accents,Wheel Diameter: 17,Wheel Width: 7,Front fog/driving lights,Leather/piano black steering wheel trim,Leather/metal-look shift knob trim,Metal-look dash trim,Metal-look door trim,Video Monitor Location: Front,Trip computer,External temperature display,Auxilliary engine cooler,Tachometer,Manufacturer's 0-60mph acceleration time (seconds): 9.2 s,Power remote driver mirror adjustment,Heated driver mirror,Heated passenger mirror,Power remote passenger mirror adjustment,Dual vanity mirrors,Daytime running lights,Heated windshield washer jets,Driver and passenger heated-cushion, driver and passenger heated-seatback,Audio controls on steering wheel,VW Car-Net,Power remote trunk release,Rear reading lights,Pre-wiring for anti-theft alarm system,Leatherette seat upholstery,Front sport seat,Rear bench,Fold forward seatback rear seats,Rear seats center armrest with pass-thru,Tilt and telescopic steering wheel,Speed-proportional electric power steering,Suspension class: Sport,Interior air filtration,Manual front air conditioning,Tire Pressure Monitoring System,Cargo area light,Max cargo capacity: 16 cu.ft.,Vehicle Emissions: ULEV II,Fuel Type: Regular unleaded,Fuel Capacity: 14.5 gal.,Instrumentation: Low fuel level,Clock: In-dash,Coil front spring,Regular front stabilizer bar,Independent front suspension classification,Strut front suspension,Four-wheel Independent Suspension,Coil rear spring,Rear Stabilizer Bar: Regular,Independent rear suspension,Multi-link rear suspension,Front and rear suspension stabilizer bars,Variable intermittent front wipers,Steel spare wheel rim,Spare Tire Mount Location: Inside under cargo,Black grille w/chrome accents,Center Console: Full with covered storage,Overhead console: Mini with storage,Curb weight: 3,177 lbs.,Gross vehicle weight: 4,299 lbs.,Overall Length: 183.3",Overall Width: 70.0",Overall height: 57.2",Wheelbase: 104.4",Front Head Room: 38.2",Rear Head Room: 37.1",Front Leg Room: 41.2",Rear Leg Room: 38.1",Front Shoulder Room: 55.2",Rear Shoulder Room: 53.6",Two 12V DC power outlets,Transmission hill holder,Seatbelt pretensioners: Front,Rear center seatbelt: 3-point belt,Door reinforcement: Side-impact door beam,Engine immobilizer,Cargo tie downs,Floor mats: Carpet front and rear,Cupholders: Front and rear,Door pockets: Driver, passenger and rear,Seatback storage: 1,Tires: Width: 225 mm,Tires: Profile: 45,Tires: Speed Rating: H,Diameter of tires: 17.0",Type of tires: AS,Tires: Prefix: P,Left rear passenger door type: Conventional,Rear door type: Trunk,Right rear passenger door type: Conventional,Body-colored bumpers,Window grid antenna,4 Door,Selective service internet access,Driver airbag,Manual child safety locks,Rear View Camera,Keyless ignition with push button start,1 USB port,VW Car-Net App-Connect mirroring,Halogen headlights,Ambient lighting,SiriusXM Satellite Radio|1|D33130A|a|CAR|1.8T Sport|14-FEB-19|Sedan|6|4|4|[]|White|0|6-Speed Automatic|||1.8||G|1||0||http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_1.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_2.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_3.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_4.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_5.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_6.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_7.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_8.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_9.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_10.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_11.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_12.jpg http://vwi.images.dmotorworks.com/cars/VWI425068/D33130A_13.jpg
  """

  NimbleCSV.define(NimblePipeParser, separator: "|", escape: "\0")

  @doc """
  Hello this is some documentation
  ## Examples
      iex> Pipeline.Ingestion.CPO.VW.inventory_from_file("test.txt")
      ["Hello World"]
  """
  def inventory_from_file(path) do
    stream =
      path
      |> File.stream!()
      |> NimblePipeParser.parse_stream(headers: false)

    [keys] = Enum.take(stream, 1)

    lines =
      stream
      |> Stream.drop(1)

    lines
    |> Stream.map(&zip_keys(&1, keys))
    |> Stream.map(&to_inventory/1)
    |> Enum.into([])
  end

  def zip_keys(line, keys) do
    IO.puts("Hello")

    keys
    |> Enum.zip(line)
    |> Enum.into(%{})
  end

  def to_inventory(item) do
    %{
      make: Map.fetch!(item, "make"),
      model: Map.fetch!(item, "model"),
      price: Map.fetch!(item, "price"),
      miles: Map.fetch!(item, "miles"),
      year: Map.fetch!(item, "year"),
      vin: Map.fetch!(item, "vin"),
      external_dealer_id: Map.fetch!(item, "web_num")
    }
    |> InventoryTracker.build_cpo_inventory()
  end
end
