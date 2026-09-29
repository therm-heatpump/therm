# Changelog

## 0.1.0 (2026-09-29)
First public release (experimental).

- **Data sources:** Home Assistant's recorder history (no token set-up) and InfluxDB 1.x. One profile works with
  both. Completed days and months are saved, so repeat loads fetch only what is new.
- **Long periods:** InfluxDB periods longer than a calendar month are processed one month at a time with a progress
  bar, so a year or more fits comfortably in memory; finished months are saved and reused.
- **Headline cards (Trends):** heat, heat pump electricity, cost (with the cost per kWh of heat), Period COP and
  System COP, for all use or just space heating or hot water; two to a row on phones. The sidebar summarises runs and
  COP for the whole system.
- **Trends:** daily energy balance (space heating, hot water, defrost), Period COP for the outdoor unit and the
  whole system, weather-compensation and hot-water charts, per-mode costs (heating, hot water, defrost, standby).
- **Run Inspector:** every heating, hot-water and cooling run with COP, cost, flow and room temperatures; a finder
  for the best and worst runs, including at today's prices.
- **Data Quality:** per-sensor coverage by day and an automatic sensor heartbeat.
- **Set-up:** Onboarding wizard with Quick start, Guided and Full routes; Review screen with "Worth checking later" deep-links; 7-tab Setup page; auto-populates time zone, currency and location from Home Assistant.
- **Optional heating zones:** First-class support for systems without zone signals; zone signals found by auto-detection are offered for you to confirm, never switched on by themselves.
- **Auto-detection:** *Detect my heat pump* for Samsung Modbus MIM-B19N, ESPHome, ha-samsungehs and EHS-Sentinel, metered
  power, weather, rooms and zones; electricity prices with dates and time-of-day bands. Samsung Modbus (MIM-B19N)
  users are warned that a separate electricity meter is required.
- **Phone layout:** Responsive mobile layout with 2-column KPI cards, full-width charts, and collapsed controls
  when viewed from a phone.
- **Add-on:** Ingress sidebar panel with no open port, amd64 and aarch64 (aarch64 not yet tested on hardware),
  profiles and caches in the add-on config folder (included in backups, caches excluded), every Python package
  pinned.
- Licence: PolyForm Noncommercial 1.0.0 (source-available); commercial use needs a separate licence from The Therm
  Authors (thermheatpumpapp@gmail.com).
