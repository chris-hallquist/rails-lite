require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params.merge(parse_www_encoded_form(req.query_string))
  end

  def [](key)
  end

  def to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    params = {}
    decode_www_form(www_form_form).each do |key_value_pair|
      parsed_key = parse_key(key_value_pair[0])
      current = params
      parsed_key[0...-1].each do |key|
        current[key] = {}
        current = current[key]
      end
      current[parsed_key[-1]] = key_value_pair[1]
    end
    params
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end