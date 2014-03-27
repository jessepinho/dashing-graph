class Graph < Hash

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

  def include_totals! name = 'Total', color = '#515151'
    @series[name] = totals_series name, color
  end

  # Dashing's <tt>send_event()</tt> method calls <tt>.to_json()</tt> on the
  # object passed into it before sending it to the browser. At this point, we
  # want to add the <tt>:points</tt> key to the hash with the graph data. This
  # way, we can simply pass a Graph object directly to <tt>send_event()</tt>.
  def to_json
    self[:points] = graphify
    super
  end

  private

    # Prepare data for graphing.
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
end
