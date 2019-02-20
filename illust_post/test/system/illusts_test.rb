require "application_system_test_case"

class IllustsTest < ApplicationSystemTestCase
  setup do
    @illust = illusts(:one)
  end

  test "visiting the index" do
    visit illusts_url
    assert_selector "h1", text: "Illusts"
  end

  test "creating a Illust" do
    visit illusts_url
    click_on "New Illust"

    fill_in "Content", with: @illust.content
    fill_in "Title", with: @illust.title
    click_on "Create Illust"

    assert_text "Illust was successfully created"
    click_on "Back"
  end

  test "updating a Illust" do
    visit illusts_url
    click_on "Edit", match: :first

    fill_in "Content", with: @illust.content
    fill_in "Title", with: @illust.title
    click_on "Update Illust"

    assert_text "Illust was successfully updated"
    click_on "Back"
  end

  test "destroying a Illust" do
    visit illusts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Illust was successfully destroyed"
  end
end
