defmodule Exgit.Util.Git do
  def shell_run(script, shell \\ "/bin/sh") do
    System.cmd(shell, ["-c", script], stderr_to_stdout: true)
  end
  def git_toplevel_cmd(path) do
      ~s(cd #{path}
      && [ "`pwd`" = "`git rev-parse --show-toplevel`" ])
      |> String.replace("\n", "")
      |> String.replace("\r\n", "")
      |> shell_run
  end
  def in_git_repo_cmd(path) do
      ~s(cd #{path}
      && git status)
      |> String.replace("\n", "")
      |> String.replace("\r\n", "")
      |> shell_run
  end

  def git?(path) do
    case git_toplevel_cmd(path) do
      {_, 0} ->
        true
      _ ->
        false
    end
  end
  def git_file?(path) do
    case in_git_repo_cmd(path) do
      {_, 0} ->
        true
      _ ->
        false
    end
  end

  def path_join_expand(paths) do
    Path.join(paths)
    |> Path.expand
  end
  def ls_git_dirs(path) do
    cond do
      git?(path) ->
        [path]
      git_file?(path) ->
        []
      true ->
        path
        |> File.ls!()
        |> Enum.map(&Path.join([path, &1]))
        |> Enum.filter(&File.dir?/1)
        |> Enum.map(&ls_git_dirs/1)
        |> List.insert_at(0, path)
        |> List.flatten
    end
  end
  def walk(path) do
    path
    |> Path.expand
    |> ls_git_dirs()
    |> Enum.filter(&git?/1)
  end

end
