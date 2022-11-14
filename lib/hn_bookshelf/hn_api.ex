defmodule HnBookshelf.HnApi do
  def get_item(item_id) when is_integer(item_id) do
    id_as_string = Integer.to_string(item_id)

    with {:ok, body} <- get(endpoint() <> "/items/#{id_as_string}"),
         {:ok, item_map} <- Jason.decode(body, keys: :atoms) do
      {:ok, item_map}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get(url, headers \\ [], http_opts \\ []) do
    case request(:get, url, "", headers, http_opts) do
      {:ok, {{_protocol, 200, _status_message}, _headers, body}} ->
        {:ok, body}

      {:ok, {{_p, status, _msg}, _headers, body}} when status != 200 ->
        {:error, "non 200 status, body: #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp request(http_method, url, req_body, headers, http_opts) do
    case http_method do
      http_method when http_method in [:get, :delete] ->
        :httpc.request(
          http_method,
          {url, headers},
          http_opts[:ssl_config] || [],
          []
        )

      http_method when http_method in [:post, :put] ->
        :httpc.request(
          http_method,
          {url, headers, 'application/json', req_body},
          http_opts[:ssl_config] || [],
          []
        )

      http_method ->
        {:error, "Unsupported HTTP Method: #{inspect(http_method)}"}
    end
  end

  def endpoint() do
    Application.get_env(:hn_bookshelf, :hn_api_endpoint)
  end
end
