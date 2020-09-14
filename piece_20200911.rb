use_random_seed 45

loop_time = 3.6
interval = 16.0
loop_number = 0

key_offset = 0
key_offset_change_chance = 90
key_offset_reset_change = 80

intensity = 0
intensity_increase = 1
intensity_reset = 95
intensity_reset_range = 12

cymbal_pedal_start = 24

chords_start = 4

#
# Melody Variables
#
melody_start_intensity = 4
melody_emphasis_start_intensity = 16
melody_emphasis_start_chance = 30
melody_skip_chance = 50
melody_offset_chance = 80
melody_offset_ratio = [2,4,8].sample
melody_delay_reset_chance = 80
melody_silent_chance_base = 60
melody_silent_chance_max = 90

#
#depth variables
#
depth_loop_time_slower_chance = 100
depth_loop_time_faster_chance = 100
growl_start = 16


live_loop :cymbal do
  loop_number += 1
  #set intensity!
  if loop_number % intensity_increase == 0 then intensity += 1 end
  if rand(100) > intensity_reset then intensity -= rand(intensity_reset_range) end
  
  print("intensity", intensity, "loop_number", loop_number)
  sample :drum_cymbal_soft
  if intensity > 0 then sample :drum_bass_hard end
  sleep loop_time / interval
  
  extra_hits = rand(intensity) > 20
  
  if extra_hits
    sample :drum_cymbal_soft
    if intensity > 0 then sample :drum_bass_hard end
  end
  sleep loop_time / interval
  sample :drum_cymbal_soft
  if intensity > 1 then sample :drum_bass_hard end
  sleep loop_time / interval
  if intensity > cymbal_pedal_start then sample :drum_cymbal_pedal end
  
  sample :drum_cymbal_soft
  if intensity > 1 then sample :drum_bass_hard end
  sleep loop_time / interval #4
  
  sleep loop_time / interval
  sample :drum_cymbal_soft
  if intensity > 3 then sample :drum_bass_hard end
  
  sleep loop_time / interval
  sample :drum_cymbal_soft
  if intensity > 3 then sample :drum_bass_hard end
  
  sleep loop_time / interval
  if intensity > cymbal_pedal_start then sample :drum_cymbal_pedal end
  
  if extra_hits
    sample :drum_cymbal_soft
    if intensity > 0 then sample :drum_bass_hard end
  end
  sleep loop_time / interval #8
  
  sample :drum_cymbal_soft
  if intensity > 2 then sample :drum_bass_hard end
  
  sleep loop_time / interval
  if intensity > cymbal_pedal_start then sample :drum_cymbal_pedal end
  
  sleep loop_time / interval
  sample :drum_cymbal_soft
  sleep loop_time / interval
  sleep loop_time / interval #12
  
  sample :drum_cymbal_soft
  sleep loop_time / interval
  sleep loop_time / interval
  sample :drum_cymbal_soft
  sleep loop_time / interval
  if intensity > cymbal_pedal_start then sample :drum_cymbal_pedal end
  
  sleep loop_time / interval #16
end

live_loop :crash do
  sample :drum_splash_hard
  sleep loop_time * 2
end

live_loop :chords do
  #use_synth :bnoise, sustain_level:3, decay:0.2
  time_past = 0
  if intensity >= chords_start then
    use_synth :mod_fm
    current_chord = [:C3, :minor]
    if loop_number % 16 == 0 then current_chord = [:Bb3, :minor] end
    play chord(*current_chord, pan: [-1, 1].sample)
    sleep loop_time / 2
    time_past += loop_time / 2
    if
      rand(24) > 19 then play chord(:Db3, :minor)
      sample :drum_cymbal_open
    end
  end
  sleep loop_time - time_past
end


#melody
delay_set = []
new_delay = true
live_loop :lazer do
  if rand(100) >= melody_skip_chance then
    sleep loop_time
  end
  
  if rand(100) >= melody_offset_chance then
    sleep loop_time / melody_offset_ratio
  end
  
  melody_choice = [0,1].sample
  
  if rand(100) >= key_offset_reset_change then key_offset = 0 end
  if rand(100) >= key_offset_change_chance then key_offset = [1, 3, 6].sample end
  
  emphasis = intensity >= melody_emphasis_start_intensity and
  rand(100) >= melody_emphasis_start_chance + intensity
  
  
  amp = 0.3
  use_synth :saw
  time_passed = 0
  if intensity >= melody_start_intensity then
    if rand(100) >= melody_delay_reset_chance or delay_set.length == 0 then
      delay_set = []
      new_delay = true
    else
      new_delay = false
    end
    with_fx :reverb do
      
      silent = rand(100) >= [melody_silent_chance_base + intensity, melody_silent_chance_max].min
      
      delay_ind = 0
      sleep_time = loop_time / 16
      delay = [0,1,2,4].sample * sleep_time
      sleep delay
      time_passed += delay
      
      note = [[:C6], [:C6]][melody_choice].sample
      play note+key_offset, decay:0.02, amp: amp
      
      sleep sleep_time
      time_passed += sleep_time
      #########################
      
      if rand(100) > 25 and not silent then play :Bb5, amp: amp end
      
      if new_delay then
        delay = [1,2,3].sample
        delay_set.append(delay)
      else
        delay = delay_set[delay_ind]
        delay_ind += 1
      end
      sleep sleep_time * delay
      time_passed += sleep_time * delay
      #########################
      
      if not silent then
        note = [[:Ab5, :G5, :Gb5], [:Eb6, :F6]][melody_choice].sample
        play note+key_offset, amp: amp
      end
      if emphasis then
        note = [[:C4], [:C4]][melody_choice].sample
        play note+key_offset, amp: amp
      end
      
      
      if new_delay then
        delay = [2, 3, 4].sample
        delay_set.append(delay)
      else
        delay = delay_set[delay_ind]
        delay_ind += 1
      end
      
      sleep sleep_time * delay
      time_passed += sleep_time * delay
      #########################
      
      if not silent then
        note = [[:F5, :Ab5], [:F6, :Gb6]][melody_choice].sample
        play note+key_offset, amp: amp
      end
      if new_delay then
        delay = [0, 3, 3, 4, 4, 5, 5].sample
        delay_set.append(delay)
      else
        delay = delay_set[delay_ind]
        delay_ind += 1
      end
      sleep sleep_time * delay
      time_passed += sleep_time * delay
      #########################
      
      note = [[:G5], [:G6]][melody_choice].sample
      play note+key_offset, decay: 0.1, amp: amp
      
      if emphasis then
        note = [[:Eb4], [:F4]][melody_choice].sample
        play note+key_offset, amp:amp
      end
      
    end
  end
  sleep loop_time - time_passed
  new_delay = false
  print(delay_set)
end

depth_loop_time = loop_time * 2.0
live_loop :depth do
  if rand(100) >= depth_loop_time_slower_chance - intensity then
    depth_loop_time = depth_loop_time / 2.0
  end
  if rand(100) >= depth_loop_time_faster_chance - intensity then
    depth_loop_time = depth_loop_time * 2.0
  end
  
  time_passed = 0
  if intensity > growl_start then
    use_synth :growl
    play [:C2, :C2, :C2, :Eb2, :Bb2].sample, release: depth_loop_time / 2
    sleep depth_loop_time / 6
    time_passed += depth_loop_time / 6
    play [:C1, :C3, :C1, :Eb1, :Bb1].sample, release: depth_loop_time / 4
    if rand(64) > 56 then
      sleep depth_loop_time / 4
      time_passed += depth_loop_time / 4
      play [:C1, :C1, :C1, :Eb1, :Bb1].sample, release: depth_loop_time
    end
  end
  sleep depth_loop_time - time_passed
end