# ExMpesa

[![Hex.pm](https://img.shields.io/hexpm/v/ex_mpesa.svg)](https://hex.pm/packages/ex_mpesa)
[![Hex.pm](https://img.shields.io/hexpm/dt/ex_mpesa.svg)](https://hex.pm/packages/ex_mpesa)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_mpesa.svg)](https://hex.pm/packages/ex_mpesa)

An Elixir library for integrating with the Vodacom M-Pesa OpenAPI. This package provides a simple and elegant way to integrate M-Pesa payment services into your Elixir applications.

## Features

- Session key generation and management
- Customer to Business (C2B) payments
- Business to Customer (B2C) payments
- Business to Business (B2B) payments
- Transaction status queries
- Direct debit operations
- Beneficiary name queries

## Installation

Add `ex_mpesa` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_mpesa, "~> 0.1.0"}
  ]
end
```

## Configuration

Add the following configuration to your `config/config.exs` file:

```elixir
config :ex_mpesa,
  api_type: "sandbox", # or "openapi" for production
  input_currency: "LSL", # Currency code (e.g., "LSL" for Lesotho Loti)
  input_country: "LES", # Country code
  url_context: "vodacomLES", # API context (country-specific)
  api_key: "your_api_key_here", # Your M-Pesa API key
  public_key: "your_public_key_here" # Your M-Pesa public key
```

## Usage

### Session Management

Before making any transaction requests, you need to generate a session key:

```elixir
# Encrypt your API key
{:ok, encrypted_api_key} = ExMpesa.encrypt_api_key()

# Generate a session key
{:ok, session_data} = ExMpesa.generate_session_key(encrypted_api_key)
session_key = session_data["output_SessionID"]

# Encrypt the session key for use in subsequent requests
{:ok, encrypted_session_key} = ExMpesa.encrypt_session_key(session_key)
```

### Customer to Business (C2B) Payment

```elixir
payment_data = %{
  "input_Amount" => 10.0,
  "input_Country" => "LES",
  "input_Currency" => "LSL",
  "input_CustomerMSISDN" => "26675000000", # Customer phone number
  "input_ServiceProviderCode" => "00000", # Your M-Pesa service provider code
  "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761", # Unique transaction ID
  "input_TransactionReference" => "T12344C", # Your transaction reference
  "input_PurchasedItemsDesc" => "Test purchase" # Description
}

{:ok, result} = ExMpesa.c2b_single_stage(payment_data, encrypted_session_key)
```

### Business to Customer (B2C) Payment

```elixir
payment_data = %{
  "input_Amount" => 10.0,
  "input_Country" => "LES",
  "input_Currency" => "LSL",
  "input_CustomerMSISDN" => "26675000000", # Recipient phone number
  "input_ServiceProviderCode" => "00000", # Your M-Pesa service provider code
  "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761", # Unique transaction ID
  "input_TransactionReference" => "T12344C", # Your transaction reference
  "input_PaymentItemsDesc" => "Salary payment" # Description
}

{:ok, result} = ExMpesa.b2c_single_stage(payment_data, encrypted_session_key)
```

### Query Transaction Status

```elixir
query_data = %{
  "input_QueryReference" => "T12344C", # Your original transaction reference
  "input_ServiceProviderCode" => "00000", # Your M-Pesa service provider code
  "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761", # Unique conversation ID
  "input_Country" => "LES"
}

{:ok, result} = ExMpesa.query_transaction_status(query_data, encrypted_session_key)
```

### Direct Debit Operations

#### Create Direct Debit

```elixir
direct_debit_data = %{
  "input_AgreedTC" => true,
  "input_Country" => "LES",
  "input_CustomerMSISDN" => "26675000000", # Customer phone number
  "input_ServiceProviderCode" => "00000", # Your M-Pesa service provider code
  "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761", # Unique conversation ID
  "input_ThirdPartyReference" => "3333" # Your reference
}

{:ok, result} = ExMpesa.direct_debit_creation(direct_debit_data, encrypted_session_key)
```

#### Process Direct Debit Payment

```elixir
payment_data = %{
  "input_Amount" => 10.0,
  "input_Country" => "LES",
  "input_Currency" => "LSL",
  "input_CustomerMSISDN" => "26675000000", # Customer phone number
  "input_ServiceProviderCode" => "00000", # Your M-Pesa service provider code
  "input_ThirdPartyConversationID" => "asv02e5958774f7ba228d83d0d689761", # Unique conversation ID
  "input_ThirdPartyReference" => "3333" # Your reference
}

{:ok, result} = ExMpesa.direct_debit_payment(payment_data, encrypted_session_key)
```

## Error Handling

All functions return tagged tuples in the format `{:ok, result}` or `{:error, reason}`:

```elixir
case ExMpesa.c2b_single_stage(payment_data, encrypted_session_key) do
  {:ok, result} ->
    # Handle successful transaction
    IO.inspect(result)
  
  {:error, reason} ->
    # Handle error
    IO.inspect(reason)
end
```

## Advanced Usage

### Passing Custom Options

All functions accept an optional keyword list of options that can override the default configuration:

```elixir
# Override default configuration for a single request
ExMpesa.c2b_single_stage(
  payment_data, 
  encrypted_session_key, 
  [api_type: "openapi", url_context: "vodacomTZN"]
)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.