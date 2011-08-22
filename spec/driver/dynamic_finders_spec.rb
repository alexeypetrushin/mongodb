require 'driver/spec_helper'

describe "Dynamic Finders" do
  with_mongo

  before :all do
    class FindersStub
      include Mongo::DynamicFinders
    end
  end

  after(:all){remove_constants :FindersStub}

  it "parse_finder" do
    [
      [:first_by_name,  'Jim'],         [:first,  {name: 'Jim'}],
      [:first_by_name!, 'Jim'],         [:first!, {name: 'Jim'}],

      [:all_by_name,    'Jim'],         [:all,    {name: 'Jim'}],

      [:each_by_name,   'Jim'],         [:each,   {name: 'Jim'}],

      [:by_name,        'Jim'],         [:first,  {name: 'Jim'}],
      [:by_name!,       'Jim'],         [:first!, {name: 'Jim'}],

      [:first_by_id,    'id'],          [:first,  {_id: 'id'}],
      [:first_by_id!,   'id'],          [:first!, {_id: 'id'}],
      [:by_id,          'id'],          [:first,  {_id: 'id'}],
      [:by_id!,         'id'],          [:first!, {_id: 'id'}],
    ].each_slice 2 do |check, expectation|
      stub = FindersStub.new
      stub.should_receive(expectation.first).with(expectation.last)
      stub.send check.first, check.last
    end

    stub = FindersStub.new
    -> {stub.invalid_finder 'a', 'b'}.should raise_error(NoMethodError)
  end

  it "should allow to use bang version only with :first" do
    stub = FindersStub.new
    -> {stub.all_by_name!('Jim')}.should raise_error(/can't use bang/)
  end
end