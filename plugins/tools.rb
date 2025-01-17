class Tools
  include Cinch::Plugin
  include CustomHelpers

  set :help, <<-HELP
kick <user> [optreason]
  This kicks user, with optreason if given.
r <user>
  This /removes the user.
ban <user> [optreason]
  This bans user, with optreason if given.
unban <user>
  This unbans user.
mute <user>
  This mutes user.
unmute <user>
  This unmutes user.
op <user>
  This ops user.
deop <user>
  This deops user.
addadmin <user> [optchannel]
  This adds user as an admin of this bot in this channel or in optchannel if given.
remadmin <user> [optchannel]
  This removes user as an admin of this bot in this channel or in optchannel if given.
listadmin/listadmins [optchannel]
  This lists all the admins of this bot in this channel or in optchannel if given.
listalladmin/listalladmins
  This lists all the admins of this bot.
addmod <user> [optchannel]
  This adds user as a mod of this bot in this channel or in optchannel if given.
remmod <user> [optchannel]
  This removes user as a mod of this bot in this channel or in optchannel if given.
listmod/listmods
  This lists the mods of this bot.
topic <topic>
  This sets the topic for this channel.
whoami
  This returns who the bot sees you as with all of your roles given to the bot.
whois <user>
  This returns who the bot sees <user> as with all of their roles given to the bot.
db <query>
  Runs the given query against the database and returns the results.
  HELP

  match /kick (\S+)(?: (.+))?/i, method: :ckick
  match /r (.+?)/i, method: :crem
  match /ban (\S+)(?: (.+))?/i, method: :cban
  match /unban (.+)/i, method: :cunban
  match /mute (.+)/i, method: :cmute
  match /unmute (.+)/i, method: :cunmute
  match /op (.+)/i, method: :cop
  match /deop (.+)/i, method: :cdeop
  match /addadmin (\S+)(?: (.+))?/i, method: :caddadmin
  match /(?:remadmin|rmadmin) (\S+)(?: (.+))?/i, method: :cremadmin
  match /(?:listadmin|listadmins)(?: (.+))?/i, method: :clistadmins
  match /(?:listalladmin|listalladmins)/i, method: :clistalladmins
  match /addmod (\S+)(?: (.+))?/i, method: :caddmod
  match /(?:remmod|rmmod) (\S+)(?: (.+))?/i, method: :cremmod
  match /(?:listmod|listmods)/i, method: :clistmods
  match /topic (.+)$/i, method: :ctopic
  match /whoami/i, method: :cwhoami
  match /whois (.+)/i, method: :cwhois
  match /db (.+)/i, method: :cdbquery

  # Kick a user from a channel for a specific reason (or no reason)
  def ckick(m, nick, reason)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.kick(nick, reason)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Remove a user from a channel, similar to kick, but silent
  def crem(m, nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.remove(nick)
    elsif !is_chanadmin?(m.channel,m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Ban a user from a channel for a reason
  def cban(m, nick, reason)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.ban(nick.mask)
      m.channel.kick(nick, reason)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Unban a user from a channel
  def cunban(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.unban(nick.mask)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Mute a user in a channel
  def cmute(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      User('ChanServ').send("quiet #{m.channel} #{nick}")
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # UnMute a user in a channel
  def cunmute(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      User('ChanServ').send("unquiet #{m.channel} #{nick}")
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Op a user in a channel
  def cop(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.op(m.channel, nick)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # DeOp a user in a channel
  def cdeop(m, nick)
    nick = User(nick)
    if is_chanadmin?(m.channel, m.user) && is_botpowerful?(m.channel)
      m.channel.deop(m.channel, nick)
    elsif !is_chanadmin?(m.channel, m.user)
      m.reply NOTADMIN, true
    elsif !is_botpowerful?(m.channel)
      m.reply NOTOPBOT, true
    end
  end

  # Add a user as an admin of the bot for a specific channel (or current channel if none specified)
  def caddadmin(m, nick, channel)
    channel = m.channel if channel.nil?
    if is_chanadmin?(channel, m.user) || is_supadmin?(m.user)
      $adminhash[channel] << nick
      $config['admin']['channel'] = $adminhash
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been added as an admin for #{channel}.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Remove a user as an admin of the bot for the specific channel (or current channel if none specified)
  def cremadmin(m, nick, channel)
    channel = m.channel if channel.nil?
    if is_chanadmin?(channel, m.user) || is_supadmin?(m.user)
      $adminhash[channel].delete nick
      $config['admin']['channel'] = $adminhash
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been removed as an admin for #{channel}.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # List the admins for the bot for the specific channel (or current if none specified)
  def clistadmins(m, channel)
    channel = m.channel if channel.nil?
    if is_supadmin?(m.user) || is_admin?(m.user) || is_chanadmin?(channel, m.user)
      m.reply "The current admins are #{$adminhash[channel]}.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # List the admins for the bot for all channels
  def clistalladmins(m)
    if is_supadmin?(m.user) || is_admin?(m.user)
      m.reply "The current admins are #{$adminhash}.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Add a user as a moderator of this bot
  def caddmod(m, nick)
    if is_supadmin?(m.user)
      $moderators << nick
      $config['moderator'] = $moderators
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been added as a moderator.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Remove a user as a moderator of this bot
  def cremmod(m, nick)
    if is_supadmin?(m.user)
      $moderators.delete nick
      $config['moderator'] = $moderators
      File.open($conffile, 'wb') { |f| f.write $config.to_yaml }
      m.reply "#{nick} has been removed as a moderator.", true
    else
      m.reply NOTADMIN, true
    end
  end

  # List all of the mods
  def clistmods(m)
    if is_supadmin?(m.user) || is_admin?(m.user) || is_chanadmin?(m.channel, m.user) || is_mod?(m.user)
      m.reply "The current mods are #{$moderators}", true
    else
      m.reply NOTADMIN, true
    end
  end

  # Change the topic of the current channel
  def ctopic(m, topic)
    if m.channel.nil?
      m.reply "Silly #{m.user.nick}: This isn't a channel!"
    else
      if is_chanadmin?(m.channel,m.user) && is_botpowerful?(m.channel)
        m.channel.topic = topic
      elsif !is_chanadmin?(m.channel,m.user)
        m.reply NOTADMIN, true
      elsif !is_botpowerful?(m.channel)
        m.reply NOTOPBOT, true
      end
    end
  end

  # Tell a user what I know about them
  def cwhoami(m)
    if userroles(m.channel,m.user).empty?
      m.reply "You're #{m.user.nick}," + (!m.user.authname.nil? ? " authenticated as #{User(m.user).authname}," : " unauthenticated,") + " with no roles."
    else
      m.reply "You're #{m.user.nick}," + (!m.user.authname.nil? ? " authenticated as #{User(m.user).authname}," : " unauthenticated,") + " with the following roles #{userroles(m.channel,m.user)}.", true
    end
  end

  # Tell a user what I know about another user
  def cwhois(m, nick)
    nick = User(nick)
    if is_supadmin?(m.user) || is_admin?(m.user) || is_chanadmin?(m.channel, m.user) || is_mod?(m.user)
      if userroles(m.channel,nick).empty?
        m.reply "That's #{nick}," + (!User(nick).authname.nil? ? " authenticated as #{User(nick).authname}," : " unauthenticated,") + " with no roles."
      else
        m.reply "That's #{nick}, " + (!User(nick).authname.nil? ? " authenticated as #{User(nick).authname}," : " unauthenticated,") + " with the following roles #{userroles(m.channel,nick)}.", true
      end
    else
      m.reply NOTADMIN, true
    end
  end

  # Run a query against the database
  def cdbquery(m, query)
    if is_supadmin?(m.user)
      queryresult = db_custom_query(query)
      m.reply "DB Says: #{queryresult}"
    else
      m.reply NOTADMIN, true
    end
  end

end