defmodule PastimesReg.TimeZones.TimeZoneOption do
  def start_time_zone_options, do: Timex.timezones()
  def end_time_zone_options, do: Timex.timezones()
end
