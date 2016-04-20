describe IGMarkets::CLI::Positions do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Positions.new [], arguments
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints positions' do
    positions = [build(:position), build(:position)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli.list }.to output(<<-END
+---------------------------+--------------------+-----------+------+----------+----------+----------+---------+-------------+----------+
|                                                               Positions                                                               |
+---------------------------+--------------------+-----------+------+----------+----------+----------+---------+-------------+----------+
| Date                      | EPIC               | Direction | Size | Level    | Current  | Limit    | Stop    | Profit/loss | Deal IDs |
+---------------------------+--------------------+-----------+------+----------+----------+----------+---------+-------------+----------+
| 2015-07-24 09:12:37 +0000 | CS.D.EURUSD.CFD.IP | Buy       | 10.4 | 100.0000 | 100.0000 | 110.0000 | 90.0000 | USD 0.00    | deal_id  |
| 2015-07-24 09:12:37 +0000 | CS.D.EURUSD.CFD.IP | Buy       | 10.4 | 100.0000 | 100.0000 | 110.0000 | 90.0000 | USD 0.00    | deal_id  |
+---------------------------+--------------------+-----------+------+----------+----------+----------+---------+-------------+----------+
END
                                 ).to_stdout
  end

  it 'prints positions in aggregate' do
    positions = [build(:position, level: 100.0, size: 1), build(:position, level: 130.0, size: 2)]

    expect(dealing_platform.positions).to receive(:all).and_return(positions)

    expect { cli(aggregate: true).list }.to output(<<-END
+------+--------------------+-----------+------+----------+----------+-------+------+--------------+------------------+
|                                                      Positions                                                      |
+------+--------------------+-----------+------+----------+----------+-------+------+--------------+------------------+
| Date | EPIC               | Direction | Size | Level    | Current  | Limit | Stop | Profit/loss  | Deal IDs         |
+------+--------------------+-----------+------+----------+----------+-------+------+--------------+------------------+
|      | CS.D.EURUSD.CFD.IP | Buy       | 3    | 120.0000 | 100.0000 |       |      | USD -6000.00 | deal_id, deal_id |
+------+--------------------+-----------+------+----------+----------+-------+------+--------------+------------------+
END
                                                  ).to_stdout
  end

  it 'creates a new position' do
    arguments = {
      currency_code: 'USD',
      direction: 'buy',
      epic: 'CS.D.EURUSD.CFD.IP',
      size: 2
    }

    expect(dealing_platform.positions).to receive(:create).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).create
  end

  it 'updates a position' do
    arguments = {
      limit_level: 20,
      stop_level: 30
    }

    position = build :position

    expect(dealing_platform.positions).to receive(:[]).with('deal_id').and_return(position)
    expect(position).to receive(:update).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).update 'deal_id'
  end

  it 'can remove a stop and limit from a position' do
    arguments = { limit_level: '', stop_level: 'stop_level' }

    position = build :position

    expect(dealing_platform.positions).to receive(:[]).with('deal_id').and_return(position)
    expect(position).to receive(:update).with(limit_level: '', stop_level: nil).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).update 'deal_id'
  end

  it 'closes a position' do
    arguments = { size: 1 }

    position = build :position

    expect(dealing_platform.positions).to receive(:[]).with('deal_id').and_return(position)
    expect(position).to receive(:close).with(arguments).and_return('ref')
    expect(IGMarkets::CLI::Main).to receive(:report_deal_confirmation).with('ref')

    cli(arguments).close 'deal_id'
  end
end
