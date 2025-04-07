defmodule ExMpesa.Transactions do
  alias ExMpesa.HttpRequest

  def c2b_single_stage(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/c2bPayment/singleStage/"
    |> send_post(attrs, encrypt_api_key)
  end

  def b2c_single_stage(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/b2cPayment/"
    |> send_post(attrs, encrypt_api_key)
  end

  def b2b_single_stage(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/b2bPayment/"
    |> send_post(attrs, encrypt_api_key)
  end

  def query_status(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/queryTransactionStatus/"
    |> send_get(attrs, encrypt_api_key)
  end

  def reversal(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/reversal/"
    |> send_put(attrs, encrypt_api_key)
  end

  def direct_debit_creation(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/directDebitCreation/"
    |> send_post(attrs, encrypt_api_key)
  end

  def direct_debit_payment(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/directDebitPayment/"
    |> send_post(attrs, encrypt_api_key)
  end

  def query_beneficiary_name(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/queryBeneficiaryName/"
    |> send_get(attrs, encrypt_api_key)
  end

  def query_direct_debit(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/queryDirectDebit/"
    |> send_get(attrs, encrypt_api_key)
  end

  def direct_debit_cancel(attrs, encrypt_api_key, options \\ []) do
    {api_type, url_context} = extract_options(options)

    "https://openapi.m-pesa.com/#{api_type}/ipg/v2/#{url_context}/directDebitCancel/"
    |> send_put(attrs, encrypt_api_key)
  end

  defp extract_options(options \\ []) do
    api_type = Keyword.get(options, :api_type, Application.get_env(:ex_mpesa, :api_type))
    url_context = Keyword.get(options, :url_context, Application.get_env(:ex_mpesa, :url_context))

    {api_type, url_context}
  end

  defp send_get(url, attrs, encrypt_api_key) do
    HttpRequest.get(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  defp send_post(url, attrs, encrypt_api_key) do
    HttpRequest.post(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end

  defp send_put(url, attrs, encrypt_api_key) do
    HttpRequest.put(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end
end
