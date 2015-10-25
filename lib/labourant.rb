require 'telegram/bot'
require_relative 'labourant/upwork'
require 'awesome_pry'

module Labourant
  LIMIT = 5

  class << self
    def start
      telegram.listen do |message|
        case message.text
        when %r(/jobs (?<keywords>.*$))
          keywords = Regexp.last_match[:keywords]
          last_searches[message.chat.id] = [keywords, 0]
          telegram.api.send_message(chat_id: message.chat.id, text: "Searching for jobs with '#{keywords}'...")

          response = upwork.find_jobs(q: keywords, limit: LIMIT)

          if response['jobs'].empty?
            telegram.api.send_message(chat_id: message.chat.id, text: 'No jobs found')
          else
            telegram.api.send_message(
              chat_id: message.chat.id,
              text: "Showing 1..#{response['jobs'].count} of #{response['paging']['total']} jobs:"
            )

            response['jobs'].each do |offer|
              telegram.api.send_message(
                chat_id: message.chat.id,
                text: "[#{offer['title']}](#{offer['url']}) | #{offer['skills'].join(', ')}",
                parse_mode: 'Markdown'
              )
            end
          end
        when '/more'
          if last_search = last_searches[message.chat.id]
            new_offset = last_search.last + LIMIT
            last_searches[message.chat.id] = [last_search.first, new_offset]
            telegram.api.send_message(chat_id: message.chat.id, text: "Searching for more jobs with '#{last_search.first}'...")

            response = upwork.find_jobs(q: last_search.first, limit: LIMIT, offset: new_offset)

            if response['jobs'].empty?
              telegram.api.send_message(chat_id: message.chat.id, text: 'No jobs found')
            else
              telegram.api.send_message(
                chat_id: message.chat.id,
                text: "Showing #{new_offset + 1}..#{new_offset + response['jobs'].count} of #{response['paging']['total']} jobs:"
              )

              response['jobs'].each do |offer|
                telegram.api.send_message(
                  chat_id: message.chat.id,
                  text: "[#{offer['title']}](#{offer['url']}) | #{offer['skills'].join(', ')}",
                  parse_mode: 'Markdown'
                )
              end
            end
          else
            telegram.api.send_message(
              chat_id: message.chat.id,
              text: 'Use /jobs command first.'
            )
          end
        else
          file_id = 'AgADAgADqacxGyi26Afsf6Keo16E3KZjhCoABHn6hNmneqljmboAAgI'
          telegram.api.send_photo(chat_id: message.chat.id, photo: file_id)
        end
      end
    end

  private
    def last_searches
      @last_searches ||= {}
    end

    def telegram
      Telegram::Bot::Client.new(ENV['TELEGRAM_TOKEN'], logger: Logger.new(STDOUT))
    end

    def upwork
      @upwork ||= Upwork.new
    end
  end
end
