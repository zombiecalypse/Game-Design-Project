require_relative 'spell'

Shield = Spell.new name: :shield, icon: 'bolt-shield.png' do |opts|
  player = opts[:player]
  player.vulnerability = 0.2
  player.color = Colors::SHIELD
  player.color.alpha = 60
  player.during(5000) do
    player.color.alpha += 1
  end.then do
    player.color = nil
    player.vulnerability = 1
  end
end
