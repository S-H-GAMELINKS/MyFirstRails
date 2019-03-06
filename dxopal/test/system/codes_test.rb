require "application_system_test_case"

class CodesTest < ApplicationSystemTestCase
  setup do
    @code = codes(:one)
  end

  test "visiting the index" do
    visit codes_url
    assert_selector "h1", text: "Codes"
  end

  test "creating a Code" do
    visit codes_url
    click_on "New Code"

    fill_in "Content", with: @code.content
    fill_in "Title", with: @code.title
    click_on "Create Code"

    assert_text "Code was successfully created"
    click_on "Back"
  end

  test "updating a Code" do
    visit codes_url
    click_on "Edit", match: :first

    fill_in "Content", with: @code.content
    fill_in "Title", with: @code.title
    click_on "Update Code"

    assert_text "Code was successfully updated"
    click_on "Back"
  end

  test "destroying a Code" do
    visit codes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Code was successfully destroyed"
  end
end
