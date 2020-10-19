defmodule TestUUID1 do
  use UUID.Ecto.Type,
    type: :uuid1
end

defmodule TestUUID3 do
  use UUID.Ecto.Type,
    type: :uuid3,
    namespace: :dns,
    name: "mydomain.com"
end

defmodule TestApp1UUID3 do
  use UUID.Ecto.Type,
    otp_app: :uuid_utils,
    type: :uuid3,
    name: "mydomain.com"
end

defmodule TestApp2UUID3 do
  use UUID.Ecto.Type, otp_app: :uuid_utils
end

defmodule TestUUID4 do
  use UUID.Ecto.Type,
    type: :uuid4
end

defmodule TestUUID5 do
  use UUID.Ecto.Type,
    type: :uuid5,
    namespace: :dns,
    name: "mydomain.com"
end

defmodule TestUUID6 do
  use UUID.Ecto.Type,
    type: :uuid6,
    node_type: :random_bytes
end
