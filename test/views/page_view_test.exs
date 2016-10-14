defmodule Photolog2.PageViewTest do
  use Photolog2.ConnCase, async: true

  alias Photolog2.PageView

  test "friendly_date outputs day, 'month ordinal day year'" do
    dt = Ecto.DateTime.cast!({{2016, 10, 14}, {12, 30, 34}})
    friendly_dt = PageView.friendly_date(dt)

    assert friendly_dt == "Friday, October 14th 2016"
  end

  test "friendly_date outputs ordinal date numbers" do
    first = Ecto.DateTime.cast!({{2016, 10, 1}, {12, 30, 34}}) |> PageView.friendly_date
    second = Ecto.DateTime.cast!({{2016, 10, 2}, {12, 30, 34}}) |> PageView.friendly_date
    third = Ecto.DateTime.cast!({{2016, 10, 3}, {12, 30, 34}}) |> PageView.friendly_date
    fourth = Ecto.DateTime.cast!({{2016, 10, 4}, {12, 30, 34}}) |> PageView.friendly_date
    eleventh = Ecto.DateTime.cast!({{2016, 10, 11}, {12, 30, 34}}) |> PageView.friendly_date
    twenty_first = Ecto.DateTime.cast!({{2016, 10, 21}, {12, 30, 34}}) |> PageView.friendly_date
    twenty_third = Ecto.DateTime.cast!({{2016, 10, 23}, {12, 30, 34}}) |> PageView.friendly_date
    twenty_sixth = Ecto.DateTime.cast!({{2016, 10, 26}, {12, 30, 34}}) |> PageView.friendly_date

    assert first == "Saturday, October 1st 2016"
    assert second == "Sunday, October 2nd 2016"
    assert third == "Monday, October 3rd 2016"
    assert fourth == "Tuesday, October 4th 2016"
    assert eleventh == "Tuesday, October 11th 2016"
    assert twenty_first == "Friday, October 21st 2016"
    assert twenty_third == "Sunday, October 23rd 2016"
    assert twenty_sixth == "Wednesday, October 26th 2016"
  end

end
