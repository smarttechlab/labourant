require 'telegram/bot'
require_relative 'labourant/upwork'
require 'awesome_pry'

module Labourant
  LIMIT = 5

  class << self
    def start
      Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN'], logger: Logger.new(STDOUT)) do |bot|
        bot.listen do |message|
          case message.text
          when %r(/jobs (?<keywords>.*$))
            keywords = Regexp.last_match[:keywords]
            bot.api.send_message(chat_id: message.chat.id, text: "Searching for jobs with '#{keywords}'...")

            response = upwork.find_jobs(q: keywords, limit: LIMIT)
            total_found = response['paging']['total']
            offers = response['jobs']
            bot.api.send_message(chat_id: message.chat.id, text: "Showing first #{offers.count} of #{total_found} jobs:")

            offers.each do |offer|
              bot.api.send_message(
                chat_id: message.chat.id,
                text: "[#{offer['title']}](#{offer['url']}) | #{offer['skills'].join(', ')}",
                parse_mode: 'Markdown'
              )
            end
          else
            file_id = 'AgADAgADqacxGyi26Afsf6Keo16E3KZjhCoABHn6hNmneqljmboAAgI'
            bot.api.send_photo(chat_id: message.chat.id, photo: file_id)
          end
        end
      end
    end

  private
    def upwork
      @upwork ||= Upwork.new
    end
  end
end
