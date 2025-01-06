defmodule CraftScale.Repo.Migrations.ChangeAllergensName do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create unique_index(:inventory_allergens, [:name],
             name: "inventory_allergens_unique_name_index"
           )
  end

  def down do
    drop_if_exists unique_index(:inventory_allergens, [:name],
                     name: "inventory_allergens_unique_name_index"
                   )
  end
end
