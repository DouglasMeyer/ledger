
module API
  module BankEntryAutocomplete_v1
    extend Service

    def self.read(command)
      require 'ollama-ai'
      bank_entries = BankEntry.where(id: command['ids'])
      recent_bank_entries = BankEntry.includes(:accounts).limit(50).
        filter{|be| be.amount_remaining == 0}

      prompt = <<~PROMPT
        Given this table of recent entries:
        | amount_cents | description | accounts |
        ---
        #{recent_bank_entries.map{|bank_entry|
         "| #{bank_entry.amount_cents} | #{bank_entry.description} | #{bank_entry.account_entries.map(&:account_name).to_json} |"
        }.join("\n")}

        What would the accounts look like for these entries:
        | id | amount_cents | description |
        ---
        #{bank_entries.map{|bank_entry|
         "| #{bank_entry.id} | #{bank_entry.amount_cents} | #{bank_entry.description} |"
        }.join("\n")}

        Only respond with JSON, no additional formatting:
        {
          "#{command['ids'].first}": [ "Account" ],
        }
      PROMPT

      json_result = Rails.cache.fetch(prompt, expires_in: 7.days) do
        client = Ollama.new(
        )


        result = client.generate({
          model:,
          prompt:,
          stream: false,
          format: 'json'
        })

        JSON.parse(result.first['response'])
      end

      { result: json_result }
    end
  end
end
