use_random_seed 51
loop_time = 6.0
parts = [60, 20].sample
increment = 6.0 / parts
new_notes = [1, 2, 16, 4, 0].sample
new_drums = [2, 2, 4, 8, 8].sample
notes = []
drums = []
range(0, parts).each { |p|
  notes.append([])
  drums.append([])
}
loop_ind = 0
drum_start = 2
drum_end = 16
drum_amp_adjustment = 1.0
note_amp_adjustment = [0.2, 0.5, 0.8, 1.0].sample
note_max_count = parts / 2
drum_max_count = parts / 2
drum_effect_chance = 90

note_removal_rate = new_notes
drum_removal_rate = new_drums

note_turnover_rate = [new_notes - 4, 0].max
drum_turnover_rate = 0

[
  "note_turnover_rate:"+note_turnover_rate.to_s,
  "new_notes:"+new_notes.to_s,
  "parts:"+parts.to_s,
  "note_amp_adjustment"+note_amp_adjustment.to_s
].each {|l| print l}




loop do
  loop_ind += 1
  note_count = 0
  drum_count = 0
  range(0, new_notes).each {
    
    note = {
      :synth => [:dull_bell, :hollow,
                 :saw, :chiplead].sample,
      :note => [:C2, :E2, :D3, :E3, :G3].sample,
      :amp => [1.0, 0.5, 0.2, 0.7, 1.0].sample
    }
    ind = rand(parts).to_i
    notes[ind].append(note)
  }
  
  range(0, note_turnover_rate).each {
    ind = rand(parts).to_i
    if notes[ind].length > 0 then
      notes[ind].pop()
    end
    
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
        with_fx [:echo, :whammy].sample do
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
  
end
