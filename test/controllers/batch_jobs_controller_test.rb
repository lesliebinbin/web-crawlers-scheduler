require 'test_helper'

class BatchJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @batch_job = batch_jobs(:one)
  end

  test "should get index" do
    get batch_jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_batch_job_url
    assert_response :success
  end

  test "should create batch_job" do
    assert_difference('BatchJob.count') do
      post batch_jobs_url, params: { batch_job: { count: @batch_job.count, error_info: @batch_job.error_info, items: @batch_job.items, job_id: @batch_job.job_id, status: @batch_job.status } }
    end

    assert_redirected_to batch_job_url(BatchJob.last)
  end

  test "should show batch_job" do
    get batch_job_url(@batch_job)
    assert_response :success
  end

  test "should get edit" do
    get edit_batch_job_url(@batch_job)
    assert_response :success
  end

  test "should update batch_job" do
    patch batch_job_url(@batch_job), params: { batch_job: { count: @batch_job.count, error_info: @batch_job.error_info, items: @batch_job.items, job_id: @batch_job.job_id, status: @batch_job.status } }
    assert_redirected_to batch_job_url(@batch_job)
  end

  test "should destroy batch_job" do
    assert_difference('BatchJob.count', -1) do
      delete batch_job_url(@batch_job)
    end

    assert_redirected_to batch_jobs_url
  end
end
