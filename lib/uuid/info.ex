defmodule UUID.Info do
  @moduledoc false

  alias __MODULE__

  defstruct [:uuid, :binary, :type, :version, :variant]

  @type type :: :default | :hex | :urn | :raw | :slug
  @type version :: 1 | 3 | 4 | 5 | 6
  @type variant :: :rfc4122 | :reserved_ncs | :reserved_microsoft | :reserved_future
  @type t :: %Info{uuid: binary, type: type, version: version, variant: variant}

  @doc """
  Inspect a UUID and return tuple with `{:ok, result}`, where result is
  information about its 128-bit binary content, type,
  version and variant.

  Timestamp portion is not checked to see if it's in the future, and therefore
  not yet assignable. See "Validation mechanism" in section 3 of
  [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).

  Will return `{:error, message}` if the given string is not a UUID representation
  in a format like:

   * `"870df8e8-3107-4487-8316-81e089b8c2cf"`
   * `"8ea1513df8a14dea9bea6b8f4b5b6e73"`
   * `"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"`

  ## Examples

      iex> UUID.Info.new("870df8e8-3107-4487-8316-81e089b8c2cf")
      {:ok, %UUID.Info{
        uuid: "870df8e8-3107-4487-8316-81e089b8c2cf",
        binary: <<135, 13, 248, 232, 49, 7, 68, 135, 131, 22, 129, 224, 137, 184, 194, 207>>,
        type: :default,
        version: 4,
        variant: :rfc4122
      }}

      iex> UUID.Info.new("8ea1513df8a14dea9bea6b8f4b5b6e73")
      {:ok, %UUID.Info{
        uuid: "8ea1513df8a14dea9bea6b8f4b5b6e73",
        binary: <<142, 161, 81, 61, 248, 161, 77, 234, 155,
                    234, 107, 143, 75, 91, 110, 115>>,
        type: :hex,
        version: 4,
        variant: :rfc4122
      }}

      iex> UUID.Info.new("urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304")
      {:ok, %UUID.Info{
        uuid: "urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304",
        binary: <<239, 27, 26, 40, 238, 52, 17, 227, 136, 19, 20, 16, 159, 241, 163, 4>>,
        type: :urn,
        version: 1,
        variant: :rfc4122
      }}

      iex> UUID.Info.new(<<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>)
      {:ok, %UUID.Info{
        uuid: <<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>,
        binary: <<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>,
        type: :raw,
        version: 4,
        variant: :rfc4122
      }}

      iex> UUID.Info.new("12345")
      {:error, "Invalid argument; Not a valid UUID: 12345"}

  """
  @spec new(binary) :: {:ok, t} | {:error, String.t()}
  def new(uuid) do
    try do
      {:ok, new!(uuid)}
    rescue
      e in ArgumentError -> {:error, e.message}
    end
  end

  @doc """
  Inspect a UUID and return information about its 128-bit binary content, type,
  version and variant.

  Timestamp portion is not checked to see if it's in the future, and therefore
  not yet assignable. See "Validation mechanism" in section 3 of
  [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).

  Will raise an `ArgumentError` if the given string is not a UUID representation
  in a format like:

   * `"870df8e8-3107-4487-8316-81e089b8c2cf"`
   * `"8ea1513df8a14dea9bea6b8f4b5b6e73"`
   * `"urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304"`

  ## Examples

      iex> UUID.Info.new!("870df8e8-3107-4487-8316-81e089b8c2cf")
      %UUID.Info{
        uuid: "870df8e8-3107-4487-8316-81e089b8c2cf",
        binary: <<135, 13, 248, 232, 49, 7, 68, 135, 131, 22, 129, 224, 137, 184, 194, 207>>,
        type: :default,
        version: 4,
        variant: :rfc4122
      }

      iex> UUID.Info.new!("8ea1513df8a14dea9bea6b8f4b5b6e73")
      %UUID.Info{
        uuid: "8ea1513df8a14dea9bea6b8f4b5b6e73",
        binary: <<142, 161, 81, 61, 248, 161, 77, 234, 155, 234, 107, 143, 75, 91, 110, 115>>,
        type: :hex,
        version: 4,
        variant: :rfc4122
      }

      iex> UUID.Info.new!("urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304")
      %UUID.Info{
        uuid: "urn:uuid:ef1b1a28-ee34-11e3-8813-14109ff1a304",
        binary: <<239, 27, 26, 40, 238, 52, 17, 227, 136, 19, 20, 16, 159, 241, 163, 4>>,
        type: :urn,
        version: 1,
        variant: :rfc4122
      }

      iex> UUID.Info.new!(<<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>)
      %UUID.Info{
        uuid: <<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>,
        binary: <<39, 73, 196, 181, 29, 90, 74, 96, 157, 47, 171, 144, 84, 164, 155, 52>>,
        type: :raw,
        version: 4,
        variant: :rfc4122
      }

      iex> UUID.Info.new!("foobar")
      ** (ArgumentError) Invalid argument; Not a valid UUID: foobar

  """
  @spec new!(binary) :: t
  def new!(<<uuid::binary>> = uuid_string) do
    {type, <<uuid::128>>} = UUID.uuid_string_to_hex_pair(uuid)

    <<_::48, version::4, _::12, v0::1, v1::1, v2::1, _::61>> = <<uuid::128>>

    %Info{
      uuid: uuid_string,
      binary: <<uuid::128>>,
      type: type,
      version: version,
      variant: variant(<<v0, v1, v2>>)
    }
  end

  def new!(_) do
    raise ArgumentError, message: "Invalid argument; Expected: String"
  end

  @doc """
  Identify the UUID variant according to section 4.1.1 of RFC 4122.

  ## Examples

      iex> UUID.Info.variant(<<1, 1, 1>>)
      :reserved_future

      iex> UUID.Info.variant(<<1, 1, 0>>)
      :reserved_microsoft

      iex> UUID.Info.variant(<<1, 0, 0>>)
      :rfc4122

      iex> UUID.Info.variant(<<0, 1, 1>>)
      :reserved_ncs

      iex> UUID.Info.variant(<<1>>)
      ** (ArgumentError) Invalid argument; Not valid variant bits

  """
  @spec variant(binary) :: variant
  def variant(<<1, 1, 1>>), do: :reserved_future
  def variant(<<1, 1, _v>>), do: :reserved_microsoft
  def variant(<<1, 0, _v>>), do: :rfc4122
  def variant(<<0, _v::2-binary>>), do: :reserved_ncs
  def variant(_), do: raise(ArgumentError, message: "Invalid argument; Not valid variant bits")
end
