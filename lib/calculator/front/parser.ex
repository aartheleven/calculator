defmodule Calculator.Parser do
  @moduledoc false

  @op_prec %{
    "+" => 0,
    "-" => 0,
    "*" => 1,
    "/" => 1
  }

  def parse(tokens), do: parse(tokens, [], [])

  defp parse([], stack, out), do: Enum.reverse(out) ++ stack

  defp parse([token | rest], stack, out) do
    case token.type do
      type when type == :integer or type == :float ->
        parse(rest, stack, [token | out])

      :op ->
        {ord_ops, stack} = Enum.split_while(stack, &(@op_prec[&1.value] >= @op_prec[token.value]))

        parse(rest, [token | stack], Enum.reverse(ord_ops) ++ out)

      :eof ->
        parse(rest, stack, out)
    end
  end
end
