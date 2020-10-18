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

  params = [
    %{type: :uuid1},
    %{type: :uuid3, args: [:dns, "mydomain.com"]},
    %{type: :uuid4},
    %{type: :uuid5, args: [:dns, "mydomain.com"]},
    %{type: :uuid6, args: [:random_bytes]}
  ]

  @items Enum.zip([uuids, infos, params])

  @uuid_null "00000000-0000-0000-0000-000000000000"

  @default_params %{type: :uuid4, args: []}

  # ----------------------------------------------------------------------------
  # Tests
  # ----------------------------------------------------------------------------

  test "type/1" do
    for {_uuid, _info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.type(params) == :binary_id
    end
  end

  test "init/1" do
    for {_uuid, _info, params} <- @items do
      assert EctoUUID.init(Map.to_list(params)) == Map.merge(@default_params, params)
      assert EctoUUID.init([]) == @default_params
    end
  end

  test "embed_as/2" do
    for {_uuid, _info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.embed_as(:foo, params) == :self
    end
  end

  test "cast/2" do
    for {uuid, info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.cast(uuid, params) == {:ok, uuid}
      assert EctoUUID.cast(info.binary, params) == {:ok, uuid}
      assert EctoUUID.cast(String.upcase(uuid), params) == {:ok, uuid}
      assert EctoUUID.cast(String.reverse(uuid), params) == :error
      assert EctoUUID.cast(@uuid_null, params) == {:ok, @uuid_null}
      assert EctoUUID.cast(nil, params) == :error
    end
  end

  test "cast!/2" do
    for {uuid, _info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.cast!(uuid, params) == uuid

      assert_raise Ecto.CastError, "cannot cast nil to UUID.Ecto.Type", fn ->
        assert EctoUUID.cast!(nil, params)
      end
    end
  end

  test "load/3" do
    loader = & &1

    for {uuid, info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.load(info.binary, loader, params) == {:ok, uuid}
      assert EctoUUID.load("", loader, params) == :error
      assert EctoUUID.load(nil, loader, params) == :error
    end
  end

  test "dump/3" do
    dumper = & &1

    for {uuid, info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.dump(uuid, dumper, params) == {:ok, info.binary}
      assert EctoUUID.dump(info.binary, dumper, params) == {:ok, info.binary}
      assert EctoUUID.dump("", dumper, params) == :error
    end
  end

  test "equal?/3 returns true if equal" do
    for {uuid, info, params} <- @items do
      params = EctoUUID.init(params)
      assert EctoUUID.equal?(uuid, uuid, params)
      assert EctoUUID.equal?(uuid, info.binary, params)
    end
  end

  test "equal?/3 returns false if unequal" do
    for {uuid, _info, params} <- @items do
      params = EctoUUID.init(params)
      uuid_b = UUID.uuid6()
      refute EctoUUID.equal?(uuid, uuid_b, params)
    end
  end

  test "autogenerate/1" do
    for {_uuid, _info, params} <- @items do
      params = EctoUUID.init(params)
      assert uuid = EctoUUID.autogenerate(params)
      assert info = UUID.info!(uuid)

      case params[:type] do
        :uuid1 -> assert info.version == 1
        :uuid3 -> assert info.version == 3
        :uuid4 -> assert info.version == 4
        :uuid5 -> assert info.version == 5
        :uuid6 -> assert info.version == 6
        _ -> assert false
      end
    end
  end

  test "generate/0" do
    assert info = EctoUUID.generate() |> UUID.info!()
    assert UUID.valid?(info.binary)
    assert info.version == 4
  end

  test "generate/1" do
    assert info = EctoUUID.generate(:raw) |> UUID.info!()
    assert UUID.valid?(info.binary)
    assert info.version == 4
  end

  test "bingenerate/0" do
    assert info = EctoUUID.bingenerate() |> UUID.info!()
    assert UUID.valid?(info.binary)
    assert info.version == 4
  end
end
