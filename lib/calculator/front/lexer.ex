defmodule Calculator.Lexer do
  @moduledoc false

  alias Calculator.Token
  alias Calculator.TokenExcept

  @ops ["+", "-", "*", "/"]

  defguardp is_decimal_point(token) when token == "."
  defguardp is_digit(token) when token >= "0" and token <= "9"
  defguardp is_op(token) when token in @ops
  defguardp is_useless(token) when token == " " or token == "\n"

  def tokenize(input), do: tokenize(String.graphemes(input), [])

  defp tokenize([], tokens), do: Enum.reverse([Token.new({:eof, ""}) | tokens])

  defp tokenize(chars = [token | rest], tokens) do
    cond do
      is_digit(token) ->
        read_digits(chars, tokens)

      is_useless(token) ->
        tokenize(rest, tokens)

      is_decimal_point(token) ->
        raise TokenExcept, message: "Floats must have decimal leading digits"

      true ->
        read_next(chars, tokens)
    end
  end

  defp read_digits(chars, tokens) do
    {num, rest} = Enum.split_while(chars, &(is_digit(&1) or is_decimal_point(&1)))

    if is_decimal_point(List.last(num)) do
      raise TokenExcept, message: "Expected a valid token sequence, got: #{num}"
    end

    decimal_count = Enum.count(num, &is_decimal_point/1)
    num = Enum.join(num)

    token =
      case decimal_count do
        0 -> Token.new({:integer, String.to_integer(num)})
        1 -> Token.new({:float, String.to_float(num)})
        _ -> raise TokenExcept, message: "Expected a valid token sequence, got: #{num}"
      end

    tokenize(rest, [token | tokens])
  end

  defp read_next([curr | rest], tokens) when is_op(curr) do
    token = Token.new({:op, curr})

    tokenize(rest, [token | tokens])
  end
end
