class Quotes
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
addquote <quote>
  This will save quote.
deletequote/delquote/rmquote <id>
  This will remove the quote matching the given id.
findquote/quote [optionalsearch]
  This will return a random quote unless optionalsearch is specified, which will return a quote matching that term.
getquote <id>
  This will return the quote with the given id.
randquote
  This will return a random quote.
quiteinfo/qinfo <quote>
  This will return info about the quote (who saved it and when).
  HELP

  match /addquote (.+)/i, method: :addquote
  match /getquote (.+)/i, method: :getquote
  match /(?:deletequote|delquote|rmquote) (.+)/i, method: :delquote
  match /(?:findquote|quote)\b(?: (.+))?/i, method: :findquote
  match /randquote\b/i, method: :randquote
  match /(?:quoteinfo|qinfo) (.+)/i, method: :quoteinfo

  def addquote(m, quote)
    if !is_blacklisted?(m.channel, m.user.nick)
      sq = add_quote(m.user.nick, quote, DateTime.now)
      m.reply "Quote #{sq} saved", true
    else
      m.user.send BLMSG
    end
  end

  def getquote(m, qid)
    if !is_blacklisted?(m.channel, m.user.nick)
      quote = get_quote(qid)
      if quote.any?
        quote.each do |q|
          m.reply "That was #{q[0]}", true
        end
      else
        m.reply "That quote doesn't exist, sorry.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def delquote(m, qid)
    if !is_blacklisted?(m.channel, m.user.nick)
      if is_supadmin?(m.user) || is_admin?(m.user) || is_mod?(m.user)
        if del_quote(qid) == 1
          m.reply "Quote #{qid} has been deleted.", true
        else
          m.reply "That quote doesn't exist, sorry.", true
        end
      else
        m.reply NOTADMIN, true
      end
    else
      m.user.send BLMSG
    end
  end

  def findquote(m, text)
    if !is_blacklisted?(m.channel, m.user.nick)
      if text.nil?
        quote = rand_quote()
        if quote.any?
          m.reply "[#{quote[0][0]}] #{quote[0][1]}", true
        else
          m.reply "Sorry, there are no quotes to find.", true
        end
      elsif text.strip.empty?
        quote = rand_quote()
        if quote.any?
          m.reply "[#{quote[0][0]}] #{quote[0][1]}", true
        else
          m.reply "Sorry, there are no quotes to find.", true
        end
      else
        quote = find_quote(text)
        if quote.any?
          m.reply "[#{quote[0][0]}] #{quote[0][1]}", true
        else
          m.reply "Sorry, couldn't find a quote matching that.", true
        end
      end
    else
      m.user.send BLMSG
    end
  end

  def randquote(m)
    if !is_blacklisted?(m.channel, m.user.nick)
      quote = rand_quote()
      if quote.any?
        m.reply "[#{quote[0][0]}] #{quote[0][1]}", true
      else
        m.reply "Sorry, there are no quotes to find.", true
      end
    else
      m.user.send BLMSG
    end
  end

  def quoteinfo(m, qid)
    if is_supadmin?(m.user) || is_admin?(m.user) || is_mod?(m.user)
      quote = quote_info(qid)
      if quote.any?
        m.reply "Quote ##{quote[0][0]}, \"#{quote[0][1]}\" was saved by #{quote[0][2]} on #{quote[0][3]}.", true
      else
        m.reply "That quote doesn't exist, sorry.", true
      end
    else
      m.reply NOTADMIN, true
    end
  end

end
