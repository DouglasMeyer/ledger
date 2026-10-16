
module API
  module BankEntryAutocomplete_v1
    extend Service

    def self.read(command)
      address = ENV['OLLAMA_ADDRESS']
      model = ENV['OLLAMA_MODEL']

      return { result: {} } if address.blank? || model.blank?

      require 'ollama-ai'
      bank_entries = BankEntry.where(id: command['ids'])
      recent_bank_entries = BankEntry.includes(:accounts).limit(50).
        filter{|be| be.amount_remaining == 0}

      prompt = <<~PROMPT
        Given this table of recent entries:
        | amount_cents | description | accounts |
        | --- | --- | --- |
        #{recent_bank_entries.map{ |bank_entry|
          [
            bank_entry.amount_cents,
            bank_entry.description,
            bank_entry.account_entries.map(&:account_name).to_json
          ].then { |vals| "| #{ vals.join(' | ') } |" }
        }.join("\n")}

        What would the accounts look like for these entries:
        | id | amount_cents | description |
        | --- | --- | --- |
        #{bank_entries.map{ |bank_entry|
          [
            bank_entry.id,
            bank_entry.amount_cents,
            bank_entry.description
          ].then { |vals| "| #{ vals.join(' | ') } |" }
        }.join("\n")}

        Only respond with JSON, no additional formatting:
        {
          "#{command['ids'].first}": [ "Account" ],
        }
      PROMPT

      # A job or a request may cause multiple triggers. For our use-case, we only want 1 call at a time
      json_result = BankEntry.with_advisory_lock("autocomplete") do
        Rails.cache.fetch(prompt, expires_in: 7.days) do
          client = Ollama.new(credentials: { address: })

          result = client.generate({
            model:,
            prompt:,
            stream: false,
            format: 'json'
          })

          JSON.parse(result.first['response'])
        end
      end

      { result: json_result }
    end
  end
end
