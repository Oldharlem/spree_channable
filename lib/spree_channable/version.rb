module SpreeChannable
  module_function

  # Returns the version of the currently loaded SpreeChannable as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 0
    TINY  = 24

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end
end
