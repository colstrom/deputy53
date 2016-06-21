module Deputy53
  class NameError < ::NameError; end
  class AmbiguousNameError < NameError; end
  class NotFoundError < NameError; end
  class ZoneNotFoundError < NotFoundError; end
  class IdentityNotFoundError < NotFoundError; end
end
