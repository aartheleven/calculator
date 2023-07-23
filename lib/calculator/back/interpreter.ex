defmodule Calculator.Interpreter do
  @moduledoc false

  alias Calculator.Token

  def exec(tokens), do: exec(tokens, [])

  defp exec([], stack), do: hd(stack).value

  defp exec(tokens, stack) do
    case hd(tokens).type do
      :op ->
        handle_op(tokens, stack)

      type when type == :integer or type == :float ->
        exec(tl(tokens), [hd(tokens) | stack])
    end
  end

  defp handle_op([token | tokens], stack) do
    [rt | stack] = stack
    [lt | stack] = stack

    token =
      evaluate(token.value, lt.value, rt.value)
      |> ret_token()

    stack = [
      Token.new(token)
      | stack
    ]

    exec(tokens, stack)
  end

  defp evaluate(value, lt, rt) do
    case value do
      "+" -> lt + rt
      "-" -> lt - rt
      "*" -> lt * rt
      "/" -> divi(lt, rt)
    end
  end

  defp ret_token(value) when is_float(value), do: {:float, value}
  defp ret_token(value) when is_integer(value), do: {:integer, value}

  defp divi(lt, rt) do
    case lt / rt - trunc(lt / rt) do
      0.0 -> trunc(lt / rt)
      _ -> lt / rt
    end
  end
end
