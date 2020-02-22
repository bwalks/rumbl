defmodule Rumbl.Accounts.User do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "users" do
        field :name, :string
        field :username, :string
        field :password, :string, virtual: true
        field :password_hash, :string

        timestamps()
    end

    def registration_changeset(user, attrs) do
        user
        |> changeset(attrs)
        |> cast(attrs, [:password])
        |> validate_required([:password])
        |> validate_length(:password, min: 6, max: 20)
        |> put_password_hash()
    end

    def changeset(user, attrs) do
        user
        |> cast(attrs, [:name, :username])
        |> validate_required([:name, :username])
        |> validate_length(:username, min: 1, max: 20)
    end

    def put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
        put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
    end

    def put_password_hash(changeset) do
        changeset
    end
end