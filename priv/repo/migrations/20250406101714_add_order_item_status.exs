defmodule Microcraft.Repo.Migrations.AddOrderItemStatus do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:orders_items) do
      add :status, :text, null: false, default: "todo"
    end
  end

  def down do
    alter table(:orders_items) do
      remove :status
    end
  end
end
