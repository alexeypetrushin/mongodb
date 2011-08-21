require 'object/spec_helper'

describe 'Object validation' do
  with_mongo

  before :all do
    class Player
      attr_accessor :missions

      class Mission
      end
    end
  end
  after(:all){remove_constants :Player}

  before do
    @mission = Player::Mission.new
    @player = Player.new
    @player.missions = [@mission]
  end

  it 'should not save/update/destroy invalid objects' do
    # create
    @player.stub!(:_valid?).and_return(false)
    db.players.save(@player).should be_false

    @player.stub!(:_valid?).and_return(true)
    db.players.save(@player).should be_true

    # update
    @player.stub!(:_valid?).and_return(false)
    db.players.save(@player).should be_false

    @player.stub!(:_valid?).and_return(true)
    db.players.save(@player).should be_true

    # destroy
    @player.stub!(:_valid?).and_return(false)
    db.players.destroy(@player).should be_false

    @player.stub!(:_valid?).and_return(true)
    db.players.destroy(@player).should be_true
  end

  it 'should not save/update/destroy invalid embedded objects' do
    # create
    @mission.stub!(:_valid?).and_return(false)
    db.players.save(@player).should be_false

    @mission.stub!(:_valid?).and_return(true)
    db.players.save(@player).should be_true

    # update
    @mission.stub!(:_valid?).and_return(false)
    db.players.save(@player).should be_false

    @mission.stub!(:_valid?).and_return(true)
    db.players.save(@player).should be_true

    # destroy
    @mission.stub!(:_valid?).and_return(false)
    db.players.destroy(@player).should be_false

    @mission.stub!(:_valid?).and_return(true)
    db.players.destroy(@player).should be_true
  end

  it "should be able skip validation" do
    @player.stub!(:_valid?).and_return(false)
    db.players.save(@player, validate: false).should be_true

    @player.stub!(:_valid?).and_return(true)
    @mission.stub!(:_valid?).and_return(false)
    db.players.save(@player, validate: false).should be_true
  end
end