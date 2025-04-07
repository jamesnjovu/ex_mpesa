defmodule ExMpesa.HttpRequest do
  @moduledoc false
  @doc """
  Handles HTTP requests to the M-Pesa API.

  This module provides helper functions for making HTTP requests and handling
  responses from the M-Pesa API. It abstracts the details of the HTTP communication
  and provides consistent error handling.

  This module is for internal use and is not meant to be used directly by users of the library.
  """

  @options [
    timeout: 500_000,
    recv_timeout: 500_000,
    hackney: [:insecure]
  ]

  @doc """
  Constructs HTTP headers for M-Pesa API requests.

  ## Parameters

  * `key` - The encrypted API key or session key

  ## Returns

  * List of HTTP headers

  ## Examples

      iex> ExMpesa.HttpRequest.header("encrypted_session_key")
      [
        {"Content-Type", "application/json"},
        {"Origin", "*"},
        {"Authorization", "Bearer encrypted_session_key"}
      ]

  """
  def header(key),
    do: [
      {"Content-Type", "application/json"},
      {"Origin", "*"},
      {"Authorization", "Bearer #{key}"},
    ]

  @doc """
  Sends an HTTP POST request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `body` - The request body as a map (will be JSON encoded)
  * `headers` - HTTP headers list

  ## Returns

  * `{:ok, %HTTPoison.Response{}}` - The HTTP response
  * `{:error, reason}` - If the HTTP request fails

  """
  def post(url, body, headers \\ []),
    do: HTTPoison.post(url, Jason.encode!(body), headers, @options)

  @doc """
  Sends an HTTP PUT request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `body` - The request body as a map (will be JSON encoded)
  * `headers` - HTTP headers list

  ## Returns

  * `{:ok, %HTTPoison.Response{}}` - The HTTP response
  * `{:error, reason}` - If the HTTP request fails

  """
  def put(url, body, headers \\ []),
    do: HTTPoison.put(url, Jason.encode!(body), headers, @options)

  @doc """
  Sends an HTTP GET request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `attrs` - Query parameters as a map
  * `headers` - HTTP headers list

  ## Returns

  * `{:ok, %HTTPoison.Response{}}` - The HTTP response
  * `{:error, reason}` - If the HTTP request fails

  """
  def get(url, attrs \\ %{}, headers \\ []),
    do: (if Enum.empty?(attrs),
          do: HTTPoison.get(url, headers, @options),
          else: HTTPoison.get("#{url}?#{URI.encode_query(attrs)}", headers, @options))

  @doc """
  Handles HTTP responses from the M-Pesa API.

  This function processes the HTTP response and returns a standardized result.

  ## Parameters

  * `{:ok, %HTTPoison.Response{}}` - The HTTP response from HTTPoison
  * `{:error, %HTTPoison.Error{}}` - An error from HTTPoison

  ## Returns

  * `{:ok, parsed_body}` - For successful responses (status 200, 201)
  * `{:error, parsed_body}` - For error responses or HTTP errors

  """
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 201, body: body}}), do: {:ok, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 400, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 405, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 408, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 409, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 503, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:error, %HTTPoison.Error{reason: message}}), do: {:error, %{"output_error" => message}}

end
