defmodule Phoenix.LiveDashboard.ProcessInfoComponent do
  use Phoenix.LiveDashboard.Web, :live_component

  alias Phoenix.LiveDashboard.SystemInfo

  @info_keys [
    :registered_name,
    :current_function,
    :initial_call,
    :status,
    :message_queue_len,
    :links,
    :monitors,
    :monitored_by,
    :trap_exit,
    :error_handler,
    :priority,
    :group_leader,
    :total_heap_size,
    :heap_size,
    :stack_size,
    :reductions,
    :garbage_collection,
    :suspending,
    :current_stacktrace
  ]

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tabular-info">
      <%= if @alive do %>
        <table class="table table-hover tabular-info-table">
          <tbody>
            <tr><td class="border-top-0">Registered name</td><td class="border-top-0"><pre><%= @registered_name %></pre></td></tr>
            <tr><td>Current function</td><td><pre><%= @current_function %></pre></td></tr>
            <tr><td>Initial call</td><td><pre><%= @initial_call %></pre></td></tr>
            <tr><td>Status</td><td><pre><%= @status %></pre></td></tr>
            <tr><td>Message queue length</td><td><pre><%= @message_queue_len %></pre></td></tr>
            <tr><td>Links</td><td><pre><%= @links %></pre></td></tr>
            <tr><td>Monitors</td><td><pre><%= @monitors %></pre></td></tr>
            <tr><td>Monitored by</td><td><pre><%= @monitored_by %></pre></td></tr>
            <tr><td>Trap exit</td><td><pre><%= @trap_exit %></pre></td></tr>
            <tr><td>Error handler</td><td><pre><%= @error_handler %></pre></td></tr>
            <tr><td>Priority</td><td><pre><%= @priority %></pre></td></tr>
            <tr><td>Group leader</td><td><pre><%= @group_leader %></pre></td></tr>
            <tr><td>Total heap size</td><td><pre><%= @total_heap_size %></pre></td></tr>
            <tr><td>Heap size</td><td><pre><%= @heap_size %></pre></td></tr>
            <tr><td>Stack size</td><td><pre><%= @stack_size %></pre></td></tr>
            <tr><td>Reductions</td><td><pre><%= @reductions %></pre></td></tr>
            <tr><td>Garbage collection</td><td><pre><%= @garbage_collection %></pre></td></tr>
            <tr><td>Suspending</td><td><pre><%= @suspending %></pre></td></tr>
            <tr><td>Current stacktrace</td><td><pre><%= @current_stacktrace %></pre></td></tr>
          </tbody>
        </table>
      <% else %>
        <div class="tabular-info-not-exists mt-1 mb-3">Process is not alive or does not exist.</div>
      <% end %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, Enum.reduce(@info_keys, socket, &assign(&2, &1, nil))}
  end

  @impl true
  def update(%{id: pid} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(pid: pid)
     |> assign_info()}
  end

  defp assign_info(%{assigns: assigns} = socket) do
    case SystemInfo.fetch_process_info(assigns.pid, @info_keys) do
      {:ok, info} ->
        Enum.reduce(info, socket, fn {key, val}, acc ->
          assign(acc, key, format_info(key, val, assigns.live_dashboard_path))
        end)
        |> assign(alive: true)

      :error ->
        assign(socket, alive: false)
    end
  end

  defp format_info(key, val, live_dashboard_path)
       when key in [:links, :monitors, :monitored_by],
       do: format_value(val, live_dashboard_path)

  defp format_info(:current_function, val, _), do: format_call(val)
  defp format_info(:initial_call, val, _), do: format_call(val)
  defp format_info(:current_stacktrace, val, _), do: format_stacktrace(val)
  defp format_info(_key, val, live_dashboard_path), do: format_value(val, live_dashboard_path)
end
