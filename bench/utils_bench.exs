uuid_string = "716c654f-d2b7-436b-9751-2440a9cb079d"
uuid_binary = <<113, 108, 101, 79, 210, 183, 67, 107, 151, 81, 36, 64, 169, 203, 7, 157>>

Benchee.run(%{
  "info!" => fn ->
    UUID.info!(uuid_string)
  end,
  "binary_to_string!" => fn ->
    UUID.binary_to_string!(uuid_binary)
  end,
  "string_to_binary!" => fn ->
    UUID.string_to_binary!(uuid_string)
  end
})
