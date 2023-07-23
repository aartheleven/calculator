defmodule Calculator.Repl do
  @moduledoc false

  use Application

  def start(_, _) do
    loop()
  end

  defp loop() do
    input = IO.gets "REPL > "
    input = String.trim(input)

    tokens = Calculator.Lexer.tokenize(input)
    tokens = Calculator.Parser.parse(tokens)
    out = Calculator.Interpreter.exec(tokens)

    IO.puts out

    loop()
  end
end
