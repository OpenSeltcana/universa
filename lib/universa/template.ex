defmodule Universa.Template do
  require EEx

  @spec fill(String.t(), map) :: {:ok, String.t()}
  def fill(file, data) do
    t = %{
      fg: %{
        black: "\e[0;30m",
        red: "\e[0;31m",
        green: "\e[0;32m",
        yellow: "\e[0;33m",
        blue: "\e[0;34m",
        magenta: "\e[0;35m",
        cyan: "\e[0;36m",
        white: "\e[0;37m",
        bblack: "\e[30;1m",
        bred: "\e[31;1m",
        bgreen: "\e[32;1m",
        byellow: "\e[33;1m",
        bblue: "\e[34;1m",
        bmagenta: "\e[35;1m",
        bcyan: "\e[36;1m",
        bwhite: "\e[37;1m",
        reset: "\e[39;0m"
      },
      bg: %{
        black: "\e[40m",
        red: "\e[41m",
        green: "\e[42m",
        yellow: "\e[43m",
        blue: "\e[44m",
        magenta: "\e[45m",
        cyan: "\e[46m",
        white: "\e[47m",
        bblack: "\e[100m",
        bred: "\e[101m",
        bgreen: "\e[102m",
        byellow: "\e[103m",
        bblue: "\e[104m",
        bmagenta: "\e[105m",
        bcyan: "\e[106m",
        bwhite: "\e[107m",
        reset: "\e[49m"
      },
      telnet: %{
        stop_echo: "\xff\xfd\x01",
        continue_echo: "\xff\xfc\x01"
      }
    }

    local_path = "priv/templates/#{file}"
    default_path = Path.join(:code.priv_dir(:universa), "templates/#{file}")

    cond do
      File.exists?(local_path) -> # Try local files first
        {:ok, EEx.eval_file(local_path, t: t, data: data)}
      File.exists?(default_path) -> # Then try Universa's files
        {:ok, EEx.eval_file(default_path, t: t, data: data)}
      true -> # Then give up
        {:error, :not_found}
    end
  end
end