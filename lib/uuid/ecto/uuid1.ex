if Code.ensure_loaded?(Ecto) do
  defmodule UUID.Ecto.UUID1 do
    use Ecto.Type

    @impl true
    def type, do: :binary_id

    @impl true
    def autogenerate do
      UUID.uuid1()
    end

    @impl true
    def cast(value) do
      {:ok, value}
    end

    @impl true
    def load(value) do
      {:ok, value}
    end

    @impl true
    def dump(value) do
      {:ok, value}
    end
  end
end
