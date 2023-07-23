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

  defp tokenize(chars, tokens) do
    cond do
      is_digit(hd(chars)) ->
        read_digits(chars, {:integer, ""}, tokens)

      is_useless(hd(chars)) ->
        tokenize(tl(chars), tokens)

      is_decimal_point(hd(chars)) ->
        raise TokenExcept, message: "Floats must have decimal leading digits"

      true ->
        read_next(chars, tokens)
    end
  end

  defp read_digits([curr | rest], {_, value}, _tokens)
       when (is_decimal_point(curr) and is_decimal_point(hd(rest))) or
              (is_decimal_point(curr) and not is_digit(hd(rest))),
       do: raise TokenExcept, message: "Expected a valid token sequence, got: #{value <> curr <> hd(rest)}"

  defp read_digits([curr | rest], {type, value}, tokens)
       when is_digit(curr),
       do: read_digits(rest, {type, value <> curr}, tokens)

  defp read_digits([curr | rest], {_, value}, tokens)
       when is_decimal_point(curr) and is_digit(hd(rest)),
       do: read_digits(tl(rest), {:float, value <> curr <> hd(rest)}, tokens)

  defp read_digits(rest, seq, tokens) do
    token = Token.new(parse_seq(seq))

    tokenize(rest, [token | tokens])
  end

  defp read_next([curr | rest], tokens) when is_op(curr) do
    token = Token.new({:op, curr})

    tokenize(rest, [token | tokens])
  end

  defp parse_seq({type, value}) do
    value =
      case type do
        :integer -> String.to_integer(value)
        :float -> String.to_float(value)
      end

    {type, value}
  end
end
