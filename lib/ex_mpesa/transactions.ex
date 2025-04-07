defmodule ExMpesa.Transactions do
  alias ExMpesa.HttpRequest

  @moduledoc """
  Handles transaction operations for the M-Pesa OpenAPI.

  This module provides functions for various M-Pesa transaction types, including:
  - Customer to Business (C2B) payments
  - Business to Customer (B2C) payments
  - Business to Business (B2B) payments
  - Transaction status queries
  - Direct debit operations
  - Beneficiary name queries

  All functions require an encrypted session key that must be generated first using
  the `ExMpesa.GenerateSessionKey` module.

  ## Example Usage

      # First, encrypt the API key and get a session key
      {:ok, encrypted_api_key} = ExMpesa.encrypt_api_key()
      {:ok, session_data} = ExMpesa.generate_session_key(encrypted_api_key)
      session_key = session_data["output_SessionID"]
      {:ok, encrypted_session_key} = ExMpesa.encrypt_session_key(session_key)

      # Then, perform a C2B transaction
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

      {:ok, result} = ExMpesa.Transactions.c2b_single_stage(payment_data, encrypted_session_key)
  """

  @doc """
  Performs a Customer to Business (C2B) single-stage payment.

  This function allows customers to pay businesses for goods or services.

  ## Parameters

  * `attrs` - Map containing the transaction details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_TransactionReference"` - Your reference for this transaction
  * `"input_PurchasedItemsDesc"` - Description of the purchase

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

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
      iex> ExMpesa.Transactions.c2b_single_stage(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def c2b_single_stage(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/c2bPayment/singleStage/"
    |> send_post(attrs, encrypt_api_key)
  end

  @doc """
  Performs a Business to Customer (B2C) single-stage payment.

  This function allows businesses to pay customers, such as for disbursements,
  refunds, or salary payments.

  ## Parameters

  * `attrs` - Map containing the transaction details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_CustomerMSISDN"` - The recipient's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_TransactionReference"` - Your reference for this transaction
  * `"input_PaymentItemsDesc"` - Description of the payment

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

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
      iex> ExMpesa.Transactions.b2c_single_stage(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def b2c_single_stage(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/b2cPayment/"
    |> send_post(attrs, encrypt_api_key)
  end

  @doc """
  Performs a Business to Business (B2B) single-stage payment.

  This function allows businesses to pay other businesses.

  ## Parameters

  * `attrs` - Map containing the transaction details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_PrimaryPartyCode"` - The primary party code (your business)
  * `"input_ReceiverPartyCode"` - The receiver party code (recipient business)
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_TransactionReference"` - Your reference for this transaction
  * `"input_PurchasedItemsDesc"` - Description of the payment

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

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
      iex> ExMpesa.Transactions.b2b_single_stage(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def b2b_single_stage(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/b2bPayment/"
    |> send_post(attrs, encrypt_api_key)
  end

  @doc """
  Queries the status of a transaction.

  ## Parameters

  * `attrs` - Map containing the query details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_QueryReference"` - The original transaction reference
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this query
  * `"input_Country"` - The country code (e.g., "LES")

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> query_data = %{
      ...>   "input_QueryReference" => "T12344C",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_Country" => "LES"
      ...> }
      iex> ExMpesa.Transactions.query_status(query_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def query_status(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/queryTransactionStatus/"
    |> send_get(attrs, encrypt_api_key)
  end

  @doc """
  Reverses a transaction.

  ## Parameters

  * `attrs` - Map containing the reversal details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_ReversalAmount"` - The amount to reverse
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this reversal
  * `"input_TransactionID"` - The original transaction ID

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> reversal_data = %{
      ...>   "input_ReversalAmount" => 10.0,
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_TransactionID" => "12345678"
      ...> }
      iex> ExMpesa.Transactions.reversal(reversal_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def reversal(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/reversal/"
    |> send_put(attrs, encrypt_api_key)
  end

  @doc """
  Creates a direct debit mandate.

  ## Parameters

  * `attrs` - Map containing the direct debit details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_AgreedTC"` - Whether the customer has agreed to terms and conditions (boolean)
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_ThirdPartyReference"` - Your reference for this mandate

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> direct_debit_data = %{
      ...>   "input_AgreedTC" => true,
      ...>   "input_Country" => "LES",
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ExMpesa.Transactions.direct_debit_creation(direct_debit_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def direct_debit_creation(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/directDebitCreation/"
    |> send_post(attrs, encrypt_api_key)
  end

  @doc """
  Processes a direct debit payment.

  ## Parameters

  * `attrs` - Map containing the payment details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_Amount"` - The transaction amount
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_Currency"` - The currency code (e.g., "LSL")
  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this transaction
  * `"input_ThirdPartyReference"` - Your reference for this payment

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

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
      iex> ExMpesa.Transactions.direct_debit_payment(payment_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def direct_debit_payment(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/directDebitPayment/"
    |> send_post(attrs, encrypt_api_key)
  end

  @doc """
  Queries a beneficiary's name based on their mobile number.

  ## Parameters

  * `attrs` - Map containing the query details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this query

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> query_data = %{
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761"
      ...> }
      iex> ExMpesa.Transactions.query_beneficiary_name(query_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", "output_CustomerFirstName" => "John", "output_CustomerLastName" => "Doe"}}

  """
  def query_beneficiary_name(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/queryBeneficiaryName/"
    |> send_get(attrs, encrypt_api_key)
  end

  @doc """
  Queries the status of a direct debit mandate.

  ## Parameters

  * `attrs` - Map containing the query details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this query
  * `"input_ThirdPartyReference"` - The original mandate reference

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> query_data = %{
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ExMpesa.Transactions.query_direct_debit(query_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def query_direct_debit(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/queryDirectDebit/"
    |> send_get(attrs, encrypt_api_key)
  end

  @doc """
  Cancels a direct debit mandate.

  ## Parameters

  * `attrs` - Map containing the cancellation details
  * `encrypt_api_key` - The encrypted session key
  * `options` - A keyword list of options (see below)

  ## Options

  * `:api_type` - Override the configured API type ("sandbox" or "openapi")
  * `:url_context` - Override the configured URL context

  ## Required Attributes

  * `"input_CustomerMSISDN"` - The customer's phone number
  * `"input_Country"` - The country code (e.g., "LES")
  * `"input_ServiceProviderCode"` - The service provider code
  * `"input_ThirdPartyConversationID"` - A unique ID for this cancellation
  * `"input_ThirdPartyReference"` - The original mandate reference

  ## Returns

  * `{:ok, response}` - The API response on success
  * `{:error, reason}` - If the API call fails

  ## Examples

      iex> cancel_data = %{
      ...>   "input_CustomerMSISDN" => "26675000000",
      ...>   "input_Country" => "LES",
      ...>   "input_ServiceProviderCode" => "00000",
      ...>   "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761",
      ...>   "input_ThirdPartyReference" => "3333"
      ...> }
      iex> ExMpesa.Transactions.direct_debit_cancel(cancel_data, encrypted_session_key)
      {:ok, %{"output_ResponseCode" => "INS-0", "output_ResponseDesc" => "Request processed successfully", ...}}

  """
  def direct_debit_cancel(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/directDebitCancel/"
    |> send_put(attrs, encrypt_api_key)
  end

  @doc false
  defp extract_options(options \\ []) do
    api_type = Keyword.get(options, :api_type, Application.get_env(:ex_mpesa, :api_type))
    url_context = Keyword.get(options, :url_context, Application.get_env(:ex_mpesa, :url_context))

    {api_type, url_context}
  end

  @doc false
  defp send_get(url, attrs, encrypt_api_key) do
    HttpRequest.get(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  @doc false
  defp send_post(url, attrs, encrypt_api_key) do
    HttpRequest.post(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  @doc false
  defp send_put(url, attrs, encrypt_api_key) do
    HttpRequest.put(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end
end
