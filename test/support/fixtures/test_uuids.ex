defmodule TestUUID1 do
  use UUID.Ecto.Type,
    otp_app: :uuid,
    type: :uuid1
end

defmodule TestUUID3 do
  use UUID.Ecto.Type,
    otp_app: :uuid,
    type: :uuid3,
    args: [:dns, "mydomain.com"]
end

defmodule TestUUID4 do
  use UUID.Ecto.Type,
    otp_app: :uuid,
    type: :uuid4
end

defmodule TestUUID5 do
  use UUID.Ecto.Type,
    otp_app: :uuid,
    type: :uuid5,
    args: [:dns, "mydomain.com"]
end

defmodule TestUUID6 do
  use UUID.Ecto.Type,
    otp_app: :uuid,
    type: :uuid6,
    args: [:random_bytes]
end
