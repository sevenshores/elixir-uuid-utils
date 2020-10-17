if Code.ensure_loaded?(Ecto) do
  defmodule UUID.Ecto.Type do
    @moduledoc """
    Ecto UUID type.
    """

    defmacro __using__(opts) do
      type = Keyword.get(opts, :type, :uuid4)
      type_args = Keyword.get(opts, :args, [])

      quote do
        use Ecto.Type

        @behaviour UUID.Ecto.Type

        @uuid_type unquote(type)
        @uuid_type_args unquote(type_args)

        @doc false
        @impl Ecto.Type
        def type, do: :binary_id

        @doc """
        Casts to UUID.
        """
        @impl Ecto.Type
        @spec cast(UUID.t()) :: {:ok, UUID.str()} | :error
        def cast(value) do
          try do
            {_type, raw} = UUID.uuid_string_to_hex_pair(value)
            {:ok, UUID.binary_to_string!(raw)}
          rescue
            _ -> :error
          end
        end

        @doc """
        Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
        """
        @spec cast!(UUID.t()) :: UUID.str()
        def cast!(value) do
          case cast(value) do
            {:ok, uuid} -> uuid
            :error -> raise Ecto.CastError, type: __MODULE__, value: value
          end
        end

        @doc """
        Converts a string representing a UUID into a binary.
        """
        @impl Ecto.Type
        @spec dump(UUID.str()) :: {:ok, UUID.raw()} | :error
        def dump(value) do
          try do
            {:ok, UUID.string_to_binary!(value)}
          rescue
            _ -> :error
          end
        end

        @doc """
        Converts a binary UUID into a string.
        """
        @impl Ecto.Type
        @spec load(UUID.raw()) :: {:ok, UUID.str()} | :error
        def load(value) do
          try do
            {:ok, UUID.binary_to_string!(value)}
          rescue
            _ -> :error
          end
        end

        # Callback invoked by autogenerate fields.
        @doc false
        @impl Ecto.Type
        def autogenerate, do: generate()

        @doc """
        Generates a UUID.
        """
        @impl UUID.Ecto.Type
        @spec generate(UUID.type()) :: UUID.t()
        def generate(format \\ :default) do
          apply(UUID, @uuid_type, @uuid_type_args ++ [format])
        end

        @doc """
        Generates a UUID in the binary format.
        """
        @impl UUID.Ecto.Type
        @spec bingenerate :: UUID.raw()
        def bingenerate do
          apply(UUID, @uuid_type, @uuid_type_args ++ [:raw])
        end

        defoverridable generate: 1, bingenerate: 0
      end
    end

    @doc """
    Generates a UUID.
    """
    @callback generate(UUID.type()) :: UUID.t()

    @doc """
    Generates a UUID in the binary format.
    """
    @callback bingenerate :: UUID.raw()
  end
end
