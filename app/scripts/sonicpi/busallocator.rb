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
require_relative "bus"
require_relative "atom"
require "hamster/vector"

module SonicPi
  class BusAllocator
    def initialize(max_bus_id, idx_offset)
      @IDX_OFFSET = idx_offset
      @MAX_BUS_ID = max_bus_id

      @bus_ids_A = Atom.new(Hamster.vector)
      @busses_A = Atom.new(Hamster.vector)
    end

    def allocate(num_adj_busses)
      idx = nil
      ids = @bus_ids_A.swap! do |bids|
        idx = find_gap(0, num_adj_busses, bids)
        new_bus_ids = (idx...idx+num_adj_busses).reduce {|bs, i| bs.set(i, true)}
      end

      offsetted = idx + @IDX_OFFSET
      bus = bus_class.new(offsetted, num_adj_busses, self){|id, size| release!(id-@IDX_OFFSET, size)}

      @busses_A.swap! {|bs| bs.add(bus)}
      bus
    end

    def release(bus)
      bus.free
    end

    def reset!
      old_busses = @busses_A.swap_returning_old! {|bs| Hamster.vector}
      old_busses.each {|b| b.free}

      @busses_A.reset! Hamster.vector
    end

    private

    def bus_class
      raise "Implement me!"
    end

    def release!(idx, num_adj_busses)
      @bus_ids_A.swap! do |bids|
        (idx...idx+num_adj_busses).reduce {|bs, i| bs.set(i, false)}
      end
    end

    def valid_gap?(idx, gap_size, bids)
      bus_seg = bids.to_a[idx...idx+gap_size]
      bus_seg.all?{|el| !el}
    end

    def find_gap(idx, gap_size, bids)
      raise "Unable to allocate bus" if (idx > @MAX_BUS_ID)

      if valid_gap?(idx, gap_size, bids)
        idx
      else
        find_gap idx+1, gap_size, bids
      end
    end
  end
end
