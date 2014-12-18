class Memos
  include Cinch::Plugin

  listen_to :message

  match /(msg|tell|ask) (.+?) (.+)/i, method: :memo

  def memo(m, mtype, who, text)
    if who == m.user.nick
      m.reply "tell that to yourself...", true
    elsif who == m.bot.nick
      m.reply "I'm not interested.", true
    elsif
      location = if m.channel then m.channel.to_s else 'private 'end
      save_memo(who, m.user.nick, location, mtype, text, DateTime.now)
      m.reply "#{m.user.nick}: I'll let #{who} know when I see them."
    end
  end

  def listen(m)
    #This is stuff.
    memos = get_memos(m.user.nick)
    if memos.any?
      memos.each do |mem|
        if mem[3] == "ask"
          memtype = "asked"
        else
          memtype = "told"
        end
        m.reply "#{mem[1]} #{memtype} you \"#{mem[4]}\" on #{mem[5]}", true
      end
    end
  end

end