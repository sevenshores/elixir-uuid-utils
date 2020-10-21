if Code.ensure_loaded?(Ecto) do
  defmodule UUID.Ecto.Type do
    @moduledoc """
    Ecto UUID type.
    """

    @type uuid_type :: :uuid1 | :uuid3 | :uuid4 | :uuid5 | :uuid6
    @type uuid_type_args :: list(term)
    @type params :: {uuid_type, uuid_type_args}

    # Parameterized types are Ecto types that can be customized per field.
    # These are available in Ecto >= 3.5
    if Code.ensure_loaded?(Ecto.ParameterizedType) do
      use Ecto.ParameterizedType

      @doc false
      @impl Ecto.ParameterizedType
      @spec type(params) :: :binary_id
      def type(_params), do: :binary_id

      @doc false
      @impl Ecto.ParameterizedType
      @spec init(keyword) :: params
      def init(opts) do
        UUID.Ecto.TypeConfig.init_opts(opts)
      end

      @doc """
      Casts to UUID.
      """
      @impl Ecto.ParameterizedType
      @spec cast(UUID.t(), params) :: {:ok, UUID.str()} | :error
      def cast(value, _params) do
        result =
          try do
            UUID.uuid_string_to_hex_pair(value)
          rescue
            _ -> :error
          end

        with {_type, raw} <- result do
          {:ok, UUID.binary_to_string!(raw)}
        end
      end

      @doc """
      Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
      """
      @spec cast!(UUID.t(), params) :: UUID.str()
      def cast!(value, params) do
        case cast(value, params) do
          {:ok, uuid} -> uuid
          :error -> raise Ecto.CastError, type: __MODULE__, value: value
        end
      end

      @doc """
      Converts a string representing a UUID into a binary.
      """
      @impl Ecto.ParameterizedType
      @spec dump(UUID.str(), function, params) :: {:ok, UUID.raw()} | :error
      def dump(value, _dumper, _params) do
        try do
          {:ok, UUID.string_to_binary!(value)}
        rescue
          _ -> :error
        end
      end

      @doc """
      Converts a binary UUID into a string.
      """
      @impl Ecto.ParameterizedType
      @spec load(UUID.t(), function, params) :: {:ok, UUID.str()} | :error
      def load(<<_::128>> = value, _loader, _params) do
        try do
          {:ok, UUID.binary_to_string!(value)}
        rescue
          _ -> :error
        end
      end

      def load(value, _loader, _params) do
        try do
          info = UUID.info!(value)
          {:ok, UUID.binary_to_string!(info.binary)}
        rescue
          _ -> :error
        end
      end

      @impl Ecto.ParameterizedType
      @spec equal?(UUID.t(), UUID.t(), params) :: boolean
      def equal?(value1, value2, _params) do
        UUID.info!(value1).binary == UUID.info!(value2).binary
      end

      # Callback invoked by autogenerate fields.
      @doc false
      @impl Ecto.ParameterizedType
      @spec autogenerate(params) :: UUID.t()
      def autogenerate({type, args}), do: apply(UUID, type, args ++ [:default])
    end

    @doc """
    Used to create a normal Ecto.Type.

    ### Defining a UUID Ecto type

        defmodule Foo.Types.UUID6 do
          use UUID.Ecto.Type,
            type: :uuid6,
            node_type: :random_bytes
        end

    ### Using

        defmodule Foo.Bar do
          use Ecto.Schema

          alias Foo.Types.UUID6

          @primary_key {:id, UUID6, autogenerate: true}

          schema "foo" do
            field :bar_id, UUID6
          end
        end

    """
    # Coveralls isn't counting the using macro...
    # coveralls-ignore-start
    defmacro __using__(opts) do
      quote bind_quoted: [opts: opts] do
        use Ecto.Type

        @behaviour UUID.Ecto.Type

        {uuid_type, args} = UUID.Ecto.TypeConfig.compile_type_config(__MODULE__, opts)

        @uuid_type uuid_type
        @uuid_type_args args

        @doc false
        @impl Ecto.Type
        def type, do: :binary_id

        @doc """
        Casts to UUID.
        """
        @impl Ecto.Type
        @spec cast(UUID.t()) :: {:ok, UUID.str()} | :error
        def cast(value) do
          result =
            try do
              UUID.uuid_string_to_hex_pair(value)
            rescue
              _ -> :error
            end

          with {_type, raw} <- result do
            {:ok, UUID.binary_to_string!(raw)}
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
        @spec load(UUID.t()) :: {:ok, UUID.str()} | :error
        def load(<<_::128>> = value) do
          try do
            {:ok, UUID.binary_to_string!(value)}
          rescue
            _ -> :error
          end
        end

        def load(value) do
          try do
            info = UUID.info!(value)
            {:ok, UUID.binary_to_string!(info.binary)}
          rescue
            _ -> :error
          end
        end

        @impl Ecto.Type
        @spec equal?(UUID.t(), UUID.t()) :: boolean
        def equal?(value1, value2) do
          UUID.info!(value1).binary == UUID.info!(value2).binary
        end

        # Callback invoked by autogenerate fields.
        @doc false
        @impl Ecto.Type
        def autogenerate, do: generate()

        @doc """
        Generates a UUID.

        This are here if you want your module to work as a drop-in replacement for `Ecto.UUID`.
        """
        @impl UUID.Ecto.Type
        @spec generate(UUID.type()) :: UUID.t()
        def generate(format \\ :default) do
          apply(UUID, @uuid_type, @uuid_type_args ++ [format])
        end

        @doc """
        Generates a UUID in the binary format.

        This are here if you want your module to work as a drop-in replacement for `Ecto.UUID`.
        """
        @impl UUID.Ecto.Type
        @spec bingenerate :: UUID.raw()
        def bingenerate do
          apply(UUID, @uuid_type, @uuid_type_args ++ [:raw])
        end

        defoverridable generate: 1, bingenerate: 0
      end
    end

    # coveralls-ignore-stop

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
