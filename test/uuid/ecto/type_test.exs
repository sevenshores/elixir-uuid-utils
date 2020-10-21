defmodule UUID.Ecto.TypeTest do
  use ExUnit.Case

  # ----------------------------------------------------------------------------
  # Setup
  # ----------------------------------------------------------------------------

  alias UUID.{TestUUID1, TestUUID3, TestUUID4, TestUUID5, TestUUID6}

  test_types = [TestUUID1, TestUUID3, TestUUID4, TestUUID5, TestUUID6]
  uuids = Enum.map(test_types, & &1.generate())
  infos = Enum.map(uuids, &UUID.info!/1)

  @items Enum.zip([test_types, uuids, infos])

  @uuid_null "00000000-0000-0000-0000-000000000000"

  defp start_repo(_) do
    start_supervised!(UUID.TestRepo)

    :ok
  end

  # ----------------------------------------------------------------------------
  # Tests
  # ----------------------------------------------------------------------------

  test "type/0" do
    for {type, _uuid, _info} <- @items do
      assert type.type() == :binary_id
    end
  end

  test "embed_as/1" do
    for {type, _uuid, _info} <- @items do
      assert type.embed_as(:foo) == :self
    end
  end

  test "cast/1" do
    for {type, uuid, info} <- @items do
      assert type.cast(uuid) == {:ok, uuid}
      assert type.cast(info.binary) == {:ok, uuid}
      assert type.cast(String.upcase(uuid)) == {:ok, uuid}
      assert type.cast(String.reverse(uuid)) == :error
      assert type.cast(@uuid_null) == {:ok, @uuid_null}
      assert type.cast(nil) == :error
    end
  end

  test "cast!/1" do
    for {type, uuid, _info} <- @items do
      assert type.cast!(uuid) == uuid
      ["UUID", type_str] = Module.split(type)

      assert_raise Ecto.CastError, "cannot cast nil to UUID.#{type_str}", fn ->
        assert type.cast!(nil) == :error
      end
    end
  end

  test "load/1" do
    for {type, uuid, info} <- @items do
      assert type.load(info.binary) == {:ok, uuid}
      assert type.load(info.uuid) == {:ok, uuid}
      assert type.load("") == :error
      assert type.load(uuid <> "1") == :error
    end
  end

  test "dump/1" do
    for {type, uuid, info} <- @items do
      assert type.dump(uuid) == {:ok, info.binary}
      assert type.dump(info.binary) == {:ok, info.binary}
      assert type.dump(String.reverse(uuid)) == :error
    end
  end

  test "equal?/2 returns true if equal" do
    for {type, uuid, info} <- @items do
      assert type.equal?(uuid, uuid)
      assert type.equal?(uuid, info.binary)
    end
  end

  test "equal?/2 returns false if unequal" do
    for {type, uuid, _info} <- @items do
      # Type 3 and 5 are not random and will always be the same.
      uuid_b = if type in [TestUUID3, TestUUID5], do: UUID.uuid4(), else: type.generate()
      refute type.equal?(uuid, uuid_b)
    end
  end

  test "autogenerate/0" do
    for {type, _uuid, _info} <- @items do
      assert uuid = type.autogenerate()
      assert info = UUID.info!(uuid)
      assert UUID.valid?(info.binary)

      case type do
        TestUUID1 -> assert info.version == 1
        TestUUID3 -> assert info.version == 3
        TestUUID4 -> assert info.version == 4
        TestUUID5 -> assert info.version == 5
        TestUUID6 -> assert info.version == 6
        _ -> assert false
      end
    end
  end

  test "generate/0" do
    for {type, _, _} <- @items do
      assert info = type.generate() |> UUID.info!()
      assert UUID.valid?(info.binary)

      case type do
        TestUUID1 -> assert info.version == 1
        TestUUID3 -> assert info.version == 3
        TestUUID4 -> assert info.version == 4
        TestUUID5 -> assert info.version == 5
        TestUUID6 -> assert info.version == 6
        _ -> assert false
      end
    end
  end

  test "generate/1" do
    for {type, _, _} <- @items do
      assert info = type.generate(:raw) |> UUID.info!()
      assert UUID.valid?(info.binary)

      case type do
        TestUUID1 -> assert info.version == 1
        TestUUID3 -> assert info.version == 3
        TestUUID4 -> assert info.version == 4
        TestUUID5 -> assert info.version == 5
        TestUUID6 -> assert info.version == 6
        _ -> assert false
      end
    end
  end

  test "bingenerate/0" do
    for {type, _, _} <- @items do
      assert info = type.bingenerate() |> UUID.info!()
      assert UUID.valid?(info.binary)

      case type do
        TestUUID1 -> assert info.version == 1
        TestUUID3 -> assert info.version == 3
        TestUUID4 -> assert info.version == 4
        TestUUID5 -> assert info.version == 5
        TestUUID6 -> assert info.version == 6
        _ -> assert false
      end
    end
  end

  describe "Repo" do
    setup [:start_repo]

    test "autogenerates proper UUID" do
      {:ok, foo} =
        UUID.TestSchema.changeset(%{})
        |> UUID.TestRepo.insert()

      assert info = UUID.info!(foo.id)
      assert info.version == 6
    end

    test "casts UUID" do
      {:ok, foo} =
        %{foo_bar_id: UUID.uuid6()}
        |> UUID.TestSchema.changeset()
        |> UUID.TestRepo.insert()

      assert info = UUID.info!(foo.foo_bar_id)
      assert info.version == 6
    end
  end
end
