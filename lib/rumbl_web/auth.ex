defmodule RumblWeb.Auth do
    use RumblWeb, :controller

    alias Rumbl.Accounts
    alias Rumbl.Accounts.User

    def login(conn, user) do
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
    end

    def logout(conn) do
        conn
        |> delete_session(:user_id)
    end

    def authenticate_by_username_and_password(username, password) do
        user = Accounts.get_user_by_params(username: username)
        cond do
            user && Pbkdf2.verify_pass(password, user.password_hash) -> {:ok, user}
            user -> {:error, :unauthorized}
            true -> 
                Pbkdf2.no_user_verify()
                {:error, :not_found}
        end     
    end
end