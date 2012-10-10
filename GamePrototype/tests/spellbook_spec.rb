require_relative '../databases/spellbook'

require 'rspec'

describe Array do
  it "is prefix of itself" do
    [:top_arc].has_prefix?([:top_arc]).should be(true)
  end

  it "knows a prefix" do
    [:top_arc, :up].has_prefix?([:top_arc]).should be(true)
  end

  it "hasn't a prefix longer than itself" do
    [:top_arc].has_prefix?([:top_arc, :up]).should be(false)
  end

  it "hasn't a differing prefix" do
    [:top_arc, :down].has_prefix?([:top_arc, :up]).should be(false)
  end

  it "is subsequence of itself" do
    [:top_arc, :down].has_subsequence?([:top_arc, :down]).should be(true)
  end

  it "doesn't have a completely weird subsequence" do
    [:top_arc].has_subsequence?([:up, :down]).should be(false)
    [:up, :down].has_subsequence?([:top_arc]).should be(false)
  end
end

describe Databases::SpellBook do
  it "should lookup the shield spell with [:top_arc]" do
    book = Databases::SpellBook.new
    book.lookup([:top_arc]).should be(Databases::Shield)
  end

  it "should define Spells" do
    Databases::SpellBook.spell "Explosion", [:up, :up]

    book = Databases::SpellBook.new
    book.lookup([:up, :up]).should eq("Explosion")
  end

  it "should not allow common postfix" do
    expect { Databases::SpellBook.spell("Explosion", [:down]) }.to raise_error
  end

  it "should not allow superceding in common" do
    expect {
      Databases::SpellBook.spell("Explosion", [:up, :up, :down, :down]) }.to raise_error
  end

end
