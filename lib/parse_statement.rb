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
      balance = data.scan(/<LEDGERBAL>.*?<.LEDGERBAL>/m)[0].scan(/<BALAMT>(.*)/)[0][0].strip
      transactions = data.scan(/<STMTTRN>.*?<.STMTTRN>/m).map do |x|
        StatementEntry.new(x)
      end
      [ transactions, balance ]
    end

    attr_reader :raw
    statement_attr :type,    'TRNTYPE'
    statement_attr(:id,      'FITID'   ){ |string| string.to_i }
    statement_attr :name,    'NAME'
    statement_attr :memo,    'MEMO'
    statement_attr(:date,    'DTPOSTED'){ |string| DateTime.parse(string) }
    statement_attr(:ammount, 'TRNAMT'  ){ |string| BigDecimal.new(string) }

    def initialize(raw)
      @raw = raw
    end

    def ammount_cents
      ammount.to_f * 100
    end

    def inspect
      attrs = %w(type id name memo).inject({}){|a,e| a[e.to_sym] = send(e); a}
      attrs[:ammount] = ammount.to_f
      attrs[:date] = date.strftime("%D")
      "#<StatementEntry: #{attrs.inspect}>"
    end
  end

  def self.run(file)
    require 'pathname'
    require 'pp'
    require 'date'

    transactions, balance = StatementEntry.parse(file)
    return unless transactions.any?

    transactions.sort_by!{|tr| tr.id }

    transactions.map! do |t|
      {
          external_id: t.id,
                 date: t.date,
        ammount_cents: t.ammount_cents,
                notes: "#{t.type}: #{t.memo}",
          description: t.name
      }
    end

    [ transactions, balance ]
  end
end
