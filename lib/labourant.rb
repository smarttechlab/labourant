require 'telegram/bot'
require_relative 'labourant/upwork'
require 'awesome_pry'

module Labourant
  LIMIT = 5

  class << self
    def start
      telegram.listen do |message|
        user_id = message.chat.id

        if authorized_uids.include?(user_id)
          case message.text
          when %r(/jobs (?<keywords>.*$))
            keywords = Regexp.last_match[:keywords]
            last_searches[user_id] = [keywords, 0]
            send_message("Searching for jobs with '#{keywords}'...", to: user_id)

            find_and_send_jobs(keywords, 0, user_id)
          when '/more'
            if last_search = last_searches[user_id]
              new_offset = last_search.last + LIMIT
              last_searches[user_id] = [last_search.first, new_offset]
              send_message("Searching for more jobs with '#{last_search.first}'...", to: user_id)

              find_and_send_jobs(last_search.first, new_offset, user_id)
            else
              send_message('Use /jobs command first.', to: user_id)
            end
          else
            file_id = 'AgADAgADqacxGyi26Afsf6Keo16E3KZjhCoABHn6hNmneqljmboAAgI'
            telegram.api.send_photo(chat_id: user_id, photo: file_id)
          end
        else
          send_message('You are not allowed to use this bot', to: user_id)
        end
      end
    end

  private
    def find_and_send_jobs(keywords, offset, user_id)
      response = upwork.find_jobs(q: keywords, limit: LIMIT, offset: offset)

      if response['jobs'].empty?
        send_message('No jobs found', to: user_id)
      else
        text = "Showing #{offset + 1}..#{offset + response['jobs'].count} of #{response['paging']['total']} jobs:"
        send_message(text, to: user_id)

        response['jobs'].each do |offer|
          text = "[#{offer['title']}](#{offer['url']}) | #{offer['skills'].join(', ')}"
          send_message(text, to: user_id, parse_mode: 'Markdown')
        end
      end
    end

    def send_message(message, to:, **options)
      telegram.api.send_message(chat_id: to, text: message, **options)
    end

    def last_searches
      @last_searches ||= {}
    end

    def authorized_uids
      ENV['AUTHORIZED_UIDS'].split(',').map(&:to_i)
    end

    def telegram
      Telegram::Bot::Client.new(ENV['TELEGRAM_TOKEN'], logger: Logger.new(STDOUT))
    end

    def upwork
      @upwork ||= Upwork.new
    end
  end
end
