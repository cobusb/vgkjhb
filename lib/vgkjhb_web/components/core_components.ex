defmodule VgkjhbWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import VgkjhbWeb.Gettext

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="shadow-zinc-700/10 ring-zinc-700/10 relative hidden rounded-2xl bg-white p-14 shadow-lg ring-1 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: nil, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        Attempting to reconnect <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        Hang in there while we get back on track
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-10 space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-2 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="w-[40rem] mt-11 sm:w-full">
        <thead class="text-sm text-left leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            <th :if={@action != []} class="relative p-0 pb-4">
              <span class="sr-only"><%= gettext("Actions") %></span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative w-14 p-0">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-50 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(VgkjhbWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(VgkjhbWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end


  def hk_inleiding(assigns) do
    ~H"""
        <div class="bg-white py-5 sm:py-10">
          <div id="page_1" class="mx-auto max-w-7xl px-6 lg:px-8">
            <div class="mx-auto max-w-2xl lg:mx-0">
              <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Heidelbergse Kategismus</h2>
              <p  class="mt-4 text-lg leading-8 text-gray-600">Sondag 1.</p>
            </div>
                <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
                  <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
                    <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">1. Wat is jou enigste troos in lewe en in sterwe?</dt>
                    <dd class="mt-2 lg:col-span-7 lg:mt-0">
                      <p class="text-base leading-7 text-gray-600">
                        Dat ek met liggaam en siel in lewe en in sterwe (a) nie aan myself (b) nie, maar aan my getroue Verlosser, Jesus
                        Christus behoort (c). Hy het met sy kosbare bloed vir al my sondes ten volle betaal (d) en my uit alle heerskappy van
                        die duiwel verlos (e). Hy bewaar (f) my op so 'n wyse dat sonder die wil van my hemelse Vader, geen haar van my kop kan
                        val nie (g). Alles moet inderdaad tot my saligheid dien (h). Daarom verseker Hy my ook deur sy Heilige Gees van die
                        ewige lewe (i) en maak Hy my van harte gewillig en bereid om voortaan vir Hom te lewe (k).</p>
                      <p class="text-gray-600 text-sm mt-1">
                        (a)Rom 14:8. (b) 1 Kor 6:19. (c) 1 Kor 3:22; Tit 2:14: (d) 1 Pet 1:18, 19;1 Joh 1:7; 2:2, 12. (e) Heb 2:14;1 Joh 3:8;
                        Joh 8:34-36. (f) Joh 6:39; 10:28; 2 Tess 3:3; 1 Pet 1:5. (g) Matt 10:30; Luk 21:18. (h) Rom 8:28. (i) 2 Kor 1:22; 5:5;
                        Ef 1:14; Rom 8:16. (k) Rom 8:14;1 Joh 3:3:</p>
                    </dd>
                  </div>
                </dl>
                <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
                  <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
                    <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">2. Hoeveel dinge moet jy weet om in hierdie troos salig te kan lewe en sterwe?</dt>
                    <dd class="mt-2 lg:col-span-7 lg:mt-0">
                      <p class="text-base leading-7 text-gray-600">
                          Drie dinge (a): Ten eerste, hoe groot my sonde en ellende is (b); ten tweede; hoe ek van al my sonde en ellende verlos
                          word (c) en ten derde hoe ek God vir so 'n verlossing dankbaar moet wees (d).</p>
                      <p class="text-gray-600 text-sm mt-1">
                          (a)Matt 11:28-30; Ef 5:8. (b) Joh 9:41; Matt 9:12; Rom 3:10;1 Joh 1:9;10. (c) Joh 17:3; Hand 4:12 10:43. (d) Ef 5:10; Ps
                          50:14; Matt 5:16; 1 Pet 2:12; Rom 6:13; 2 Tim 2:15.</p>
                    </dd>
                  </div>
                </dl>
            <div class="mx-auto mt-10 grid max-w-2xl grid-cols-1 gap-x-8 gap-y-16 border-t border-gray-200 pt-10 sm:mt-16 sm:pt-16 lg:mx-0 lg:max-w-none lg:grid-cols-3">
              <article class="flex max-w-xl flex-col items-start justify-between">
                <div class="flex items-center gap-x-4 text-xs">
                <.link navigate="/church_site/ellende">
                  <div class="text-gray-500">Sondag 2 - 4 </div>
                </.link>
                </div>
                <div class="group relative">
                  <h3 class="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                    <.link navigate="/church_site/ellende">
                      <span class="inset-0">Die ellende</span>
                    </.link>
                  </h3>
                  <p class="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">Die eerste deel van die Kategismus handel oor die ellende van die mens.</p>
                </div>
              </article>
              <article class="flex max-w-xl flex-col items-start justify-between">
                <div class="flex items-center gap-x-4 text-xs">
                <.link navigate="/church_site/verlossing">
                  <div class="text-gray-500">Sondag 5 - 31</div>
                </.link>
                </div>
                <div class="group relative">
                  <h3 class="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                    <.link navigate="/church_site/verlossing">
                        <span class="inset-0">Verlossing</span>
                    </.link>
                  </h3>
                  <p class="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">Die tweede deel van die Kategismus handel oor die
                    verlossing van die mens.</p>
                      <a href="#">
                        <div class="mt-2 inset-0">Inleiding: <span class="text-gray-500 text-xs">5 - 8</span></div>
                        <div class="mt-2 inset-0">God die Vader en ons skepping:  <span class="text-gray-500 text-xs">9 - 10</span></div>
                        <div class="mt-2 inset-0">God die Seun en ons verlossing:  <span class="text-gray-500 text-xs">11 - 19</span></div>
                        <div class="mt-2 inset-0">God die Heilige Gees en ons heiligmaking: <span class="text-gray-500 text-xs">20 - 24</span></div>
                        <div class="mt-2 inset-0">Die Heilige Sakramente: <span class="text-gray-500 text-xs">25</span></div>
                        <div class="mt-2 inset-0">Die Heilige Doop: <span class="text-gray-500 text-xs">26 - 27</span></div>
                        <div class="mt-2 inset-0">Die Heilige Nagmaal: <span class="text-gray-500 text-xs">28 - 30</span></div>
                      </a>
                </div>
              </article>
              <article class="flex max-w-xl flex-col items-start justify-between">
                <div class="flex items-center gap-x-4 text-xs">
                  <div  class="text-gray-500">Sondag 32 - 52 </div>
                </div>
                <div class="group relative">
                  <h3 class="mt-3 text-lg font-semibold leading-6 text-gray-900 group-hover:text-gray-600">
                    <a href="#">
                      <span class="inset-0">Dankbaarheid </span>
                    </a>
                  </h3>
                  <p class="mt-5 line-clamp-3 text-sm leading-6 text-gray-600">Die derde deel handel oor die dankbaarheid wat ons aan God vir die verlossing verskuldig is.</p>
                </div>
              </article>
            </div>
          </div>
        </div>
    """
  end

  def ellende(assigns) do
    ~H"""
        <div class="bg-white py-5 sm:py-10">
      <div id="page_2" class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl lg:mx-0">
          <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Die ellende</h2>
          <p   class="mt-4 text-lg leading-8 text-gray-600">Sondag 2.</p>
        </div>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">3. Waaruit ken jy jou ellende?
            </dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                Uit die wet van God (a).</p>
              <p class="text-gray-600 text-sm mt-1">
                (a)Rom 3:20.
              </p>
            </dd>
          </div>
        </dl>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">2. Hoeveel dinge moet jy weet om in hierdie troos salig te kan lewe en sterwe?</dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                  Drie dinge (a): Ten eerste, hoe groot my sonde en ellende is (b); ten tweede; hoe ek van al my sonde en ellende verlos
                  word (c) en ten derde hoe ek God vir so 'n verlossing dankbaar moet wees (d).</p>
              <p class="text-gray-600 text-sm mt-1">
                  (a)Matt 11:28-30; Ef 5:8. (b) Joh 9:41; Matt 9:12; Rom 3:10;1 Joh 1:9;10. (c) Joh 17:3; Hand 4:12 10:43. (d) Ef 5:10; Ps
                  50:14; Matt 5:16; 1 Pet 2:12; Rom 6:13; 2 Tim 2:15.</p>
            </dd>
          </div>
        </dl>
      </div>
      <div id="page_3" class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl lg:mx-0">
          <p  class="mt-4 text-lg leading-8 text-gray-600">Sondag 3.</p>
        </div>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">4. Wat eis die wet van God van ons?
            </dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                Dit leer Christus ons samevattend in Matteus 22:37-40: Jy moet die Here jou God liefhê met jou hele hart en met jou hele
                siel en met jou hele verstand. Dit is die eerste en groot gebod. En die tweede wat hiermee gelyk staan: Jy moet jou
                naaste liefhê soos jouself. Aan hierdie twee gebooie hang die hele wet en die profete (a).</p>
              <p class="text-gray-600 text-sm mt-1">
                (a)Deut 6:5; Lev 19:18; Mark 12:30; Luk 10:27
              </p>
            </dd>
          </div>
        </dl>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">5. Kan jy dit alles ten volle nakom?</dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                Nee (a), want ek is van nature geneig om God en my naaste te haat (b).</p>
              <p class="text-gray-600 text-sm mt-1">
                (a)Rom 3:10, 20, 23;1 Joh 1:8, 10. (b) Rom 8:7; 2:3; Tit 3:3; Gen 6:5; 8:21; Jer 17:9; Rom 7:23.</p>
            </dd>
          </div>
        </dl>
      </div>
      <div d="page_4" class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl lg:mx-0">
          <p i class="mt-4 text-lg leading-8 text-gray-600">Sondag 4.</p>
        </div>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">9. Doen God die mens dan nie onreg aan as Hy in sy wet van hom eis wat hy tog nie kan doen nie?
            </dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                Nee (a), want God het die mens so geskep dat hy dit kon doen (b). Maar die mens het homself en sy hele
                nageslag as gevolg van die aanhitsing van die duiwel (c) en deur moedswillige ongehoorsaamheid van hierdie gawes beroof.
                </p>
              <p class="text-gray-600 text-sm mt-1">
                (a)Ef 4:24. (b) Gen 3:13; 1 Tim 2:13, 14. (c) Gen 3:6; Rom 5:12.
              </p>
            </dd>
          </div>
        </dl>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">10. Wil God hierdie ongehoorsaamheid en afval ongestraf laat bly?
            </dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                Nee, glad nie; inteendeel, sy toorn is verskriklik (a) sowel oor die erfsonde as oor die sonde wat ons self
                doen: Hy wil dit in die tyd en in die ewigheid met 'n regverdige oordeel straf (b). Hy het immers gesê: Vervloek is
                elkeen wat nie bly in alles wat geskryf is in die boek van die wet om dit te doen nie (c).</p>
              <p class="text-gray-600 text-sm mt-1">
              (a)Gen 2:17; Rom 5:12. (b) Ps 50:21; 5:6; Nah 1:2; Eks 20:5; 34:7; Rom 1:18; Ef 5:6. (c) Deut 27:26; Gal 3:10.</p>
            </dd>
          </div>
        </dl>
        <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
          <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
            <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">11. Is God dan nie ook barmhartig nie?
            </dt>
            <dd class="mt-2 lg:col-span-7 lg:mt-0">
              <p class="text-base leading-7 text-gray-600">
                God is wel barmhartig (a); maar Hy is ook regverdig (b). Daarom eis sy geregtigheid dat die sonde wat teen die
                allerhoogste majesteit van God gedoen is; ook met die swaarste straf gestraf moet word - dit is met die ewige straf aan
                liggaam en siel.</p>
              <p class="text-gray-600 text-sm mt-1">
                (a)Eks 34:6, 7; 20:6. (b) Ps 7:10; Eks 20:5; 23:7; 34:7; Ps 5:5, 6; Nah 1:2, 3.          </p>
            </dd>
          </div>
        </dl>
      </div>
    </div>
    """
  end

  @spec verlossing(any()) :: Phoenix.LiveView.Rendered.t()
  def verlossing(assigns) do
    ~H"""
      <div class="bg-white py-5 sm:py-10">
        <div id="page_5" class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl lg:mx-0">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Die verlossing</h2>
            <p  class="mt-4 text-lg leading-8 text-gray-600">Sondag 5.</p>
          </div>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">12. Aangesien ons volgens die regverdige oordeel van God die tydelike en ewige straf verdien het, hoe kan ons van
              hierdie straf bevry en weer in genade aangeneem word?
              </dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  God wil dat daar aan sy geregtigheid voldoen word (a). Daarom moet ons òf deur onsself òf deur 'n ander ten volle betaal
                  (b).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Gen 2:27; Eks 23:7; Eseg 18:4; Matt 5:26; 2 Tess 1:6; Luk 16:2. (b) Rom 8:4.
                </p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">13. Kan ons deur onsself betaal?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                    Nee, glad nie; ons maak juis ons skuld elke dag nog groter (a).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Job 9:2; 15:15, 16; 4:18, 19; Ps 130:3; Matt 6:12; 18:25; 16:26.</p>
              </dd>
            </div>
          </dl>
          <dl  class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">14. Kan enige ander skepsel vir ons betaal?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Nee, want Ten eerste wil God aan geen ander skepsel die skuld straf wat die mens gemaak het nie (a). Ten
                  tweede kan geen gewone skepsel die las van die ewige toorn van God teen die sonde dra en ander skepsels daarvan verlos
                  nie (b).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Eseg 18:4; Gen 3:17. (b) Nah 1:6; Ps 130:3.</p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">15. Hoe 'n middelaar en verlosser moet ons dan soek?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  So een wat 'n ware (a) en regverdige (b) mens is, maar nogtans ook sterker as alle skepsels is, dit wil sê wat
                  terselfdertyd ware God is (c).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)1 Kor 15:21: (b) Heb 7:26. (c) Jes 7:14; 9:5; Jer 23:6; Luk 11:22.</p>
              </dd>
            </div>
          </dl>
        </div>
        <div id="page_6" class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl lg:mx-0">
            <p  class="mt-4 text-lg leading-8 text-gray-600">Sondag 6.</p>
          </div>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">16. Waarom moet hy 'n ware en regverdige mens wees?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Omdat die geregtigheid van God eis dat die menslike natuur wat gesondig het, vir die sonde moet betaal (a). Maar die
                  mens wat self sondaar is, kan nie vir ander betaal nie (b).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Eseg 18:4, 20; Rom 5:18; 1 Kor 15:21; Heb 2:14-16. (b) Heb2:26, 27; Ps 49:8; 1 Pet 3:18.
                </p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">17. Waarom moet hy terselfdertyd ware God wees?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Om deur die krag van sy Godheid (a) die las van die toorn van God (b) aan sy mensheid te kon dra (c) en vir ons die
                  geregtigheid en die lewe te kan verwerf en teruggee (d).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Jes 9:5; 63:3; (b) Deut 4:24; Nah 1:6; Ps 130:3. (c) Jes 53:4, 11; (d) Jes 53:5, 11.</p>
              </dd>
            </div>
          </dl>
          <dl  class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">18. Wie is hierdie Middelaar wat terselfdertyd ware God (a) en ware (b) regverdige mens is (c)?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Ons Here Jesus Christus (d), wat God vir ons tot wysheid, geregtigheid, heiligmaking en volkome verlossing gegee het
                  (e).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)1 Joh 5:20; Rom 9:5; 8:3; Gal 4:4; Jes 9:6; Jer 23:6; Mal 3:1: (b) Luk 1:42; 2:6, 7; Rom 1:3; 9:5; Fil 2:7; Heb 2:14,
                  16, 17; 4:15. (c) Jes 53:9, 11; Jer 23:5; Luk 1:35; Joh 8:46; Heb 4:15; 7:26; 1 Pet 1:19; 2:22, 3:18. (d) l Tim 2:5;
                  Matt 1:23; 1 Tim 3:16; Luk 2:11; Heb 2:9..(e) 1 Kor 1:30.</p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">19. Waaruit weet jy dit?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Uit die heilige evangelie, wat God self aanvanklik in die paradys bekend gemaak het (a). Daarna het Hy dit deur die
                  heilige aartsvaders (b) en profete (c) laat verkondig en deur die offers en ander seremonies van die wet laat uitbeeld;
                  (d). Eindelik het Hy dit deur sy eniggebore Seun vervul (e).</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Gen 3:15: (b) Gen 22:18; 12:3; 49:10. (c) Jes 53; 42:1-4; 43:25; 49:5, 6, 22, 23; Jer 23:5, 6; 31:32, 33; 32:39-41,
                  Miga 7:18-20; Hand 10:43; 3:22-24; Rom 1:2; Heb 1:1. (d) Heb 10:1, 7; Kol 2:7; Joh 5:46. (e) Rom 10:4; Gal 4:4; 3:24;
                  Kol 2:17.</p>
              </dd>
            </div>
          </dl>
        </div>
        <div id="page_7" class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl lg:mx-0">
            <p   class="mt-4 text-lg leading-8 text-gray-600">Sondag 7.</p>
          </div>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">20. Word al die mense dan weer deur Christus salig soos hulle deur Adam verlore gegaan het?
              </dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Nee; (a); maar slegs die wat deur 'n ware geloof in Hom ingelyf word en al sy weldade aanneem (b).            </p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Matt 7:14; 22:14. (b) Mark 16:16; Joh 1:12; 3:16, 18, 36; Jes 53:11; Ps 2:12; Rom 11:20; 3:22; Heb 4:3; 5:9; 10:39;
                  11:6.
                </p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">21. Wat is 'n ware geloof?
              </dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                    'n Ware geloof is nie alleen 'n vasstaande kennis waardeur ek alles wat God in sy Woord aan ons geopenbaar het (a) vir
                    waar aanvaar nie, maar ook 'n vaste vertroue (b) wat die Heilige Gees (c) deur die evangelie in my hart werk (d),
                    naamlik dat God nie net aan ander nie, maar ook aan my uit loutere genade, slegs op grond van die verdienste van
                    Christus (e), vergewing van sondes, ewige geregtigheid en saligheid (f) geskenk het.               </p>
              <p class="text-gray-600 text-sm mt-1">
                (a)Jak 2:19. (b) Heb 11:1, 7; Rom 4:18-21; 10:10; Ef 3:12; Heb 4:16; Jak 1:6. (c) Gal 5:22; Matt 16:17; 2 Kor 4:13; Joh
                6:29; Ef 2:8; Fil 1:19; Hand 16:14. (d) Rom 1:16; 10:17; 1 Kor 1:21; Hand 10:44; 16:14. (e) Ef 2:8; Rom 3:24; 5:19; Luk
                1:77, 78. (f) Rom 1:17; Gal 3:11; Heb 10:10, 38; Gal 2:16.  </p>      </dd>
            </div>
          </dl>
          <dl   class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">22. Wat moet 'n Christen glo?
              </dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Alles wat in die evangelie aan ons beloof word (a) en wat die artikels van ons algemene en ongetwyfelde
                  Christelike
                  geloof ons in hoofsaak leer.</p>
                <p class="text-gray-600 text-sm mt-1">
                  (a)Joh 20:31; Matt 28:19; Mark 1:15. </p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">23. Hoe lui die artikels?
              </dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                    (1) Ek glo in God die Vader, die Almagtige, die Skepper van die hemel en die aarde. (2) En in Jesus Christus, sy
                    eniggebore Seun, ons Here; (3) wat ontvang is van die Heilige Gees, gebore uit die maagd Maria; (4) wat gely het onder
                    Pontius Pilatus, gekruisig is, gesterf het en begrawe is en neergedaal het na die hel; (5) wat op die derde dag weer
                    opgestaan het uit die dood; (6) opgevaar het na die hemel en sit aan die regterhand van God, die almagtige Vader, (7)
                    waarvandaan Hy sal kom om die lewendes en die dooies te oordeel. (8) Ek glo in die Heilige Gees. (9) Ek glo aan 'n
                    heilige, algemene, Christelike kerk, die gemeenskap van die heiliges; (10) die vergewing van sondes; (I1) die opstanding
                    van die liggaam (12) en 'n ewige lewe.</p>
              </dd>
            </div>
          </dl>
        </div>
        <div id="page_8" class="mx-auto max-w-7xl px-6 lg:px-8">
          <div class="mx-auto max-w-2xl lg:mx-0">
            <p  class="mt-4 text-lg leading-8 text-gray-600">Sondag 8.</p>
          </div>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">24. Hoe word hierdie artikels ingedeel?
              </dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  In drie dele: die eerste handel oor God die Vader en ons skepping; die tweede oor God die Seun en ons verlossing; die
                  derde oor God die Heilige Gees en ons heiligmaking.   </p>
              </dd>
            </div>
          </dl>
          <dl class="mt-2 space-y-2 divide-y divide-gray-900/10">
            <div class="pt-4 lg:grid lg:grid-cols-12 lg:gap-8">
              <dt class="text-base font-semibold leading-7 text-gray-900 lg:col-span-5">25. Terwyl daar maar tog net een, enige Goddelike Wese is, waarom praat jy van drie, naamlik die Vader, Seun en
              Heilige Gees (a)?</dt>
              <dd class="mt-2 lg:col-span-7 lg:mt-0">
                <p class="text-base leading-7 text-gray-600">
                  Omdat God Hom so in sy Woord geopenbaar het (b) dat hierdie drie onderskeie Persone die enige, ware en ewige God is. </p>
                <p class="text-gray-600 text-sm mt-1">
                (a)Deut 6:4; Ef 4:6; Jes 44:6; 45:5; 1 Kor 8:4, 6. (b) Jes 61:1; Luk 4:18; Gen 1:2, 3; Ps 33:6; Jes 48:16; Matt 3:16,
                17; 28:19; 1 Joh 5:7; Jes 6:1, 3; Joh 14:26; 15:26; 2 Kor 13:13; Gal 4:6; Ef 2:l8; Tit 3:5, 6.</p>
              </dd>
            </div>
          </dl>
        </div>
      </div>

    """
  end
end
