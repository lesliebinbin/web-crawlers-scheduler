json.extract! batch_job, :id, :job_id, :count, :items, :status, :error_info, :created_at, :updated_at
json.url batch_job_url(batch_job, format: :json)
