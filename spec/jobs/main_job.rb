class MainJob
  include Sidekiq::Worker
  sidekiq_options queue: :customqueue, unique: :until_executed,
                  log_duplicate_payload: true

  def perform(_)
  end
end
