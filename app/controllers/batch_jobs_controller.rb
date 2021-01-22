class BatchJobsController < ApplicationController
  before_action :set_batch_job, only: [:show, :edit, :update, :destroy]

  # GET /batch_jobs
  # GET /batch_jobs.json
  def index
    @batch_jobs = BatchJob.all
  end

  # GET /batch_jobs/1
  # GET /batch_jobs/1.json
  def show
  end

  # GET /batch_jobs/new
  def new
    @batch_job = BatchJob.new
  end

  # GET /batch_jobs/1/edit
  def edit
  end

  # POST /batch_jobs
  # POST /batch_jobs.json
  def create
    @batch_job = BatchJob.new(batch_job_params)

    respond_to do |format|
      if @batch_job.save
        format.html { redirect_to @batch_job, notice: 'Batch job was successfully created.' }
        format.json { render :show, status: :created, location: @batch_job }
      else
        format.html { render :new }
        format.json { render json: @batch_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batch_jobs/1
  # PATCH/PUT /batch_jobs/1.json
  def update
    respond_to do |format|
      if @batch_job.update(batch_job_params)
        format.html { redirect_to @batch_job, notice: 'Batch job was successfully updated.' }
        format.json { render :show, status: :ok, location: @batch_job }
      else
        format.html { render :edit }
        format.json { render json: @batch_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batch_jobs/1
  # DELETE /batch_jobs/1.json
  def destroy
    @batch_job.destroy
    respond_to do |format|
      format.html { redirect_to batch_jobs_url, notice: 'Batch job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch_job
      @batch_job = BatchJob.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def batch_job_params
      params.require(:batch_job).permit(:job_id, :count, :items, :status, :error_info)
    end
end
