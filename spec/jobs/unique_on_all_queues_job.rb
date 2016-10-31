class UniqueOnAllQueuesJob
  include Sidekiq::Worker
  sidekiq_options queue: :working, retry: 1, backtrace: 10,
                  unique: :until_executed, unique_on_all_queues: true

  sidekiq_retries_exhausted do |msg|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  def perform(*)
    # NO-OP
  end
end
