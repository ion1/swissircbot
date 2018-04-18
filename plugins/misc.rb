class Misc
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
4d3d3d3 [optionaluser]
  This will send a link to the 4d3d3d3 video to the channel, optionaluser will be highlighted if provided.
numa [optionaluser]
  This will send a link to the numa video to the channel, optionaluser will be highlighted if provided.
yo [optionaluser]
  This will reply to you with "Yo!", optionaluser will get the highlight instead if provided.
  HELP

  match /4d3d3d3(?: (.+))?/i, method: :c4d3d3d3
  match /yo(?: (.+))?/i, method: :cyo
  match /numa(?: (.+))?/i, method: :cnuma

  def c4d3d3d3(m, nick) #OhGodWhy
    if !is_blacklisted?(m.channel, m.user.nick)
      if nick.nil?
        m.reply "https://www.youtube.com/watch?v=XWX4GUYGQXQ", true
      else
        m.reply "#{nick}: #{m.user.nick} points you to https://www.youtube.com/watch?v=XWX4GUYGQXQ"
      end
    else
      m.user.send BLMSG
    end
  end

  def cyo(m, nick) #Sigh...the things I do for you people.
    if !is_blacklisted?(m.channel, m.user.nick)
      if nick.nil?
        m.reply "Yo!", true
      else
        m.reply "#{nick}: #{m.user.nick} says Yo!"
      end
    else
      m.user.send BLMSG
    end
  end

  def cnuma(m, nick) #AgeOldAwesome!
    if !is_blacklisted?(m.channel, m.user.nick)
      if nick.nil?
        m.reply "https://www.youtube.com/watch?v=KmtzQCSh6xk", true
      else
        m.reply "#{nick}: #{m.user.nick} points you to https://www.youtube.com/watch?v=KmtzQCSh6xk"
      end
    else
      m.user.send BLMSG
    end
  end

end