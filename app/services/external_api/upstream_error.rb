module ExternalApi
  class UpstreamError < StandardError
    attr_reader :service, :status, :method, :url, :response_body, :context

    def initialize(message:, service:, status: nil, method: "GET", url: nil, response_body: nil, context: {})
      super(message)
      @service = service
      @status = status
      @method = method
      @url = url
      @response_body = response_body
      @context = context || {}
    end

    def metadata
      data = {
        "service" => service,
        "status" => status,
        "method" => method,
        "url" => url,
        "response_body" => response_body
      }.merge(context)

      data.reject { |_, value| value.nil? || (value.respond_to?(:empty?) && value.empty?) }
    end

    def log_message
      parts = []
      parts << "service=#{service}" if service
      parts << "status=#{status}" if status
      parts << "method=#{method}" if method
      parts << "url=#{url}" if url
      parts << "context=#{context.inspect}" if context.any?
      parts << "response_body=#{response_body}" if response_body.to_s.strip != ""
      parts.join(" ")
    end
  end
end
