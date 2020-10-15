Benchee.run(%{
  "uuid1" => fn ->
    UUID.uuid1()
  end,
  "uuid3 dns" => fn ->
    UUID.uuid3(:dns, "test.example.com")
  end,
  "uuid4" => fn ->
    UUID.uuid4()
  end,
  "uuid5 dns" => fn ->
    UUID.uuid5(:dns, "test.example.com")
  end,
  "uuid6 mac_address" => fn ->
    UUID.uuid6(:mac_address)
  end,
  "uuid6 random_bytes" => fn ->
    UUID.uuid6(:random_bytes)
  end
})
