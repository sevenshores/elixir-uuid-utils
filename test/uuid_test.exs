defmodule UUIDTest do
  use ExUnit.Case, async: true

  doctest UUID, except: [uuid1: 1, uuid1: 3, uuid4: 0, uuid4: 1, uuid4: 2, uuid6: 2, uuid6: 3]

  test "info/1 invalid argument type" do
    assert UUID.info(:not_a_uuid) ==
             {:error, "Invalid argument; Expected: String, got :not_a_uuid"}
  end

  test "info/1 invalid UUID" do
    assert UUID.info("not_a_uuid") == {:error, "Invalid argument; Not a valid UUID: not_a_uuid"}
  end

  test "info!/1 invalid argument type" do
    assert_raise(
      ArgumentError,
      "Invalid argument; Expected: String, got :not_a_uuid",
      fn ->
        UUID.info!(:not_a_uuid)
      end
    )
  end

  test "info!/1 invalid UUID" do
    assert_raise(
      ArgumentError,
      "Invalid argument; Not a valid UUID: not_a_uuid",
      fn ->
        UUID.info!("not_a_uuid")
      end
    )
  end

  test "binary_to_string!/2 converts binaries to strings" do
    for type <- [:default, :raw, :hex, :urn, :slug] do
      UUID.uuid4(:raw) |> UUID.binary_to_string!(type) |> UUID.valid?()
    end
  end

  test "binary_to_string!/2 with invalid UUID type returns error" do
    for type <- [:default, :raw, :hex, :urn, :slug] do
      assert_raise(
        ArgumentError,
        "Invalid argument; Expected: <<uuid::128>>",
        fn ->
          UUID.binary_to_string!(123, type)
        end
      )
    end
  end

  test "binary_to_string!/2 with invalid UUID returns error" do
    for type <- [:default, :hex, :urn, :slug] do
      assert_raise(
        ArgumentError,
        "Invalid binary data; Expected: <<uuid::128>>",
        fn ->
          UUID.binary_to_string!("not_a_uuid", type)
        end
      )
    end
  end

  test "string_to_binary!/2 converts strings to binaries" do
    for type <- [:default, :raw, :hex, :urn, :slug] do
      UUID.uuid4(type) |> UUID.string_to_binary!() |> UUID.valid?()
    end
  end

  test "string_to_binary!/2 with invalid UUID type returns error" do
    assert_raise(
      ArgumentError,
      "Invalid argument; Expected: String",
      fn ->
        UUID.string_to_binary!(123)
      end
    )
  end

  test "string_to_binary!/2 with invalid UUID returns error" do
    assert_raise(
      ArgumentError,
      "Invalid argument; Not a valid UUID: foo",
      fn ->
        UUID.string_to_binary!("foo")
      end
    )
  end

  test "uuid1_to_uuid6/1 converts UUIDs" do
    uuid1 = UUID.uuid1() |> validate(1)
    assert uuid1 == UUID.uuid1_to_uuid6(uuid1) |> validate(6) |> UUID.uuid6_to_uuid1()
  end

  test "uuid6_to_uuid1/1 converts UUIDs" do
    uuid6 = UUID.uuid6() |> validate(6)
    assert uuid6 == UUID.uuid6_to_uuid1(uuid6) |> validate(1) |> UUID.uuid1_to_uuid6()
  end

  test "valid?/2 validates valid UUIDs" do
    assert UUID.uuid1() |> UUID.valid?()
    assert UUID.uuid1() |> UUID.valid?(1)

    assert UUID.uuid3(:dns, "my.domain.com") |> UUID.valid?()
    assert UUID.uuid3(:dns, "my.domain.com") |> UUID.valid?(3)

    assert UUID.uuid4() |> UUID.valid?()
    assert UUID.uuid4() |> UUID.valid?(4)

    assert UUID.uuid5(:dns, "my.domain.com") |> UUID.valid?()
    assert UUID.uuid5(:dns, "my.domain.com") |> UUID.valid?(5)

    assert UUID.uuid6() |> UUID.valid?()
    assert UUID.uuid6() |> UUID.valid?(6)
  end

  test "valid?/2 invalidates invalid UUIDs" do
    refute UUID.valid?("foo")
  end

  # Expand the lines in info_tests.txt into individual tests for the
  # UUID.info!/1 and UUID.info/1 functions, assuming the lines are:
  #   test name || expected output || input value
  # info_file = Path.expand("../support/info_tests.txt", __DIR__)
  for line <- File.stream!(Path.expand("./support/fixtures/info_tests.txt", __DIR__), [], :line) do
    [name, expected, input] = line |> String.split("||") |> Enum.map(&String.trim/1)

    test "UUID.info!/1 #{name}" do
      {expected, []} = Code.eval_string(unquote(expected))
      result = UUID.info!(unquote(input))
      assert ^expected = result
      validate(UUID.binary_to_string!(result.binary), expected.version)
    end

    test "UUID.info/1 #{name}" do
      {expected, []} = Code.eval_string(unquote(expected))
      {:ok, result} = UUID.info(unquote(input))
      assert ^expected = result
      validate(UUID.binary_to_string!(result.binary), expected.version)
    end
  end

  defp validate(uuid, version) when version in 0..6 do
    assert UUID.valid?(uuid, version)
    uuid
  end
end
