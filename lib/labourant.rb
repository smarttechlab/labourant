require 'telegram/bot'
require_relative 'labourant/upwork'

module Labourant
  class << self
    def start
      Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN'], logger: Logger.new(STDOUT)) do |bot|
        bot.listen do |message|
          case message.text
          when '/start'
            bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
          when '/stop'
            bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
          when '/wat'
            file_id = 'AgADAgADqacxGyi26Afsf6Keo16E3KZjhCoABHn6hNmneqljmboAAgI'
            bot.api.send_photo(chat_id: message.chat.id, photo: file_id)
          end
        end
      end
    end
  end
end
