defmodule ExMpesa do
  alias ExMpesa.{
    GenerateSessionKey,
    Transactions,
  }

  @moduledoc """
  Documentation for `ExMpesa`.
  """

  def encrypt_api_key(options \\ []), do: ExMpesa.GenerateSessionKey.encrypt_api_key(options)

  def generate_session_key(encrypt_api_key \\ nil, options \\ []), do: ExMpesa.GenerateSessionKey.generate_output_session_id(encrypt_api_key, options)

  def encrypt_session_key(session_key, options \\ []), do: ExMpesa.GenerateSessionKey.encrypt_session_id(session_key, options)

  def c2b_single_stage(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.c2b_single_stage(body, encrypted_session_key, options)

  def b2c_single_stage(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.b2c_single_stage(body, encrypted_session_key, options)

  def b2b_single_stage(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.b2b_single_stage(body, encrypted_session_key, options)

  def query_transaction_status(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.query_status(body, encrypted_session_key, options)

  def direct_debit_creation(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.direct_debit_creation(body, encrypted_session_key, options)

  def direct_debit_payment(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.direct_debit_payment(body, encrypted_session_key, options)

  def query_beneficiary_name(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.query_beneficiary_name(body, encrypted_session_key, options)

  def query_direct_debit(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.query_direct_debit(body, encrypted_session_key, options)

  def direct_debit_cancel(body, encrypted_session_key, options \\ []), do: ExMpesa.Transactions.direct_debit_cancel(body, encrypted_session_key, options)

end
