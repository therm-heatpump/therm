# therm

therm analyses your heat pump's performance from data Home Assistant already records: efficiency (COP), heating and
hot-water runs, defrosts, cycling and data quality. It turns this into interactive charts and a run-by-run analyser.

> **Status: experimental.** The add-on reads your data directly from Home Assistant's history or from InfluxDB;
> no exports or uploads are needed.

## Requirements
- Home Assistant OS (add-ons are not available on Container/Core installs; Supervised may work but is no longer
  supported by Home Assistant). Home Assistant only offers therm on the architectures below.
- amd64 or 64-bit ARM (aarch64, e.g. Raspberry Pi 4/5 with a 64-bit OS). Every dependency is available as a
  prebuilt ARM wheel, but therm has not yet been run on ARM hardware; reports are welcome.
- Heat pump sensors in Home Assistant. At minimum: electrical **power**. For heat output, COP and cost of heat, also
  **either** a heat meter (heat output) **or** the **flow rate** plus **flow** and **return** temperatures. Outdoor
  temperature is strongly recommended.
- **Samsung Modbus (MIM-B19N): a separate electricity meter is required.** The Modbus interface does not report the heat
  pump's electricity use; add a meter on its supply (e.g. a Shelly EM or a CT clamp). *Detect my heat pump* warns
  when it finds Modbus sensors but no power meter.
- Free RAM: InfluxDB periods longer than a calendar month are processed one month at a time, so memory stays well under
  1 GB even for ten months with ~30 sensors (several years fit in 2 GB). therm checks before loading and tells you the
  longest period that fits, instead of running out of memory.

## Installation
1. Settings → Add-ons → Add-on Store → ⋮ → **Repositories**, add `https://github.com/therm-heatpump/therm`.
2. Install **therm**, start it, and switch on **Show in sidebar**.
3. Open **therm** from the sidebar.

## Configuration

| Option | Meaning |
|---|---|
| InfluxDB host / port / database | Only if you record to InfluxDB. For the InfluxDB add-on the host is `a0d7b954-influxdb` and the database is usually `homeassistant`. Leave the host empty otherwise |
| InfluxDB username / password | The InfluxDB user therm should read with. Use a **read-only** user. Without HTTPS, InfluxDB's basic authentication is sent unencrypted on the network, which is acceptable only between add-ons on the same host or on a trusted network |
| Use HTTPS | Only if your InfluxDB is served over TLS |
| Log level | `debug` for troubleshooting; set back to `info` afterwards |

## First run
1. At the top of the sidebar, choose **Home Assistant** or **InfluxDB**.
2. **Setup wizard:** On your first run, therm automatically scans your entities and greets you with the set-up wizard:
   - **Quick start:** Uses what therm detected immediately. Takes your time zone, currency and location name from Home Assistant when available. If the core heat pump sensors are found, it takes you straight to the Review screen.
   - **Guided (recommended):** Five short steps covering the essentials that matter most for COP and cost figures: core heat pump sensors, heat measurement & primary fluid (water or glycol mix), hot water detection, electricity prices & time zone, and rooms.
   - **Full set-up:** Steps through all eleven screens, including weather fallback sensors, extra diagnostic sensors, run-detection and hydraulic thresholds, and AI context notes.
   - If you prefer, choose **"I'd rather see the whole Setup page"** at any time to open the full tabbed Setup page directly.
3. **Heating zones:** Heating zones are optional. If your system does not record separate zone valve or pump signals, choose **One heating circuit, or no zone signals in Home Assistant** (the default): all room sensors are used for heating runs, hot water is identified by the cylinder temperature, and heating during hot water reheating cannot be identified. Zone signals **Detect** finds are offered under Rooms & zones, never switched on by themselves (a zone can be off all summer, so no recent activity is required).
4. **Review:** Checks your configuration, highlights any missing sensors, and suggests items **"Worth checking later"** (such as fluid type or tariff rates) with one-click links directly into the relevant Setup tab.
5. Press **Save and start**. The configuration is saved inside therm as your active profile.
6. In the sidebar, choose a **Period** and press **Load latest data**.

On later visits therm opens the active profile and shows your last analysis straight away; **Load latest data** updates it. You can return to **⚙️ Setup** at any time, switch between **Saved profiles**, or press **Run guided set-up again** or **Start a new profile**.

## Layout
- **Main panel:** the **Trends | Run Inspector** toggle, then the interactive charts. In **Trends**, five headline metric cards (Total heat, Electricity, Cost with unit cost of heat, Period COP and System COP) follow the All / Space heating / Hot water selector.
- **Sidebar:** data source, Period, **Load latest data**; **Whole system** summary with heat, electricity, COP and runs; **⚙️ Setup** and **Data Quality** (sensor coverage, gaps and heartbeats); and at the bottom, **Troubleshooting (debug files)**. Sensors with no data in the last load are listed under **Data Quality**; the saved source data can be cleared in **⚙️ Setup → Saved source data**.
- **Setup tabs:** when opening **⚙️ Setup**, configuration is organized across seven tabs:
  - **Sensors:** core heat pump sensors (power, flow and return temperatures, flow rate) and optional extra sensors.
  - **Heat & hot water:** heat calculation method, fluid type (water or glycol mix), immersion deduction, and hot water detection.
  - **Rooms & zones:** room temperature sensors, heating zone controls, and room-to-zone assignments.
  - **Weather:** outdoor temperature, humidity, wind, and solar irradiance with secondary fallback stations.
  - **Costs & time zone:** electricity tariffs, currency, time-of-day bands, and time zone.
  - **Thresholds:** run detection durations, cycling criteria, hydraulics, weather-compensation curves, and diagnostics.
  - **Notes:** AI report background context, property details, and configuration change log.
- **Phone layout:** on narrow windows and phones (<640px), the headline cards stack two-by-two, and secondary expanders start collapsed. The sidebar can be opened with the **>** arrow at the top left.

## Data sources
- **Home Assistant** reads the recorder history. HA keeps full history only for its recorder retention (10 days by
  default). Completed days are saved in therm's cache, so a repeat load only asks HA for today, and days stay
  available in therm after HA deletes them. Up to four days are fetched in parallel.
- **InfluxDB** reads HA's InfluxDB database for long periods. Numeric sensors are averaged to 1-minute values by
  InfluxDB (as therm does with Grafana exports); mode sensors (valve, DHW, defrost, immersion, zones) are read as
  change events and never averaged. Data is fetched a month at a time, and completed months are saved in therm's cache.
- **Long InfluxDB periods** (more than one calendar month) are processed month by month, with a progress bar per month.
  Finished months are saved, so a later load only processes the current month, unless you change the setup, which
  processes every month again. Heat, electricity, cost, COP, defrosts and every run are the same as processing the
  whole period at once, and daily sensor values match too, except on a day where a data outage crosses a month end
  (sensor states are then held only up to their normal limit).
- Every press of **Load** fetches the latest data. Only the incomplete parts (today, the current month) and anything
  not yet saved are fetched from the source.
- Clock changes are handled: the autumn day has 25 hours and the spring day 23.

## Caches and how to refresh them

| Cache | Where (Samba: the add-on's config folder, below) | Refresh |
|---|---|---|
| InfluxDB months | `cache/influx-minute-tz/` | Completed months are kept. If past data was corrected or back-filled in InfluxDB, clear it in **⚙️ Setup → Saved source data** |
| Home Assistant days | `cache/ha-history/` | Days older than about a week are never re-saved. Clear in **⚙️ Setup → Saved source data** |
| Processed results | `cache/processed/` | The two most recent analyses. Reused only when the data, profile and engine version are identical; each entry is signed, and unsigned or altered entries are discarded |
| Processed months | `cache/processed-months/` | Month results of long InfluxDB analyses, 6–14 MB each; the 60 most recently used are kept. Same reuse rules and signing as processed results |
| Sensor heartbeat | `heartbeats/` | Built automatically from analyses of 28 days or more (the last 92 days of a longer one), one per profile. A new heartbeat applies from the next load of new data, so the analysis on screen is not processed again |

The whole `cache/` folder can be deleted at any time; therm refetches and reprocesses as needed.

## Your data
- Everything runs locally inside the add-on and nothing is sent anywhere. The AI exports create a file for you to
  download and, if you choose, paste into an AI assistant yourself.
- therm's files are in its add-on config folder, visible over Samba as `addon_configs/<id>_therm`: the folder name
  starts with an ID derived from the repository and ends in `_therm`.
- Saved profiles are in its `profiles` folder (one JSON file per profile), included in Home Assistant backups, so you
  can copy profiles in or out. `.therm_state.json` remembers the active profile and the preferred data source.
- Profiles never contain passwords or hosts, but they do contain your profile name (which may come from Home
  Assistant's location name), entity and room names, and any notes you wrote. Check them before sharing.
- therm is reached only through Home Assistant's sidebar (Ingress); the add-on does not open a network port.
- **Uninstalling** therm keeps its config folder (profiles, heartbeats and caches, up to about 1 GB for long analyses)
  so a reinstall picks up where you left off. To remove everything, delete the `addon_configs/<id>_therm` folder after
  uninstalling (Samba, the File editor or the Terminal add-on).

## Support
Please open an issue at https://github.com/therm-heatpump/therm/issues and attach the debug bundle from the app
(sidebar → **Troubleshooting (debug files)**; for long analyses it covers the most recent month). Check it first for
anything you would rather not share.

## Licence
therm is source-available under the PolyForm Noncommercial License 1.0.0 (see the repository's `LICENSE`): free for
personal and other noncommercial use. Commercial use requires a separate written licence from the copyright holders.
Contact The Therm Authors at thermheatpumpapp@gmail.com.
