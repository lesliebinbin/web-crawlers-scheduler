require "application_system_test_case"

class SpidersTest < ApplicationSystemTestCase
  setup do
    @spider = spiders(:one)
  end

  test "visiting the index" do
    visit spiders_url
    assert_selector "h1", text: "Spiders"
  end

  test "creating a Spider" do
    visit spiders_url
    click_on "New Spider"

    fill_in "Container", with: @spider.container_id
    fill_in "Frequency", with: @spider.frequency
    fill_in "Image", with: @spider.image_id
    fill_in "Max memory", with: @spider.max_memory
    fill_in "Name", with: @spider.name
    fill_in "Prefix", with: @spider.prefix
    fill_in "Run info", with: @spider.run_info
    fill_in "Status", with: @spider.status
    click_on "Create Spider"

    assert_text "Spider was successfully created"
    click_on "Back"
  end

  test "updating a Spider" do
    visit spiders_url
    click_on "Edit", match: :first

    fill_in "Container", with: @spider.container_id
    fill_in "Frequency", with: @spider.frequency
    fill_in "Image", with: @spider.image_id
    fill_in "Max memory", with: @spider.max_memory
    fill_in "Name", with: @spider.name
    fill_in "Prefix", with: @spider.prefix
    fill_in "Run info", with: @spider.run_info
    fill_in "Status", with: @spider.status
    click_on "Update Spider"

    assert_text "Spider was successfully updated"
    click_on "Back"
  end

  test "destroying a Spider" do
    visit spiders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Spider was successfully destroyed"
  end
end
