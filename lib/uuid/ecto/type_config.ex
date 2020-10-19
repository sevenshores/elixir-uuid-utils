if Code.ensure_loaded?(Ecto) do
  defmodule UUID.Ecto.TypeConfig do
    @moduledoc false

    ## Valid types

    @valid_types [:uuid1, :uuid3, :uuid4, :uuid5, :uuid6]
    @valid_v3_namespaces [:dns, :url, :oid, :x500, nil]
    @valid_v5_namespaces @valid_v3_namespaces
    @valid_v6_node_types [:mac_address, :random_bytes]

    ## Defaults

    @default_uuid_type :uuid4
    @default_v6_node_type :random_bytes

    ## Typespecs

    @type uuid_type :: UUID.Ecto.Type.uuid_type()
    @type uuid_type_args :: UUID.Ecto.Type.uuid_type_args()
    @type params :: UUID.Ecto.Type.params()

    @doc """
    Get the init opts for the Parameterized UUID type.
    """
    @spec init_opts(keyword) :: params
    def init_opts(opts) when is_list(opts) do
      {uuid_type, opts} = Keyword.pop(opts, :type, @default_uuid_type)
      args = get_and_validate_args(uuid_type, opts)
      {uuid_type, args}
    end

    @doc """
    Get and validate the config for the user-defined UUID.Ecto.Type.
    """
    @spec compile_type_config(module, keyword) :: params
    def compile_type_config(module, opts) when is_list(opts) do
      {otp_app, opts} = Keyword.pop(opts, :otp_app)

      {uuid_type, opts} =
        if otp_app do
          otp_app
          |> Application.get_env(module, [])
          |> Keyword.merge(opts)
          |> keyword_pop!(:type)
        else
          keyword_pop!(opts, :type)
        end

      args = get_and_validate_args(uuid_type, opts)

      {uuid_type, args}
    end

    @doc """
    Validate the provided opts for different types.
    """
    @spec get_and_validate_args(uuid_type, keyword) :: uuid_type_args
    def get_and_validate_args(:uuid1, _), do: []

    def get_and_validate_args(:uuid3, opts) do
      namespace = Keyword.fetch!(opts, :namespace)
      name = Keyword.fetch!(opts, :name)

      if namespace not in @valid_v3_namespaces do
        # If the namespace is not in the list of valid namespaces, the only
        # other valid option is that it is a UUID.
        unless UUID.valid?(namespace) do
          namespace_str = Enum.join(@valid_v3_namespaces, "|")
          raise ArgumentError, message: "Invalid namespace; expected #{namespace_str} or a UUID"
        end
      end

      if not is_binary(name) do
        raise ArgumentError, message: "Invalid name: #{inspect(name)}; expected String"
      end

      [namespace, name]
    end

    def get_and_validate_args(:uuid4, _), do: []

    def get_and_validate_args(:uuid5, opts) do
      namespace = Keyword.fetch!(opts, :namespace)
      name = Keyword.fetch!(opts, :name)

      if namespace not in @valid_v5_namespaces do
        # If the namespace is not in the list of valid namespaces, the only
        # other valid option is that it is a UUID.
        unless UUID.valid?(namespace) do
          namespace_str = Enum.join(@valid_v5_namespaces, "|")
          raise ArgumentError, message: "Invalid namespace; expected #{namespace_str} or a UUID"
        end
      end

      if not is_binary(name) do
        raise ArgumentError, message: "Invalid name: #{inspect(name)}; expected String"
      end

      [namespace, name]
    end

    def get_and_validate_args(:uuid6, opts) do
      node_type = Keyword.get(opts, :node_type, @default_v6_node_type)

      if node_type not in @valid_v6_node_types do
        node_types_str = Enum.join(@valid_v6_node_types, "|")

        raise ArgumentError,
          message: "Invalid node type: #{inspect(node_type)}; expected one of #{node_types_str}"
      end

      [node_type]
    end

    # Catch-all validator.
    def get_and_validate_args(type, _opts) do
      type_str = Enum.join(@valid_types, "|")
      raise ArgumentError, message: "Invalid type; type: #{inspect(type)}, expected types: #{type_str}"
    end

    # Backfill for Elixir < 1.10.x
    defp keyword_pop!(keywords, key) when is_list(keywords) and is_atom(key) do
      if function_exported?(Keyword, :pop!, 2) do
        Keyword.pop!(keywords, key)
      else
        case Keyword.fetch(keywords, key) do
          {:ok, value} -> {value, Keyword.delete(keywords, key)}
          :error -> raise KeyError, key: key, term: keywords
        end
      end
    end
  end
end
