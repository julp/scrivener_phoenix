ExUnit.start()
Application.ensure_all_started(:scrivener_phoenix)

{:ok, _pid} = ScrivenerPhoenixTest.Application.start(:unused, :unused)

Process.flag(:trap_exit, true)
#Ecto.Adapters.SQL.Sandbox.mode(ScrivenerPhoenixTest.Repo, :manual)
