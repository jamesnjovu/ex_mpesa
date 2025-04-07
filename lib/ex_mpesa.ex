defmodule ElixirMpesa do
  alias ElixirMpesa.{
    GenerateSessionKey,
    Transactions,
  }

  @moduledoc """
  ElixirMpesa is an Elixir library for integrating with Vodacom M-Pesa OpenAPI.

  This library provides functions to interact with various M-Pesa services including:
  - Session key generation and management
  - Customer to Business (C2B) payments
  - Business to Customer (B2C) payments
  - Business to Business (B2B) payments
  - Transaction status queries
  - Direct debit operations
  - Beneficiary name queries

  ## Configuration

  Add the following to your `config/config.exs`:

  ```elixir
  config :elixir_mpesa,
    api_type: "sandbox", # or "openapi" for production
    input_currency: "LSL", # Currency code (e.g., "LSL" for Lesotho Loti)
    input_country: "LES", # Country code
    url_context: "vodacomLES", # API context (country-specific)
    api_key: "your_api_key_here", # Your M-Pesa API key
    public_key: "your_public_key_here" # Your M-Pesa public key
  ```

  ## Basic Usage

  ```elixir
  # Encrypt your API key
  {:ok, encrypted_api_key} = ElixirMpesa.encrypt_api_key()

  # Generate a session key
  {:ok, session_data} = ElixirMpesa.generate_session_key(encrypted_api_key)
  session_key = session_data["output_SessionID"]

  # Encrypt the session key for use in subsequent requests
  {:ok, encrypted_session_key} = ElixirMpesa.encrypt_session_key(session_key)

  # Make a C2B payment
  payment_data = %{
    "input_Amount" => 10.0,
    "input_Country" => "LES",
    "input_Currency" => "LSL",
    "input_CustomerMSISDN" => "26675000000",
    "input_ServiceProviderCode" => "00000",
    "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
    "input_TransactionReference" => "T12344C",
    "input_PurchasedItemsDesc" => "Test purchase"
  }

  {:ok, result} = ElixirMpesa.c2b_single_stage(payment_data, encrypted_session_key)
  ```
  """

  @doc """
  Encrypts the API key using the configured public key.

  ## Options

  * `:public_key` - Override the configured public key
  * `:api_key` - Override the configured API key
  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Examples

      iex> ElixirMpesa.encrypt_api_key()
      {:ok, "encrypted_api_key_string"}

      iex> ElixirMpesa.encrypt_api_key([public_key: "custom_public_key", api_key: "custom_api_key"])
      {:ok, "encrypted_api_key_string"}

  """
  def encrypt_api_key(options \\ []), do: ElixirMpesa.GenerateSessionKey.encrypt_api_key(options)

  @doc """
  Generates a session key using the encrypted API key.

  ## Parameters

  * `encrypt_api_key` - The encrypted API key (optional)
  * `options` - Configuration options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Examples

      iex> {:ok, encrypted_api_key} = ElixirMpesa.encrypt_api_key()
      iex> ElixirMpesa.generate_session_key(encrypted_api_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", "output_SessionID" => "session_key_string"}}

      iex> ElixirMpesa.generate_session_key()  # Uses the default configured API key
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", "output_SessionID" => "session_key_string"}}

  """
  def generate_session_key(encrypt_api_key \\ nil, options \\ []), do: ElixirMpesa.GenerateSessionKey.generate_output_session_id(encrypt_api_key, options)

  @doc """
  Encrypts a session key using the configured public key.

  ## Parameters

  * `session_key` - The session key to encrypt
  * `options` - Configuration options (see below)

  ## Options

  * `:public_key` - Override the configured public key

  ## Examples

      iex> {:ok, session_result} = ElixirMpesa.generate_session_key()
      iex> session_key = session_result["output_SessionID"]
      iex> ElixirMpesa.encrypt_session_key(session_key)
      {:ok, "encrypted_session_key_string"}

  """
  def encrypt_session_key(session_key, options \\ []), do: ElixirMpesa.GenerateSessionKey.encrypt_session_id(session_key, options)

  @doc """
  Performs a Customer to Business (C2B) single-stage payment.

  ## Parameters

  * `body` - Map containing the transaction details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_TransactionReference"` - Your reference for this transaction
  * `"input_PurchasedItemsDesc"` - Description of the purchase

  ## Examples

      iex> payment_data = %{
      ...>   "input_Amount" => 10.0,
      ...>   "input_Country" => "LES",
      ...>   "input_Currency" => "LSL",
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_TransactionReference" => "T12344C",
      ...>   "input_PurchasedItemsDesc" => "Test purchase"
      ...> }
      iex> ElixirMpesa.c2b_single_stage(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def c2b_single_stage(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.c2b_single_stage(body, encrypted_session_key, options)

  @doc """
  Performs a Business to Customer (B2C) single-stage payment.

  ## Parameters

  * `body` - Map containing the transaction details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_CustomerMSISDN"` - The recipient's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_TransactionReference"` - Your reference for this transaction
  * `"input_PaymentItemsDesc"` - Description of the payment

  ## Examples

      iex> payment_data = %{
      ...>   "input_Amount" => 10.0,
      ...>   "input_Country" => "LES",
      ...>   "input_Currency" => "LSL",
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_TransactionReference" => "T12344C",
      ...>   "input_PaymentItemsDesc" => "Salary payment"
      ...> }
      iex> ElixirMpesa.b2c_single_stage(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def b2c_single_stage(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.b2c_single_stage(body, encrypted_session_key, options)

  @doc """
  Performs a Business to Business (B2B) single-stage payment.

  ## Parameters

  * `body` - Map containing the transaction details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_PrimaryPartyCode"` - The primary party code (your business)
  * `"input_ReceiverPartyCode"` - The receiver party code (recipient business)
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_TransactionReference"` - Your reference for this transaction
  * `"input_PurchasedItemsDesc"` - Description of the payment

  ## Examples

      iex> payment_data = %{
      ...>   "input_Amount" => 1000.0,
      ...>   "input_Country" => "LES",
      ...>   "input_Currency" => "LSL",
      ...>   "input_PrimaryPartyCode" => "12345",
      ...>   "input_ReceiverPartyCode" => "54321",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_TransactionReference" => "T12344C",
      ...>   "input_PurchasedItemsDesc" => "Invoice payment"
      ...> }
      iex> ElixirMpesa.b2b_single_stage(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def b2b_single_stage(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.b2b_single_stage(body, encrypted_session_key, options)

  @doc """
  Queries the status of a transaction.

  ## Parameters

  * `body` - Map containing the query details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_QueryReference"` - The original transaction reference
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this query
  * `"input_Country"` - The country code (e.g., "LES")

  ## Examples

      iex> query_data = %{
      ...>   "input_QueryReference" => "T12344C",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_Country" => "LES"
      ...> }
      iex> ElixirMpesa.query_transaction_status(query_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def query_transaction_status(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.query_status(body, encrypted_session_key, options)

  @doc """
  Creates a direct debit mandate.

  ## Parameters

  * `body` - Map containing the direct debit details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_AgreedTC"` - Whether the customer has agreed to terms and conditions (boolean)
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_ThirdPartyReference"` - Your reference for this mandate

  ## Examples

      iex> direct_debit_data = %{
      ...>   "input_AgreedTC" => true,
      ...>   "input_Country" => "LES",
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ElixirMpesa.direct_debit_creation(direct_debit_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def direct_debit_creation(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.direct_debit_creation(body, encrypted_session_key, options)

  @doc """
  Processes a direct debit payment.

  ## Parameters

  * `body` - Map containing the payment details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_ThirdPartyReference"` - Your reference for this payment

  ## Examples

      iex> payment_data = %{
      ...>   "input_Amount" => 10.0,
      ...>   "input_Country" => "LES",
      ...>   "input_Currency" => "LSL",
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ElixirMpesa.direct_debit_payment(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def direct_debit_payment(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.direct_debit_payment(body, encrypted_session_key, options)

  @doc """
  Queries a beneficiary's name based on their mobile number.

  ## Parameters

  * `body` - Map containing the query details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this query

  ## Examples

      iex> query_data = %{
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761"
      ...> }
      iex> ElixirMpesa.query_beneficiary_name(query_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", "output_CustomerFirstName" => "John", "output_CustomerLastName" => "Doe"}}

  """
  def query_beneficiary_name(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.query_beneficiary_name(body, encrypted_session_key, options)

  @doc """
  Queries the status of a direct debit mandate.

  ## Parameters

  * `body` - Map containing the query details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this query
  * `"input_ThirdPartyReference"` - The original mandate reference

  ## Examples

      iex> query_data = %{
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ElixirMpesa.query_direct_debit(query_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def query_direct_debit(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.query_direct_debit(body, encrypted_session_key, options)

  @doc """
  Cancels a direct debit mandate.

  ## Parameters

  * `body` - Map containing the cancellation details
  * `encrypted_session_key` - The encrypted session key
  * `options` - Configuration options

  ## Body Parameters

  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this cancellation
  * `"input_ThirdPartyReference"` - The original mandate reference

  ## Examples

      iex> cancel_data = %{
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ElixirMpesa.direct_debit_cancel(cancel_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def direct_debit_cancel(body, encrypted_session_key, options \\ []), do: ElixirMpesa.Transactions.direct_debit_cancel(body, encrypted_session_key, options)

end
