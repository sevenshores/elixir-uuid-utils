defmodule UUID.TestSchema do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, UUID.TestUUID6, autogenerate: true}

  schema "test_schemas" do
    field(:foo_bar_id, UUID.TestUUID6)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:foo_bar_id])
  end
end
