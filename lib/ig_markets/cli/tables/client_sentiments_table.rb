module IGMarkets
  module CLI
    # Helper class that prints out an array of {IGMarkets::ClientSentiment} instances in a table.
    class ClientSentimentsTable < Table
      private

      def headings
        ['Market', 'Long %', 'Short %']
      end

      def right_aligned_columns
        [1, 2]
      end

      def row(client_sentiment)
        [
          client_sentiment.market_id,
          client_sentiment.long_position_percentage,
          client_sentiment.short_position_percentage
        ]
      end
    end
  end
end
