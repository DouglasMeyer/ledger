module ParseStatement
  module MoneyParser
    def self.included(klass)
      klass.module_eval do

        def self.statement_attr(attr, key, &block)
          define_method attr do
            value = raw.scan(/<#{key}>(.*)/)[0][0].strip
            value = block.call(value) if block_given?
            value
          end
        end

        def self.parse(file)
          data = file.read
          balance = file.read.scan(/<LEDGERBAL>.*?<.LEDGERBAL>/m)[0].scan(/<BALAMT>(.*)/)[0][0].strip.to_f
          transactions = data.scan(/<STMTTRN>.*?<.STMTTRN>/m).map do |x|
            StatementEntry.new(x)
          end
          transactions.sort_by{|t| t.id }.reverse.each do |transaction|
            transaction.balance = balance
            balance -= transaction.ammount
          end
        end

      end
    end
  end

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
      balance = file.read.scan(/<LEDGERBAL>.*?<.LEDGERBAL>/m)[0].scan(/<BALAMT>(.*)/)[0][0].strip
      balance = BigDecimal.new(balance)
      transactions = data.scan(/<STMTTRN>.*?<.STMTTRN>/m).map do |x|
        StatementEntry.new(x)
      end
      transactions.sort_by{|t| t.id }.reverse.each do |transaction|
        transaction.balance = balance
        balance -= transaction.ammount
      end
    end

    attr_reader :raw
    statement_attr :type,    'TRNTYPE'
    statement_attr(:id,      'FITID'   ){ |string| string.to_i }
    statement_attr :name,    'NAME'
    statement_attr :memo,    'MEMO'
    statement_attr(:date,    'DTPOSTED'){ |string| DateTime.parse(string) }
    statement_attr(:ammount, 'TRNAMT'  ){ |string| BigDecimal.new(string) }
    attr_accessor :balance

    def initialize(raw)
      @raw = raw
    end

    def ammount_cents
      ammount.to_f * 100
    end

    def inspect
      attrs = %w(type id name memo).inject({}){|a,e| a[e.to_sym] = send(e); a}
      attrs[:ammount] = ammount.to_f
      attrs[:balance] = balance.to_f
      attrs[:date] = date.strftime("%D")
      "#<StatementEntry: #{attrs.inspect}>"
    end
  end

  def self.run(file)
    require 'pathname'
    require 'pp'
    require 'date'

    transactions = StatementEntry.parse(file).sort_by{|tr| tr.id }
    return unless transactions.any?
    pp transactions

    transactions.map do |t|
      {
          external_id: t.id,
                 date: t.date,
        ammount_cents: t.ammount_cents,
   bank_balance_cents: (t.balance.to_f * 100).to_i,
                notes: "#{t.type}: #{t.memo}",
          description: t.name
      }
    end
  end
end
