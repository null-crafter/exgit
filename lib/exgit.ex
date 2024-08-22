defmodule Exgit do
  alias Exgit.Util.Git
  @moduledoc """
  Exgit keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def git_repo_names(path \\ nil) do
    walk_path = if path != nil do
      path |> Path.expand
    else
      Application.get_env(:exgit, :repo_dir) |> Path.expand
    end

    Git.walk(walk_path)
    |> Enum.map(&Path.relative_to(&1, walk_path))
  end
end
