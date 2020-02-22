defmodule RumblWeb.UserController do
    use RumblWeb, :controller

    alias Rumbl.Accounts
    alias Rumbl.Accounts.User
    alias RumblWeb.Auth
    
    plug :authenticate when action in [:index, :show, :delete]

    defp authenticate(conn, _opts) do
        if conn.assigns.current_user do 
            conn
        else
            conn
            |> put_flash(:error, "Not logged in")
            |> redirect(to: Routes.page_path(conn, :index))
            |> halt()
        end
    end

    def show(conn, %{"id" => id}) do
        user = Accounts.get_user(id)
        render(conn, "show.json", user: user)
    end

    def index(conn, _params) do
        users = Accounts.list_users()
        render(conn, "index.html", users: users)
    end

    def new(conn, _params) do
        changeset = Accounts.change_user(%User{})
        render(conn, "new.html", changeset: changeset, conn: conn)
    end

    def create(conn, %{"user" => user_params}) do
        case Accounts.register_user(user_params) do
            {:ok, user} ->
                conn
                |> RumblWeb.Auth.login(user)
                |> put_flash(:info, "Welcome, #{user.username}!")
                |> redirect(to: Routes.user_path(conn, :index))
            {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "new.html", changeset: changeset)
        end
    end

    def delete(conn, %{"id" => id}) do
        Accounts.delete_by_id(id)
        if conn.current_user.id == id do
            conn = Auth.logout(conn)
        end
        conn
        |> put_flash(:info, "Deleted user!")
        |> redirect(to: Routes.user_path(conn, :index))
    end
end