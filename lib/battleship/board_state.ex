defmodule Battleship.BoardState do
  # [5, 4, 3, 3, 2]
  defstruct ships: %{five: nil, four: nil,
                    three_1: nil, three_2: nil, two: nil },
            misses: [],
            user: nil
end