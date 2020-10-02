use_random_seed 55

loop_time = 6.0
loop_number = 0

parts = [60, 40, 20].sample
parts = 16
increment = 4.0 / parts
new_notes = [1, 2, 16, 4, 0].sample
new_drums = [2, 2, 4, 8, 8].sample
notes = []
drums = []
range(0, parts).each {|p|
  notes.append([])
  drums.append([])
}
loop_ind = 0
drum_start = 0
drum_end = 24
drum_amp_adjustment = 1.0
note_amp_adjustment = [0.2, 0.5, 0.8, 0.4].sample
note_max_count = 5
drum_max_count = 8 #parts / 2
drum_effect_chance = 60

note_removal_rate = new_notes
drum_removal_rate = new_drums
drum_removal_retry = 4

note_turnover_rate = [new_notes - 4, 1].max
drum_turnover_rate = (new_drums / 2).to_i

slow_chance = 20
slow_chord_chance = 60
slow_chord_start = 4

melody_stop = 32
slow_stop = 36

[
  "note_turnover_rate:"+note_turnover_rate.to_s,
  "note_removal_rate:"+note_removal_rate.to_s,
  "new_notes:"+new_notes.to_s,
  "drum_turnover_rate:"+drum_turnover_rate.to_s,
  "drum_removal_rate:"+drum_removal_rate.to_s,
  "new_drums:"+new_drums.to_s,
  "parts:"+parts.to_s,
  "note_amp_adjustment:"+note_amp_adjustment.to_s
].each {|l| print l}
key_offset = 0
melody_notes = [:C2, :E2, :D3, :E3, :G3]
melody_notes_to_add = [:Bb3, :Db4, :Gb4]
add_notes_start = 4
add_notes_frequency = 1

live_loop :control do
  loop_number += 1
  if loop_number >= add_notes_start and
    (loop_number - add_notes_start) % add_notes_frequency == 0 then
    if melody_notes_to_add.length > 0 then
      melody_notes.append(melody_notes_to_add.pop())
    end
  end
  if rand(100) >= 10 then
    key_offset += 1
  end
  if rand(100) >= 90 then
    key_offset -= 6
  end
  sleep loop_time
end


live_loop :slow do
  if loop_number > slow_stop then stop end
  sleep_time = increment * rand(parts).to_i
  sleep sleep_time
  if rand(100) >= slow_chance then
    use_synth [:dark_ambience].sample
    play [:E2, :F2, :G2, :Bb2].map{|k|k+key_offset}.sample,
      release: [4, 8].sample,
      amp: 0.8
  end
  if rand(100) >= slow_chord_chance and
    loop_number >= slow_chord_start then
    use_synth :sine
    key_adj = [0, 0, 0, 12].sample
    play_chord [:C2, :E2, :Bb2, :Db3, :Gb3].map {|a|a+key_adj},
      release: 10, attack: 4, amp: 0.7
  end
  sleep loop_time - sleep_time
end


live_loop :main do
  if loop_number > melody_stop then stop end
  loop_ind += 1
  note_count = 0
  drum_count = 0
  new_notes.times {
    
    note = {
      :synth => [:dull_bell, :hollow,
                 :saw, :chiplead, :beep].sample,
      :note => melody_notes.map{|k| k+key_offset}.sample,
      :amp => [1.0, 0.5, 0.2, 0.7, 1.0].sample
    }
    ind = rand(parts).to_i
    notes[ind].append(note)
  }
  
  note_turnover_rate.times {
    drum_removal_retry.times {
      ind = rand(parts).to_i
      if notes[ind].length > 0 then
        notes[ind].pop()
        break
      end
    }
  }
  
  if loop_ind >= drum_start and
    loop_ind <= drum_end then
    range(0, new_drums).each {
      #sample :drum_splash_soft
      hit = {
        :sound => [
          :drum_cymbal_soft,
          :drum_tom_lo_soft,
          :drum_tom_mid_soft,
        :drum_tom_hi_soft].sample
      }
      drums[rand(parts).to_i].append(hit)
    }
    
  end
  
  #print(ind, "-------", notes)
  range(0, parts).each do |ind|
    slice = notes[ind]
    #print slice
    slice.each { |note|
      use_synth note[:synth]
      play note[:note], amp: note[:amp] * note_amp_adjustment
      note_count += 1
    }
    drum = drums[ind]
    drum.each {|hit|
      if rand(100) >= drum_effect_chance then
        with_fx [:echo, :whammy, :echo, :echo].sample do
          sample hit[:sound]
        end
      else
        sample hit[:sound]
      end
      drum_count += 1
    }
    sleep increment
  end
  if note_count >= note_max_count then
    range(0, note_removal_rate).each {
      ind = rand(parts).to_i
      if notes[ind].length > 0 then
        notes[ind].pop()
      end
      
    }
  end
  if drum_count >= drum_max_count then
    drum_removal_rate.times {
      drum_removal_retry.times {
        ind = rand(parts).to_i
        if drums[ind].length > 0 then
          drums[ind].pop
        end
      }
    }
  end
  print "note_count:", note_count
  print "drum_count:", drum_count
  print "melody_notes:", melody_notes
  print "loop_number:", loop_number
  print "key_offset:", key_offset
end
