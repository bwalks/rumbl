defmodule RumblWeb.SessionController do
    use RumblWeb, :controller
    alias Rumbl.Accounts
    alias RumblWeb.Auth

    def new(conn, _) do
        render(conn, "new.html", conn: conn)
    end

    def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
        case Auth.authenticate_by_username_and_password(username, password) do
            {:ok, user} -> 
                conn
                |> RumblWeb.Auth.login(user)
                |> put_flash(:info, "Welcome, #{username}!")
                |> redirect(to: Routes.user_path(conn, :index))
            {:error, _} ->
                conn
                |> put_flash(:error, "Invalid username/password")
                |> render("new.html")
        end
    end

    def delete(conn, _) do
        conn
        |> RumblWeb.Auth.logout()
        |> put_flash(:info, "Logged out!")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
  