require 'object/spec_helper'

describe "Miscellaneous" do
  with_mongo
  old = Mongo.defaults[:generate_id] = false
  before do
    Mongo.defaults[:generate_id] = true
    class Tmp
      include Mongo::Object
    end
  end
  after do
    Mongo.defaults[:generate_id] = old
    remove_constants :Tmp
  end

  it "should use random string id (instead of default BSON::ObjectId)" do
    o = Tmp.new
    db.objects.save o
    o._id.should be_a(String)
    o._id.size.should == Mongo.defaults[:random_string_id_size]
  end
end