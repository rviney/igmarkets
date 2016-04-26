module IGMarkets
  # Contains details on a single transaction that occurred on an IG Markets account. Returned by
  # {DealingPlatform::AccountMethods#transactions_in_date_range} and
  # {DealingPlatform::AccountMethods#recent_transactions}.
  class Transaction < Model
    attribute :cash_transaction, Boolean
    attribute :close_level, String, nil_if: %w(- 0)
    attribute :currency
    attribute :date, Date, format: '%d/%m/%y'
    attribute :instrument_name
    attribute :open_level, String, nil_if: %w(- 0)
    attribute :period, Time, nil_if: '-', format: '%d/%m/%y %T', time_zone: -> { @dealing_platform.account_time_zone }
    attribute :profit_and_loss
    attribute :reference
    attribute :size, String, nil_if: '-'
    attribute :transaction_type, Symbol, allowed_values: [:deal, :depo, :dividend, :exchange, :with]

    # Returns whether or not this transaction was an interest payment. Interest payments can be either deposits or
    # withdrawals depending on the underlying instrument and currencies involved. Interest payments are identified by
    # the presence of the word `interest` in {#instrument_name}.
    #
    # @return [Boolean]
    def interest?
      [:depo, :with].include?(transaction_type) && !(instrument_name.downcase =~ /(^|[^a-z])interest([^a-z]|$)/).nil?
    end

    # Returns this transaction's {#profit_and_loss} as a `Float`, denominated in this transaction's {#currency}.
    #
    # @return [Float]
    def profit_and_loss_amount
      raise 'profit_and_loss does not start with the expected currency' unless profit_and_loss.start_with? currency

      profit_and_loss[currency.length..-1].delete(',').to_f
    end
  end
end
