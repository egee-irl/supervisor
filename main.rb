# frozen_string_literal: true

require 'faye/websocket'
require 'eventmachine'
require 'json'

EM.run do
  ws = Faye::WebSocket::Client.new("ws://rust.egee.io:28016/#{ENV['RUST_PASSWORD']}")

  ws.on :open do |event|
    p [:open]
    puts event
  end

  # inventory.giveto eg ammo.shotgun.fire 1

  ws.on :message do |event|
    message = JSON.parse(event.data)
    if message['Message'].include? 'joined from ip'
      ws.send "{Identifier: 1, Message: 'inventory.giveall pumpkin 5'}"
      ws.send "{Identifier: 1, Message: 'inventory.giveall wood 10000'}"
      ws.send "{Identifier: 1, Message: 'inventory.giveall lowgradefuel 250'}"
      ws.send "{Identifier: 1, Message: 'inventory.giveall sleepingbag 1'}"
      ws.send "{Identifier: 1, Message: 'say If you need more items, join our Discord server & ask in #rust. Invite link: https://discord.gg/EMbcgR8'}"
    elsif message['Message'] == '!help'
      ws.send "{Identifier: 1, Message: 'say Commands will be added next wipe. In the mean time, join our Discord server to request items.'}"
    end
    puts message['Message']
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
    abort 'the whole thing shit the bed'
  end
end
