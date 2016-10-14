defmodule Photolog2.PageView do
  use Photolog2.Web, :view

  def friendly_date(ecto_datetime) do
    erl_dtime = Ecto.DateTime.to_erl(ecto_datetime)
    {{_, _, day}, _} = erl_dtime

    erl_dtime
      |> Timex.Date.from
      |> Timex.format!("%A, %B #{day}#{ordinalize(day)} %Y", :strftime)
  end

  defp ordinalize(day) do
    if rem(day, 100) in 11..13 do
      "th"
    else
      case rem(day, 10) do
        1 ->
          "st"
        2 ->
          "nd"
        3 ->
          "rd"
        _ ->
          "th"
      end
    end
  end
end
