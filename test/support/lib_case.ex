defmodule Photolog2.LibCase do
  @moduledoc """
  This module defines a testcase to be used with testing modules under the lib/ directory - modules that need access to the project's db, but that are not dependent of Phoenix.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Mock
      import Photolog2.TestHelpers
      import Ecto

      alias Photolog2.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Photolog2.Repo)

    unless tags[:async] do
        Ecto.Adapters.SQL.Sandbox.mode(Photolog2.Repo, {:shared, self()})
    end

    :ok
  end
end
