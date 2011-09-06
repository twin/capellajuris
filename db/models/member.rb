class Member < Sequel::Model
  VOICES = {
    'S' => 'soprani',
    'A' => 'alti',
    'T' => 'tenori',
    'B' => 'basi'
  }

  def self.voices
    VOICES.values
  end

  def self.by_voice(name)
    filter(:voice => VOICES.index(name))
  end

  def name
    "#{first_name} #{last_name}"
  end
  alias to_s name
end