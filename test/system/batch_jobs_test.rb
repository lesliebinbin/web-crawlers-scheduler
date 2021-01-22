require "application_system_test_case"

class BatchJobsTest < ApplicationSystemTestCase
  setup do
    @batch_job = batch_jobs(:one)
  end

  test "visiting the index" do
    visit batch_jobs_url
    assert_selector "h1", text: "Batch Jobs"
  end

  test "creating a Batch job" do
    visit batch_jobs_url
    click_on "New Batch Job"

    fill_in "Count", with: @batch_job.count
    fill_in "Error info", with: @batch_job.error_info
    fill_in "Items", with: @batch_job.items
    fill_in "Job", with: @batch_job.job_id
    fill_in "Status", with: @batch_job.status
    click_on "Create Batch job"

    assert_text "Batch job was successfully created"
    click_on "Back"
  end

  test "updating a Batch job" do
    visit batch_jobs_url
    click_on "Edit", match: :first

    fill_in "Count", with: @batch_job.count
    fill_in "Error info", with: @batch_job.error_info
    fill_in "Items", with: @batch_job.items
    fill_in "Job", with: @batch_job.job_id
    fill_in "Status", with: @batch_job.status
    click_on "Update Batch job"

    assert_text "Batch job was successfully updated"
    click_on "Back"
  end

  test "destroying a Batch job" do
    visit batch_jobs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Batch job was successfully destroyed"
  end
end
