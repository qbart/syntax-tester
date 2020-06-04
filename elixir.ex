# Code examples taken from:
# - https://github.com/ueberauth/guardian
# - https://github.com/phoenixframework/phoenix
# - https://github.com/peburrows/goth
# - https://github.com/stavro/arc
# and modifed to expose as many Elixir features to test highlighting. Feel free to contribute.


defmodule Arc.File do
  defp get_remote_path(remote_path) do
    options = [
      follow_redirect: true,
      recv_timeout: Application.get_env(:arc, :recv_timeout, 5_000),
      backoff_max: Application.get_env(:arc, :backoff_max, 30_000),
    ]

    request(remote_path, options)
  end
end

defmodule Phoenix.MixProject do
  def application do
    [
      mod: {Phoenix, []},
      extra_applications: [:logger, :eex, :crypto, :public_key],
      env: [
        logger: true,
        stacktrace_depth: nil,
        template_engines: [],
        filter_parameters: ["password"],
        serve_endpoints: false,
        gzippable_exts: ~w(.js .css .txt .text .html .json .svg .eot .ttf),
        trim_on_html_eex_engine: true
      ]
    ]
  end
end

defmodule Goth.Token do
  @type t :: %__MODULE__{
          token: String.t(),
          type: String.t(),
          scope: String.t(),
          sub: String.t() | nil,
          expires: non_neg_integer,
          account: String.t()
        }

  defstruct [:token, :type, :scope, :sub, :expires, :account]

  @doc """
  ## Example
      iex> Token.for_scope("https://www.googleapis.com/auth/pubsub")
      {:ok, %Goth.Token{expires: ..., token: "...", type: "..."} }
  """
  def for_scope(info, sub \\ nil)

  @spec for_scope(scope :: String.t(), sub :: String.t() | nil) :: {:ok, t} | {:error, any()}
  def for_scope(scope, sub) when is_binary(scope) do
    case TokenStore.find({:default, scope}, sub) do
      :error -> retrieve_and_store!({:default, scope}, sub)
      {:ok, token} -> {:ok, token}
    end
  end
end

defmodule Guardian.Plug do

  defmodule UnauthenticatedError do
    defexception message: "Unauthenticated", status: 401
  end

  @default_key "default"
  @default_cookie_max_age [max_age: 60 * 60 * 24 * 7 * 4]

  import Guardian, only: [returning_tuple: 1]
  import Plug.Conn

  alias __MODULE__.UnauthenticatedError

  defmacro __using__(impl) do
    quote do
      @spec implementation() :: unquote(impl)
      def implementation, do: unquote(impl)

      def put_current_token(conn, token, opts \\ []),
        do: Guardian.Plug.put_current_token(conn, token, opts)
    end
  end

  def session_active?(conn) do
    key = :second |> System.os_time() |> to_string()
    get_session(conn, key) == nil
  rescue
    ArgumentError -> false
  end

  @spec sign_in(Plug.Conn.t(), module, any, Guardian.Token.claims(), Guardian.options()) :: Plug.Conn.t()
  def sign_in(conn, impl, resource, claims \\ %{}, opts \\ []) do
    with {:ok, token, full_claims} <- Guardian.encode_and_sign(impl, resource, claims, opts),
         {:ok, conn} <- add_data_to_conn(conn, resource, token, full_claims, opts),
         {:ok, conn} <- returning_tuple({impl, :after_sign_in, [conn, resource, token, full_claims, opts]}) do
      if session_active?(conn) do
        put_session_token(conn, token, opts)
      else
        conn
      end
    else
      err -> handle_unauthenticated(conn, err, opts)
    end
  end

  @spec find_token_from_cookies(conn :: Plug.Conn.t(), Keyword.t()) :: {:ok, String.t()} | :no_token_found
  def find_token_from_cookies(conn, opts \\ []) do
    key =
      conn
      |> Pipeline.fetch_key(opts)
      |> token_key()

    token = conn.req_cookies[key] || conn.req_cookies[to_string(key)]
    if token, do: {:ok, token}, else: :no_token_found
  end

  defp cookie_options(mod, %{"exp" => timestamp}) do
    max_age = timestamp - Guardian.timestamp()
    Keyword.merge([max_age: max_age], mod.config(:cookie_options, []))
  end

  defp cookie_options(mod, _) do
    Keyword.merge(@default_cookie_max_age, mod.config(:cookie_options, []))
  end

  defp do_sign_out(%{private: private} = conn, impl, :all, opts) do
    private
    |> Map.keys()
    |> Enum.map(&key_from_other/1)
    |> Enum.filter(&(&1 != nil))
    |> Enum.uniq()
    |> Enum.reduce({:ok, conn}, &clear_key(&1, &2, impl, opts))
    |> cleanup_session(opts)
  end

  defp do_sign_out(conn, impl, key, opts) do
    with {:ok, conn} <- returning_tuple({impl, :before_sign_out, [conn, key, opts]}),
         {:ok, conn} <- revoke_token(conn, impl, key, opts),
         {:ok, conn} <- remove_data_from_conn(conn, key: key) do
      if session_active?(conn) do
        {:ok, delete_session(conn, token_key(key))}
      else
        {:ok, conn}
      end
    end
  end
end

