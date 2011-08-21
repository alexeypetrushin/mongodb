require 'object/spec_helper'
require 'object/crud_shared'

describe "Object CRUD" do
  with_mongo

  describe 'simple' do
    before :all do
      class Unit2
        def initialize name = nil, info = nil; @name, @info = name, info end
        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.respond_to(:name), o.respond_to(:info)] end
      end
    end
    after(:all){remove_constants :Unit2}

    before do
      @zeratul = Unit2.new 'Zeratul', 'Dark Templar'
    end

    it_should_behave_like "object CRUD"
  end

  describe 'embedded' do
    before :all do
      class Player2
        attr_accessor :missions
        def == o; [self.class, self.missions] == [o.class, o.respond_to(:missions)] end

        class Mission
          def initialize name = nil, stats = nil; @name, @stats = name, stats end
          attr_accessor :name, :stats
          def == o; [self.class, self.name, self.stats] == [o.class, o.respond_to(:name), o.respond_to(:stats)] end
        end
      end
    end
    after(:all){remove_constants :Player2}

    before do
      @mission_class = Player2::Mission
      @player = Player2.new
      @player.missions = [
        Player2::Mission.new('Wasteland',         {buildings: 5, units: 10}),
        Player2::Mission.new('Backwater Station', {buildings: 8, units: 25}),
      ]
    end

    it_should_behave_like 'embedded object CRUD'
  end
end