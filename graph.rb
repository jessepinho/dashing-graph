class Graph

  class Series

    attr_accessor :name, :data, :color

    def initialize name, color
      @name = name
      @data = Hash.new { |h, k| h[k] = 0 }
      @color = color
    end

    def add_point x, y
      @data[x.to_i] ||= 0
      @data[x.to_i] += y.to_i
    end
  end

  attr_accessor :series

  def initialize series
    @series = {}
    series.each { |name, color|
      @series[name] = Series.new name, color
    }
  end

  def add_point series, x, y
    # Rickshaw (the graphing library) has a fun limitation wherein stacked
    # series need to have the same number of points. Hence we loop through
    # each series to add {x: <whatever>, y: 0} points to make sure that this
    # point exists in every series, not just the one we're explicitly adding it
    # to. Since add_point will sum the y value, we can add it to +series+ twice.
    @series.each do |name, series|
      series.add_point x, 0
    end
    @series[series].add_point x, y
  end

  def totals_series name, color
    totals_series = Series.new name, color
    @series.each do |name, series|
      series.data.each do |x, y|
        totals_series.add_point x, y
      end
    end
    totals_series
  end

  def include_totals! name = 'Total', color = '#515151'
    @series[name] = totals_series name, color
  end

  # Prepare data for graphing. The hash returned by this method is ready to be
  # sent to a Rickshaw graph via <tt>send_event()</tt>.
  def graphify
    graphified = @series.map do |name, series|
      {
        name: series.name,
        color: series.color,
        data: series.data.map { |x, y|
          {
            x: x,
            y: y
          }
        }
      }
    end

    {
      points: graphified
    }
  end
end
