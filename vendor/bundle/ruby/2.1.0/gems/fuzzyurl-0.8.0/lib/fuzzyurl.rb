require 'fuzzyurl/version'
require 'fuzzyurl/fields'
require 'fuzzyurl/protocols'
require 'fuzzyurl/match'
require 'fuzzyurl/strings'

class Fuzzyurl
  FIELDS.each {|f| attr_accessor f}

  # Creates a new Fuzzyurl object from the given params or URL string.
  # Keys of `params` should be symbols.
  #
  # @param params [Hash|String|nil] URL string or parameter hash.
  # @return [Fuzzyurl] New Fuzzyurl object.
  def initialize(params={})
    p = params.kind_of?(String) ? Fuzzyurl.from_string(params).to_hash : params
    (FIELDS & p.keys).each do |f|
      self.send("#{f}=", p[f])
    end
  end

  # Returns a hash representation of this Fuzzyurl, with one key/value pair
  # for each of `Fuzzyurl::FIELDS`.
  #
  # @return [Hash] Hash representation of this Fuzzyurl.
  def to_hash
    FIELDS.reduce({}) do |hash, f|
      val = self.send(f)
      val = val.to_s if val
      hash[f] = val
      hash
    end
  end

  # Returns a new copy of this Fuzzyurl, with the given params changed.
  #
  # @param params [Hash|nil] New parameter values.
  # @return [Fuzzyurl] Copy of `self` with the given parameters changed.
  def with(params={})
    fu = Fuzzyurl.new(self.to_hash)
    (FIELDS & params.keys).each do |f|
      fu.send("#{f}=", params[f].to_s)
    end
    fu
  end

  # Returns a string representation of this Fuzzyurl.
  #
  # @return [String] String representation of this Fuzzyurl.
  def to_s
    Fuzzyurl::Strings.to_string(self)
  end

  # @private
  def ==(other)
    self.to_hash == other.to_hash
  end


  class << self

    # Returns a Fuzzyurl suitable for use as a URL mask, with the given
    # values optionally set from `params` (Hash or String).
    #
    # @param params [Hash|String|nil] Parameters to set.
    # @return [Fuzzyurl] Fuzzyurl mask object.
    def mask(params={})
      params ||= {}
      return from_string(params, default: "*") if params.kind_of?(String)

      m = Fuzzyurl.new
      FIELDS.each do |f|
        m.send("#{f}=", params.has_key?(f) ? params[f].to_s : "*")
      end
      m
    end

    # Returns a string representation of `fuzzyurl`.
    #
    # @param fuzzyurl [Fuzzyurl] Fuzzyurl to convert to string.
    # @return [String] String representation of `fuzzyurl`.
    def to_string(fuzzyurl)
      Fuzzyurl::Strings.to_string(fuzzyurl)
    end

    # Returns a Fuzzyurl representation of the given URL string.
    # Any fields not present in `str` will be assigned the value
    # of `opts[:default]` (defaults to nil).
    #
    # @param str [String] String URL to convert to Fuzzyurl.
    # @param opts [Hash|nil] Options.
    # @return [Fuzzyurl] Fuzzyurl representation of `str`.
    def from_string(str, opts={})
      Fuzzyurl::Strings.from_string(str, opts)
    end

    # Returns an integer representing how closely `mask` matches `url`
    # (0 means wildcard match, higher is closer), or nil for no match.
    #
    # `mask` and `url` may each be Fuzzyurl or String format.
    #
    # @param mask [Fuzzyurl|String] URL mask.
    # @param url [Fuzzyurl|String] URL.
    # @return [Integer|nil] 0 for wildcard match, 1 for perfect match, or nil.
    def match(mask, url)
      m = mask.kind_of?(Fuzzyurl) ? mask : Fuzzyurl.mask(mask)
      u = url.kind_of?(Fuzzyurl) ? url : Fuzzyurl.from_string(url)
      Fuzzyurl::Match.match(m, u)
    end

    # Returns true if `mask` matches `url`, false otherwise.
    #
    # `mask` and `url` may each be Fuzzyurl or String format.
    #
    # @param mask [Fuzzyurl|String] URL mask.
    # @param url [Fuzzyurl|String] URL.
    # @return [Boolean] Whether `mask` matches `url`.
    def matches?(mask, url)
      m = mask.kind_of?(Fuzzyurl) ? m : Fuzzyurl.mask(m)
      u = url.kind_of?(Fuzzyurl) ? u : Fuzzyurl.from_string(u)
      m = mask.kind_of?(Fuzzyurl) ? mask : Fuzzyurl.mask(mask)
      u = url.kind_of?(Fuzzyurl) ? url : Fuzzyurl.from_string(url)
      Fuzzyurl::Match.matches?(m, u)
    end

    # Returns a Hash of match scores for each field of `mask` and
    # `url`, indicating the closeness of the match.  Values are from
    # `fuzzy_match`: 0 indicates wildcard match, 1 indicates perfect
    # match, and nil indicates no match.
    #
    # `mask` and `url` may each be Fuzzyurl or String format.
    #
    # @param mask [Fuzzyurl|String] URL mask.
    # @param url [Fuzzyurl|String] URL.
    def match_scores(mask, url)
      m = mask.kind_of?(Fuzzyurl) ? m : Fuzzyurl.mask(m)
      u = url.kind_of?(Fuzzyurl) ? u : Fuzzyurl.from_string(u)
      m = mask.kind_of?(Fuzzyurl) ? mask : Fuzzyurl.mask(mask)
      u = url.kind_of?(Fuzzyurl) ? url : Fuzzyurl.from_string(url)
      Fuzzyurl::Match.match_scores(m, u)
    end

    # Given an array of URL masks, returns the array index of the one which
    # most closely matches `url`, or nil if none match.
    #
    # `url` and each element of `masks` may be Fuzzyurl or String format.
    #
    # @param masks [Array] Array of URL masks.
    # @param url [Fuzzyurl|String] URL.
    # @return [Integer|nil] Array index of best-matching mask, or nil for no match.
    def best_match_index(masks, url)
      ms = masks.map {|m| m.kind_of?(Fuzzyurl) ? m : Fuzzyurl.mask(m)}
      u = url.kind_of?(Fuzzyurl) ? url : Fuzzyurl.from_string(url)
      Fuzzyurl::Match.best_match_index(ms, u)
    end

    # Given an array of URL masks, returns the one which
    # most closely matches `url`, or nil if none match.
    #
    # `url` and each element of `masks` may be Fuzzyurl or String format.
    #
    # @param masks [Array] Array of URL masks.
    # @param url [Fuzzyurl|String] URL.
    # @return [Integer|nil] Best-matching given mask, or nil for no match.
    def best_match(masks, url)
      index = best_match_index(masks, url)
      index && masks[index]
    end

    # If `mask` (which may contain * wildcards) matches `url` (which may not),
    # returns 1 if `mask` and `url` match perfectly, 0 if `mask` and `url`
    # are a wildcard match, or null otherwise.
    #
    # Wildcard language:
    #
    #     *              matches anything
    #     foo/*          matches "foo/" and "foo/bar/baz" but not "foo"
    #     foo/**         matches "foo/" and "foo/bar/baz" and "foo"
    #     *.example.com  matches "api.v1.example.com" but not "example.com"
    #     **.example.com matches "api.v1.example.com" and "example.com"
    #
    # Any other form is treated as a literal match.
    #
    # @param mask [String] String mask to match with (may contain wildcards).
    # @param value [String] String value to match.
    # @returns [Integer|nil] 0 for wildcard match, 1 for perfect match, else nil.
    def fuzzy_match(mask, value)
      Fuzzyurl::Match.fuzzy_match(mask, value)
    end

  end # class << self

end

