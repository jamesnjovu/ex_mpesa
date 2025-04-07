defmodule ElixirMpesaTest do
  use ExUnit.Case
  doctest ElixirMpesa

  test "encrypt_api_key returns a tuple with ok atom" do
    # Mock the public key and api_key for testing
    :meck.new(Application, [:passthrough])
    :meck.expect(Application, :get_env, fn
      :elixir_mpesa, :public_key -> "MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEArv9yxA69XQKBo24BaF/D+fvlqmGdYjqLQ5WtNBb5tquqGvAvG3WMFETVUSow/LizQalxj2gsqGHkCFsKIj82A9X3Ux1XYe4p5Qk8Ugj0SIipaYea3cunFhbN6QhzaBNheVtIaS47XrsBm6i1sj6fS6/2uHvnEZY8U9NLDgEj7KxzwXxGNfQaLEV0ZNBR6EwHu+LHAGS3pQn4mLpNS1IyGM4i3nQw4DN09mKh7hF5gQchFk/Khny7yNqzg1OFdLQTxGiWjPRCxXqfl79gqSFNvB149qvNR9MWaJOytCY9T4KUScORQIxfGg9ry18Q5PGRwB39aOJPupXHpkC4HaCSA1L2xw4S312vP0rTmOTQpmCpLqPwJRU7JqQsq8VVo07E7rNoHYwK6Hk2jyM1SKvUJHJnSeSOpD3ZFSmUvQPbOQEfkTRwzR2B0dIdrtCqJukRZ2RuzqGnI8Dd6u4C6nHNjIjlu0QDM28XBmFfx0NLDFJr+QunqQlwx0q7E4RlMwfZXUu3wj5A1gGQ4Jz5ILbPnRV4IH f1MnTQ7kIpQP48ZnvMTQ/NeEsyePjHBLQc8qK6q5tFn6RqFF6KOaRKGMgj3P6fGqZQzaQU/YZATu2Z5nVkY5plkQtxmXcJ38d+Kq5WM6rNKHC/L7eMQix/CzMJXkIYXRqA2EFG6CboVV7sCAwEAAQ=="
      :elixir_mpesa, :api_key -> "test_api_key"
      :elixir_mpesa, :api_type -> "sandbox"
      :elixir_mpesa, :url_context -> "vodacomLES"
      _, _ -> nil
    end)

    # Mock the encrypt function to return a predetermined value
    :meck.new(:public_key, [:passthrough])
    :meck.expect(:public_key, :der_decode, fn _, _ -> {:"SubjectPublicKeyInfo", [], <<1, 2, 3>>} end)
    :meck.expect(:public_key, :der_decode, fn :RSAPublicKey, _ -> {:"RSAPublicKey", 1, 2} end)
    :meck.expect(:public_key, :encrypt_public, fn _, _, _ -> "encrypted" end)

    # Test the function
    assert {:ok, _} = ElixirMpesa.encrypt_api_key()

    # Clean up mocks
    :meck.unload(Application)
    :meck.unload(:public_key)
  end

end
