# This module contains all the code for the IG Markets gem. See the {DealingPlatform} class to get started.
module IGMarkets
  # This is the primary class for interacting with the IG Markets API. Sign in using {#sign_in}, then call other
  # instance methods as required to perform the actions you are interested in. See `README.md` for a usage example.
  #
  # If any errors occur while executing requests to the IG Markets API then {RequestFailedError} will be raised.
  class DealingPlatform
    # @return [Session] The session used by this dealing platform.
    attr_reader :session

    # @return [AccountMethods] Helper for working with the logged in account.
    attr_reader :account

    # @return [ClientSentimentMethods] Helper for working with client sentiment.
    attr_reader :client_sentiment

    # @return [MarketMethods] Helper for working with markets.
    attr_reader :markets

    # @return [PositionMethods] Helper for working with positions.
    attr_reader :positions

    # @return [SprintMarketPositionMethods] Helper for working with sprint market positions.
    attr_reader :sprint_market_positions

    # @return [WatchlistMethods] Helper for working with watchlists.
    attr_reader :watchlists

    # @return [WorkingOrderMethods] Helper for working with working orders.
    attr_reader :working_orders

    def initialize
      @session = Session.new

      @account = AccountMethods.new self
      @client_sentiment = ClientSentimentMethods.new self
      @markets = MarketMethods.new self
      @positions = PositionMethods.new self
      @sprint_market_positions = SprintMarketPositionMethods.new self
      @watchlists = WatchlistMethods.new self
      @working_orders = WorkingOrderMethods.new self
    end

    # Signs in to the IG Markets Dealing Platform, either the production platform or the demo platform.
    #
    # @param [String] username The account username.
    # @param [String] password The account password.
    # @param [String] api_key The account API key.
    # @param [:production, :demo] platform The platform to use.
    #
    # @return [void]
    def sign_in(username, password, api_key, platform)
      session.username = username
      session.password = password
      session.api_key = api_key
      session.platform = platform

      session.sign_in
    end

    # Signs out of the IG Markets Dealing Platform, ending any current session.
    #
    # @return [void]
    def sign_out
      session.sign_out
    end

    # Returns a full deal confirmation for the specified deal reference.
    #
    # @return [DealConfirmation]
    def deal_confirmation(deal_reference)
      DealConfirmation.from session.get "confirms/#{deal_reference}", API_V1
    end

    # Returns details on the IG Markets applications for the accounts associated with this login.
    #
    # @return [Array<Application>]
    def applications
      Application.from session.get 'operations/application', API_V1
    end

    # Sends a GET request to a URL then takes a single key from the returned hash and converts its contents to an array
    # of type `klass`.
    #
    # @param [String] url The URL to send a GET request to.
    # @param [Symbol] collection The name of the top level symbol that contains the array of data to return.
    # @param [Class] klass The type to return
    # @param [API_V1, API_V2] api_version The API version to target for the request
    #
    # @return [Array]
    def gather(url, collection, klass, api_version = API_V1)
      klass.from(session.get(url, api_version).fetch(collection)).tap do |result|
        # Set @dealing_platform on all the results
        result.each do |item|
          item.instance_variable_set :@dealing_platform, self
        end
      end
    end
  end
end
