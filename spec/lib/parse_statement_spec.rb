require 'rails_helper'

describe ParseStatement do

  def run_parse(_transactions = [], balance = 10_000.00)
    string = StringIO.new <<-END
OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

<OFX>
<SIGNONMSGSRSV1>
   <SONRS>
      <STATUS>
         <CODE>0
         <SEVERITY>INFO
      </STATUS>
      <DTSERVER>20150116120000
      <LANGUAGE>ENG
      <FI>
         <ORG>Harris N.A. - New Online Banking
         <FID>9931
      </FI>
      <INTU.BID>1334
      <INTU.USERID>someone
   </SONRS>
</SIGNONMSGSRSV1>
<BANKMSGSRSV1>
   <STMTTRNRS>
      <TRNUID>0
      <STATUS>
         <CODE>0
         <SEVERITY>INFO
      </STATUS>
      <STMTRS>
         <CURDEF>USD
         <BANKACCTFROM>
            <BANKID>123410
            <ACCTID>11
            <ACCTTYPE>CHECKING
         </BANKACCTFROM>
         <BANKTRANLIST>
            <DTSTART>20150116120000
            <DTEND>20150116120000
         </BANKTRANLIST>
         <LEDGERBAL>
            <BALAMT>#{balance}
            <DTASOF>20150116120000
         </LEDGERBAL>
      </STMTRS>
   </STMTTRNRS>
</BANKMSGSRSV1>
</OFX>
    END
    ParseStatement.run(string)
  end

  describe 'an empty run' do
    it 'returns no transaction' do
      bank_entry_attrs, balance = run_parse

      expect(bank_entry_attrs).to eq([])
      expect(balance).to eq(10_000.0.to_s)
    end
  end
end
