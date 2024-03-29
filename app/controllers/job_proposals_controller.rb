class JobProposalsController < ApplicationController
  before_action :authenticate_user!
  include Pagination

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :render_job_proposal_not_found

  wrap_parameters format: []

  def search
    if params[:query].present?
      @job_proposals = JobProposal.where("job_title ILIKE ? OR task_description ILIKE?",
                                         "%#{JobProposal.sanitize_sql_like(params[:query])}%",
                                         "%#{JobProposal.sanitize_sql_like(params[:query])}%")
      render json: @job_proposals, each_serializer: JobProposalSerializer, status: :ok
    end
  end

  def index
    @job_proposals = JobProposal.page(params[:page]).per(params[:per_page] || 10)
    @job_proposals = @job_proposals.where(task_id: job_proposal_params[:task_id]) if params[:task_id].present?
    @job_proposals = @job_proposals.where(handyman_id: job_proposal_params[:handyman_id]) if params[:handyman_id].present?
    @job_proposals = @job_proposals.by_location(params[:city]) if params[:city].present?
    @job_proposals = @job_proposal.by_service(params[:service_id]) if params[:service_id].present?
    job_proposals_json = ActiveModelSerializers::SerializableResource.new(@job_proposals, each_serializer: JobProposalSerializer).as_json
    render json: { meta: pagination_meta(@job_proposals), job_proposals: job_proposals_json }, status: :ok
  end

  def show
    @job_proposal = JobProposal.find(params[:id])
    render json: { success: true, data: JobProposalSerializer.new(@job_proposal) }, status: :ok
  end

  def create
    api_key = Rails.application.credentials.dig(:firebase, :api_key)
    @job_proposal = JobProposal.create!(job_proposal_params)
    # device_token = "CLIENT_DEVICE_TOKEN"
    # title = "New Job Proposal"
    # body = "You have a new job proposal from a handyman."
    # data = { proposal_id: "123", custom_key: "custom_value" }
    # push_notification_service = PushNotificationService.new(api_key)
    # response = push_notification_service.send_notification_to_client(device_token, title, body, data)
    render json: { success: true, data: JobProposalSerializer.new(@job_proposal) }, status: :created
  end

  def update
    @job_proposal = JobProposal.find(params[:id])
    @job_proposal.update!(job_proposal_params)
    render json: { success: true, data: JobProposalSerializer.new(@job_proposal) }, status: :accepted
  end

  def destroy
    @job_proposal = JobProposal.find(params[:id])
    @job_proposal.destroy
    head :no_content
  end

  private

  def job_proposals_json
    ActiveModelSerializers::SerializableResource.new(@job_proposals, each_serializer: JobProposalSerializer).as_json
  end

  def job_proposal_params
    params.permit(
      :task_id,
      :handyman_id,
      :job_status,
      :proposal_text
    )
  end

  def render_job_proposal_not_found
    render json: { error: "Job Proposal not found" }, status: :not_found
  end
end
