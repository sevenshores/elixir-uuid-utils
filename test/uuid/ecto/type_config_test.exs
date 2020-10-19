defmodule UUID.Ecto.TypeConfigTest do
  use ExUnit.Case

  alias UUID.Ecto.TypeConfig

  # ----------------------------------------------------------------------------
  # Setup
  # ----------------------------------------------------------------------------

  test_types = [TestUUID1, TestUUID3, TestUUID4, TestUUID5, TestUUID6]
  uuids = Enum.map(test_types, & &1.generate())
  infos = Enum.map(uuids, &UUID.info!/1)

  opts = [
    [type: :uuid1],
    [type: :uuid3, namespace: :dns, name: "mydomain.com"],
    [type: :uuid4],
    [type: :uuid5, namespace: :dns, name: "mydomain.com"],
    [type: :uuid6, node_type: :random_bytes]
  ]

  @type_items Enum.zip([test_types, uuids, infos, opts])

  uuids = [
    UUID.uuid1(),
    UUID.uuid3(:dns, "mydomain.com"),
    UUID.uuid4(),
    UUID.uuid5(:dns, "mydomain.com"),
    UUID.uuid6(:random_bytes)
  ]

  infos = Enum.map(uuids, &UUID.info!/1)

  @param_items Enum.zip([uuids, infos, opts])

  # ----------------------------------------------------------------------------
  # Tests
  # ----------------------------------------------------------------------------

  ## init/1

  test "init_opts/1" do
    for {_uuid, _info, opts} <- @param_items do
      assert {type, args} = TypeConfig.init_opts(opts)
      assert type == opts[:type]
      assert is_list(args)
    end
  end

  test "init_opts/1 provides default UUID type" do
    {:uuid4, []} = TypeConfig.init_opts([])
  end

  test "init_opts/1 provides default on missing UUID v6 option" do
    {:uuid6, [:random_bytes]} = TypeConfig.init_opts(type: :uuid6)
  end

  test "init_opts/1 errors on unrecognized UUID v1 options" do
    assert_raise ArgumentError, ~r/Invalid type, or unrecognized option/, fn ->
      TypeConfig.init_opts(type: :uuid1, namespace: :dns)
    end
  end

  test "init_opts/1 errors on invalid UUID v3 namespace" do
    assert_raise ArgumentError, "Invalid namespace; expected dns|url|oid|x500| or a UUID", fn ->
      TypeConfig.init_opts(type: :uuid3, namespace: :foo, name: "bar")
    end
  end

  test "init_opts/1 errors on invalid UUID v3 name" do
    assert_raise ArgumentError, "Invalid name: 1; expected String", fn ->
      TypeConfig.init_opts(type: :uuid3, namespace: :dns, name: 1)
    end
  end

  test "init_opts/1 errors on missing UUID v3 option" do
    assert_raise KeyError, ~S(key :namespace not found in: [name: "foo"]), fn ->
      TypeConfig.init_opts(type: :uuid3, name: "foo")
    end

    assert_raise KeyError, "key :name not found in: [namespace: :dns]", fn ->
      TypeConfig.init_opts(type: :uuid3, namespace: :dns)
    end
  end

  test "init_opts/1 errors on unrecognized UUID v4 options" do
    assert_raise ArgumentError, ~r/Invalid type, or unrecognized option/, fn ->
      TypeConfig.init_opts(type: :uuid4, namespace: :dns)
    end
  end

  test "init_opts/1 errors on invalid UUID v5 namespace" do
    assert_raise ArgumentError, "Invalid namespace; expected dns|url|oid|x500| or a UUID", fn ->
      TypeConfig.init_opts(type: :uuid5, namespace: :foo, name: "bar")
    end
  end

  test "init_opts/1 errors on invalid UUID v5 name" do
    assert_raise ArgumentError, "Invalid name: 1; expected String", fn ->
      TypeConfig.init_opts(type: :uuid5, namespace: :dns, name: 1)
    end
  end

  test "init_opts/1 errors on missing UUID v5 option" do
    assert_raise KeyError, ~S(key :namespace not found in: [name: "foo"]), fn ->
      TypeConfig.init_opts(type: :uuid5, name: "foo")
    end

    assert_raise KeyError, "key :name not found in: [namespace: :dns]", fn ->
      TypeConfig.init_opts(type: :uuid5, namespace: :dns)
    end
  end

  test "init_opts/1 errors on invalid UUID v6 node_type" do
    assert_raise ArgumentError,
                 "Invalid node type: :foo; expected one of mac_address|random_bytes",
                 fn ->
                   TypeConfig.init_opts(type: :uuid6, node_type: :foo)
                 end
  end

  ## compile_type_config/2

  test "compile_type_config/2" do
    for {type, _uuid, _info, opts} <- @type_items do
      assert {type, args} = TypeConfig.compile_type_config(type, opts)
      assert type == opts[:type]
      assert is_list(args)
    end
  end

  test "compile_type_config/2 with otp_app" do
    opts1 = [otp_app: :uuid_utils, type: :uuid3, name: "foobar.com"]
    assert {type1, args1} = TypeConfig.compile_type_config(TestApp1UUID3, opts1)
    assert type1 == opts1[:type]
    assert args1 == [:dns, "foobar.com"]

    opts2 = [otp_app: :uuid_utils, type: :uuid3, namespace: :url]
    assert {type2, args2} = TypeConfig.compile_type_config(TestApp2UUID3, opts2)
    assert type2 == opts2[:type]
    assert args2 == [:url, "elixir.com"]
  end
end
