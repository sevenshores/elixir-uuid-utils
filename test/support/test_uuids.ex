defmodule UUID.TestUUID1 do
  use UUID.Ecto.Type,
    type: :uuid1
end

defmodule UUID.TestUUID3 do
  use UUID.Ecto.Type,
    type: :uuid3,
    namespace: :dns,
    name: "mydomain.com"
end

defmodule UUID.TestUUID4 do
  use UUID.Ecto.Type,
    type: :uuid4
end

defmodule UUID.TestUUID5 do
  use UUID.Ecto.Type,
    type: :uuid5,
    namespace: :dns,
    name: "mydomain.com"
end

defmodule UUID.TestUUID6 do
  use UUID.Ecto.Type,
    type: :uuid6,
    node_type: :random_bytes
end
