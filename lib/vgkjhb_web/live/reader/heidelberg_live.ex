defmodule VgkjhbWeb.HeidelbergLive.Index do
  use VgkjhbWeb, :live_view

    @impl true
    def render(assigns) do
      ~H"""
        <div class="w-full mt-2" id="page-main" phx-hook="MyScroller">
          <.hk_inleiding :if={@page_number == 1}/>

          <.ellende :if={@page_number > 1 && @page_number < 5}/>

          <.verlossing :if={@page_number > 4 && @page_number < 32}/>
        </div>
      """
    end

    @impl true
    def mount(%{"page" => page_number, "act" => "scroll"}, _session, socket) do
      {:ok,
        socket
        |> push_navigate(to: ~p"/heidelberg?page=#{page_number}")}
    end


    @impl true
    def mount(_params, _session, socket) do
      {:ok, socket |> assign(:page_number, 1)}
    end

    @impl true
    def handle_params(%{"page" => page_number, "act" => "scroll"}, _url, socket) do

      socket =
        socket
        |> assign(:page_number, Integer.parse(page_number) |> elem(0))

      {:noreply, socket}
    end


    @impl true
    def handle_params(%{"page" => page_number}, _url, socket) do
      socket =
        socket
        |> assign(:page_number, Integer.parse(page_number) |> elem(0))

      {:noreply, push_event(socket, "scrollto", %{page: "page_#{page_number}"})}
    end

    @impl true
    def handle_params(_params, _url, socket) do
      {:noreply, socket}
    end

    @impl true
    def handle_event("sliding", %{"_target" => ["reader_progress"], "reader_progress" => reader_progress}, socket) do
      {:noreply,
        socket
        |> push_patch(to: ~p"/heidelberg?page=#{reader_progress}")}
    end

    @impl true
    def handle_event("scrollto", %{"position" => position}, socket) do
      {:noreply,
        socket
        |> push_patch(to: ~p"/heidelberg?page=#{position}&act=scroll")}
    end

end
