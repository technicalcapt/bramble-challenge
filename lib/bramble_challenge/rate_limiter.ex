defmodule BrambleChallenge.RateLimiter do
  use GenServer
  require Logger

  @max_per_minute 5
  @sweep_after :timer.seconds(60)
  @tab :rate_limiter_requests

  ## Client

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def log(uid) do
    case :ets.update_counter(@tab, uid, {2, 1}, {uid, 0}) do
      count when count > @max_per_minute -> {:error, :rate_limited}
      _count -> :ok
    end
  end

  ## Server
  def init(_) do
    :ets.new(@tab, [:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
    schedule_sweep()
    {:ok, %{}}
  end

  def handle_info(:sweep, state) do
    Logger.debug("Sweeping requests")
    :ets.delete_all_objects(@tab)
    schedule_sweep()
    {:noreply, state}
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_after)
  end
end
