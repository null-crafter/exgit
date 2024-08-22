defmodule Exgit.Util.Git do
  def git?(path) do
    File.ls!(path)
    |> Enum.any?(&Enum.member?([".git", "packed-refs"], &1))
  end

  def path_join_expand(paths) do
    Path.join(paths)
    |> Path.expand
  end
  def ls_git_dirs(path) do
    cond do
      git?(path) ->
        [path]
      true ->
        path
        |> File.ls!()
        |> Enum.map(&Path.join([path, &1]))
        |> Enum.filter(&File.dir?/1)
        |> Enum.map(&ls_git_dirs/1)
        |> List.insert_at(0, path)
        |> List.flatten
        |> Enum.filter(&git?/1)
    end
  end
  def walk(path) do
    path
    |> Path.expand
    |> ls_git_dirs()
  end

end
