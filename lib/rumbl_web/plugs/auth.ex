defmodule RumblWeb.Plugs.Auth do
    import Plug.Conn
    alias Rumbl.Accounts

    def init(opts), do: opts

    def call(conn, _opts) do
        user_id = get_session(conn, :user_id)
        conn
        |> get_and_add_user_to_conn(user_id)
    end

    defp get_and_add_user_to_conn(conn, nil) do
        conn
    end

    defp get_and_add_user_to_conn(conn, user_id) do
        user = user_id && Accounts.get_user(user_id)
        case user do
            nil -> delete_session(conn, :user_id)
            _ -> assign(conn, :current_user, user)
        end
    end
end