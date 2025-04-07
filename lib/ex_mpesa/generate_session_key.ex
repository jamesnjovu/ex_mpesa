defmodule ExMpesa.GenerateSessionKey do
  alias ExMpesa.HttpRequest

  @moduledoc """
  Before you can integrate on the M-Pesa OpenAPI solution, you must exchange your Application Key for a Session Key. The API Key is created with the creation of a new application. The Session Key acts as an access token that authorises the rest of your REST API calls to the system. A valid Session Key is needed to transact on M-Pesa using OpenAPI.
  """

  def encrypt_api_key(options \\ []) do
    {public_key, api_key, _api_type, _url_context} = extract_options(options)
    encrypt(public_key, api_key)
  end

  def encrypt_session_id(session_id, options \\ []) do
    {public_key, _api_key, _api_type, _url_context} = extract_options(options)
    encrypt(public_key, session_id)
  end

  def generate_output_session_id(encrypted_api_key, options \\ []) do
    {_public_key, _api_key, api_type, url_context} = extract_options(options)
    auth(api_type, url_context, encrypted_api_key || encrypt_api_key())
  end

  defp encrypt(public_key_b64, api_key) when is_binary(public_key_b64) and is_binary(api_key) do
    try do
      # Decode Base64 public key
      {:ok, key_der} = Base.decode64(public_key_b64)

      # Decode SubjectPublicKeyInfo (DER)
      {:SubjectPublicKeyInfo, _, rsa_key_bin} = :public_key.der_decode(:SubjectPublicKeyInfo, key_der)

      # Decode the raw RSA public key
      {:"RSAPublicKey", modulus, exponent} = :public_key.der_decode(:RSAPublicKey, rsa_key_bin)

      # Encrypt using :public_key.encrypt_public
      encrypted = :public_key.encrypt_public(api_key, {:"RSAPublicKey", modulus, exponent}, [:rsa_pkcs1_padding])

      {:ok, Base.encode64(encrypted)}
    rescue
      e in RuntimeError ->
        {:error, "Encryption failed: #{Exception.message(e)}"}

      e ->
        {:error, "Encryption failed: #{inspect(e)}"}
    end
  end

  defp auth(context, url_context, {:ok, encrypt_api_key}) do
    uri = "https://openapi.m-pesa.com/#{context}/ipg/v2/#{url_context}/getSession/"
    HttpRequest.get(uri, %{}, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  defp auth(_context, _url_context, {:error, message}), do: {:error, message}

  defp auth(context, url_context, encrypt_api_key) do
    uri = "https://openapi.m-pesa.com/#{context}/ipg/v2/#{url_context}/getSession/"
    HttpRequest.get(uri, %{}, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  defp extract_options(options \\ []) do
    public_key = Keyword.get(options, :public_key, Application.get_env(:ex_mpesa, :public_key))
    api_key = Keyword.get(options, :api_key, Application.get_env(:ex_mpesa, :api_key))
    api_type = Keyword.get(options, :api_type, Application.get_env(:ex_mpesa, :api_type))
    url_context = Keyword.get(options, :url_context, Application.get_env(:ex_mpesa, :url_context))

    {public_key, api_key, api_type, url_context}
  end
end
