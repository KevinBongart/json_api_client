require 'test_helper'

class ResourceTest < MiniTest::Test

  def test_basic
    assert_equal :user_id, UserPreference.primary_key
    assert_equal "user_preferences", UserPreference.table_name
    assert_equal "user_preference", UserPreference.resource_name
  end

  def test_each_on_scope
    stub_request(:get, "http://example.com/user_preferences")
      .with(query: {filter: {user: '5'}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "user_preferences",
          id: "1",
          attributes: {
            receive_email: true
          }
        }]
      }.to_json)

    user_preferences = []
    UserPreference.where(user: '5').each do |user_preference|
      user_preferences.push(user_preference)
    end
    assert_equal 1, user_preferences.length
  end

  def test_should_always_have_type_attribute
    article = Article.new
    assert_equal "articles", article.type
    assert_equal({type: "articles"}.with_indifferent_access, article.attributes)
  end

  def test_support_for_underscorized_type_attribute
    user_preference = UserPreference.new
    assert_equal "user_preferences", user_preference.type
    assert_equal({type: "user_preferences"}.with_indifferent_access, user_preference.attributes)
  end

  def test_support_for_dasherized_type_attribute
    test_resource = DasherizedKeysTestResource.new
    assert_equal "dasherized-keys-test-resources", test_resource.type
    assert_equal({type: "dasherized-keys-test-resources"}.with_indifferent_access, test_resource.attributes)
  end

  def test_can_set_arbitrary_attributes
    article = Article.new(asdf: "qwer")
    article.foo = "bar"
    assert_equal({type: "articles", asdf: "qwer", foo: "bar"}.with_indifferent_access, article.attributes)
  end

  def test_dynamic_attribute_methods
    article = Article.new(foo: "bar")

    assert article.respond_to? :foo
    assert article.respond_to? :foo=
    assert_equal(article.foo, "bar")

    refute article.respond_to? :bar
    assert article.respond_to? :bar=
    article.bar = "baz"
    assert article.respond_to? :bar

    assert_raises NoMethodError do
      article.quux
    end
  end

  def test_dasherized_keys_support
    article = Article.new("foo-bar" => "baz")
    assert_equal("baz", article.send("foo-bar"))
    assert_equal("baz", article.send(:"foo-bar"))
    assert_equal("baz", article["foo-bar"])
    assert_equal("baz", article[:"foo-bar"])
  end

end
