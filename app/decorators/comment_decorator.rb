# frozen_string_literal: true

module CommentDecorator
  def created_elapsed_time
    elapsed_seconds = (Time.current - created_at).floor
    [[60, "秒"], [60, "分"], [24, "時間"], [7, "日"], [4.3, "週間"], [12, "カ月"]].each.with_index.inject(elapsed_seconds) do |result, (array, idx)|
      q, r = result.divmod(array[0])
      break "#{r}#{array[1]}" if q.zero?

      if idx == 5
        "#{q}年"
      else
        q
      end
    end
  end
end
