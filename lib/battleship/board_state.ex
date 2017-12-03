defmodule BoardState do
  # [5, 4, 3, 3, 2]
  defstruct ships: %{five: {:unplaced}, four: {:unplaced},
                    three_1: {:unplaced}, three_2: {:unplaced}, two: {:unplaced} },
            misses: []
end