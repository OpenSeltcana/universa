defmodule Filter.MCCP do
  use Universa.Filter

  def get(packet, _state), do: {packet, []}

  # If mccp is enabled, compress
  def put(packet, %{telnet_mccp: true, telnet_mccp_compressor: zlib}) do
    [compressed_packet] = :zlib.deflate(zlib, packet, :sync)
    {compressed_packet, []}
  end

  # Else just return the packet as-is
  def put(packet, state) do
    {packet, []}
  end
end