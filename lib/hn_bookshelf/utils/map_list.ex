defmodule HnBookshelf.Utils.MapList do
  @doc """
  This is a hash map implementation where items of duplicate key are inserted as
  a list rather than replacing the new element

  ### Examples

    iex> m  = %{}
    iex> MapList.put(m, :hello, "there")
    iex> MapList.put(m, :hello, "you")
    iex> m
    %{:hello => ["there", "you"]}
  """

  def put(m, k, v) when is_map(m) do
    case Map.fetch(m, k) do
      {:ok, value_list} ->
        Map.put(m, k, [v | value_list])

      :error ->
        Map.put(m, k, [v])
    end
  end
end
