require 'spec_helper'

describe 'Detailed param requirements for a' do
  class ExposedModel < Grape::Entity
    expose :name, documentation: {
      type: String, desc: 'name of item',
      required_details: {
        request: { GET: false, POST: true, PUT: true, default: true },
        response: false } }
    expose :alt_name, documentation: {
      type: String, desc: 'alternative name of item',
      required_details: { request: { GET: true } } }
    expose :description, documentation: {
      type: String, desc: 'description',
      required_details: { request: false, response: true } }
    expose :alt_description, documentation: {
      type: String, desc: 'alt_description',
      required_details: { request: false }, required: true }
  end

  def app
    Class.new(Grape::API) do
      format :json

      helpers do
        params :mixed_requirements do
          # fallback to true
          requires :name, type: String, desc: 'name of item', required_details: {
            request: { GET: false, POST: true, PUT: true, default: true } }
          # fallback to false
          optional :alt_name, type: String, desc: 'alternative name of item', required_details: {
            request: { GET: true } }
          # fallback to true
          requires :description, type: String, desc: 'description of item', required_details: { request: false }
        end
      end

      desc 'get items' do
        success ExposedModel
      end
      params do
        use :mixed_requirements
      end
      get '/items' do
        {}
      end

      params do
        use :mixed_requirements
      end
      post '/items' do
        {}
      end

      params do
        use :mixed_requirements
      end
      put '/items/:id' do
        {}
      end

      params do
        use :mixed_requirements
      end
      patch '/items/:id' do
        {}
      end

      add_swagger_documentation
    end
  end

  subject do
    get '/swagger_doc/items'
    JSON.parse(last_response.body)
  end

  context 'request' do
    it 'can be specified per request method' do
      # validate for GET
      expect(subject['apis'][0]['operations'][0]['parameters'][0]['required']).to eq false
      # validate for POST
      expect(subject['apis'][0]['operations'][1]['parameters'][0]['required']).to eq true
      # validate for PUT
      expect(subject['apis'][1]['operations'][0]['parameters'][1]['required']).to eq true
    end

    it 'use the default if method specific value was not specified' do
      # validate for PATCH
      expect(subject['apis'][1]['operations'][1]['parameters'][1]['required']).to eq true
    end

    it 'can be specified for all request methods' do
      # validate for GET
      expect(subject['apis'][0]['operations'][0]['parameters'][2]['required']).to eq false
      # validate for POST
      expect(subject['apis'][0]['operations'][1]['parameters'][2]['required']).to eq false
      # validate for PUT
      expect(subject['apis'][1]['operations'][0]['parameters'][3]['required']).to eq false
      # validate for PATCH
      expect(subject['apis'][1]['operations'][1]['parameters'][3]['required']).to eq false
    end

    it 'uses required as fallback if no details were specified' do
      # validate for GET
      expect(subject['apis'][0]['operations'][0]['parameters'][1]['required']).to eq true
      # validate for POST
      expect(subject['apis'][0]['operations'][1]['parameters'][1]['required']).to eq false
      # validate for PUT
      expect(subject['apis'][1]['operations'][0]['parameters'][2]['required']).to eq false
      # validate for PATCH
      expect(subject['apis'][1]['operations'][1]['parameters'][2]['required']).to eq false
    end

    it 'can be specified per request method' do
      # validate for GET
      expect(subject['apis'][0]['operations'][0]['parameters'][0]['required']).to eq false
      # validate for POST
      expect(subject['apis'][0]['operations'][1]['parameters'][0]['required']).to eq true
      # validate for PUT
      expect(subject['apis'][1]['operations'][0]['parameters'][1]['required']).to eq true
    end

    it 'use the default if method specific value was not specified' do
      # validate for PATCH
      expect(subject['apis'][1]['operations'][1]['parameters'][1]['required']).to eq true
    end

    it 'can be specified for all request methods' do
      # validate for GET
      expect(subject['apis'][0]['operations'][0]['parameters'][2]['required']).to eq false
      # validate for POST
      expect(subject['apis'][0]['operations'][1]['parameters'][2]['required']).to eq false
      # validate for PUT
      expect(subject['apis'][1]['operations'][0]['parameters'][3]['required']).to eq false
      # validate for PATCH
      expect(subject['apis'][1]['operations'][1]['parameters'][3]['required']).to eq false
    end

    it 'uses required as fallback if no details were specified' do
      # validate for GET
      expect(subject['apis'][0]['operations'][0]['parameters'][1]['required']).to eq true
      # validate for POST
      expect(subject['apis'][0]['operations'][1]['parameters'][1]['required']).to eq false
      # validate for PUT
      expect(subject['apis'][1]['operations'][0]['parameters'][2]['required']).to eq false
      # validate for PATCH
      expect(subject['apis'][1]['operations'][1]['parameters'][2]['required']).to eq false
    end
  end

  context 'response' do
    it 'can be specified and fallback to the required value' do
      expect(subject['models'].count).to eq 1
      expect(subject['models']['ExposedModel']['properties'].count).to eq 4
      # fallback to false, 1x false, 1x true ==> expected 1
      expect(subject['models']['ExposedModel']['required'].count).to eq 2
      expect(subject['models']['ExposedModel']['required'][0]).to eq 'description'
      expect(subject['models']['ExposedModel']['required'][1]).to eq 'alt_description'
    end
  end

  it 'request and response does not affect the grape route setup' do
    expect(subject['apis'].count).to eq 2
    expect(subject['apis'][0]['path']).to start_with '/items'
    expect(subject['apis'][1]['path']).to start_with '/items/{id}'

    # GET and POST do not have the :id
    expect(subject['apis'][0]['operations'][0]['parameters'].count).to eq 3
    expect(subject['apis'][0]['operations'][1]['parameters'].count).to eq 3
    # PUT and PATCH do have the :id
    expect(subject['apis'][1]['operations'][0]['parameters'].count).to eq 4
    expect(subject['apis'][1]['operations'][1]['parameters'].count).to eq 4

    # validate for GET
    expect(subject['apis'][0]['operations'][0]['method']).to eq 'GET'
    # validate for POST
    expect(subject['apis'][0]['operations'][1]['method']).to eq 'POST'
    # validate for PUT
    expect(subject['apis'][1]['operations'][0]['method']).to eq 'PUT'
    # validate for PATCH
    expect(subject['apis'][1]['operations'][1]['method']).to eq 'PATCH'
  end
end
