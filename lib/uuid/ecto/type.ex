if Code.ensure_loaded?(Ecto) do
  defmodule UUID.Ecto.Type do
    @moduledoc """
    Ecto UUID type.
    """

    # Parameterized types are Ecto types that can be customized per field.
    # These are available in Ecto >= 3.5
    if Code.ensure_loaded?(Ecto.ParameterizedType) do
      use Ecto.ParameterizedType

      @defaults %{type: :uuid4, args: []}

      @doc false
      @impl Ecto.ParameterizedType
      @spec type(map) :: :binary_id
      def type(_params), do: :binary_id

      @doc false
      @impl Ecto.ParameterizedType
      @spec init(keyword) :: map
      def init(opts) do
        # validate_opts(opts)
        Enum.into(opts, @defaults)
      end

      @doc """
      Casts to UUID.
      """
      @impl Ecto.ParameterizedType
      @spec cast(UUID.t(), map) :: {:ok, UUID.str()} | :error
      def cast(value, _params) do
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
      @spec cast!(UUID.t(), map) :: UUID.str()
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
      @spec dump(UUID.str(), function, map) :: {:ok, UUID.raw()} | :error
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
      @spec load(UUID.raw(), function, map) :: {:ok, UUID.str()} | :error
      def load(value, _loader, _params) do
        try do
          {:ok, UUID.binary_to_string!(value)}
        rescue
          _ -> :error
        end
      end

      @impl Ecto.ParameterizedType
      @spec equal?(UUID.t(), UUID.t(), map) :: boolean
      def equal?(value1, value2, _params) do
        UUID.info!(value1).binary == UUID.info!(value2).binary
      end

      # Callback invoked by autogenerate fields.
      @doc false
      @impl Ecto.ParameterizedType
      @spec autogenerate(map) :: UUID.t()
      def autogenerate(%{type: type, args: args}) do
        apply(UUID, type, args ++ [:default])
      end
    end

    @doc """
    Used to create a normal Ecto.Type.

    ### Defining a UUID Ecto type

        defmodule MyApp.UUID6 do
          use UUID.Ecto.Type,
            otp_app: :my_app,
            type: :uuid6,
            args: [:random_bytes]
        end

    ### Using

        defmodule MyApp.Foo do
          use Ecto.Schema

          alias MyApp.UUID6

          @primary_key {:id, UUID6, autogenerate: true}

          schema "foo" do
            field :bar_id, UUID6
          end
        end

    """
    # Coveralls isn't counting the using macro...
    # coveralls-ignore-start
    defmacro __using__(opts) do
      otp_app = Keyword.fetch!(opts, :otp_app)

      quote do
        use Ecto.Type

        @behaviour UUID.Ecto.Type

        @defaults [type: :uuid4, args: []]

        @config Application.get_env(unquote(otp_app), __MODULE__, @defaults)
                |> Keyword.merge(unquote(opts))

        @uuid_type @config[:type]
        @uuid_type_args @config[:args]

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

    # coveralls-ignore-stop

    @doc """
    Generates a UUID.
    """
    @callback generate(UUID.type()) :: UUID.t()

    @doc """
    Generates a UUID in the binary format.
    """
    @callback bingenerate :: UUID.raw()

    @doc """
    Generates a version 4 UUID.
    """
    @spec generate(UUID.type()) :: UUID.t()
    def generate(format \\ :default) do
      UUID.uuid4(format)
    end

    @doc """
    Generates a version 4 UUID in the binary format.
    """
    @spec bingenerate :: UUID.raw()
    def bingenerate do
      UUID.uuid4(:raw)
    end
  end
end
