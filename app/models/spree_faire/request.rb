require 'httparty'

class SpreeFaire::Request
  FAIRE_BASE_URL='https://www.faire.com/external-api/v2'
  
  attr_reader :request
  
  def initialize(store)
    @store = store
    @request = nil
  end

  def get(path)
    @request = HTTParty.get("#{FAIRE_BASE_URL}#{path}", headers: headers)
  end
  
  def patch(path, data)
    @request = HTTParty.patch("#{FAIRE_BASE_URL}#{path}", body: data, headers: headers)
  end

  def put(path, data)
    @request = HTTParty.put(path, body: data, headers: headers)
  end

  def post(path, data)
    @request = HTTParty.post("#{@store.url}#{path}", body: data, headers: headers)
  end

  def headers
    { 'X-FAIRE-ACCESS-TOKEN': @store.faire_api_key, 'Accept': 'application/json', 'Content-Type': 'application/json' }
  end

  def body
    @request.body
  end

  def success?
    @request.success?
  end

  def response_code
    @request.code
  end
end
