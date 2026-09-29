# therm — heat pump analysis for Home Assistant

**therm** (Thermal Health & Efficiency Reporting Module) shows how well your heat pump is really working, using
the sensor history Home Assistant already records. It works out efficiency (COP), splits heat between space heating
and hot water, and picks out every run, defrost and short cycle. It also costs everything at your electricity prices
and tells you how complete your sensor data is.

It runs as a Home Assistant add-on, opens from the sidebar and reads your data directly from Home Assistant or
InfluxDB, so there is nothing to export or upload.

> **Status: experimental (0.1.x).** It was developed on a Samsung EHS system and recognises common Samsung
> integrations, but works with any heat pump that reports electrical power and either heat output or flow rate with
> flow and return temperatures.
> Feedback and [issues](https://github.com/therm-heatpump/therm/issues) are welcome.

## What you get

- **Trends:** a daily energy balance (heat delivered for heating and hot water against electricity used), COP for
  the period and each day, cost and cost per kWh of heat, a weather-compensation chart and hot-water consistency.
- **Run Inspector:** every heating, hot-water and cooling run with its COP, cost, flow and room temperatures, plus
  a finder for your best and worst runs.
- **Data Quality:** which sensors reported, how often and where the gaps are, so you know how far to trust the
  numbers.
- **Private by design:** everything is calculated inside your Home Assistant; nothing is sent anywhere.

---

## Install

[![Add the therm repository to your Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Ftherm-heatpump%2Ftherm)

Or add the repository by hand:

1. In Home Assistant go to **Settings → Add-ons → Add-on Store**, open the **⋮** menu (top right) and choose
   **Repositories**.
2. Add `https://github.com/therm-heatpump/therm` and close the dialog.
3. Find **therm** in the store, press **Install**, then **Start**, and switch on **Show in sidebar**.
   The first install builds the add-on on your system and can take several minutes.
4. Open **therm** from the sidebar.

**You need:** Home Assistant OS (add-ons are not available on Container or Core installs; Supervised may work but is
no longer supported by Home Assistant), on amd64
or 64-bit ARM. Your heat pump's electrical **power** must be in Home Assistant. For heat output, COP and costs per
unit of heat, therm also needs **either** a heat meter (heat output) **or** the **flow rate** plus **flow and return
temperatures**. **Outdoor temperature** is strongly recommended.

> **Samsung Modbus (MIM-B19N) users: a separate electricity meter is required.** Samsung's Modbus interface does not report
> the heat pump's electricity use, so without a meter on its supply (e.g. a Shelly EM or a CT clamp) therm cannot
> calculate COP or costs. The NASA-based integrations (ha-samsungehs, EHS-Sentinel, ESPHome) report the
> unit's own estimate, but a meter is still more accurate.

**Using InfluxDB?** Only then, fill in the add-on's **Configuration** tab before starting it: host, database and a
**read-only** InfluxDB user. For the InfluxDB add-on the host is `a0d7b954-influxdb` and the database is usually
`homeassistant`. Without InfluxDB, leave the host empty; therm reads Home Assistant's own history.

## Quick start

1. At the top of therm's sidebar, choose **Home Assistant** or **InfluxDB** as the data source.
2. Follow the set-up wizard:
   - **Quick start:** Uses what therm auto-detects from your system, borrowing your time zone, currency and location name from Home Assistant. If all core sensors are found, it takes you straight to the Review screen.
   - **Guided (recommended):** Walk through five focused steps covering the sensors and settings that matter most: core heat pump sensors, fluid type and heat measurement, hot water detection, electricity prices & time zone, and rooms.
   - **Full set-up:** Review all eleven steps in detail, including weather fallbacks, diagnostic sensors, thresholds, and AI context notes.
   - Or click **"I'd rather see the whole Setup page"** to open all configuration tabs immediately.
3. Review your setup and any suggestions under **Worth checking later**, then press **Save and start**.
4. In the sidebar, choose a **Period** and press **Load latest data**.

The next time you open therm it shows your last analysis straight away; **Load latest data** brings it up to date.

---

## Using therm

### The screen

- **Main panel:** the **Trends | Run Inspector** toggle and the interactive charts. In **Trends**, five headline metric cards (Total heat, Electricity, Cost with unit cost of heat, Period COP and System COP) summarize the period and adapt when filtering by All, Space heating, or Hot water.
- **Sidebar:** the data source, **Period** and **Load latest data**; **Whole system** stats (heat, electricity, COP and runs); **⚙️ Setup** and **Data Quality**; and at the bottom, **Troubleshooting (debug files)**.
- **Phone layout:** on mobile screens (<640px), the headline cards adapt two-to-a-row, and secondary expanders start collapsed. The sidebar can be opened with the **>** arrow at the top left.

### Setting up your heat pump

Setup maps each of therm's *roles* (power, flow temperature, DHW valve, outdoor temperature and so on) to one of
your sensors, and configures your heating system characteristics.

- **🔎 Detect my heat pump** scans your available entities and recognises common integrations (Samsung Modbus MIM-B19N,
  ESPHome, ha-samsungehs and EHS-Sentinel), metered power devices, weather stations, rooms and zones. Zone signals
  it finds are offered under **Rooms & zones** for you to confirm; zones are never switched on by themselves.
- **Heating zones are optional:** If your installation controls heating through thermostats or smart valves with
  individual zone signals, map them in **Rooms & zones**. If your system does not record separate zone signals, choose
  **One heating circuit, or no zone signals in Home Assistant** (the default): all room sensors are used for heating runs, hot water is tracked from the cylinder
  temperature, and heating while the tank is reheating cannot be identified. Zone settings can be turned on or off at
  any time without losing your zone choices.
- **Setup tabs:** When viewing the full Setup page, settings are organised into seven clear tabs:
  - **Sensors:** Required core sensors (electrical power, flow and return temperatures, and flow rate unless a heat
    meter is used) and optional extra channels (compressor frequency, indoor unit power, immersion).
  - **Heat & hot water:** Heat calculation methods, primary circuit fluid (water or glycol mixture, which shifts heat
    output by ~7%), and hot water run detection.
  - **Rooms & zones:** Room temperature sensors and heating zone controls.
  - **Weather:** Primary outdoor temperature, humidity, wind, and solar sensors, plus secondary weather fallbacks.
  - **Costs & time zone:** Electricity pricing with effective dates and time-of-day bands (day, night, peak), currency
    selection (pre-populated from Home Assistant when available), and local time zone.
  - **Thresholds:** Run detection parameters, minimum run durations, flow limits, weather-compensation curves, and
    diagnostics.
  - **Notes:** Property and heat pump background context for AI reports, and a log of system setting adjustments.
- **Review & guidance:** The wizard's Review screen highlights any missing essential sensors and notes settings
  **"Worth checking later"** (such as default fluid type or example electricity prices) with direct buttons to the
  relevant tab. You can re-run the walkthrough at any time by pressing **Run guided set-up again**, or use
  **Start a new profile** to configure a second heat pump or start fresh.
- Profiles are saved as JSON files inside the add-on. You can maintain multiple profiles and switch between them under
  **Saved profiles**.

### Loading data

- **Home Assistant** reads the recorder history. Home Assistant keeps about 10 days by default. therm saves each
  completed day, so it keeps them after Home Assistant has deleted them, and history builds up in therm over time.
- **InfluxDB** reads your InfluxDB history, so you can analyse months or years. Periods longer than a month are
  processed one month at a time with a progress bar. Finished months are saved, so later loads only process the
  current month (or every month again if you change Setup).
- therm checks memory before loading. If a period is too long it tells you the longest period that fits.
- **Data Quality** lists any mapped sensors that had no data in the last load. If past data was corrected or
  back-filled in the source, clear the saved copy under **⚙️ Setup → Saved source data** and load again.

### Trends

- **Daily Energy Balance:** heat delivered each day for space heating and hot water against electricity used, net of
  heat taken back by defrosts.
- **COP:** *Period COP* for the outdoor unit alone and for the whole system (outdoor plus indoor unit), with daily
  values. Immersion heater use is reported separately and not counted in the COP.
- **Space heating runs against outdoor temperature** show your weather-compensation curve. **Hot-water runs** show
  how consistent tank reheats are.
- Cost, cost per kWh of heat, defrosts, cycling, and wind, humidity and sunshine against efficiency.

### Run Inspector

Every heating, hot-water and cooling run in the period. Choose a run to see minute-by-minute power, flow and return
temperatures, flow rate, room temperatures and its COP and cost.

**🔎 Find runs to investigate** ranks runs by COP or by cost per kWh of heat and shows the best or worst 10, 25 or
50 %. *At today's prices* lets runs from different tariff periods be compared fairly.

### Data Quality

How complete each sensor's data is, day by day. therm learns each sensor's normal reporting rhythm (its
*heartbeat*) automatically from longer analyses, and shows how much of the energy figures rest on real readings
rather than filled-in gaps. Check here first if a result looks wrong.

### Your data and backups

- therm's files are in its add-on config folder, visible over Samba as `addon_configs/<id>_therm`. Saved profiles
  are JSON files in its `profiles` folder, so you can copy them in and out.
- Profiles are included in Home Assistant backups; the `cache` folder is not, and can be deleted at any time.
- Profiles never contain passwords or hosts, but they do contain your profile name (which may come from Home
  Assistant's location name), entity and room names, and any notes you wrote. Check them before sharing.
- therm opens no network port; it is reached only through Home Assistant's sidebar.
- The **AI** downloads in Trends and Run Inspector give you a JSON summary to paste into an AI assistant yourself;
  therm never sends it anywhere.

The add-on's **Documentation** tab in Home Assistant covers the options, data sources and caches in more detail.

### Problems and questions

Open an [issue](https://github.com/therm-heatpump/therm/issues). If you can, attach the debug bundle from the sidebar
(**Troubleshooting (debug files)**) after checking it for anything you would rather not share.

---

## Licence

therm is **source-available** under the [PolyForm Noncommercial License 1.0.0](LICENSE). It is free for personal
and other noncommercial use, including by charities, schools and public bodies. **Commercial use needs a separate
written licence from the copyright holders**, for example for installers, businesses, hosted services or commercial
integrations. For commercial licensing, contact **The Therm Authors** at
[thermheatpumpapp@gmail.com](mailto:thermheatpumpapp@gmail.com). Because commercial use is restricted, therm is not
"open source" in the OSI sense.

Before external pull requests are accepted, a short contributor agreement will be required so the project can
continue to offer both licences.

*therm is for information and analysis only. It is not a substitute for professional heating advice, and the
authors are not responsible for decisions made on the basis of its results.*
