ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Photolog2.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Photolog2.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Photolog2.Repo)

