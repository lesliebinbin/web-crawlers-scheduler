require 'test_helper'

class SpidersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @spider = spiders(:one)
  end

  test "should get index" do
    get spiders_url
    assert_response :success
  end

  test "should get new" do
    get new_spider_url
    assert_response :success
  end

  test "should create spider" do
    assert_difference('Spider.count') do
      post spiders_url, params: { spider: { container_id: @spider.container_id, frequency: @spider.frequency, image_id: @spider.image_id, max_memory: @spider.max_memory, name: @spider.name, prefix: @spider.prefix, run_info: @spider.run_info, status: @spider.status } }
    end

    assert_redirected_to spider_url(Spider.last)
  end

  test "should show spider" do
    get spider_url(@spider)
    assert_response :success
  end

  test "should get edit" do
    get edit_spider_url(@spider)
    assert_response :success
  end

  test "should update spider" do
    patch spider_url(@spider), params: { spider: { container_id: @spider.container_id, frequency: @spider.frequency, image_id: @spider.image_id, max_memory: @spider.max_memory, name: @spider.name, prefix: @spider.prefix, run_info: @spider.run_info, status: @spider.status } }
    assert_redirected_to spider_url(@spider)
  end

  test "should destroy spider" do
    assert_difference('Spider.count', -1) do
      delete spider_url(@spider)
    end

    assert_redirected_to spiders_url
  end
end
