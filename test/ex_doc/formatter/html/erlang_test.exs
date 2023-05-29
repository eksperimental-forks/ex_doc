defmodule ExDoc.Formatter.HTML.ErlangTest do
  use ExUnit.Case
  import TestHelper

  @moduletag :otp_eep48
  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    output = tmp_dir <> "/doc"
    File.mkdir!(output)
    File.touch!("#{output}/.ex_doc")
  end

  test "smoke test", c do
    erlc(c, :foo, ~S"""
    %% @doc
    %% foo module.
    -module(foo).
    -export([foo/1]).
    -export_type([t/0]).

    %% @doc
    %% f/0 function.
    -spec foo(atom()) -> atom().
    foo(X) -> X.

    -type t() :: atom().
    %% t/0 type.
    """)

    doc = generate_docs(c)

    assert "-spec foo(atom()) -> atom()." =
             doc |> Floki.find("pre:fl-contains('foo(atom())')") |> Floki.text()

    assert "-type t() :: atom()." =
             doc |> Floki.find("pre:fl-contains('t() :: atom().')") |> Floki.text()
  end

  defp generate_docs(c) do
    config = [
      version: "1.0.0",
      project: "Foo",
      formatter: "html",
      output: Path.join(c.tmp_dir, "doc"),
      source_beam: Path.join(c.tmp_dir, "ebin"),
      extras: []
    ]

    ExDoc.generate_docs(config[:project], config[:version], config)
    [c.tmp_dir, "doc", "foo.html"] |> Path.join() |> File.read!() |> Floki.parse_document!()
  end
end
