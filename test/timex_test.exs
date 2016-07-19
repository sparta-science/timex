defmodule TimexTests do
  use ExUnit.Case, async: true
  use Timex
  doctest Timex

  test "century" do
    assert 21 === Timex.century

    date = Timex.to_datetime({{2015, 6, 24}, {14, 27, 52}})
    c = date |> Timex.century
    assert 21 === c
  end

  test "add" do
    date     = Timex.to_datetime({{2015, 6, 24}, {14, 27, 52}})
    expected = Timex.to_datetime({{2015, 7, 2}, {14, 27, 52}})
    result   = Timex.add(date, Duration.from_days(8))
    assert expected === result
  end

  test "add microseconds" do
    time = Timex.to_datetime({{2015, 6, 24}, {14, 27, 52}})
    time = %{time | microsecond: {900_000, 6}}
    added = Timex.add(time, Duration.from_microseconds(42))
    assert added.microsecond === {900_042, 6}
  end

  test "subtract" do
    date     = Timex.to_datetime({{2015, 6, 24}, {14, 27, 52}})
    expected = Timex.to_datetime({{2015, 6, 16}, {14, 27, 52}})
    result   = Timex.subtract(date, Duration.from_days(8))
    assert expected === result
  end

  test "weekday" do
    localdate = {{2013,3,17},{11,59,10}}
    assert Timex.weekday(Timex.to_datetime(localdate)) === 7
    assert Timex.weekday(Timex.epoch()) === 4
  end

  test "day" do
    assert Timex.day(Timex.to_datetime({3,1,1})) === 1
    assert Timex.day(Timex.to_datetime({3,2,1})) === 32
    assert Timex.day(Timex.to_datetime({3,12,31})) === 365
    assert Timex.day(Timex.to_datetime({2012,12,31})) === 366
  end

  test "week" do
    localdate = {{2013,3,17},{11,59,10}}
    assert Timex.iso_week(localdate) === {2013,11}
    assert Timex.iso_week(Timex.to_datetime(localdate)) === {2013,11}
    assert Timex.iso_week(Timex.epoch()) === {1970,1}
  end

  test "iso_triplet" do
    localdate = {{2013,3,17},{11,59,10}}
    assert Timex.iso_triplet(Timex.to_datetime(localdate)) === {2013,11,7}
    assert Timex.iso_triplet(Timex.epoch()) === {1970,1,4}
  end

  test "days_in_month" do
    localdate = {{2013,2,17},{11,59,10}}
    assert Timex.days_in_month(Timex.to_datetime(localdate)) === 28

    localdate = {{2000,2,17},{11,59,10}}
    assert Timex.days_in_month(Timex.to_datetime(localdate)) === 29

    assert Timex.days_in_month(Timex.epoch()) === 31
    assert Timex.days_in_month(2012, 2) === 29
    assert Timex.days_in_month(2013, 2) === 28
  end

  test "month_to_num" do
    assert Timex.month_to_num("April") == 4
    assert Timex.month_to_num("april") == 4
    assert Timex.month_to_num("Apr") == 4
    assert Timex.month_to_num("apr") == 4
    assert Timex.month_to_num(:apr) == 4
  end

  test "day_to_num" do
    assert Timex.day_to_num("Wednesday") == 3
    assert Timex.day_to_num("wednesday") == 3
    assert Timex.day_to_num("Wed") == 3
    assert Timex.day_to_num("wed") == 3
    assert Timex.day_to_num(:wed) == 3
  end

  test "is_leap" do
    assert not Timex.is_leap?(Timex.epoch())
    assert Timex.is_leap?(2012)
    assert not Timex.is_leap?(2100)
  end

  test "is_valid?" do
    assert Timex.is_valid?(Timex.now())
    assert Timex.is_valid?({1,1,1})
    assert Timex.is_valid?(Timex.to_date({1,1,1}))
    assert Timex.is_valid?(Timex.to_naive_datetime({{1,1,1}, {0,0,0}}))
    assert Timex.is_valid?(Timex.to_naive_datetime({{1,1,1}, {23,59,59}}))
    assert Timex.is_valid?(Timex.to_datetime({{1,1,1},{1,1,1}}, "Etc/UTC"))

    new_date = %DateTime{year: 0, month: 0, day: 0,
                         hour: 0, minute: 0, second: 0, microsecond: {0,0},
                         time_zone: "Etc/UTC", zone_abbr: "UTC",
                         utc_offset: 0, std_offset: 0}
    assert not Timex.is_valid?(Timex.set(new_date, [date: {12,13,14}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [date: {12,12,34}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [date: {1,0,1}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [date: {1,1,0}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [datetime: {{12,12,12}, {24,0,0}}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [datetime: {{12,12,12}, {23,60,0}}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [datetime: {{12,12,12}, {23,59,60}}, validate: false]))
    assert not Timex.is_valid?(Timex.set(new_date, [datetime: {{12,12,12}, {-1,59,59}}, validate: false]))
  end

  test "set" do
    utc = Timezone.get(:utc)

    tuple = {{2013,3,17}, {17,26,5}}
    date = Timex.to_datetime(tuple, "Europe/Athens")
    assert {{1,1,1},{17,26,5}} == Timex.to_erl(Timex.set(date, date: {1,1,1}))
    assert {{2013,3,17},{0,26,5}} == Timex.to_erl(Timex.set(date, hour: 0))
    assert {{2013,3,17},{17,26,5}} == Timex.to_erl(Timex.set(date, timezone: Timex.timezone(:utc, tuple)))

    assert {{1,1,1},{13,26,59}} == Timex.to_erl(Timex.set(date, [date: {1,1,1}, hour: 13, second: 61, timezone: utc]))
    assert {{0,1,1},{23,26,59}} == Timex.to_erl(Timex.set(date, [date: {-1,-2,-3}, hour: 33, second: 61, timezone: utc]))
  end

  test "compare" do
    assert Timex.compare(Timex.epoch(), Timex.zero()) === 1
    assert Timex.compare(Timex.zero(), Timex.epoch()) === -1

    date1 = Timex.to_datetime({{2013,3,18},{13,44,0}}, 2)
    date2 = Timex.to_datetime({{2013,3,18},{8,44,0}}, -3)
    assert Timex.compare(date1, date2) === 0

    date3 = Timex.to_datetime({{2013,3,18},{13,44,0}}, 3)
    assert Timex.compare(date1, date3) === 1

    date = Timex.now()
    assert Timex.compare(Timex.epoch(), date) === -1

    assert Timex.compare(date, :distant_past) === +1
    assert Timex.compare(date, :distant_future) === -1

    date = Timex.today()
    assert Timex.compare(date, :epoch) === 1
    assert Timex.compare(date, :zero) === 1
    assert Timex.compare(date, :distant_past) === 1
    assert Timex.compare(date, :distant_future) === -1
  end

  test "compare with granularity" do
    date1 = Timex.to_datetime({{2013,3,18},{13,44,0}}, 2)
    date2 = Timex.to_datetime({{2013,3,18},{8,44,0}}, -3)
    date3 = Timex.to_datetime({{2013,4,18},{8,44,10}}, -3)
    date4 = Timex.to_datetime({{2013,4,18},{8,44,23}}, -3)

    assert Timex.compare(date1, date2, :years) === 0
    assert Timex.compare(date1, date2, :months) === 0
    assert Timex.compare(date1, date3, :months) === -1
    assert Timex.compare(date3, date1, :months) === 1
    assert Timex.compare(date1, date3, :weeks) === -1
    assert Timex.compare(date1, date2, :days) === 0
    assert Timex.compare(date1, date3, :days) === -1
    assert Timex.compare(date1, date2, :hours) === 0
    assert Timex.compare(date3, date4, :minutes) === 0
    assert Timex.compare(date3, date4, :seconds) === -1
  end

  test "equal" do
    assert Timex.equal?(Timex.today, Timex.today)
    refute Timex.equal?(Timex.today, Timex.epoch)
    assert Timex.equal?(Timex.today, Timex.today)
    refute Timex.equal?(Timex.now, Timex.epoch)
  end

  test "diff" do
    epoch = Timex.epoch()
    date1 = Timex.to_datetime({1971,1,1})
    date2 = Timex.to_datetime({1973,1,1})

    assert Timex.diff(date1, date2, :seconds) === (Timex.diff(date2, date1, :seconds)*-1)
    assert Timex.diff(date1, date2, :minutes) === (Timex.diff(date2, date1, :minutes)*-1)
    assert Timex.diff(date1, date2, :hours)   === (Timex.diff(date2, date1, :hours)*-1)
    assert Timex.diff(date1, date2, :days)    === (Timex.diff(date2, date1, :days)*-1)
    assert Timex.diff(date1, date2, :weeks)   === (Timex.diff(date2, date1, :weeks)*-1)
    assert Timex.diff(date1, date2, :months)  === (Timex.diff(date2, date1, :months)*-1)
    assert Timex.diff(date1, date2, :years)   === (Timex.diff(date2, date1, :years)*-1)

    d1 = Timex.to_date({1971,1,1})
    d2 = Timex.to_date({1973,1,1})
    assert Timex.diff(d1, d2, :hours)   === (Timex.diff(d2, d1, :hours)*-1)
    assert Timex.diff(d1, d2, :days)    === (Timex.diff(d2, d1, :days)*-1)
    assert Timex.diff(d1, d2, :weeks)   === (Timex.diff(d2, d1, :weeks)*-1)
    assert Timex.diff(d1, d2, :months)  === (Timex.diff(d2, d1, :months)*-1)
    assert Timex.diff(d1, d2, :years)   === (Timex.diff(d2, d1, :years)*-1)

    date3 = Timex.to_datetime({2015,1,1})
    date4 = Timex.to_datetime({2015,12,31})
    assert 52 = Timex.diff(date4, date3, :weeks)
    assert 53 = Timex.diff(date4, date3, :calendar_weeks)
    assert -52 = Timex.diff(date3, date4, :weeks)
    assert -53 = Timex.diff(date3, date4, :calendar_weeks)

    date5 = Timex.to_datetime({2015,12,31})
    date6 = Timex.to_datetime({2016,1,1})
    assert 1 = Timex.diff(date6, date5, :days)
    assert 0 = Timex.diff(date6, date5, :weeks)
    assert 1 = Timex.diff(date6, date5, :calendar_weeks)
    assert 0 = Timex.diff(date6, date5, :years)

    assert Timex.diff(date2, date1, :duration) === %Duration{megaseconds: 63, seconds: 158400, microseconds: 0}

    assert Timex.diff(date1, epoch, :days) === 365
    assert Timex.diff(date1, epoch, :seconds) === 365 * 24 * 3600
    assert Timex.diff(date1, epoch, :years) === 1

    # additional day is added because 1972 was a leap year
    assert Timex.diff(date2, epoch, :days) === 365*3 + 1
    assert Timex.diff(date2, epoch, :seconds) === (365*3 + 1) * 24 * 3600
    assert Timex.diff(date2, epoch, :years) === 3

    assert Timex.diff(date1, epoch, :months) === 12
    assert Timex.diff(date2, epoch, :months) === 36
    assert Timex.diff(date2, date1, :months) === 24

    date1 = Timex.to_datetime({1971,3,31})
    date2 = Timex.to_datetime({1969,2,11})
    assert Timex.diff(date1, date2, :months) === 25
    assert Timex.diff(date2, date1, :months) === -25
  end

  test "timestamp diff same datetime" do
      dt = Timex.to_datetime({1984, 5, 10})
      assert Timex.diff(dt, dt, :duration) === Duration.zero
  end

  test "beginning_of_year" do
    year_start = Timex.to_datetime({{2015,1,1},{0,0,0}})
    assert Timex.beginning_of_year(2015) == Timex.to_date(year_start)
    assert Timex.beginning_of_year({2015,6,15}) == {2015,1,1}
  end

  test "end_of_year" do
    year_end = Timex.to_datetime({{2015, 12, 31},  {23, 59, 59}})
    assert Timex.end_of_year(2015) == Timex.to_date(year_end)
    assert {2015,12,31} = Timex.end_of_year({2015,6,15})
  end

  test "beginning_of_month" do
    assert Timex.beginning_of_month({2016,2,15}) == {2016, 2, 1}
    assert Timex.beginning_of_month(Timex.to_datetime({{2014,2,15},{14,14,14}})) == Timex.to_datetime({{2014,2,1},{0,0,0}})
  end

  test "end_of_month" do
    assert Timex.end_of_month({2016,2,15}) == {2016,2,29}
    refute Timex.end_of_month(~D[2016-02-15]) == ~D[2016-02-28]
    assert Timex.end_of_month(~N[2014-02-15T14:14:14]) == ~N[2014-02-28T23:59:59.999999]
    assert Timex.end_of_month(2015, 11) == ~D[2015-11-30]

    assert {:error, _} = Timex.end_of_month(2015, 13)
    assert {:error, _} = Timex.end_of_month(-2015, 12)
  end

  test "beginning_of_quarter" do
    assert Timex.beginning_of_quarter({2016,3,15}) == {2016,1,1}
    assert Timex.beginning_of_quarter(~N[2014-02-15T14:14:14]) == Timex.to_naive_datetime({{2014,1,1},{0,0,0}})
    assert Timex.beginning_of_quarter({2016,5,15}) == {2016,4,1}
    assert Timex.beginning_of_quarter({2016,8,15}) == {2016,7,1}
    assert Timex.beginning_of_quarter({2016,11,15}) == {2016,10,1}
  end

  test "end_of_quarter" do
    assert Timex.end_of_quarter({2016,2,15}) == {2016,3,31}
    expected = %{Timex.to_datetime({{2014,3,31},{23,59,59}}) | :microsecond => {999_999,6}}
    assert Timex.end_of_quarter(Timex.to_datetime({{2014,2,15},{14,14,14}})) == expected
    assert Timex.end_of_quarter(2015, 1) == Timex.to_date({2015, 3, 31})

    assert {:error, _} = Timex.end_of_quarter(2015, 13)
  end

  test "beginning_of_week" do
    # Monday 30th November 2015
    date = Timex.to_datetime({{2015, 11, 30}, {13, 30, 30}})

    # Monday..Monday
    monday = Timex.to_datetime({2015, 11, 30})
    assert Timex.days_to_beginning_of_week(date) == 0
    assert Timex.days_to_beginning_of_week(date, 1) == 0
    assert Timex.days_to_beginning_of_week(date, :mon) == 0
    assert Timex.days_to_beginning_of_week(date, "Monday") == 0
    assert Timex.beginning_of_week(date) == monday
    assert Timex.beginning_of_week(date, 1) == monday
    assert Timex.beginning_of_week(date, :mon) == monday
    assert Timex.beginning_of_week(date, "Monday") == monday

    # Monday..Tuesday
    tuesday = Timex.to_datetime({2015, 11, 24})
    assert Timex.days_to_beginning_of_week(date, 2) == 6
    assert Timex.days_to_beginning_of_week(date, :tue) == 6
    assert Timex.days_to_beginning_of_week(date, "Tuesday") == 6
    assert Timex.beginning_of_week(date, 2) == tuesday
    assert Timex.beginning_of_week(date, :tue) == tuesday
    assert Timex.beginning_of_week(date, "Tuesday") == tuesday

    # Monday..Wednesday
    wednesday = Timex.to_datetime({2015, 11, 25})
    assert Timex.days_to_beginning_of_week(date, 3) == 5
    assert Timex.days_to_beginning_of_week(date, :wed) == 5
    assert Timex.days_to_beginning_of_week(date, "Wednesday") == 5
    assert Timex.beginning_of_week(date, 3) == wednesday
    assert Timex.beginning_of_week(date, :wed) == wednesday
    assert Timex.beginning_of_week(date, "Wednesday") == wednesday

    # Monday..Thursday
    thursday = Timex.to_datetime({2015, 11, 26})
    assert Timex.days_to_beginning_of_week(date, 4) == 4
    assert Timex.days_to_beginning_of_week(date, :thu) == 4
    assert Timex.days_to_beginning_of_week(date, "Thursday") == 4
    assert Timex.beginning_of_week(date, 4) == thursday
    assert Timex.beginning_of_week(date, :thu) == thursday
    assert Timex.beginning_of_week(date, "Thursday") == thursday

    # Monday..Friday
    friday = Timex.to_datetime({2015, 11, 27})
    assert Timex.days_to_beginning_of_week(date, 5) == 3
    assert Timex.days_to_beginning_of_week(date, :fri) == 3
    assert Timex.days_to_beginning_of_week(date, "Friday") == 3
    assert Timex.beginning_of_week(date, 5) == friday
    assert Timex.beginning_of_week(date, :fri) == friday
    assert Timex.beginning_of_week(date, "Friday") == friday

    # Monday..Saturday
    saturday = Timex.to_datetime({2015, 11, 28})
    assert Timex.days_to_beginning_of_week(date, 6) == 2
    assert Timex.days_to_beginning_of_week(date, :sat) == 2
    assert Timex.days_to_beginning_of_week(date, "Saturday") == 2
    assert Timex.beginning_of_week(date, 6) == saturday
    assert Timex.beginning_of_week(date, :sat) == saturday
    assert Timex.beginning_of_week(date, "Saturday") == saturday

    # Monday..Sunday
    sunday = Timex.to_datetime({2015, 11, 29})
    assert Timex.days_to_beginning_of_week(date, 7) == 1
    assert Timex.days_to_beginning_of_week(date, :sun) == 1
    assert Timex.days_to_beginning_of_week(date, "Sunday") == 1
    assert Timex.beginning_of_week(date, 7) == sunday
    assert Timex.beginning_of_week(date, :sun) == sunday
    assert Timex.beginning_of_week(date, "Sunday") == sunday

    # Invalid start of week - out of range
    assert {:error, _} = Timex.days_to_beginning_of_week(date, 0)
    assert {:error, _} = Timex.beginning_of_week(date, 0)

    # Invalid start of week - out of range
    assert {:error, _} = Timex.days_to_beginning_of_week(date, 8)
    assert {:error, _} = Timex.beginning_of_week(date, 8)

    # Invalid start of week string
    assert {:error, _} = Timex.days_to_beginning_of_week(date, "Made up day")
    assert {:error, _} = Timex.beginning_of_week(date, "Made up day")
  end

  test "end_of_week" do
    # Monday 30th November 2015
    date = Timex.to_datetime({2015, 11, 30})

    # Monday..Sunday
    sunday = Timex.to_datetime({{2015, 12, 6}, {23, 59, 59}})
    sunday = %{sunday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date) == 6
    assert Timex.days_to_end_of_week(date, 1) == 6
    assert Timex.days_to_end_of_week(date, :mon) == 6
    assert Timex.days_to_end_of_week(date, "Monday") == 6
    assert Timex.end_of_week(date) == sunday
    assert Timex.end_of_week(date, 1) == sunday
    assert Timex.end_of_week(date, :mon) == sunday
    assert Timex.end_of_week(date, "Monday") == sunday

    # Monday..Monday
    monday = Timex.to_datetime({{2015, 11, 30}, {23, 59, 59}})
    monday = %{monday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date, 2) == 0
    assert Timex.days_to_end_of_week(date, :tue) == 0
    assert Timex.days_to_end_of_week(date, "Tuesday") == 0
    assert Timex.end_of_week(date, 2) == monday
    assert Timex.end_of_week(date, :tue) == monday
    assert Timex.end_of_week(date, "Tuesday") == monday

    # Monday..Tuesday
    tuesday = Timex.to_datetime({{2015, 12, 1}, {23, 59, 59}})
    tuesday = %{tuesday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date, 3) == 1
    assert Timex.days_to_end_of_week(date, :wed) == 1
    assert Timex.days_to_end_of_week(date, "Wednesday") == 1
    assert Timex.end_of_week(date, 3) == tuesday
    assert Timex.end_of_week(date, :wed) == tuesday
    assert Timex.end_of_week(date, "Wednesday") == tuesday

    # Monday..Wednesday
    wednesday = Timex.to_datetime({{2015, 12, 2}, {23, 59, 59}})
    wednesday = %{wednesday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date, 4) == 2
    assert Timex.days_to_end_of_week(date, :thu) == 2
    assert Timex.days_to_end_of_week(date, "Thursday") == 2
    assert Timex.end_of_week(date, 4) == wednesday
    assert Timex.end_of_week(date, :thu) == wednesday
    assert Timex.end_of_week(date, "Thursday") == wednesday

    # Monday..Thursday
    thursday = Timex.to_datetime({{2015, 12, 3}, {23, 59, 59}})
    thursday = %{thursday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date, 5) == 3
    assert Timex.days_to_end_of_week(date, :fri) == 3
    assert Timex.days_to_end_of_week(date, "Friday") == 3
    assert Timex.end_of_week(date, 5) == thursday
    assert Timex.end_of_week(date, :fri) == thursday
    assert Timex.end_of_week(date, "Friday") == thursday

    # Monday..Friday
    friday = Timex.to_datetime({{2015, 12, 4}, {23, 59, 59}})
    friday = %{friday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date, 6) == 4
    assert Timex.days_to_end_of_week(date, :sat) == 4
    assert Timex.days_to_end_of_week(date, "Saturday") == 4
    assert Timex.end_of_week(date, 6) == friday
    assert Timex.end_of_week(date, :sat) == friday
    assert Timex.end_of_week(date, "Saturday") == friday

    # Monday..Saturday
    saturday = Timex.to_datetime({{2015, 12, 5}, {23, 59, 59}})
    saturday = %{saturday | :microsecond => {999_999,6}}
    assert Timex.days_to_end_of_week(date, 7) == 5
    assert Timex.days_to_end_of_week(date, :sun) == 5
    assert Timex.days_to_end_of_week(date, "Sunday") == 5
    assert Timex.end_of_week(date, 7) == saturday
    assert Timex.end_of_week(date, :sun) == saturday
    assert Timex.end_of_week(date, "Sunday") == saturday

    # Invalid start of week - out of range
    assert {:error, _} = Timex.days_to_end_of_week(date, 0)
    assert {:error, _} = Timex.end_of_week(date, 0)

    # Invalid start of week - out of range
    assert {:error, _} = Timex.days_to_end_of_week(date, 8)
    assert {:error, _} = Timex.end_of_week(date, 8)

    # Invalid start of week string
    assert {:error, _} = Timex.days_to_end_of_week(date, "Made up day")
    assert {:error, _} = Timex.end_of_week(date, "Made up day")
  end

  test "beginning_of_day" do
    date = Timex.to_datetime({{2015,1,1},{13,14,15}})
    assert Timex.beginning_of_day(date) == Timex.to_datetime({{2015,1,1},{0,0,0}})
  end

  test "end_of_day" do
    date = Timex.to_datetime({{2015,1,1},{13,14,15}})
    expected = %{Timex.to_datetime({{2015,1,1},{23,59,59}}) | :microsecond => {999_999,6}}
    assert Timex.end_of_day(date) == expected
  end
end
