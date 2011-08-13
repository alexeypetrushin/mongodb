require 'driver/spec_helper'

describe "Example" do
  with_mongo
  
  defaults = nil
  before(:all){defaults = Mongo.defaults.clone}
  after(:all){Mongo.defaults = defaults}
  
  it "core" do    
    require 'mongo_db/driver'  
    
    # connection & db
    connection = Mongo::Connection.new
    db = connection.db 'default_test'
    
    # collection shortcuts
    db.some_collection
    
    # create
    zeratul =  {name: 'Zeratul',  stats: {attack: 85, life: 300, shield: 100}}
    tassadar = {name: 'Tassadar', stats: {attack: 0,  life: 80,  shield: 300}}
    
    db.units.save zeratul
    db.units.save tassadar
    
    # udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it)
    tassadar[:stats][:attack] = 20
    db.units.save tassadar
    
    # querying first & all, there's also :each, the same as :all
    db.units.first name: 'Zeratul'                     # => zeratul
    db.units.all name: 'Zeratul'                       # => [zeratul]
    db.units.all name: 'Zeratul' do |hero|
      hero                                             # => zeratul
    end
  end
  
  it "optional" do
    # simple finders (bang versions also availiable)
    db.units.by_name 'Zeratul'                         # => zeratul
    db.units.first_by_name 'Zeratul'                   # => zeratul
    db.units.all_by_name 'Zeratul'                     # => [zeratul]
  end
end