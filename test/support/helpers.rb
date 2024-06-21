module TestHelpers
  def record_queries
    return unless @sub.nil?
    @queries = []
    @sub = ActiveSupport::Notifications.subscribe 'sql.active_record' do |_name, _started, _finished, _uid, data|
      @queries << [data.fetch(:sql), data.fetch(:type_casted_binds)]
    end
  end

  def clear_queries
    return if @sub.nil?
    ActiveSupport::Notifications.unsubscribe @sub
    @sub = nil
    @queries
  end
end
