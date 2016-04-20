describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: 'username', password: 'password', api_key: 'api-key' }.merge(arguments)
  end

  before do
    IGMarkets::CLI::Main.instance_variable_set :@dealing_platform, dealing_platform
  end

  it 'correctly signs in' do
    expect(dealing_platform).to receive(:sign_in).with('username', 'password', 'api-key', :production)

    IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
  end

  it 'reports an argument error' do
    expect(dealing_platform).to receive(:sign_in).and_raise(ArgumentError, 'test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("Argument error: test\n").to_stderr.and raise_error(SystemExit)
  end

  it 'reports a request failure' do
    expect(dealing_platform).to receive(:sign_in).and_raise(IGMarkets::RequestFailedError, 'test')

    expect do
      IGMarkets::CLI::Main.begin_session(cli.options) { |dealing_platform| }
    end.to output("Request error: test\n").to_stderr.and raise_error(SystemExit)
  end

  it 'reports a deal confirmation' do
    deal_confirmation = build :deal_confirmation

    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

    expect { IGMarkets::CLI::Main.report_deal_confirmation 'ref' }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, accepted, epic: CS.D.EURUSD.CFD.IP
END
                                                                            ).to_stdout
  end

  it 'reports a deal confirmation that was rejected' do
    deal_confirmation = build :deal_confirmation, deal_status: :rejected, reason: :unknown

    expect(dealing_platform).to receive(:deal_confirmation).with('ref').and_return(deal_confirmation)

    expect { IGMarkets::CLI::Main.report_deal_confirmation 'ref' }.to output(<<-END
Deal reference: ref
Deal confirmation: deal_id, rejected, reason: unknown, epic: CS.D.EURUSD.CFD.IP
END
                                                                            ).to_stdout
  end

  it 'reports the version' do
    ['-v', '--version'].each do |argument|
      expect do
        IGMarkets::CLI::Main.bootstrap [argument]
      end.to output("#{IGMarkets::VERSION}\n").to_stdout.and raise_error(SystemExit)
    end
  end

  it 'runs with no config file' do
    expect(IGMarkets::CLI::ConfigFile).to receive(:find).and_return(nil)
    expect(IGMarkets::CLI::Main).to receive(:start).with(['--test'])

    IGMarkets::CLI::Main.bootstrap ['--test']
  end

  it 'uses a config file if present' do
    config_file = instance_double IGMarkets::CLI::ConfigFile

    expect(config_file).to receive(:arguments).and_return(['--username', 'USER'])
    expect(IGMarkets::CLI::ConfigFile).to receive(:find).and_return(config_file)
    expect(IGMarkets::CLI::Main).to receive(:start).with(['--username', 'USER', '--test'])

    IGMarkets::CLI::Main.bootstrap ['--test']
  end
end
