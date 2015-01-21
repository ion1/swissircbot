class Define
  include Cinch::Plugin

  match /(?:define|def)$/i, method: :cblankdef
  match /(?:define|def) (\S+)(?: (.+))?/i, method: :cdef
  match /forget (.+)/i, method: :cforget
  match /forgetme/i, method: :cforgetme

  def cblankdef(m)
    dm = get_definition(m.user.nick)
    if dm.present?
      m.reply dm[0], true
    else
      m.reply "I don't know about you!", true
    end
  end

  def cdef(m,term,meaning)
    term = m.user.nick unless term.present?
    if meaning.present?
      save_definition(m.user.nick, term, meaning)
      m.reply "I've saved that for you boss", true
    else
      dm = get_definition(term)
      p dm
      if dm.present?
        m.reply "#{term} #{dm[0]}"
      else
        m.reply "I don't know about #{term}", true
      end
    end
  end

  def cforget(m,term)
    dm = del_definition(term)
    if dm.present?
      m.reply "Huh? I forgot what #{term} was..", true
    else
      m.reply "I can't forget that.", true
    end
  end

  def cforgetme(m)
    dm = del_definition(m.user.nick)
    if dm.present?
      m.reply "Who is #{m.user.nick}?"
    else
      m.reply "SOmething is horribly wrong.", true
    end
  end

end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        