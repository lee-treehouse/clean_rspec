require "spec_helper"
require "./lib/gilded_rose"

RSpec.describe GildedRose do
  
  class Workshop
    def initialize(seats: 10)
      @participants = []
      @seats = seats
    end
    def enroll(participant)
      if @participants.length < @seats
         @participants << participant
      end 
    end
    def noop; end
  end

  class Participant
    def initialize(first_name)
      @first_name = first_name
    end
  end
  
  # let's be very explicit about what subject is, instead of gaining subject definition automagically
  subject(:gilded_rose) {described_class.new}
  let(:name) { 'Normal Item' }

  it "is a gilded rose" do
    expect(gilded_rose).to be_a(GildedRose)
  end

  # #methodname implies instance method, .methodname implies class method
  describe "#enroll" do 
    # suggestion is: if you are using 'when' in an it block, should you be using a context?
    context "when the class is not full" do
      it "adds a participant to a workshop" do 
        expect(true).to be_truthy 
      end
    end
    context "when the class is full" do
      it "does not add a participant to a workshop when the class is full" do 
        expect(true).to be_truthy 
      end 
    end     
  end

  #now lets talk about let, let!, vs before
  #we want to really run this example so let's add some classes but the implementation is not important it's just for sake of argument
  # let is lazily loaded - it won't run until it's called
  #let(:workshop) {Workshop.new(seats:15)}
  # let! is eager loaded, it's the same as before except there is a variable assignment
  #before {Workshop.new(seats:15)}
  #before runs for each it block in scope (same as let!) let's demonstrate 
  
  describe "Workshop" do    
    let(:workshop) do
      #puts "it's getting workshop in here" #see that got printed a lot and then when I moved it into the describe, only twice 
      puts "it's getting workshop in here" #see that got printed only once due to lazy load
      Workshop.new(seats:15)
    end
  

    describe "#enroll" do
      participant = Participant.new("Lee")
      context "when the conditions we want to test are happening" do
        it 'the thing we want to happen happens' do
          workshop.enroll(participant)
          # we can demonstrate the memoisation by accessing workshop again. still only two puts
          # but if we go back to let!? still only two so it's memoised as well 
          workshop.noop
          expect(workshop.instance_variable_get(:@participants).length).to be(1)
        end
        it 'the other thing we want to happen happens' do
          workshop.noop #our puts now printed twice
          expect(true).to be_truthy 
        end
      end
    end 
  end
 
  
  # improve with describe and context but not with before / beforeach 
  # perhaps have nested context: normal item, when after sell date
  describe "#tick with normal item" do
    context "when after sell date" do
      # so does it really matter if this is in a let block or not? well, we're not creating it each it block
      # In particular, if we are using it in lots and lots of blocks then maybe the let is better
      gr = GildedRose.new(name: "Normal Item", days_remaining: -10, quality: 10)
      gr.tick  
    
      it "reduces days remaining by 1" do 
        expect(gr.days_remaining).to eq(-11)
      end

      it "reduces quality by 2" do 
        expect(gr.quality).to eq(8)
      end
    end     
  end
  
  it "normal item after sell date" do
    gr = GildedRose.new(name: "Normal Item", days_remaining: -10, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(-11)
    expect(gr.quality).to eq(8)
  end

  shared_examples :gilded_rose do |name, days_remaining, quality, expected_days_remaining, expected_quality|
    it 'ticks' do
      gr = GildedRose.new(name: name, days_remaining: days_remaining, quality: quality)
      gr.tick
      expect(gr).to have_attributes(days_remaining: expected_days_remaining, quality: expected_quality)
    end
  end

  it "normal item before sell date" do
    gr = GildedRose.new(name: "Normal Item", days_remaining: 5, quality: 10)
    gr2 = GildedRose.new(name: "Normal Item", days_remaining: -1, quality: 8)
    gr3 = GildedRose.new(name: "Normal Item", days_remaining: 1, quality: 12)

    gr.tick

    expect(gr).to have_attributes(days_remaining: 4, quality: 9)
  end

  it "normal item on sell date" do
    gr = GildedRose.new(name: "Normal Item", days_remaining: 0, quality: 10)

    expect(gr).to be_instance_of(GildedRose) 

    gr.tick

    expect(gr.days_remaining).to eq(-1)
    expect(gr.quality).to eq(8)
  end

  it "normal item of zero quality" do
    gr = GildedRose.new(name: name, days_remaining: 5, quality: 0)

    gr.tick

    expect(gr.days_remaining).to eq(4)
    expect(gr.quality).to eq(0)
  end

  it_behaves_like :gilded_rose, "Aged Brie", 5, 10, 4, 11
  it_behaves_like :gilded_rose, "Aged Brie", 5, 50, 4, 50
  it_behaves_like :gilded_rose, "Aged Brie", 0, 10, -1, 12
  it_behaves_like :gilded_rose, "Aged Brie", 0, 49, -1, 50
  it_behaves_like :gilded_rose, "Aged Brie", 0, 50, -1, 50
  it_behaves_like :gilded_rose, "Aged Brie", -10, 10, -11, 12
  it_behaves_like :gilded_rose, "Aged Brie", -10, 50, -11, 50

  it "sulfuras before sell date" do
    gr = GildedRose.new(name: "Sulfuras, Hand of Ragnaros", days_remaining: 5, quality: 80)

    gr.tick

    expect(gr.days_remaining).to eq(5)
    expect(gr.quality).to eq(80)
  end

  it "sulfuras on sell date" do
    gr = GildedRose.new(name: "Sulfuras, Hand of Ragnaros", days_remaining: 0, quality: 80)

    gr.tick

    expect(gr.days_remaining).to eq(0)
    expect(gr.quality).to eq(80)
  end

  it "sulfuras after sell date" do
    gr = GildedRose.new(name: "Sulfuras, Hand of Ragnaros", days_remaining: -10, quality: 80)

    gr.tick

    expect(gr.days_remaining).to eq(-10)
    expect(gr.quality).to eq(80)
  end

  it "backstage passes long before sell date" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 11, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(10)
    expect(gr.quality).to eq(11)
  end

  it "backstage passes long before sell date at max quality" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 11, quality: 50)

    gr.tick

    expect(gr).to have_attributes(days_remaining: 10, quality: 50)
  end

  it "backstage passes medium close to sell date upper bound" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 10, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(9)
    expect(gr.quality).to eq(12)
  end

  it "backstage passes medium close to sell date upper bound at max quality" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 10, quality: 50)

    gr.tick

    expect(gr.days_remaining).to eq(9)
    expect(gr.quality).to eq(50)
  end

  it "backstage passes medium close to sell date lower bound" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 6, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(5)
    expect(gr.quality).to eq(12)
  end

  it "backstage passes medium close to sell date lower bound at max quality" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 6, quality: 50)

    gr.tick

    expect(gr.days_remaining).to eq(5)
    expect(gr.quality).to eq(50)
  end

  it "backstage passes very close to sell date upper bound" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 5, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(4)
    expect(gr.quality).to eq(13)
  end

  it "backstage passes very close to sell date upper bound at max quality" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 5, quality: 50)

    gr.tick

    expect(gr.days_remaining).to eq(4)
    expect(gr.quality).to eq(50)
  end

  it "backstage passes very close to sell date lower bound" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 1, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(0)
    expect(gr.quality).to eq(13)
  end

  it "backstage passes very close to sell date lower bound at max quality" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 1, quality: 50)

    gr.tick

    expect(gr.days_remaining).to eq(0)
    expect(gr.quality).to eq(50)
  end

  it "backstage passes on sell date" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: 0, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(-1)
    expect(gr.quality).to eq(0)
  end

  it "backstage passes after sell date" do
    gr = GildedRose.new(name: "Backstage passes to a TAFKAL80ETC concert", days_remaining: -10, quality: 10)
# 
    gr.tick

    expect(gr.days_remaining).to eq(-11)
    expect(gr.quality).to eq(0)
  end

  xit "conjured mana before sell date" do
    gr = GildedRose.new(name: "Conjured Mana Cake", days_remaining: 5, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(4)
    expect(gr.quality).to eq(8)
  end

  xit "conjured mana before sell date at zero quality" do
    gr = GildedRose.new(name: "Conjured Mana Cake", days_remaining: 5, quality: 0)

    gr.tick

    expect(gr.days_remaining).to eq(4)
    expect(gr.quality).to eq(0)
  end

  xit "conjured mana on sell date" do
    gr = GildedRose.new(name: "Conjured Mana Cake", days_remaining: 0, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(-1)
    expect(gr.quality).to eq(6)
  end

  xit "conjured mana on sell date at zero quality" do
    gr = GildedRose.new(name: "Conjured Mana Cake", days_remaining: 0, quality: 0)

    gr.tick

    expect(gr.days_remaining).to eq(-1)
    expect(gr.quality).to eq(0)
  end

  xit "conjured mana after sell date" do
    gr = GildedRose.new(name: "Conjured Mana Cake", days_remaining: -10, quality: 10)

    gr.tick

    expect(gr.days_remaining).to eq(-11)
    expect(gr.quality).to eq(6)
  end

  xit "conjured mana after sell date at zero quality" do
    gr = GildedRose.new(name: "Conjured Mana Cake", days_remaining: -10, quality: 0)

    gr.tick

    expect(gr.days_remaining).to eq(-11)
    expect(gr.quality).to eq(0)
  end
end
