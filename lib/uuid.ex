defmodule UUID do
  @moduledoc """
  UUID generator and utilities for [Elixir](http://elixir-lang.org/).
  See [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).
  """

  alias UUID.Info

  @typedoc "One of representations of UUID."
  @type t :: str | raw | hex | urn | slug

  @typedoc "String representation of UUID."
  @type str :: <<_::288>>

  @typedoc "Raw binary representation of UUID."
  @type raw :: <<_::128>>

  @typedoc "Hex representation of UUID."
  @type hex :: <<_::256>>

  @typedoc "URN representation of UUID."
  @type urn :: <<_::360>>

  @typedoc "Slug representation of UUID."
  @type slug :: String.t()

  @typedoc "Type of UUID representation."
  @type type :: :default | :raw | :hex | :urn | :slug

  @typedoc "UUID version."
  @type version :: 1 | 3 | 4 | 5 | 6

  @typedoc "Variant of UUID: see RFC for the details."
  @type variant ::
          :reserved_future
          | :reserved_microsoft
          | :rfc4122
          | :reserved_ncs

  @typedoc """
  Namespace for UUID v3 and v5 (with some predefined UUIDs as atom aliases).
  """
  @type namespace :: :dns | :url | :oid | :x500 | nil | str

  @typedoc "Information about given UUID (see `info/1`)"
  @type info :: UUID.Info.t()

  # 15 Oct 1582 to 1 Jan 1970.
  @nanosec_intervals_offset 122_192_928_000_000_000
  # Microseconds to nanoseconds factor.
  @nanosec_intervals_factor 10

  # Variant, corresponds to variant 1 0 of RFC 4122.
  @variant10 2

  # UUID identifiers.
  @uuid_v1 1
  @uuid_v3 3
  @uuid_v4 4
  @uuid_v5 5
  @uuid_v6 6

  # UUID URN prefix.
  @urn "urn:uuid:"

  @spec info(str) :: {:ok, info} | {:error, String.t()}
  defdelegate info(uuid), to: Info, as: :new

  @spec info!(str) :: info
  defdelegate info!(uuid), to: Info, as: :new!

  @doc """
  Convert binary UUID data to a string.

  Will raise an ArgumentError if the given binary is not valid UUID data, or
  the format argument is not one of: `:default`, `:hex`, `:urn`, or `:raw`.

  ## Examples

      iex> UUID.binary_to_string!(<<135, 13, 248, 232, 49, 7, 68, 135,
      ...>        131, 22, 129, 224, 137, 184, 194, 207>>)
      "870df8e8-3107-4487-8316-81e089b8c2cf"

      iex> UUID.binary_to_string!(<<142, 161, 81, 61, 248, 161, 77, 234, 155,
      ...>        234, 107, 143, 75, 91, 110, 115>>, :hex)
      "8ea1513df8a14dea9bea6b8f4b5b6e73"

      iex> UUID.binary_to_string!(<<239, 27, 26, 40, 238, 52, 17, 227, 136,
      ...>        19, 20, 16, 159, 241, 163, 4>>, :urn)
      "urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"

      iex> UUID.binary_to_string!(<<39, 73, 196, 181, 29, 90, 74, 96, 157,
      ...>        47, 171, 144, 84, 164, 155, 52>>, :raw)
      <<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>

  """
  @spec binary_to_string!(raw) :: str
  @spec binary_to_string!(raw, type) :: t
  def binary_to_string!(uuid, format \\ :default)

  def binary_to_string!(<<uuid::binary>>, format) do
    uuid_to_string(<<uuid::binary>>, format)
  end

  def binary_to_string!(_, _) do
    raise ArgumentError, message: "Invalid argument; Expected: <<uuid::128>>"
  end

  @doc """
  Convert a UUID string to its binary data equivalent.

  Will raise an ArgumentError if the given string is not a UUID representation
  in a format like:
   * `"870df8e8-3107-4487-8316-81e089b8c2cf"`
   * `"8ea1513df8a14dea9bea6b8f4b5b6e73"`
   * `"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"`

  ## Examples

      iex> UUID.string_to_binary!("870df8e8-3107-4487-8316-81e089b8c2cf")
      <<135, 13, 248, 232, 49, 7, 68, 135, 131, 22, 129, 224, 137, 184, 194, 207>>

      iex> UUID.string_to_binary!("8ea1513df8a14dea9bea6b8f4b5b6e73")
      <<142, 161, 81, 61, 248, 161, 77, 234, 155, 234, 107, 143, 75, 91, 110, 115>>

      iex> UUID.string_to_binary!("urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304")
      <<239, 27, 26, 40, 238, 52, 17, 227, 136, 19, 20, 16, 159, 241, 163, 4>>

      iex> UUID.string_to_binary!(<<39, 73, 196, 181, 29, 90, 74, 96, 157, 47,
      ...>        171, 144, 84, 164, 155, 52>>)
      <<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>

  """
  @spec string_to_binary!(str) :: raw
  def string_to_binary!(<<uuid::binary>>) do
    {_type, <<uuid::128>>} = uuid_string_to_hex_pair(uuid)
    <<uuid::128>>
  end

  def string_to_binary!(_) do
    raise ArgumentError, message: "Invalid argument; Expected: String"
  end

  @doc """
  Generate a new UUID v1. This version uses a combination of one or more of:
  unix epoch, random bytes, pid hash, and hardware address.

  ## Examples

      iex> UUID.uuid1()
      "cdfdaf44-ee35-11e3-846b-14109ff1a304"

      iex> UUID.uuid1(:default)
      "cdfdaf44-ee35-11e3-846b-14109ff1a304"

      iex> UUID.uuid1(:hex)
      "cdfdaf44ee3511e3846b14109ff1a304"

      iex> UUID.uuid1(:urn)
      "urn:uuid:cdfdaf44-ee35-11e3-846b-14109ff1a304"

      iex> UUID.uuid1(:raw)
      <<205, 253, 175, 68, 238, 53, 17, 227, 132, 107, 20, 16, 159, 241, 163, 4>>

      iex> UUID.uuid1(:slug)
      "zf2vRO41EeOEaxQQn_GjBA"

  """
  @spec uuid1() :: str
  @spec uuid1(type) :: t
  def uuid1(format \\ :default) do
    uuid1(uuid1_clockseq(), uuid1_node(), format)
  end

  @doc """
  Generate a new UUID v1, with an existing clock sequence and node address. This
  version uses a combination of one or more of: unix epoch, random bytes,
  pid hash, and hardware address.

  ## Examples

      iex> UUID.uuid1()
      "cdfdaf44-ee35-11e3-846b-14109ff1a304"

      iex> UUID.uuid1(:default)
      "cdfdaf44-ee35-11e3-846b-14109ff1a304"

      iex> UUID.uuid1(:hex)
      "cdfdaf44ee3511e3846b14109ff1a304"

      iex> UUID.uuid1(:urn)
      "urn:uuid:cdfdaf44-ee35-11e3-846b-14109ff1a304"

      iex> UUID.uuid1(:raw)
      <<205, 253, 175, 68, 238, 53, 17, 227, 132, 107, 20, 16, 159, 241, 163, 4>>

      iex> UUID.uuid1(:slug)
      "zf2vRO41EeOEaxQQn_GjBA"

  """
  @spec uuid1(clock_seq :: <<_::14>>, node :: <<_::48>>) :: str
  @spec uuid1(clock_seq :: <<_::14>>, node :: <<_::48>>, type) :: t
  def uuid1(clock_seq, node, format \\ :default)

  def uuid1(<<clock_seq::14>>, <<node::48>>, format) do
    <<time_hi::12, time_mid::16, time_low::32>> = uuid1_time()
    <<clock_seq_hi::6, clock_seq_low::8>> = <<clock_seq::14>>

    <<time_low::32, time_mid::16, @uuid_v1::4, time_hi::12, @variant10::2, clock_seq_hi::6,
      clock_seq_low::8, node::48>>
    |> uuid_to_string(format)
  end

  def uuid1(_, _, _) do
    raise ArgumentError, message: "Invalid argument; Expected: <<clock_seq::14>>, <<node::48>>"
  end

  @doc """
  Generate a new UUID v3. This version uses an MD5 hash of fixed value chosen
  based on a namespace atom - see Appendix C of
  [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt) and a name value. Can also be
  given an existing UUID String instead of a namespace atom.

  Accepted arguments are: `:dns`|`:url`|`:oid`|`:x500`|`:nil` OR uuid, String

  ## Examples

      iex> UUID.uuid3(:dns, "my.domain.com")
      "03bf0706-b7e9-33b8-aee5-c6142a816478"

      iex> UUID.uuid3(:dns, "my.domain.com", :default)
      "03bf0706-b7e9-33b8-aee5-c6142a816478"

      iex> UUID.uuid3(:dns, "my.domain.com", :hex)
      "03bf0706b7e933b8aee5c6142a816478"

      iex> UUID.uuid3(:dns, "my.domain.com", :urn)
      "urn:uuid:03bf0706-b7e9-33b8-aee5-c6142a816478"

      iex> UUID.uuid3(:dns, "my.domain.com", :raw)
      <<3, 191, 7, 6, 183, 233, 51, 184, 174, 229, 198, 20, 42, 129, 100, 120>>

      iex> UUID.uuid3("cdfdaf44-ee35-11e3-846b-14109ff1a304", "my.domain.com")
      "8808f33a-3e11-3708-919e-15fba88908db"

      iex> UUID.uuid3(:dns, "my.domain.com", :slug)
      "A78HBrfpM7iu5cYUKoFkeA"

  """
  @spec uuid3(namespace, name :: binary) :: str
  @spec uuid3(namespace, name :: binary, type) :: t
  def uuid3(namespace_or_uuid, name, format \\ :default)

  def uuid3(:dns, <<name::binary>>, format) do
    namebased_uuid(:md5, <<0x6BA7B8109DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid3(:url, <<name::binary>>, format) do
    namebased_uuid(:md5, <<0x6BA7B8119DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid3(:oid, <<name::binary>>, format) do
    namebased_uuid(:md5, <<0x6BA7B8129DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid3(:x500, <<name::binary>>, format) do
    namebased_uuid(:md5, <<0x6BA7B8149DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid3(nil, <<name::binary>>, format) do
    namebased_uuid(:md5, <<0::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid3(<<uuid::binary>>, <<name::binary>>, format) do
    {_type, <<uuid::128>>} = uuid_string_to_hex_pair(uuid)

    namebased_uuid(:md5, <<uuid::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid3(_, _, _) do
    raise ArgumentError,
      message: "Invalid argument; Expected: :dns|:url|:oid|:x500|:nil OR String, String"
  end

  @doc """
  Generate a new UUID v4. This version uses pseudo-random bytes generated by
  the `crypto` module.

  ## Examples

      iex> UUID.uuid4()
      "fb49a0ec-d60c-4d20-9264-3b4cfe272106"

      iex> UUID.uuid4(:default)
      "fb49a0ec-d60c-4d20-9264-3b4cfe272106"

      iex> UUID.uuid4(:hex)
      "fb49a0ecd60c4d2092643b4cfe272106"

      iex> UUID.uuid4(:urn)
      "urn:uuid:fb49a0ec-d60c-4d20-9264-3b4cfe272106"

      iex> UUID.uuid4(:raw)
      <<251, 73, 160, 236, 214, 12, 77, 32, 146, 100, 59, 76, 254, 39, 33, 6>>

      iex> UUID.uuid4(:slug)
      "-0mg7NYMTSCSZDtM_ichBg"

  """
  @spec uuid4() :: str
  @spec uuid4(type | :strong | :weak) :: t
  def uuid4(), do: uuid4(:default)

  # For backwards compatibility.
  def uuid4(:strong), do: uuid4(:default)
  # For backwards compatibility.
  def uuid4(:weak), do: uuid4(:default)

  def uuid4(format) do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = :crypto.strong_rand_bytes(16)

    <<u0::48, @uuid_v4::4, u1::12, @variant10::2, u2::62>>
    |> uuid_to_string(format)
  end

  @doc """
  Generate a new UUID v5. This version uses an SHA1 hash of fixed value chosen
  based on a namespace atom - see Appendix C of
  [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt) and a name value. Can also be
  given an existing UUID String instead of a namespace atom.

  Accepted arguments are: `:dns`|`:url`|`:oid`|`:x500`|`:nil` OR uuid, String

  ## Examples

      iex> UUID.uuid5(:dns, "my.domain.com")
      "016c25fd-70e0-56fe-9d1a-56e80fa20b82"

      iex> UUID.uuid5(:dns, "my.domain.com", :default)
      "016c25fd-70e0-56fe-9d1a-56e80fa20b82"

      iex> UUID.uuid5(:dns, "my.domain.com", :hex)
      "016c25fd70e056fe9d1a56e80fa20b82"

      iex> UUID.uuid5(:dns, "my.domain.com", :urn)
      "urn:uuid:016c25fd-70e0-56fe-9d1a-56e80fa20b82"

      iex> UUID.uuid5(:dns, "my.domain.com", :raw)
      <<1, 108, 37, 253, 112, 224, 86, 254, 157, 26, 86, 232, 15, 162, 11, 130>>

      iex> UUID.uuid5("fb49a0ec-d60c-4d20-9264-3b4cfe272106", "my.domain.com")
      "822cab19-df58-5eb4-98b5-c96c15c76d32"

      iex> UUID.uuid5("fb49a0ec-d60c-4d20-9264-3b4cfe272106", "my.domain.com", :slug)
      "giyrGd9YXrSYtclsFcdtMg"

  """
  @spec uuid5(namespace, binary) :: str
  @spec uuid5(namespace, name :: binary, type) :: t
  def uuid5(namespace_or_uuid, name, format \\ :default)

  def uuid5(:dns, <<name::binary>>, format) do
    namebased_uuid(:sha1, <<0x6BA7B8109DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid5(:url, <<name::binary>>, format) do
    namebased_uuid(:sha1, <<0x6BA7B8119DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid5(:oid, <<name::binary>>, format) do
    namebased_uuid(:sha1, <<0x6BA7B8129DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid5(:x500, <<name::binary>>, format) do
    namebased_uuid(:sha1, <<0x6BA7B8149DAD11D180B400C04FD430C8::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid5(nil, <<name::binary>>, format) do
    namebased_uuid(:sha1, <<0::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid5(<<uuid::binary>>, <<name::binary>>, format) do
    {_type, <<uuid::128>>} = uuid_string_to_hex_pair(uuid)

    namebased_uuid(:sha1, <<uuid::128, name::binary>>)
    |> uuid_to_string(format)
  end

  def uuid5(_, _, _) do
    raise ArgumentError,
      message: "Invalid argument; Expected: :dns|:url|:oid|:x500|:nil OR String, String"
  end

  @doc """
  Generate a new UUID v6. This version uses a combination of one or more of:
  unix epoch, random bytes, pid hash, and hardware address.

  Accepts a `node_type` argument that can be either `:mac_address` or
  `:random_bytes`. Defaults to `:random_bytes`.

  See the [RFC draft, section 3.3](https://tools.ietf.org/html/draft-peabody-dispatch-new-uuid-format-00#section-3.3)
  for more information on the node parts.

  ## Examples

      iex> UUID.uuid6()
      "1eb0d28f-da4c-6eb2-adc1-0242ac120002"

      iex> UUID.uuid6(:random_bytes, :default)
      "1eb0d297-eb1e-62a6-a37f-a55eda5dd6e4"

      iex> UUID.uuid6(:random_bytes, :hex)
      "1eb0d298502563fcadcd25e5d0a44c1a"

      iex> UUID.uuid6(:random_bytes, :urn)
      "urn:uuid:1eb0d298-ca10-6914-ab0e-7d7e1e6e1808"

      iex> UUID.uuid6(:random_bytes, :raw)
      <<30, 176, 210, 153, 52, 23, 102, 230, 164, 146, 99, 66, 4, 72, 220, 114>>

      iex> UUID.uuid6(:random_bytes, :slug)
      "HrDSmab8ZnqR4SKw4LN-UA"

  """
  @spec uuid6() :: str
  @spec uuid6(:random_bytes | :mac_address) :: str
  @spec uuid6(:random_bytes | :mac_address, type) :: t
  def uuid6(node_type \\ :random_bytes, format \\ :default)
      when node_type in [:mac_address, :random_bytes] do
    uuid6(uuid1_clockseq(), uuid6_node(node_type), format)
  end

  @doc """
  Generate a new UUID v6, with an existing clock sequence and node address. This
  version uses a combination of one or more of: unix epoch, random bytes,
  pid hash, and hardware address.
  """
  def uuid6(<<clock_seq::14>>, <<node::48>>, format) do
    <<time_hi::12, time_mid::16, time_low::32>> = uuid1_time()
    <<time_low1::20, time_low2::12>> = <<time_low::32>>
    <<clock_seq_hi::6, clock_seq_low::8>> = <<clock_seq::14>>

    <<time_hi::12, time_mid::16, time_low1::20, @uuid_v6::4, time_low2::12, @variant10::2,
      clock_seq_hi::6, clock_seq_low::8, node::48>>
    |> uuid_to_string(format)
  end

  def uuid6(_, _, _) do
    raise ArgumentError, message: "Invalid argument; Expected: <<clock_seq::14>>, <<node::48>>"
  end

  @doc """
  Convert a UUID v1 to a UUID v6 in the same format.

  ## Examples

      iex> UUID.uuid1_to_uuid6("dafc431a-0d21-11eb-adc1-0242ac120002")
      "1eb0d21d-afc4-631a-adc1-0242ac120002"

      iex> UUID.uuid1_to_uuid6("2vxDGg0hEeutwQJCrBIAAg")
      "HrDSHa_EYxqtwQJCrBIAAg"

      iex> UUID.uuid1_to_uuid6(<<218, 252, 67, 26, 13, 33, 17, 235, 173, 193, 2, 66, 172, 18, 0, 2>>)
      <<30, 176, 210, 29, 175, 196, 99, 26, 173, 193, 2, 66, 172, 18, 0, 2>>

  """
  def uuid1_to_uuid6(uuid1) do
    {format, ub1} = uuid_string_to_hex_pair(uuid1)

    <<time_low::32, time_mid::16, @uuid_v1::4, time_hi::12, rest::binary>> = ub1
    <<time_low1::20, time_low2::12>> = <<time_low::32>>

    <<time_hi::12, time_mid::16, time_low1::20, @uuid_v6::4, time_low2::12, rest::binary>>
    |> uuid_to_string(format)
  end

  @doc """
  Convert a UUID v6 to a UUID v1 in the same format.

  ## Examples

      iex> UUID.uuid6_to_uuid1("1eb0d21d-afc4-631a-adc1-0242ac120002")
      "dafc431a-0d21-11eb-adc1-0242ac120002"

      iex> UUID.uuid6_to_uuid1("HrDSHa_EYxqtwQJCrBIAAg")
      "2vxDGg0hEeutwQJCrBIAAg"

      iex> UUID.uuid6_to_uuid1(<<30, 176, 210, 29, 175, 196, 99, 26, 173, 193, 2, 66, 172, 18, 0, 2>>)
      <<218, 252, 67, 26, 13, 33, 17, 235, 173, 193, 2, 66, 172, 18, 0, 2>>

  """
  def uuid6_to_uuid1(uuid6) do
    {format, ub6} = uuid_string_to_hex_pair(uuid6)

    <<time_hi::12, time_mid::16, time_low1::20, @uuid_v6::4, time_low2::12, rest::binary>> = ub6
    <<time_low::32>> = <<time_low1::20, time_low2::12>>

    <<time_low::32, time_mid::16, @uuid_v1::4, time_hi::12, rest::binary>>
    |> uuid_to_string(format)
  end

  @doc """
  Validate a RFC4122 UUID.
  """
  @spec valid?(binary, 0..6 | String.t()) :: boolean
  def valid?(uuid, version \\ "[0-6]")

  def valid?(uuid, version) when version in 0..6 or version == "[0-6]" do
    case info(uuid) do
      {:ok, info} ->
        ~r/^[0-9a-f]{8}-[0-9a-f]{4}-#{version}[0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i
        |> Regex.match?(uuid_to_string_default(info.binary))

      {:error, _} ->
        false
    end
  end

  def valid?(_, _), do: false

  @doc """
  Identify the UUID variant according to section 4.1.1 of RFC 4122.

  ## Examples

      iex> UUID.variant(<<1, 1, 1>>)
      :reserved_future

      iex> UUID.variant(<<1, 1, 0>>)
      :reserved_microsoft

      iex> UUID.variant(<<1, 0, 0>>)
      :rfc4122

      iex> UUID.variant(<<0, 1, 1>>)
      :reserved_ncs

      iex> UUID.variant(<<1>>)
      ** (ArgumentError) Invalid argument; Not valid variant bits

  """
  @spec variant(binary) :: variant()
  def variant(<<1, 1, 1>>), do: :reserved_future
  def variant(<<1, 1, _v>>), do: :reserved_microsoft
  def variant(<<1, 0, _v>>), do: :rfc4122
  def variant(<<0, _v::2-binary>>), do: :reserved_ncs
  def variant(_), do: raise(ArgumentError, message: "Invalid argument; Not valid variant bits")

  # ----------------------------------------------------------------------------
  # Internal utility functions.
  # ----------------------------------------------------------------------------

  # Convert UUID bytes to String.
  defp uuid_to_string(<<_::128>> = u, :default) do
    uuid_to_string_default(u)
  end

  defp uuid_to_string(<<_::128>> = u, :hex) do
    IO.iodata_to_binary(for <<part::4 <- u>>, do: e(part))
  end

  defp uuid_to_string(<<_::128>> = u, :urn) do
    @urn <> uuid_to_string(u, :default)
  end

  defp uuid_to_string(<<_::128>> = u, :raw) do
    u
  end

  defp uuid_to_string(<<_::128>> = u, :slug) do
    Base.url_encode64(u, padding: false)
  end

  defp uuid_to_string(_u, format) when format in [:default, :hex, :urn, :slug] do
    raise ArgumentError, message: "Invalid binary data; Expected: <<uuid::128>>"
  end

  defp uuid_to_string(_u, format) do
    raise ArgumentError, message: "Invalid format #{format}; Expected: :default|:hex|:urn|:slug"
  end

  defp uuid_to_string_default(<<_::128>> = uuid) do
    <<a1::4, a2::4, a3::4, a4::4, a5::4, a6::4, a7::4, a8::4, b1::4, b2::4, b3::4, b4::4, c1::4,
      c2::4, c3::4, c4::4, d1::4, d2::4, d3::4, d4::4, e1::4, e2::4, e3::4, e4::4, e5::4, e6::4,
      e7::4, e8::4, e9::4, e10::4, e11::4, e12::4>> = uuid

    <<e(a1), e(a2), e(a3), e(a4), e(a5), e(a6), e(a7), e(a8), ?-, e(b1), e(b2), e(b3), e(b4), ?-,
      e(c1), e(c2), e(c3), e(c4), ?-, e(d1), e(d2), e(d3), e(d4), ?-, e(e1), e(e2), e(e3), e(e4),
      e(e5), e(e6), e(e7), e(e8), e(e9), e(e10), e(e11), e(e12)>>
  end

  @compile {:inline, e: 1}

  defp e(0), do: ?0
  defp e(1), do: ?1
  defp e(2), do: ?2
  defp e(3), do: ?3
  defp e(4), do: ?4
  defp e(5), do: ?5
  defp e(6), do: ?6
  defp e(7), do: ?7
  defp e(8), do: ?8
  defp e(9), do: ?9
  defp e(10), do: ?a
  defp e(11), do: ?b
  defp e(12), do: ?c
  defp e(13), do: ?d
  defp e(14), do: ?e
  defp e(15), do: ?f

  @doc """
  Extract the type (:default etc) and pure byte value from a UUID String.
  """
  @spec uuid_string_to_hex_pair(t) :: {type, raw}
  def uuid_string_to_hex_pair(<<_::128>> = uuid) do
    {:raw, uuid}
  end

  def uuid_string_to_hex_pair(<<uuid_in::binary>>) do
    uuid = String.downcase(uuid_in)

    {type, hex_str} =
      case uuid do
        <<u0::64, ?-, u1::32, ?-, u2::32, ?-, u3::32, ?-, u4::96>> ->
          {:default, <<u0::64, u1::32, u2::32, u3::32, u4::96>>}

        <<u::256>> ->
          {:hex, <<u::256>>}

        <<@urn, u0::64, ?-, u1::32, ?-, u2::32, ?-, u3::32, ?-, u4::96>> ->
          {:urn, <<u0::64, u1::32, u2::32, u3::32, u4::96>>}

        _ ->
          case uuid_in do
            _ when byte_size(uuid_in) == 22 ->
              case Base.url_decode64(uuid_in <> "==") do
                {:ok, decoded} -> {:slug, Base.encode16(decoded)}
                _ -> raise ArgumentError, message: "Invalid argument; Not a valid UUID: #{uuid}"
              end

            _ ->
              raise ArgumentError, message: "Invalid argument; Not a valid UUID: #{uuid}"
          end
      end

    try do
      {type, hex_str_to_binary(hex_str)}
    catch
      _, _ ->
        raise ArgumentError, message: "Invalid argument; Not a valid UUID: #{uuid}"
    end
  end

  # Get unix epoch as a 60-bit timestamp.
  defp uuid1_time() do
    {mega_sec, sec, micro_sec} = :os.timestamp()
    epoch = mega_sec * 1_000_000_000_000 + sec * 1_000_000 + micro_sec
    timestamp = @nanosec_intervals_offset + @nanosec_intervals_factor * epoch
    <<timestamp::60>>
  end

  # Generate random clock sequence.
  defp uuid1_clockseq() do
    <<rnd::14, _::2>> = :crypto.strong_rand_bytes(2)
    <<rnd::14>>
  end

  # Get local IEEE 802 (MAC) address, or a random node id if it can't be found.
  defp uuid1_node() do
    {:ok, ifs0} = :inet.getifaddrs()
    uuid1_node(ifs0)
  end

  defp uuid1_node([{_if_name, if_config} | rest]) do
    case :lists.keyfind(:hwaddr, 1, if_config) do
      false ->
        uuid1_node(rest)

      {:hwaddr, hw_addr} ->
        if length(hw_addr) != 6 or Enum.all?(hw_addr, fn n -> n == 0 end) do
          uuid1_node(rest)
        else
          :erlang.list_to_binary(hw_addr)
        end
    end
  end

  defp uuid1_node(_) do
    <<rnd_hi::7, _::1, rnd_low::40>> = :crypto.strong_rand_bytes(6)
    <<rnd_hi::7, 1::1, rnd_low::40>>
  end

  defp uuid6_node(:mac_address) do
    uuid1_node()
  end

  defp uuid6_node(:random_bytes) do
    :crypto.strong_rand_bytes(6)
  end

  # Generate a hash of the given data.
  defp namebased_uuid(:md5, data) do
    md5 = :crypto.hash(:md5, data)
    compose_namebased_uuid(@uuid_v3, md5)
  end

  defp namebased_uuid(:sha1, data) do
    <<sha1::128, _::32>> = :crypto.hash(:sha, data)
    compose_namebased_uuid(@uuid_v5, <<sha1::128>>)
  end

  # Format the given hash as a UUID.
  defp compose_namebased_uuid(version, hash) do
    <<time_low::32, time_mid::16, _::4, time_hi::12, _::2, clock_seq_hi::6, clock_seq_low::8,
      node::48>> = hash

    <<time_low::32, time_mid::16, version::4, time_hi::12, @variant10::2, clock_seq_hi::6,
      clock_seq_low::8, node::48>>
  end

  defp hex_str_to_binary(
         <<a1, a2, a3, a4, a5, a6, a7, a8, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4, e1, e2,
           e3, e4, e5, e6, e7, e8, e9, e10, e11, e12>>
       ) do
    <<d(a1)::4, d(a2)::4, d(a3)::4, d(a4)::4, d(a5)::4, d(a6)::4, d(a7)::4, d(a8)::4, d(b1)::4,
      d(b2)::4, d(b3)::4, d(b4)::4, d(c1)::4, d(c2)::4, d(c3)::4, d(c4)::4, d(d1)::4, d(d2)::4,
      d(d3)::4, d(d4)::4, d(e1)::4, d(e2)::4, d(e3)::4, d(e4)::4, d(e5)::4, d(e6)::4, d(e7)::4,
      d(e8)::4, d(e9)::4, d(e10)::4, d(e11)::4, d(e12)::4>>
  end

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?A), do: 10
  defp d(?B), do: 11
  defp d(?C), do: 12
  defp d(?D), do: 13
  defp d(?E), do: 14
  defp d(?F), do: 15
  defp d(?a), do: 10
  defp d(?b), do: 11
  defp d(?c), do: 12
  defp d(?d), do: 13
  defp d(?e), do: 14
  defp d(?f), do: 15
  defp d(_), do: throw(:error)
end
