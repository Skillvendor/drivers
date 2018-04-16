module ApiMacros
  def method_missing(name, *args, &block)
    if name.to_sym == :auth_headers

      @auth_headers = {}
    else
      super
    end
  end

  def api_get path, options = {}, headers = {}, api_auth_headers = auth_headers
    options.merge! format: :json
    get '' + path, params: options, headers: headers_with_auth(headers, api_auth_headers)
  end

  def api_post path, options = {}, headers = {}, api_auth_headers = auth_headers
    options.merge! format: :json
    post '' + path, params: options.to_json, headers: merge_headers(headers_with_auth(headers, api_auth_headers))
  end

  def api_patch path, options = {}, headers = {}, api_auth_headers = auth_headers
    options.merge! format: :json
    patch '' + path, params: options.to_json, headers: merge_headers(headers_with_auth(headers, api_auth_headers))
  end

  def api_put path, options = {}, headers = {}, api_auth_headers = auth_headers
    options.merge! format: :json
    put '' + path, params: options.to_json, headers: merge_headers(headers_with_auth(headers, api_auth_headers))
  end

  def api_delete path, options = {}, headers = {}, api_auth_headers = auth_headers
    options.merge! format: :json
    delete '' + path, params: options.to_json, headers: merge_headers(headers_with_auth(headers, api_auth_headers))
  end

  def headers_with_auth(headers, auth_headers)
    headers ||= {}

    headers.merge(auth_headers)
  end

  def merge_headers(headers = {})
    { 'CONTENT_TYPE' => 'application/json' }.merge(headers)
  end
end