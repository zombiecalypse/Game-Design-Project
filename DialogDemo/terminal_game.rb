require_relative 'dialog.rb'

dialog = Dialog.new("What's your name?", "Claudio", "Aaron", "The Chosen One")
pack = dialog.ask
puts pack.join("\n")
choice = gets.to_i
while choice < 1 or choice > 3
  choice = gets.to_i
end
puts pack[choice]