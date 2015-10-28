module ParseStatement
  class StatementEntry
    def self.statement_attr(attr, key, &block)
      define_method attr do
        value = raw.scan(/<#{key}>(.*)/)[0][0].strip
        value = block.call(value) if block_given?
        value
      end
    end

    def self.parse(file)
      data = file.read
      balance = data
                .scan(/<LEDGERBAL>.*?<.LEDGERBAL>/m)[0]
                .scan(/<BALAMT>(.*)/)[0][0]
                .strip
      transactions = data.scan(/<STMTTRN>.*?<.STMTTRN>/m).map do |x|
        StatementEntry.new(x)
      end
      [ transactions, balance ]
    end

    attr_reader :raw
    statement_attr(:type,   "TRNTYPE")
    statement_attr(:id,     "FITID", &:to_i)
    statement_attr(:name,   "NAME")
    statement_attr(:memo,   "MEMO")
    statement_attr(:date,   "DTPOSTED") { |string| DateTime.parse(string) }
    statement_attr(:amount, "TRNAMT") { |string| BigDecimal.new(string) }

    def initialize(raw)
      @raw = raw
    end

    def amount_cents
      amount.to_f * 100
    end

    def inspect
      attrs = %w(type id name memo).each_with_object({}) do |e, a|
        a[e.to_sym] = send(e)
      end
      attrs[:amount] = amount.to_f
      attrs[:date] = date.strftime("%D")
      "#<StatementEntry: #{attrs.inspect}>"
    end
  end

  def self.run(file)
    require "pathname"
    require "pp"
    require "date"

    transactions, balance = StatementEntry.parse(file)

    transactions.sort_by!(&:id)

    transactions.map! do |t|
      {
        external_id: t.id,
        date: t.date,
        amount_cents: t.amount_cents,
        notes: "#{t.type}: #{t.memo}",
        description: t.name
      }
    end

    [ transactions, balance ]
  end
end
