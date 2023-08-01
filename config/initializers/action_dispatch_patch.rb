module ActionDispatch
  class HostAuthorization
    HOSTNAME = /[a-z0-9.-]+|\[[a-f0-9]*:[a-f0-9.:]+\]/i
    VALID_ORIGIN_HOST = /\A(#{HOSTNAME})(?::\d+)?\z/
    VALID_FORWARDED_HOST = /(?:\A|,[ ]?)(#{HOSTNAME})(?::\d+)?\z/ # rubocop:disable Style/RedundantRegexpCharacterClass

  private

    def authorized?(request)
      origin_host =
        request.get_header("HTTP_HOST")&.slice(VALID_ORIGIN_HOST, 1) || ""
      forwarded_host =
        request.x_forwarded_host&.slice(VALID_FORWARDED_HOST, 1) || ""
      @permissions.allows?(origin_host) &&
        (forwarded_host.blank? || @permissions.allows?(forwarded_host))
    end
  end
end
