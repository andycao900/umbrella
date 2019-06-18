defmodule Authentication.UserFromAuthTest do
  use ExUnit.Case
  use Engine.DataCase

  import ExUnit.CaptureLog

  alias Authentication.UserFromAuth
  alias Ueberauth.Auth
  alias Ueberauth.Auth.Info

  alias Engine.Accounts
  alias Engine.Accounts.User

  @base_auth0_response %Auth{
    uid: "auth0|5c882ac49ad10a6d8ec35793",
    info: %Info{
      email: "foo@example.com",
      name: "John Doe",
      first_name: "John",
      last_name: "Doe",
      nickname: nil,
      image: "www.cars.com/mackey.png"
    }
  }

  describe "find_or_create/2 :internal" do
    test "success with basic info" do
      auth = %Auth{
        uid: "auth0|5c881ac49ad10a6d8ec35793",
        info: %Info{
          email: "test_user@test.com",
          name: "John Doe",
          image: "https://localhost/1x1.png"
        }
      }

      {:ok,
       %User{email: email, name: name, auth0_id: auth0_id, avatar_url: avatar_url, type: type}} =
        UserFromAuth.find_or_create(auth, :internal)

      assert email == auth.info.email
      assert name == auth.info.name
      assert auth0_id == auth.uid
      assert avatar_url == auth.info.image
      assert type == "internal"
    end

    test "with ADFS user, `email_verified` is set to true" do
      auth = %Auth{
        uid: "adfs|cars-adfs|john@cars.com",
        info: %Info{
          email: "john@cars.com",
          name: "John Doe",
          image: "https://localhost/1x1.png"
        }
      }

      assert {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.email_verified == true
    end

    test "without ADFS user, `email_verified` is set to false" do
      auth = %Auth{
        uid: "auth0|5c881ac49ad10a6d8ec35793",
        info: %Info{
          email: "test_user@test.com",
          name: "John Doe",
          image: "https://localhost/1x1.png"
        }
      }

      assert {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.email_verified == false
    end

    test "no auth struct provided" do
      fun = fn -> UserFromAuth.find_or_create(%{}, :internal) end

      assert capture_log(fun) =~ "Login Failure"
    end

    test "success with first_name and last_name, but no name provided" do
      auth = %Auth{
        uid: "auth0|5c882ac49ad10a6d8ec35793",
        info: %Info{
          email: "foo@example.com",
          name: nil,
          first_name: "John",
          last_name: "Doe",
          nickname: nil,
          image: "www.cars.com/mackey.png"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.name == "#{auth.info.first_name} #{auth.info.last_name}"
    end

    test "use nickname when no name, first_name, and last_name provided" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: nil,
          last_name: nil,
          nickname: "jodo",
          image: "www.cars.com/mackey.png",
          email: "foo@example.com"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.name == auth.info.nickname
    end

    test "use nickname when name is nil, first_name and last_names are empty string" do
      auth = %Auth{
        uid: "auth0|5c885ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: "",
          last_name: "",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.name == auth.info.nickname
    end

    test "use first name only" do
      auth = %Auth{
        uid: "auth0|5c885ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: "John",
          last_name: "",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.name == auth.info.first_name
    end

    test "use last name only" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: "",
          last_name: "Doe",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.name == auth.info.last_name
    end

    test "name is empty string" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: "",
          first_name: "John",
          last_name: "Doe",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      assert user.name == "#{auth.info.first_name} #{auth.info.last_name}"
    end

    test "name equals email, ignore name" do
      email = "foo@email.com"

      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: email,
          email: email,
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :internal)

      refute user.name == user.email
    end

    test "new user is created in database" do
      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :internal)

      assert Accounts.get_user!(user.id) == user
    end

    test "existing user returned instead of created in database" do
      UserFromAuth.find_or_create(@base_auth0_response, :internal)

      query = from(user in User, select: count(user.id))
      users_count = Engine.Repo.all(query)

      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :internal)

      assert users_count == Engine.Repo.all(query)
      assert user.auth0_id == @base_auth0_response.uid
    end

    test "new user has value for last_signed_in_at" do
      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :internal)

      assert %DateTime{} = user.last_signed_in_at
    end

    test "existing user last_signed_in_at updated during subsequent login" do
      first_signed_in_at = DateTime.from_naive!(~N[2019-01-01 08:00:00], "Etc/UTC")

      first_user_attrs = %{
        last_signed_in_at: first_signed_in_at,
        auth0_id: @base_auth0_response.uid
      }

      insert(:user, first_user_attrs)

      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :internal)

      assert DateTime.compare(user.last_signed_in_at, first_signed_in_at) == :gt
    end

    test "failure to create new user in database" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: "",
          first_name: "John",
          last_name: "Doe",
          nickname: "jodo",
          email: nil,
          image: "www.cars.com/mackey.gif"
        }
      }

      assert {:error, %Ecto.Changeset{}} = UserFromAuth.find_or_create(auth, :internal)
    end
  end

  describe "find_or_create/2 :consumer when a User doesn't exist" do
    test "success with basic info" do
      auth = %Auth{
        uid: "auth0|5c881ac49ad10a6d8ec35793",
        info: %Info{
          email: "test_user@test.com",
          name: "John Doe",
          image: "https://localhost/1x1.png"
        }
      }

      {:ok,
       %User{email: email, name: name, auth0_id: auth0_id, avatar_url: avatar_url, type: type}} =
        UserFromAuth.find_or_create(auth, :consumer)

      assert email == auth.info.email
      assert name == auth.info.name
      assert auth0_id == auth.uid
      assert avatar_url == auth.info.image
      assert type
    end

    test "no auth struct provided" do
      fun = fn -> UserFromAuth.find_or_create(%{}, :consumer) end

      assert capture_log(fun) =~ "Login Failure"
    end

    test "success with first_name and last_name, but no name provided" do
      auth = %Auth{
        uid: "auth0|5c882ac49ad10a6d8ec35793",
        info: %Info{
          email: "foo@example.com",
          name: nil,
          first_name: "John",
          last_name: "Doe",
          nickname: nil,
          image: "www.cars.com/mackey.png"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      assert user.name == "#{auth.info.first_name} #{auth.info.last_name}"
    end

    test "use nickname when no name, first_name, and last_name provided" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: nil,
          last_name: nil,
          nickname: "jodo",
          image: "www.cars.com/mackey.png",
          email: "foo@example.com"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      assert user.name == auth.info.nickname
    end

    test "use nickname when name is nil, first_name and last_names are empty string" do
      auth = %Auth{
        uid: "auth0|5c885ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: "",
          last_name: "",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      assert user.name == auth.info.nickname
    end

    test "use first name only" do
      auth = %Auth{
        uid: "auth0|5c885ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: "John",
          last_name: "",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      assert user.name == auth.info.first_name
    end

    test "use last name only" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: nil,
          first_name: "",
          last_name: "Doe",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      assert user.name == auth.info.last_name
    end

    test "name is empty string" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: "",
          first_name: "John",
          last_name: "Doe",
          nickname: "jodo",
          email: "foo@example.com",
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      assert user.name == "#{auth.info.first_name} #{auth.info.last_name}"
    end

    test "name equals email, ignore name" do
      email = "foo@email.com"

      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: email,
          email: email,
          image: "www.cars.com/mackey.gif"
        }
      }

      {:ok, user} = UserFromAuth.find_or_create(auth, :consumer)

      refute user.name == user.email
    end

    test "new user is created in database" do
      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :consumer)

      assert Accounts.get_user!(user.id) == user
    end

    test "existing user returned instead of created in database" do
      UserFromAuth.find_or_create(@base_auth0_response, :consumer)

      query = from(user in User, select: count(user.id))
      users_count = Engine.Repo.all(query)

      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :consumer)

      assert users_count == Engine.Repo.all(query)
      assert user.auth0_id == @base_auth0_response.uid
    end

    test "new user has value for last_signed_in_at" do
      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :consumer)

      assert %DateTime{} = user.last_signed_in_at
    end

    test "existing user last_signed_in_at updated during subsequent login" do
      first_signed_in_at = DateTime.from_naive!(~N[2019-01-01 08:00:00], "Etc/UTC")

      first_user_attrs = %{
        last_signed_in_at: first_signed_in_at,
        auth0_id: @base_auth0_response.uid
      }

      insert(:user, first_user_attrs)

      {:ok, user} = UserFromAuth.find_or_create(@base_auth0_response, :consumer)

      assert DateTime.compare(user.last_signed_in_at, first_signed_in_at) == :gt
    end

    test "failure to create new user in database" do
      auth = %Auth{
        uid: "auth0|5c883ac49ad10a6d8ec35793",
        info: %Info{
          name: "",
          first_name: "John",
          last_name: "Doe",
          nickname: "jodo",
          email: nil,
          image: "www.cars.com/mackey.gif"
        }
      }

      assert {:error, %Ecto.Changeset{}} = UserFromAuth.find_or_create(auth, :consumer)
    end
  end
end
