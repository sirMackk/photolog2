defmodule Photolog2.PageView do
  use Photolog2.Web, :view

  def friendly_date(ecto_datetime) do
    erl_dtime = Ecto.DateTime.to_erl(ecto_datetime)
    {{_, _, day}, _} = erl_dtime

    erl_dtime
      |> Timex.Date.from
      |> Timex.format!("%A, %B #{day}#{ordinalize(day)} %Y", :strftime)
  end

  def paginate(conn, current, per_page, total) do
    # TODO: Figure out an idiomatic way to build this. Idea: template could be more suitable.

    nav = []
    if (pages = div(total, per_page) + 1) > 1 do
      if (current != 1) do
        nav = nav ++ [
          link("<<", to: page_path(conn, :index, page: 1)),
          link("<", to: page_path(conn, :index, page: current - 1)),
        ]
      end
      nav = nav ++ [content_tag(:p, "Page #{current} of #{pages}")]
      if (current != pages) do
        nav = nav ++ [
          link(">", to: page_path(conn, :index, page: current + 1)),
          link(">>", to: page_path(conn, :index, page: pages))
        ]
      end

      nav
    end
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
