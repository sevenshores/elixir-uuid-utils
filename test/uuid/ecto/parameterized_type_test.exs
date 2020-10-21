if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule UUID.Ecto.ParameterizedTypeTest do
    use ExUnit.Case

    alias UUID.Ecto.Type, as: EctoUUID

    # ----------------------------------------------------------------------------
    # Setup
    # ----------------------------------------------------------------------------

    uuids = [
      UUID.uuid1(),
      UUID.uuid3(:dns, "mydomain.com"),
      UUID.uuid4(),
      UUID.uuid5(:dns, "mydomain.com"),
      UUID.uuid6(:random_bytes)
    ]

    infos = Enum.map(uuids, &UUID.info!/1)

    opts = [
      [type: :uuid1],
      [type: :uuid3, namespace: :dns, name: "mydomain.com"],
      [type: :uuid4],
      [type: :uuid5, namespace: :dns, name: "mydomain.com"],
      [type: :uuid6, node_type: :random_bytes]
    ]

    @items Enum.zip([uuids, infos, opts])

    @uuid_null "00000000-0000-0000-0000-000000000000"

    @default_params {:uuid4, []}

    # ----------------------------------------------------------------------------
    # Tests
    # ----------------------------------------------------------------------------

    test "type/1" do
      for {_uuid, _info, opts} <- @items do
        # TODO: Swap out the rest of the tests with the Ecto public interface for the types,
        # Instead of EctoUUID, use Ecto.Type, like:
        assert Ecto.Type.type({:parameterized, UUID.Ecto.Type, opts}) == :binary_id
      end
    end

    test "init/1" do
      assert EctoUUID.init([]) == @default_params

      for {_uuid, _info, opts} <- @items do
        assert {type, args} = EctoUUID.init(opts)
        assert type in [:uuid1, :uuid3, :uuid4, :uuid5, :uuid6]
        assert is_list(args)
      end
    end

    test "embed_as/2" do
      for {_uuid, _info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert EctoUUID.embed_as(:foo, params) == :self
      end
    end

    test "cast/2" do
      for {uuid, info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert EctoUUID.cast(uuid, params) == {:ok, uuid}
        assert EctoUUID.cast(info.binary, params) == {:ok, uuid}
        assert EctoUUID.cast(String.upcase(uuid), params) == {:ok, uuid}
        assert EctoUUID.cast(String.reverse(uuid), params) == :error
        assert EctoUUID.cast(@uuid_null, params) == {:ok, @uuid_null}
        assert EctoUUID.cast(nil, params) == :error
      end
    end

    test "cast!/2" do
      for {uuid, _info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert EctoUUID.cast!(uuid, params) == uuid

        assert_raise Ecto.CastError, "cannot cast nil to UUID.Ecto.Type", fn ->
          assert EctoUUID.cast!(nil, params)
        end
      end
    end

    test "load/3" do
      loader = & &1

      for {uuid, info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert EctoUUID.load(info.binary, loader, params) == {:ok, uuid}
        assert EctoUUID.load(info.uuid, loader, params) == {:ok, uuid}
        assert EctoUUID.load("", loader, params) == :error
        assert EctoUUID.load(nil, loader, params) == :error
      end
    end

    test "dump/3" do
      dumper = & &1

      for {uuid, info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert EctoUUID.dump(uuid, dumper, params) == {:ok, info.binary}
        assert EctoUUID.dump(info.binary, dumper, params) == {:ok, info.binary}
        assert EctoUUID.dump("", dumper, params) == :error
      end
    end

    test "equal?/3 returns true if equal" do
      for {uuid, info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert EctoUUID.equal?(uuid, uuid, params)
        assert EctoUUID.equal?(uuid, info.binary, params)
      end
    end

    test "equal?/3 returns false if unequal" do
      for {uuid, _info, opts} <- @items do
        params = EctoUUID.init(opts)
        uuid_b = UUID.uuid6()
        refute EctoUUID.equal?(uuid, uuid_b, params)
      end
    end

    test "autogenerate/1" do
      for {_uuid, _info, opts} <- @items do
        params = EctoUUID.init(opts)
        assert uuid = EctoUUID.autogenerate(params)
        assert info = UUID.info!(uuid)
        assert UUID.valid?(uuid)

        case params do
          {:uuid1, _} -> assert info.version == 1
          {:uuid3, _} -> assert info.version == 3
          {:uuid4, _} -> assert info.version == 4
          {:uuid5, _} -> assert info.version == 5
          {:uuid6, _} -> assert info.version == 6
          _ -> assert false
        end
      end
    end
  end
end
