module IGMarkets
  class Transaction < Model
    attribute :cash_transaction, Boolean
    attribute :close_level
    attribute :currency
    attribute :date, DateTime, format: '%d/%m/%y'
    attribute :instrument_name
    attribute :open_level, String, nil_if: '-'
    attribute :period, String, nil_if: '-'
    attribute :profit_and_loss
    attribute :reference
    attribute :size, String, nil_if: '-'
    attribute :transaction_type, Symbol, allowed_values: [:deal, :depo, :dividend, :exchange, :with]
  end
end
