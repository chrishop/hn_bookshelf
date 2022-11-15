defmodule Test.Support.Helper do
  import ExUnit.Callbacks, only: [on_exit: 1]

  def bypass_expect(bypass, opts) when is_list(opts) do
    resp_body =
      cond do
        opts[:resp_body] ->
          opts[:resp_body]

        opts[:resp_body_fixture] ->
          File.read!(File.cwd!() <> opts[:resp_body_fixture])

        true ->
          nil
      end

    Bypass.expect_once(bypass, opts[:method] || "GET", opts[:path], fn conn ->
      if resp_body do
        Plug.Conn.resp(conn, opts[:status_code] || 200, resp_body)
      else
        Plug.Conn.put_status(conn, opts[:status_code] || 200)
      end
    end)
  end

  def set_env(app, key, new_value) do
    original_value = Application.get_env(app, key)
    Application.put_env(app, key, new_value)

    on_exit(fn -> Application.put_env(app, key, original_value) end)
  end

  def localhost(port) do
    "http://localhost:#{port}/api/v1"
  end
end
