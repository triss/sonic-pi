#!/usr/bin/env ruby -wKU
#--
# This file is part of Sonic Pi: http://sonic-pi.net
# Full project source: https://github.com/samaaron/sonic-pi
# License: https://github.com/samaaron/sonic-pi/blob/master/LICENSE.md
#
# Copyright 2013, 2014 by Sam Aaron (http://sam.aaron.name).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as this
# notice is included.
#++

$:.unshift File.expand_path("../vendor/osc-ruby/lib", __FILE__)
require 'osc-ruby'

SYNTH_GROUP = 1
client = OSC::Client.new('localhost', 4556)
client.send(OSC::Message.new("/g_freeAll", SYNTH_GROUP))
