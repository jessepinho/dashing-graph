# Dashing-Graph
A class for preparing graphs for [Dashing](https://github.com/Shopify/dashing).

The following example uses the Graph class along with the [Sequel](https://github.com/jeremyevans/sequel) gem to count the number of users and orders per day, then plot them as separate series on the graph.

```ruby
graph = Graph.new 'Users' => '#ff0000',
                  'Orders' => '#00ff00'
db[:users]
  .select(:created_at)
  .each do |row|
    # Group by day
    time = Time.at(row[:created_at]).to_datetime.at_beginning_of_day.to_i,
    # Add to the graph
    graph.add_point 'Users', time, 1
  end

db[:orders]
  .select(:created_at)
  .each do |row|
    # Group by day
    time = Time.at(row[:created_at]).to_datetime.at_beginning_of_day.to_i,
    # Add to the graph
    graph.add_point 'Orders', time, 1
  end

send_event('users-and-orders-per-day', graph.graphify)
```
