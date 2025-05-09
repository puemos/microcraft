defmodule CraftdayWeb.InventoryLive.Show do
  @moduledoc false
  use CraftdayWeb, :live_view

  alias Craftday.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <.breadcrumb>
        <:crumb label="Inventory" path={~p"/manage/inventory"} current?={false} />
        <:crumb label={@material.name} path={~p"/manage/inventory/#{@material.sku}"} current?={true} />
      </.breadcrumb>

      <:actions>
        <.link patch={~p"/manage/inventory/#{@material.sku}/adjust"} phx-click={JS.push_focus()}>
          <.button>Adjust Stock</.button>
        </.link>
        <.link patch={~p"/manage/inventory/#{@material.sku}/edit"} phx-click={JS.push_focus()}>
          <.button>Edit</.button>
        </.link>
      </:actions>
    </.header>

    <.tabs id="material-tabs">
      <:tab
        label="Details"
        path={~p"/manage/inventory/#{@material.sku}/details"}
        selected?={@live_action == :details || @live_action == :show}
      >
        <.list>
          <:item title="Name">{@material.name}</:item>
          <:item title="SKU">
            <.kbd>
              {@material.sku}
            </.kbd>
          </:item>
          <:item title="Price">
            {format_money(@settings.currency, @material.price)}
          </:item>
          <:item title="Allergens">
            <div class="flex-inline items-center space-x-1">
              <.badge :for={allergen <- Enum.map(@material.allergens, & &1.name)} text={allergen} />
              <span :if={Enum.empty?(@material.allergens)}>None</span>
            </div>
          </:item>
          <:item title="Nutrition">
            <div class="flex-inline items-center space-x-1">
              <.badge
                :for={fact <- @material.material_nutritional_facts}
                text={"#{fact.nutritional_fact.name}: #{fact.amount} #{fact.unit}"}
              />
              <span :if={Enum.empty?(@material.material_nutritional_facts)}>None</span>
            </div>
          </:item>
          <:item title="Current Stock">
            {format_amount(@material.unit, @material.current_stock)}
          </:item>
          <:item title="Minimum Stock">
            {format_amount(@material.unit, @material.minimum_stock)}
          </:item>
          <:item title="Maximum Stock">
            {format_amount(@material.unit, @material.maximum_stock)}
          </:item>
        </.list>
      </:tab>

      <:tab
        label="Allergens"
        path={~p"/manage/inventory/#{@material.sku}/allergens"}
        selected?={@live_action == :allergens}
      >
        <.live_component
          module={CraftdayWeb.InventoryLive.FormComponentAllergens}
          id="material-allergens-form"
          material={@material}
          current_user={@current_user}
          settings={@settings}
          patch={~p"/manage/inventory/#{@material.sku}/allergens"}
          allergens={@allergens_available}
        />
      </:tab>

      <:tab
        label="Nutrition"
        path={~p"/manage/inventory/#{@material.sku}/nutritional_facts"}
        selected?={@live_action == :nutritional_facts}
      >
        <.live_component
          module={CraftdayWeb.InventoryLive.FormComponentNutritionalFacts}
          id="material-nutritional-facts-form"
          material={@material}
          current_user={@current_user}
          settings={@settings}
          patch={~p"/manage/inventory/#{@material.sku}/nutritional_facts"}
          nutritional_facts={@nutritional_facts_available}
        />
      </:tab>

      <:tab
        label="Stock"
        path={~p"/manage/inventory/#{@material.sku}/stock"}
        selected?={@live_action == :stock}
      >
        <div>
          <.table id="inventory_movements" no_margin rows={@material.movements}>
            <:empty>
              <div class="block py-4 pr-6">
                <span class={["relative"]}>
                  No movements found
                </span>
              </div>
            </:empty>

            <:col :let={entry} label="Date">
              {format_time(entry.inserted_at, @time_zone)}
            </:col>

            <:col :let={entry} label="Quantity">
              {format_amount(@material.unit, entry.quantity)}
            </:col>
            <:col :let={entry} label="Reason">{entry.reason}</:col>
          </.table>
        </div>
      </:tab>
    </.tabs>

    <.modal
      :if={@live_action == :edit}
      id="material-modal"
      title={@page_title}
      show
      on_cancel={JS.patch(~p"/manage/inventory/#{@material.sku}")}
    >
      <.live_component
        module={CraftdayWeb.InventoryLive.FormComponentMaterial}
        id={@material.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        material={@material}
        settings={@settings}
        patch={~p"/manage/inventory/#{@material.sku}/details"}
      />
    </.modal>
    <.modal
      :if={@live_action == :adjust}
      title={"Adjust Stock for #{@material.name}"}
      id="material-movement-modal"
      show
      on_cancel={JS.patch(~p"/manage/inventory/#{@material.sku}")}
    >
      <.live_component
        module={CraftdayWeb.InventoryLive.FormComponentMovement}
        id={@material.id}
        material={@material}
        current_user={@current_user}
        settings={@settings}
        patch={~p"/manage/inventory/#{@material.sku}/stock"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:allergens_available, list_all_allergens())
     |> assign(:nutritional_facts_available, list_all_nutritional_facts())}
  end

  @impl true
  def handle_params(%{"sku" => sku}, _, socket) do
    material =
      Inventory.get_material_by_sku!(sku,
        actor: socket.assigns[:current_user],
        load: [
          :current_stock,
          :movements,
          :allergens,
          :material_allergens,
          :nutritional_facts,
          material_nutritional_facts: [:nutritional_fact]
        ]
      )

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:material, material)}
  end

  defp list_all_allergens do
    Craftday.Inventory.list_allergens!()
  end

  defp list_all_nutritional_facts do
    Craftday.Inventory.list_nutritional_facts!()
  end

  @impl true
  def handle_info({:saved_nutritional_facts, material_id}, socket) do
    material =
      Inventory.get_material_by_id!(material_id,
        actor: socket.assigns[:current_user],
        load: [
          :current_stock,
          :movements,
          :allergens,
          :material_allergens,
          :nutritional_facts,
          material_nutritional_facts: [:nutritional_fact]
        ]
      )

    {:noreply, assign(socket, :material, material)}
  end

  defp page_title(:show), do: "Show Material"
  defp page_title(:adjust), do: "Adjust Material"
  defp page_title(:edit), do: "Edit Material"
  defp page_title(:details), do: "Material Details"
  defp page_title(:allergens), do: "Material Allergens"
  defp page_title(:nutritional_facts), do: "Material Nutrition"
  defp page_title(:stock), do: "Material Stock"
end
