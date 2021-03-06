require 'object/spec_helper'

describe "Object" do
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
    remove_constants :Tmp, :Comment, :Tags
  end

  after{remove_constants :Post, :Tags}

  it "should use autogenerated random string id (if specified, instead of default BSON::ObjectId)" do
    o = Tmp.new
    db.objects.save o
    o.id.should be_a(String)
    o.id.size.should == Mongo.defaults[:random_string_id_size]
  end

  it "shoud convert to hash" do
    class Tmp
      attr_accessor :name
    end
    o = Tmp.new
    o.name = 'some name'
    o.to_hash.should == {name: 'some name', _class: 'Tmp'}
  end

  it "should convert object to mongo and to Hash" do
    class Post
      include Mongo::Object

      attr_accessor :title, :tags, :comments
    end

    class Comment
      include Mongo::Object

      attr_accessor :text
    end

    class Tags < Array
      include Mongo::Object
    end

    comment = Comment.new
    comment.text = 'Some text'

    tags = Tags.new
    tags.push 'a', 'b'

    post = Post.new
    post.title = 'Some title'
    post.comments = [comment]
    post.tags = tags

    post.to_mongo.should == {
      "_class"   => "Post",
      "title"    => 'Some title',
      "comments" => [{"text" => "Some text", "_class" => "Comment"}],
      "tags"     => ['a', 'b']
    }

    post.to_hash.should == {
      _class:   "Post",
      title:    'Some title',
      comments: [{text: "Some text", _class: "Comment"}],
      tags:     ['a', 'b']
    }
  end
end