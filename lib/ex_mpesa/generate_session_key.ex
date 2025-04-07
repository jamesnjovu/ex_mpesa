defmodule ElixirMpesa.GenerateSessionKey do
  alias ElixirMpesa.HttpRequest

  @moduledoc """
  Handles the session key generation and management for M-Pesa OpenAPI.

  Before integrating with the M-Pesa OpenAPI solution, you must exchange your
  Application Key for a Session Key. The API Key is created with the creation of a new application.
  The Session Key acts as an access token that authorizes the rest of your REST API calls to the system.
  A valid Session Key is needed to transact on M-Pesa using OpenAPI.

  ## Process Flow

  1. Encrypt API key using the public key provided by M-Pesa
  2. Send the encrypted API key to the Session API endpoint
  3. Receive a session key in response
  4. Encrypt the session key for use in subsequent API calls

  ## Example

      # Encrypt the API key
      {:ok, encrypted_api_key} = ElixirMpesa.GenerateSessionKey.encrypt_api_key()

      # Generate a session ID using the encrypted API key
      {:ok, session_data} = ElixirMpesa.GenerateSessionKey.generate_output_session_id(encrypted_api_key)
      session_key = session_data["output_SessionID"]

      # Encrypt the session key for use in transactions
      {:ok, encrypted_session_key} = ElixirMpesa.GenerateSessionKey.encrypt_session_id(session_key)

  """

  @doc """
  Encrypts the API key using the configured public key.

  This function takes the API key and encrypts it using the RSA public key provided by M-Pesa.
  The encrypted API key is then used to obtain a session key.

  ## Options

  * `:public_key` - Override the configured public key
  * `:api_key` - Override the configured API key
  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Returns

  * `{:ok, encrypted_api_key}` - The successfully encrypted API key
  * `{:error, reason}` - If encryption fails

  ## Examples

      iex> ElixirMpesa.GenerateSessionKey.encrypt_api_key()
      {:ok, "encrypted_api_key_string"}

      iex> ElixirMpesa.GenerateSessionKey.encrypt_api_key([public_key: "custom_public_key"])
      {:ok, "encrypted_api_key_string"}

  """
  def encrypt_api_key(options \\ []) do
    {public_key, api_key, _api_type, _url_context} = extract_options(options)
    encrypt(public_key, api_key)
  end

  @doc """
  Encrypts a session ID using the configured public key.

  After obtaining a session ID from the M-Pesa API, it needs to be encrypted
  before it can be used in subsequent API calls.

  ## Parameters

  * `session_id` - The session ID to encrypt
  * `options` - A keyword list of options (see below)

  ## Options

  * `:public_key` - Override the configured public key

  ## Returns

  * `{:ok, encrypted_session_id}` - The successfully encrypted session ID
  * `{:error, reason}` - If encryption fails

  ## Examples

      iex> ElixirMpesa.GenerateSessionKey.encrypt_session_id("session_id_string")
      {:ok, "encrypted_session_id_string"}

  """
  def encrypt_session_id(session_id, options \\ []) do
    {public_key, _api_key, _api_type, _url_context} = extract_options(options)
    encrypt(public_key, session_id)
  end

  @doc """
  Generates a session ID by sending the encrypted API key to the M-Pesa API.

  ## Parameters

  * `encrypted_api_key` - The encrypted API key (optional, will use the configured key if nil)
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Returns

  * `{:ok, response}` - The API response containing the session ID
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> {:ok, encrypted_key} = ElixirMpesa.GenerateSessionKey.encrypt_api_key()
      iex> ElixirMpesa.GenerateSessionKey.generate_output_session_id(encrypted_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", "output_SessionID" => "session_id_string"}}

  """
  def generate_output_session_id(encrypted_api_key, options \\ []) do
    {_public_key, _api_key, api_type, url_context} = extract_options(options)
    auth(api_type, url_context, encrypted_api_key || encrypt_api_key())
  end

  @doc false
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

  @doc false
  defp auth(context, url_context, {:ok, encrypt_api_key}) do
    uri = "https://openapi.m-pesa.com/#{context}/ipg/v2/#{url_context}/getSession/"
    HttpRequest.get(uri, %{}, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  @doc false
  defp auth(_context, _url_context, {:error, message}), do: {:error, message}

  @doc false
  defp auth(context, url_context, encrypt_api_key) do
    uri = "https://openapi.m-pesa.com/#{context}/ipg/v2/#{url_context}/getSession/"
    HttpRequest.get(uri, %{}, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  @doc false
  defp extract_options(options \\ []) do
    public_key = Keyword.get(options, :public_key, Application.get_env(:elixir_mpesa, :public_key))
    api_key = Keyword.get(options, :api_key, Application.get_env(:elixir_mpesa, :api_key))
    api_type = Keyword.get(options, :api_type, Application.get_env(:elixir_mpesa, :api_type))
    url_context = Keyword.get(options, :url_context, Application.get_env(:elixir_mpesa, :url_context))

    {public_key, api_key, api_type, url_context}
  end
end
