defmodule Calculator.Token do
  @moduledoc false

  defstruct [:type, :value]

  def new({type, value}) do
    %__MODULE__{
      type: type,
      value: value
    }
  end
end
